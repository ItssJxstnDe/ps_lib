ps = {}
----------------------------------------------------------------
ps.Debug = true
ps.VersionChecker = true
----------------------------------------------------------------
-- Only Required for PS.RegisterCommand // View Wiki for more Information about that!
ps.Framework = 'qbcore' -- Set to 'standalone', 'esx' or 'qbcore'
----------------------------------------------------------------
ps.showCoords = {
    enable = true,
    command = 'coords',
    groups = {'superadmin', 'admin'}
}
----------------------------------------------------------------
-- Set to 'native' for FiveM Native Notification
-- Set to 'PS' for NUI Notification
-- Set to 'okok' for OKOK Notification
ps.Notification = 'native'
ps.VersionChecker = 0
ps.Webhooks = { -- Main config section
    ['deaths'] --[[ Webhook Name/ID that will be used in the export ]] = {
        Username = "Player Deaths", -- Webhook username
        Icon = '', -- Image URL that will be used in footer and profile picture
        URL = '', -- Webhook URL
    },
    ['test']= {
        Username = "Test Webhook",
        Icon = '',
        URL = '',
    },
    -- ['Add more webhooks here!']= {
    --     Username = "You can add how many webhooks you want!",
    --     Icon = '',
    --     URL = '',
    -- },

}

ps.useTarget = false -- Use ox_target instead of item?
ps.removeHeadbagOnRespawn = true -- If player get his headbag removed when he (re)spawns?

ps.Locale = { -- You can translate the script here
    HeadbagTarget = "Use Headbag",
    ContextTitle = "Headbag Menu",
    ContextPutOn = "Put on headbag",
    ContextDescPutOn = "Use your headbag to put it on another player",
    ContextTakeOff = "Take off headbag",
    ContextDescTakeOff = "Take off headbag from the closest player",
    NotifyTitle = "Headbag",
    NotifyPutOn = "You put a headbag on a player",
    NotifyTookOff = "Someone took off your headbag",
    NotifyAlreadyOn = "This player already has a headbag!",
    NotifyNoOneNearby = "No one is nearby",
    NotifyNoHeadbag = "You don't have any headbags",
    Unpacking = "Unpacking headbag...",
}

function Notification(title,desc) -- You can edit your notify function here
    lib.notify({
        title = title,
        description = desc,
        position = 'top',
        style = {
            backgroundColor = '#1E1E2E',
        },
        icon = 'masks-theater',
    })
end