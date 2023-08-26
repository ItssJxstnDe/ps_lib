PS = {}

local RegisteredCommands, Callbacks, callbackRequest = {}, {}, {}

AddEventHandler('onResourceStart', function(resource)
	if GetCurrentResourceName() ~= 'ps_lib' then
        print('^1Please rename the Script to^3 ps_lib^0!')
        print('^1Server will be shutdown^0!')
        os.exit()
    end
end)

if ps.Framework:match('esx') then
    ESX = exports["es_extended"]:getSharedObject()
elseif ps.Framework:match('qbcore') then
    QBCore = exports['qb-core']:GetCoreObject()
end

PS.RegisterServerCallback = function(name, cb)
    Callbacks[name] = cb
end
PS.RegisterCallback = PS.RegisterServerCallback
exports('RegisterServerCallback', RegisterServerCallback)

PS.TriggerClientCallback = function(name, playerId, ...)
    local requestId = GenerateRequestKey(callbackRequest)
    local response

    callbackRequest[requestId] = function(...)
        response = {...}
    end

    TriggerClientEvent('ps_lib:triggerCallback', playerId, name, requestId, ...)

    while not response do Wait(0) end
    
    return table.unpack(response)
end
PS.TriggerCallback = PS.TriggerClientCallback
exports('TriggerClientCallback', TriggerClientCallback)

PS.RegisterCommand = function(name, group, cb, console, framework, suggestion)    
    if type(name) == 'table' then
        for k, v in ipairs(name) do 
            PS.RegisterCommand(v, group, cb, console, framework, suggestion)
        end
        return
    end

    if RegisteredCommands[name] then
       -- logging('debug', ('Command %s is already registerd. Overriding Command...'):format(name))
    end
    
    local added = addChatSuggestions(name, suggestion)
    while not added do Wait(1) end
    
    RegisteredCommands[name] = {group = group, cb = cb, console = console, suggestion = suggestion}

    RegisterCommand(name, function(source, args, rawCommand)
        local source = source
        local Command, error = RegisteredCommands[name], nil

        if not Command.console and source == 0 then 
          --  logging('error', 'You can not run this Command in Server Console!')
        else
            if Command.suggestion and Command.suggestion.arguments then 
                local newArgs = {}

                for k, v in ipairs(Command.suggestion.arguments) do 
                    if v.action == 'number' then
                        if args[k] then
                            if tonumber(args[k]) then
                                newArgs[v.name] = args[k]
                            else
                                error = ('Argument %s is not a number!'):format(v.name)
                            end
                        end
                    elseif v.action == 'playerId' then
                        if args[k] then
                            if tonumber(args[k]) > 0 and doesPlayerIdExist(args[k]) then
                                newArgs[v.name] = args[k]
                            else
                                error = ('PlayerId %s does not exist!'):format(args[k])
                            end
                        end
                    else
                        newArgs[v.name] = args[k]
                    end

                    if not error and not newArgs[v.name] and v.val then 
                        error = ('Argument Mismatch with Argument %s'):format(v.name)
                    end
                    if error then break end
                end

                args = newArgs
            end

            if error then
                if source == 0 then
                    --logging('error', error)
                else
                    PS.Notification(source, error)
                end
            else
                if ps.Framework:match('esx') and framework then
                    local xPlayer = ESX.GetPlayerFromId(source)
                    cb(xPlayer, args, rawCommand)
                elseif ps.Framework:match('qbcore') and framework then
                    local Player = QBCore.Functions.GetPlayer(source)
                    cb(Player, args, rawCommand)
                elseif ps.Framework:match('standalone') or not framework then
                    cb(source, args, rawCommand)
                end
            end
        end
    end, true)

    if type(group) == 'table' then
        for k, v in ipairs(group) do
            ExecuteCommand(('add_ace group.%s command.%s allow'):format(v, name))
        end
    else
        ExecuteCommand(('add_ace group.%s command.%s allow'):format(group, name))
    end
end
exports('RegisterCommand', RegisterCommand)

PS.Notification = function(src, title, message, info, time)
    if not src or src == 0 then return end
    TriggerClientEvent('ps_lib:notification', src, title, message, info, time)
end
exports('Notification', Notification)

PS.AdvancedNotification = function(src, text, title, subtitle, icon, flash, icontype)
    if not src or src == 0 then return end
    TriggerClientEvent('ps_lib:advancedNotification', src, text, title, subtitle, icon, flash, icontype)
end
exports('AdvancedNotification', AdvancedNotification)

