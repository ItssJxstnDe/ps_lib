local showCoords = false

RegisterNetEvent('ps_lib:showCoords', function()
	showCoords = not showCoords
end)

local DrawGenericText = function(text)
	SetTextColour(186, 186, 186, 255)
	SetTextFont(7)
	SetTextScale(0.378, 0.378)
	SetTextWrap(0.0, 1.0)
	SetTextCentre(false)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 205)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(0.40, 0.00)
end

CreateThread(function()
	while true do
		local sleep = 500

		if showCoords then
			sleep = 0
			local playerPed = PlayerPedId()
			local playerX, playerY, playerZ = table.unpack(GetEntityCoords(playerPed))
			local playerH = GetEntityHeading(playerPed)

			DrawGenericText(("~g~X~w~ = ~r~%s ~g~Y~w~ = ~r~%s ~g~Z~w~ = ~r~%s ~g~H~w~ = ~r~%s~s~"):format(PS.Round(playerX, 2), PS.Round(playerY, 2), PS.Round(playerZ, 2), PS.Round(playerH, 2)))
		end

		Wait(sleep)
	end
end)