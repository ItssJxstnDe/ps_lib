PS.GetPlayer = function(player)
    local Player

    if player.source then
        if ps.Framework == 'esx' then
            Player = ESX.GetPlayerFromId(player.source)
        elseif ps.Framework == 'qbcore' then
            Player = QBCore.Functions.GetPlayer(player.source)
        end
    elseif player.identifier then
        if ps.Framework == 'esx' then
            Player = ESX.GetPlayerFromIdentifier(player.identifier)
        elseif ps.Framework == 'qbcore' then
            Player = PS.GetPlayer({source = QBCore.Functions.GetSource(player.identifier)})
        end
    elseif player.citizenid then
        if ps.Framework == 'esx' then
            Player = ESX.GetPlayerFromIdentifier(player.citizenid)
        elseif ps.Framework == 'qbcore' then
            Player = QBCore.Functions.GetPlayerByCitizenId(player.citizenid)
        end
    elseif player.phone then
        if ps.Framework == 'esx' then
            if ESX.GetPlayerFromPhoneNumber then 
                Player = ESX.GetPlayerFromPhoneNumber(player.phone)
            else
                local data = MySQL.query.await('SELECT * from users WHERE phone_number = ?', {player.phone})
                if data and data[1] then Player = ESX.GetPlayerFromIdentifier(data[1].identifier) end
            end
        elseif ps.Framework == 'qbcore' then
            Player = QBCore.Functions.GetPlayerByPhone(tostring(player.phone))
        end
    end

    return Player
end
exports('GetPlayer', GetPlayer)

PS.GetPlayers = function(key, val)
    local Players

    if ps.Framework == 'esx' then
        Players = ESX.GetExtendedPlayers(key, val)
    elseif ps.Framework == 'qbcore' then
        if not key then 
            Players = QBCore.Functions.GetQBPlayers()
        else
            local qbPlayers

            for k, Player in pairs(QBCore.Functions.GetQBPlayers()) do
                if key == 'job' then
                    if Player.PlayerData.job.name == val then
                        qbPlayers[#qbPlayers + 1] = Player
                    end
                elseif key == 'gang' then
                    if Player.PlayerData.gang.name == val then
                        qbPlayers[#qbPlayers + 1] = Player
                    end
                elseif key == 'group' then
                    if IsPlayerAceAllowed(Player.PlayerData.source, val) then
                        qbPlayers[#qbPlayers + 1] = Player
                    end
                end
            end

            Players = qbPlayers
        end
    end

    return Players
end
exports('GetPlayers', GetPlayers)