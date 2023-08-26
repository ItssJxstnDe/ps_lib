local hasBag = false -- Check if player has headbag on
local bags = {}

function GetClosestPlayer() -- Find the closest player and trigger event to get headbag on his head
  local closestPlayer = lib.getClosestPlayer(GetEntityCoords(PlayerPedId()), 2.0, false)
  if closestPlayer == nil or not closestPlayer then -- If the closest player in 2.0 units isn't found
    Notification(ps.Locale.NotifyTitle,ps.Locale.NotifyNoOneNearby)
  else -- If he IS found
    if not hasBag then -- Check if player doesn't already have headbag
      TriggerServerEvent('ps_lib:closestPlayer', GetPlayerServerId(closestPlayer))
      Notification(ps.Locale.NotifyTitle,ps.Locale.NotifyPutOn)
      TriggerServerEvent('ps_lib:closest')
      hasBag = true
    else
      hasBag = false
      Notification(ps.Locale.NotifyTitle,ps.Locale.NotifyAlreadyOn)
    end
  end
end


RegisterNetEvent('ps_lib:putOn') -- Simple trigger to put on the headbag
AddEventHandler('ps_lib:putOn', function()
    Headbag = CreateObject(GetHashKey("prop_money_bag_01"), 0, 0, 0, true, true, true)
    AttachEntityToEntity(Headbag, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 12844), 0.22, 0.04, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
    table.insert(bags,Headbag)
    SendNUIMessage({type = 'bagOn'}) -- Trigger NUI image of the headbag (make player blind)
    SetNuiFocus(false,false) -- idk why but without this the player is stuck in the nui
    hasBag = true
end)

RegisterNetEvent('ps_lib:takeOff') -- Simple trigger to take the bag off
AddEventHandler('ps_lib:takeOff', function()
  Notification(ps.Locale.NotifyTitle,ps.Locale.NotifyTookOff)
  DeleteEntity(Headbag)
  SetEntityAsNoLongerNeeded(Headbag)
  SendNUIMessage({type = 'bagOff'})
  hasBag = false
end)

local function bagmenu() -- Function to open the bag menu
  lib.registerContext({
    id = 'headbag',
    title = ps.Locale.ContextTitle,
    options = {
      {
        title = ps.Locale.ContextPutOn,
        description = ps.Locale.ContextDescPutOn,
        icon = 'mask',
        onSelect = function()
          GetClosestPlayer()
        end,

      },
      {
        title = ps.Locale.ContextTakeOff,
        description = ps.Locale.ContextDescTakeOff,
        icon = 'masks-theater',
        onSelect = function()
          TriggerServerEvent('ps_lib:takeOff')
        end,

      },

    }
  })

  lib.showContext('headbag')
end

RegisterNetEvent('ps_lib:openMenu') -- Trigger to open the bag menu
AddEventHandler('ps_lib:openMenu',function ()
  local count = exports.ox_inventory:Search('count', 'headbag') -- Check if player has headbag in his inventory
  if count >= 1 or hasBag then
      if lib.progressCircle({
        duration = math.random(4000,5000),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        label = ps.Locale.Unpacking,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
        anim = {
            dict = 'mp_arresting',
            clip = 'a_uncuff'
        },
        prop = {
          model = `prop_money_bag_01`,
          pos = vec3(0.013, 0.03, 0.022),
          rot = vec3(0.0, 0.0, -1.5)
      },
    }) then
      bagmenu()
    
    end
    
    -- bagmenu()
  else
    Notification(ps.Locale.NotifyTitle,ps.Locale.NotifyNoHeadbag) -- If not, throw an error
  end
end)

if ps.useTarget then -- Enable ox_target functions
  local options = {
    {
        name = 'headbagMenu',
        event = 'ps_lib:openMenu',
        distance = 2,
        icon = 'fa-solid fa-masks-theater',
        label = ps.Locale.HeadbagTarget,
    },
  }
  exports.ox_target:addGlobalPlayer(options)
end

if not ps.useTarget then -- If the target option is disabled, use export to use the item straight from the inventory
  exports('headbag', function()
    lib.progressCircle({
      duration = math.random(4000,5000),
      position = 'bottom',
      useWhileDead = false,
      canCancel = true,
      label = ps.Locale.Unpacking,
      disable = {
          car = true,
          move = true,
          combat = true,
      },
      anim = {
          dict = 'mp_arresting',
          clip = 'a_uncuff'
      },
      prop = {
        model = `prop_money_bag_01`,
        pos = vec3(0.013, 0.03, 0.022),
        rot = vec3(0.0, 0.0, -1.5)
    },
  })
    TriggerEvent('ps_lib:openMenu')
  end)
end

AddEventHandler('onResourceStop',function (resourceName) -- Delete all bags if the resource stops
  if resourceName == GetCurrentResourceName() then
    for _, bag in pairs(bags) do
      DeleteEntity(bag)
    end
  end
end)

if ps.removeHeadbagOnRespawn then
  AddEventHandler('playerSpawned', function() -- If player (re)/spawns, remove the headbag
    DeleteEntity(Headbag)
    SetEntityAsNoLongerNeeded(Headbag)
    SendNUIMessage({type = 'bagOff'})
    hasBag = false
  end)
end

Citizen.CreateThread(function ()
  while true do
    Wait(0)
    for k,v in pairs(bags) do
      if not k or not v then
       -- print(bags)
        hasBag = false
      end
    end
  end
end)

print("ps_lib Eingestellt & Aktiviert")