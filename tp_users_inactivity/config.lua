Config = {}

Config.DevMode = false -- Set this to true only if you are restarting the script while in game for testing.

---------------------- INFORMATION ----------------------

-- The system reads the users directly from `users` table,

-- Make sure the role are also updated on `users` table
-- and not `characters` table.
---------------------------------------------------------

Config.DiscordWebhooking = {
    WebhookUrl = "xxxxxxxxxxxxxxxxxxxxxxx",

    Label = "Daisy Town",
    ImageUrl = "https://i.imgur.com/xxxxxxxxx.png",
    Footer = "© Daisy Town Support Team",

    Description = "The following player was inactive for too long, we deleted all data from: ",
}

-- Updating every x minutes the players who are not online in `users` table.
-- When someone logs in (does not matter what selected character will be), the time sets back to `0`.
-- When someone is not logged in, the time updating will be added on the players `users` table.
Config.TimeUpdatingInDatabase = 15 

Config.RemoveDatabaseDataAfter = 60 -- The time is in days, if a user has equal or higher than this number, all data will be deleted.

-- Blacklisted roles won't have any timer updating.
Config.BlacklistedRoles = { 
    ['admin']     = true, 
    ['moderator'] = true, 
    ['staff']     = true,
}

-- Blacklisted users won't have any timer updating (in case someone is going to be off for personal reasons).
Config.BlacklistedUsers = {
    ['steam:1100001339c9bd5'] = true,
    ['steam:11000011471aca6'] = true,
    ['steam:1100001327367b6'] = true,
    ['steam:110000106a667e1'] = true,
}

Config.RemoveFromDatabaseDataList = {

    { table = "DELETE FROM characters WHERE identifier = @identifier" },

    { table = "DELETE FROM wagons WHERE identifier = @identifier" },

    { table = "DELETE FROM outfits WHERE identifier = @identifier" },

    { table = "DELETE FROM loadout WHERE identifier = @identifier" },

    { table = "DELETE FROM horses WHERE identifier = @identifier" },

    { table = "DELETE FROM boats WHERE identifier = @identifier" },
}
