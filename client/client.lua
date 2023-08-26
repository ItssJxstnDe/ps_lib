PS = {}

local callbackRequest, Callbacks = {}, {}

if ps.Framework:match('esx') then
    ESX = exports["es_extended"]:getSharedObject()
elseif ps.Framework:match('qbcore') then
    QBCore = exports['qb-core']:GetCoreObject()
end

PS.RegisterClientCallback = function(name, cb)
    Callbacks[name] = cb
end
PS.RegisterCallback = PS.RegisterClientCallback
exports('RegisterClientCallback', RegisterClientCallback)

PS.TriggerServerCallback = function(name, ...)
    local requestId = GenerateRequestKey(callbackRequest)
    local response

    callbackRequest[requestId] = function(...)
        response = {...}
    end

    TriggerServerEvent('ps_lib:triggerCallback', name, requestId, ...)

    while not response do Wait(0) end

    return table.unpack(response)
end
PS.TriggerCallback = PS.TriggerServerCallback
exports('TriggerServerCallback', TriggerServerCallback)

PS.Notification = function(title, message, info, time)
    if ps.Notification == 'native' then
        SetNotificationTextEntry('STRING')
        AddTextComponentString(message)
        DrawNotification(false, true)
    elseif ps.Notification == 'nui' or ps.Notification == 'PS' then
        SendNUIMessage({
            action = 'notify',
            title = title,
            message = message,
            info = info or 'general',
            time = time or 5000
        })
    elseif ps.Notification == 'okok' then
        exports['okokNotify']:Alert(title, message, time or 5000, info or 'info')
    end
end
exports('Notification', Notification)

PS.HelpNotification = function(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
exports('HelpNotification', HelpNotification)

PS.AdvancedNotification = function(text, title, subtitle, icon, flash, icontype)
    if not flash then flash = true end
    if not icontype then icontype = 1 end
    if not icon then icon = 'CHAR_HUMANDEFAULT' end

    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    SetNotificationMessage(icon, icon, flash, icontype, title, subtitle)
	DrawNotification(false, true)
end
exports('AdvancedNotification', AdvancedNotification)

PS.Draw3DText = function(coords, text, size, font)
    local coords = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)
    local camCoords = GetGameplayCamCoords()
    local distance = #(coords - camCoords)

    if not size then size = 1 end
    if not font then font = 0 end

    local scale = (size / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    SetTextScale(0.0, scale * 0.5)
    SetTextFont(font)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(coords.xyz, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end
exports('Draw3DText', Draw3DText)

PS.HasItem = function(item)
    if not ps.Framework:match('esx') or ps.Framework:match('qbcore') then 
        logging('error', ('Function %s can not used without Framework!'):format('PS.HasItem'))
        return 
    end

    local hasItem = PS.TriggerCallback('ps_lib:hasItem', item)
    return hasItem
end
exports('HasItem', HasItem)

PS.GetVehicleInDirection = function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local inDirection = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(playerCoords, inDirection, 10, playerPed, 0)
    local numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

    if hit == 1 and GetEntityType(entityHit) == 2 then
        local entityCoords = GetEntityCoords(entityHit)
        local entityDistance = #(playerCoords - entityCoords)
        return entityHit, entityCoords, entityDistance
    end

    return nil
end
exports('GetVehicleInDirection', GetVehicleInDirection)

PS.IsVehicleEmpty = function(vehicle)
    if not vehicle or (vehicle and not DoesEntityExist(vehicle)) then return end
    local passengers = GetVehicleNumberOfPassengers(vehicle)
    local driverSeatFree = IsVehicleSeatFree(vehicle, -1)

    return passengers == 0 and driverSeatFree
end
exports('IsVehicleEmpty', IsVehicleEmpty)

PS.GetPedMugshot = function(ped, transparent)
    if not DoesEntityExist(ped) then return end
    local mugshot = transparent and RegisterPedheadshotTransparent(ped) or RegisterPedheadshot(ped)

    while not IsPedheadshotReady(mugshot) do
        Wait(0)
    end

    return mugshot, GetPedheadshotTxdString(mugshot)
end
exports('GetPedMugshot', GetPedMugshot)

GenerateRequestKey = function(tbl)
    local id = string.upper(PS.GetRandomString(3)) .. math.random(000, 999) .. string.upper(PS.GetRandomString(2)) .. math.random(00, 99)

    if not tbl[id] then 
        return tostring(id)
    else
        GenerateRequestKey(tbl)
    end
end

RegisterNetEvent("ps_lib:responseCallback")
AddEventHandler("ps_lib:responseCallback", function(requestId, ...)
    if callbackRequest[requestId] then 
        callbackRequest[requestId](...)
        callbackRequest[requestId] = nil
    end
end)

RegisterNetEvent('ps_lib:triggerCallback')
AddEventHandler('ps_lib:triggerCallback', function(name, requestId, ...)
    if Callbacks[name] then
        Callbacks[name](GetPlayerServerId(PlayerId()), function(...)
            TriggerServerEvent("ps_lib:responseCallback", requestId, ...)
        end, ...)
    end
end)

RegisterNetEvent("ps_lib:notification")
AddEventHandler("ps_lib:notification", function(title, message, info, time)
    PS.Notification(title, message, info, time)
end)

RegisterNetEvent('ps_lib:advancedNotification')
AddEventHandler('ps_lib:advancedNotification', function(text, title, subtitle, icon, flash, icontype)
    PS.AdvancedNotification(text, title, subtitle, icon, flash, icontype)
end)

exports('getCoreObject', function()
    return PS
end)