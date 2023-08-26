if ps.showCoords.enable then
	PS.RegisterCommand(ps.showCoords.command, ps.showCoords.groups, function(source, args, rawCommand)
		TriggerClientEvent('ps_lib:showCoords', source)
	end, false --[[console]], false --[[framework]], {help = 'Show your own Coords'})
end