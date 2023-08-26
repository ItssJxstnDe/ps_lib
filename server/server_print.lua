
local resourceName = 
[[^6
        ps_lib
	  Created By ItssJxstn
	  Ripping or Leaking can get you Sued within German Law!
]]

Citizen.CreateThread(function()
	local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)

	function VersionCheckHTTPRequest()
		PerformHttpRequest('https://semdevelopment.com/releases/interactionmenu/info/version.json', VersionCheck, 'GET')
	end

	function VersionCheck(err, response, headers)
		Citizen.Wait(3000)
		if err == 200 then
			local data = json.decode(response)
			
			if ps.VersionChecker == 0 then
				print(resourceName)
			end

			if currentVersion ~= data.NewestVersion then
				if ps.VersionChecker == 0 then
					--print('\n   ^1SEM_InteractionMenu is outdated!^7')
					--print('     Latest Version: ^2' .. data.NewestVersion .. '^7')
					--print('     Your Version: ^1' .. currentVersion .. '^7')
					--print('     Please download the leastest version from ^5' .. data.DownloadLocation .. '^7')

					--[[ if data.Changes ~= '' then
						print('\n     ^5Changes: ^7' .. data.Changes)
					end ]]
				elseif ps.VersionChecker == 1 then
					--print('\n^1SEM_InteractionMenu is outdated!^7')
					--print('Latest Version: ^2' .. data.NewestVersion .. '^7')
					--print('Please download the leastest version from ^5' .. data.DownloadLocation .. '^7\n')
				end
			else
				--print('\n   ^2SEM_InteractionMenu is up to date!^7')
			end

			print('\n')
		else
			--print('^1SEM_InteractionMenu Version Check Failed!^7')
		end
		
		SetTimeout(60000000, VersionCheckHTTPRequest)
	end

	if ps.VersionChecker ~= 2 then
		if currentVersion then
			VersionCheckHTTPRequest()
		else
			--print('^1SEM_InteractionMenu Version Check Failed!^7')
		end
	end
end)