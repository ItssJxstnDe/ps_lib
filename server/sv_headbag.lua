-- i think i don't have to explain this section lol...

local closest = nil

RegisterServerEvent('ps_lib:closest')
AddEventHandler('ps_lib:closest', function()
    TriggerClientEvent('ps_lib:putOn', closest)
end)

RegisterServerEvent('ps_lib:closestPlayer')
AddEventHandler('ps_lib:closestPlayer', function(closestPlayer)
    closest = closestPlayer
end)

RegisterServerEvent('ps_lib:takeOff')
AddEventHandler('ps_lib:takeOff', function()
    TriggerClientEvent('ps_lib:takeOff', closest)
end)
