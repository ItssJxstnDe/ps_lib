local zones = {
   --[[  {
        name = "oceans",
        center = vector3(-1854.35,-337.83,53.71),
        distance = 16.0, -- Maximale afstand om als "in de zone" te worden beschouwd/--Maximum distance to be considered "in the zone"
        npcDelete = true, -- NPC's verwijderen in deze zone/--Remove NPCs in this zone
        vehicleDelete = true, -- Geparkeerde voertuigen verwijderen in deze zone/--Remove parked vehicles in this zone
    }, ]]
}

CreateThread(function()
    while true do
        Wait(100)

        local playerCoords = GetEntityCoords(PlayerPedId())
        
        for _, zone in ipairs(zones) do
            local distanceToZone = #(zone.center - playerCoords)

            if distanceToZone <= zone.distance then
                DeleteEntitiesInZone(zone)
            end
        end
    end
end)

function DeleteEntitiesInZone(zone)
    if zone.npcDelete then
        local peds = GetGamePool('CPed')
        for _, ped in ipairs(peds) do
            local pedCoords = GetEntityCoords(ped)
            local distanceToZone = #(zone.center - pedCoords)
            if distanceToZone <= zone.distance then
                DeleteEntity(ped)
            end
        end
    end

    if zone.vehicleDelete then
        local vehicles = GetGamePool('CVehicle')
        for _, vehicle in ipairs(vehicles) do
            local vehicleCoords = GetEntityCoords(vehicle)
            local distanceToZone = #(zone.center - vehicleCoords)
            if distanceToZone <= zone.distance and not IsPedInAnyVehicle(vehicle, false) then
                DeleteEntity(vehicle)
            end
        end
    end
end