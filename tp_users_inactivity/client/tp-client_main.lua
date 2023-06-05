

RegisterNetEvent("vorp:SelectedCharacter")
AddEventHandler("vorp:SelectedCharacter", function(charid)
	Wait(10000)

    TriggerServerEvent('tp_users_inactivity:updateLoggedInData')

end)

if Config.DevMode then
    Citizen.CreateThread(function() Wait(2000) TriggerServerEvent('tp_users_inactivity:updateLoggedInData') end)
end