PS.AddWebhook = function(webhook, botColor, botName, botAvatar, title, description, fields, footer, time)
    local content = {}

    if footer then 
        if time then
            footer = {
                ["text"] = footer.text .. " • " .. os.date(time),
                ["icon_url"] = footer.link
            }
        else
            footer = {
                ["text"] = footer.text,
                ["icon_url"] = footer.link
            }
        end
    end

    if fields then
        content = {{
            ["title"] = title,
            ["description"] = description,
            ["color"] = botColor,
            ["fields"] = fields,
            ["footer"] = footer
        }}
    else
        content = {{
            ["title"] = title,
            ["description"] = description,
            ["color"] = botColor,
            ["footer"] = footer
        }}
    end

    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
        username = botName,
        embeds = content,
        avatar_url = botAvatar
    }), {
        ['Content-Type'] = 'application/json'
    })
end
exports('AddWebhook', AddWebhook)

PS.HasItem = function(xPlayer, item)
    if not xPlayer then--[[  logging('error', 'Player on Function PS.HasItem does not exist!') ]] return end
    if not ps.Framework:match('esx') or ps.Framework:match('qbcore') then 
        --logging('error', ('Function %s can not used without Framework!'):format('^3PS.HasItem^0'))
        return 
    end
    local hasItem

    if ps.Framework:match('esx') then
        hasItem = xPlayer.getInventoryItem(item)
    elseif ps.Framework:match('qbcore') then
        hasItem = xPlayer.Functions.GetItemByName(item)
    else
       -- logging('error', 'Framework on Function PS.HasItem is not configured!')
    end

    return hasItem
end
exports('HasItem', HasItem)

PS.RegisterCallback('ps_lib:hasItem', function(source, cb, item)
    local src = source
    local xPlayer

    if ps.Framework:match('esx') then
        xPlayer = ESX.GetPlayerFromId(src)
    elseif ps.Framework:match('qbcore') then
        xPlayer = QBCore.Functions.GetPlayer(src)
    end

    cb(PS.HasItem(xPlayer, item))
end)

RegisterNetEvent('ps_lib:triggerCallback')
AddEventHandler('ps_lib:triggerCallback', function(name, requestId, ...)
    local src = source
    if Callbacks[name] then
        Callbacks[name](src, function(...)
            TriggerClientEvent("ps_lib:responseCallback", src, requestId, ...)
        end, ...)
    end
end)

RegisterNetEvent("ps_lib:responseCallback")
AddEventHandler("ps_lib:responseCallback", function(requestId, ...)
    if callbackRequest[requestId] then 
        callbackRequest[requestId](...)
        callbackRequest[requestId] = nil
    end
end)

GenerateRequestKey = function(tbl)
    local id = string.upper(PS.GetRandomString(3)) .. math.random(000, 999) .. string.upper(PS.GetRandomString(2)) .. math.random(00, 99)

    if not tbl[id] then 
        return tostring(id)
    else
        GenerateRequestKey(tbl)
    end
end

doesPlayerIdExist = function(playerId)
    for k, id in pairs(GetPlayers()) do
        if id == playerId then
            return true
        end
    end
    return false
end

addChatSuggestions = function(name, suggestion)
    if RegisteredCommands[name] then
        if RegisteredCommands[name].suggestion then
            TriggerClientEvent('chat:removeSuggestion', -1, '/' .. name)
        end
    end

    if suggestion then
        if not suggestion.arguments then suggestion.arguments = {} end
        if not suggestion.help then suggestion.help = '' end
    
        TriggerClientEvent('chat:addSuggestion', -1, '/' .. name, suggestion.help, suggestion.arguments)
    end

    return true
end

GithubUpdater = function()
    GetCurrentVersion = function()
	    return GetResourceMetadata( GetCurrentResourceName(), "version" )
    end
    
    local CurrentVersion = GetCurrentVersion()
    local resourceName = "^4["..GetCurrentResourceName().."]^0"

    if ps.VersionChecker then
        PerformHttpRequest('https://raw.githubusercontent.com/MSK-Scripts/msk_core/main/VERSION', function(Error, NewestVersion, Header)
            print("###############################")
            if CurrentVersion == NewestVersion then
                print(resourceName .. '^2 ✓ Resource is Up to Date^0 - ^5Current Version: ^2' .. CurrentVersion .. '^0')
            elseif CurrentVersion ~= NewestVersion then
                print(resourceName .. '^1 ✗ Resource Outdated. Please Update!^0 - ^5Current Version: ^1' .. CurrentVersion .. '^0')
                print('^5Newest Version: ^2' .. NewestVersion .. '^0 - ^6Download here:^9 https://github.com/MSK-Scripts/msk_core/releases/tag/v'.. NewestVersion .. '^0')
            end
            print("###############################")
        end)
    else
        print("###############################")
        print(resourceName .. '^2 ✓ Resource loaded^0')
        print("###############################")
    end
end
GithubUpdater()

exports('getCoreObject', function()
    return PS
end)