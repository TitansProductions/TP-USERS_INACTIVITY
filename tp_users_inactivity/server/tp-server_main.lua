
local VorpCore = {}

TriggerEvent("getCore",function(core) VorpCore = core end)

local LoggedPlayersList = {}

RegisterServerEvent("tp_users_inactivity:updateLoggedInData")
AddEventHandler("tp_users_inactivity:updateLoggedInData", function()
  local _source      = source
  local xPlayer      = VorpCore.getUser(_source).getUsedCharacter
  local _identifier  = xPlayer.identifier
  local playerExists = false


  -- At first, we set the inactivity time for users back to 0.
  local Parameters = { ['identifier'] = _identifier, ['inactivity_time'] = 0 }
  exports.ghmattimysql:execute("UPDATE users SET inactivity_time = @inactivity_time WHERE identifier = @identifier", Parameters)
    
  -- Checking if list is not null before checking if connected players has been already registered.
  -- If player has been registered, we update the source.
  if next(LoggedPlayersList) ~= nil then

    for index, loggedPlayer in pairs(LoggedPlayersList) do
      if loggedPlayer.identifier == _identifier then
        playerExists = true
        loggedPlayer.source = _source
      end
    end

  end
 
  Wait(2000)

  -- After 2 seconds, we check if the player already exists, if not, we add the player to the list.
  if not playerExists then

    local data = {source = _source, name = GetPlayerName(_source), identifier = _identifier}
    table.insert(LoggedPlayersList, data)

  end

end)



Citizen.CreateThread(function()
	while true do
		Wait(60000 * Config.TimeUpdatingInDatabase)

    local rows = 0

		exports.ghmattimysql:execute("SELECT COUNT(*) AS RowCnt FROM users", {}, function(result)

			for i, res in pairs (result[1]) do
				rows = res
			end

			Wait(2000)

			if tonumber(rows) ~= 0 and tonumber(rows) ~= nil and tonumber(rows) > 0 then

        exports.ghmattimysql:execute("SELECT * FROM users", {}, function(charResult)

          for index, character in pairs (charResult) do

            local identifier       = charResult[index].identifier
            local group            = charResult[index].group
            local inactivity_time  = charResult[index].inactivity_time

            local playerExists     = false
            local finishedChecking = false

            if not Config.BlacklistedUsers[identifier] and not Config.BlacklistedRoles[group] then

              if next(LoggedPlayersList) ~= nil then

                for index, loggedPlayer in pairs(LoggedPlayersList) do
                  if loggedPlayer.identifier == identifier then
                    playerExists = true
                  end

                  if next(LoggedPlayersList, index) == nil then
                    finishedChecking = true
                  end
                  
                end

              else
                finishedChecking = true
              end

              while not finishedChecking do
                Wait(100)
              end

              if not playerExists then

                local Parameters = { ['identifier'] = identifier, ['inactivity_time'] = Config.TimeUpdatingInDatabase }
                exports.ghmattimysql:execute("UPDATE users SET inactivity_time = inactivity_time + @inactivity_time WHERE identifier = @identifier", Parameters)

                inactivity_time = inactivity_time + Config.TimeUpdatingInDatabase

                local deleteDataTime = Config.RemoveDatabaseDataAfter * 1440
    
                if tonumber(inactivity_time) >= tonumber(deleteDataTime) then

                  local finishedDatabaseTablesRemoving = false

                  local UserParameters = { ['identifier'] = identifier }

                  for _d, database in pairs(Config.RemoveFromDatabaseDataList) do
                   
                    exports.ghmattimysql:execute(database.table, UserParameters)

                    if next(Config.RemoveFromDatabaseDataList, _d) == nil then
                      finishedDatabaseTablesRemoving = true
                    end
                    
                  end

                  while not finishedDatabaseTablesRemoving do
                    Wait(100)
                  end

                  exports.ghmattimysql:execute("DELETE FROM users WHERE identifier = @identifier ", UserParameters)

                  print(" [!] The following player was inactive for too long, we deleted all data from: " .. identifier)

                  SendToDiscord(identifier, Config.DiscordWebhooking.Description .. identifier)

                end

              end

            end

          end

        end)

			end

		end)
    
	end

end)


function SendToDiscord(webhook, name, description, color)
    local data = Config.DiscordWebhooking

    PerformHttpRequest(data.WebhookUrl, function(err, text, headers) end, 'POST', json.encode({
        embeds = {
            {
                ["color"] = color or 15105570,
                ["author"] = {
                    ["name"] = data.Label,
                    ["icon_url"] = data.ImageUrl,
                },
                ["title"] = name,
                ["description"] = description,
                ["footer"] = {
                    ["text"] = data.Footer .. " • " .. os.date("%x %X %p"),
                    ["icon_url"] = data.ImageUrl,

                },
            },

        },
        avatar_url = data.ImageUrl
    }), {
        ['Content-Type'] = 'application/json'
    })
end
