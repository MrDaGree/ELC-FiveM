elc_status = {}
elc_count = 0
version = "2022.05.4"

local vehicleDataLoaded = false

function loadVehicleData()
	local loadedVehicles = 0
	for i=1, #vehicleFileNames do
		
		if (LoadResourceFile(GetCurrentResourceName(), "vcf/" .. vehicleFileNames[i]) ~= nil) then
			print("[ELC] Loading file data for " .. vehicleFileNames[i])

			vehName = string.sub(vehicleFileNames[i], 1, string.len(vehicleFileNames[i])-5)

			vehicleFileData[vehName] = {}

      content = LoadResourceFile(GetCurrentResourceName(), "vcf/" .. vehicleFileNames[i])

			vehicleFileData[vehName] = json.decode(content)

      if vehicleFileData[vehName].description then
			  loadedVehicles = loadedVehicles + 1
      end
		end

    if i == #vehicleFileNames then
        print("[ELC] Finished loading " .. loadedVehicles .. "/" .. #vehicleFileNames .. " files")
        vehicleDataLoaded = true
    end
  end
end

function getVehicleConfigData(vehicle)
    return vehicleFileData[vehicle]
end

function findELCResource(dir)
  files_t = {}
  if string.sub(io.popen("uname -a"):read("*a"), 1, 5) == "Linux" then
    for file in io.popen('ls -al ' .. GetResourcePath(GetCurrentResourceName()) .. "/" .. dir):lines() do     
      splitString = {}
      for word in string.gmatch(file, '([^ ]+)') do
        table.insert(splitString, word)
      end

      if splitString[#splitString] ~= "." and splitString[#splitString] ~= ".." and splitString[1] ~= "total" and not string.find(splitString[#splitString], "disabled") then
        table.insert(files_t, splitString[#splitString])
      end
    end
  else
    for file in io.popen('dir "' .. GetResourcePath(GetCurrentResourceName()) .. "/" .. dir .. '" /b'):lines() do
      splitString = {}
      for word in string.gmatch(file, '([^.]+)') do
        table.insert(splitString, word)
      end

      if file ~= "." and file ~= ".." and file ~= "total" and splitString[#splitString] ~= "disabled" then
        table.insert(files_t, file)
      end
    end
  end

  return files_t
end

Citizen.CreateThread(function ()
	print("[ELC] Loading Emergency Lighting Control version " .. version .. " by MrDaGree and TheKeith")

  if (versionCheck) then
    PerformHttpRequest("https://raw.githubusercontent.com/MrDaGree/ELC-FiveM/master/version.json", function(errorCode, result, headers)
      if errorCode == 200 then
        latestVersion = json.decode(result)['version']

        if latestVersion ~= version then
          print("[ELC] ELC-FiveM is outdated. Current version: " .. version .. " Newest Version: " .. latestVersion .. "\n[ELC] It is recommended that you upgrade your version to ensure that you are running the best quality of ELC-FiveM")
        end
      else
        print("[ELC] There appears to be an outage. Current version: " .. version)
      end
    end)
  end

  vehicleFileNames = findELCResource('vcf')
  patternFileNames = findELCResource('patterns')

	loadVehicleData()
end)

RegisterNetEvent("elc:catchError")
AddEventHandler("elc:catchError", function(data)
	local player = source
	print("\nELC ERROR FROM CLIENT")
	print("PLAYER NAME: " .. GetPlayerName(player) .. " | " .. player)
	print("ERROR: " .. data)
end)

RegisterServerEvent("elc:ready")
AddEventHandler("elc:ready", function()
	while (not vehicleDataLoaded) do Wait(0) end
  TriggerClientEvent("elc:loadVehicleDataList", source, vehicleFileNames)
  TriggerClientEvent("elc:loadPatternDataList", source, patternFileNames)

  for k,v in pairs(elc_status) do
		TriggerClientEvent("elc:createELCVehicleData", source, k)
	end

	print("[ELC] Sending player " .. source .. " vcf configuration")
end)

RegisterServerEvent("elc:requestVehicleFileNames")
AddEventHandler('elc:requestVehicleFileNames', function()
	if printDebugInformation == nil or printDebugInformation == true then
		print("Sending player (" .. source .. ") ELC data")
	end

    TriggerClientEvent("elc:sendVehicleFileNames", source, vehicleDataFileNames)
end)

RegisterServerEvent("elc:removeVehicleCount")
AddEventHandler('elc:removeVehicleCount', function(vid)
	if (elc_status[vid] ~= nil) then
		elc_count = elc_count - 1
		elc_status[vid] = nil
	end
end)

RegisterServerEvent("elc:getVehicleData")
AddEventHandler('elc:getVehicleData', function(vid)
	if (elc_status[vid] ~= nil) then
		TriggerClientEvent("elc:updateVehicleData", source, vid, elc_status[vid])
	end
end)

RegisterServerEvent("elc:getStageData")
AddEventHandler('elc:getStageData', function(vid)
	if (elc_status[vid] ~= nil) then
		TriggerClientEvent("elc:setStageValue", source, vid, elc_status[vid].stage)
	end
end)

RegisterServerEvent("elc:getButtonData")
AddEventHandler('elc:getButtonData', function(vid)
	if (elc_status[vid] ~= nil) then
		TriggerClientEvent("elc:setButtonData", source, vid, elc_status[vid].panel.buttons)
	end
end)

RegisterServerEvent("elc:createVehicleDataForAll")
AddEventHandler('elc:createVehicleDataForAll', function(vid, model)
  while (not vehicleDataLoaded) do Wait(0) end
	if (elc_status[vid] == nil) then
		elc_status[vid] = {}

		elc_status[vid].stage = 0

		elc_status[vid].color = getVCFLightColors(model).left:sub(1, 1) .. getVCFLightColors(model).right:sub(1, 1)

		elc_status[vid].prmlPat = getStartPattern(model, 2)
		elc_status[vid].seclPat = getStartPattern(model, 1)

		elc_status[vid].panel = {}
		elc_status[vid].panel.buttons = {}
		elc_count = elc_count + 1
	end
	
    TriggerClientEvent("elc:createELCVehicleData", source, vid)
end)

RegisterServerEvent("elc:broadcastPatternChange")
AddEventHandler('elc:broadcastPatternChange', function(vid, l_type, patid)

	if (elc_status[vid] ~= nil) then
        if (l_type == "front") then
            elc_status[vid].prmlPat = patid
        else
            elc_status[vid].seclPat = patid
        end
    end

    TriggerClientEvent("elc:updatePatternValue", -1, vid, l_type, patid)
end)

RegisterServerEvent("elc:broadcastLightKindChange")
AddEventHandler('elc:broadcastLightKindChange', function(vid, lightkind)
	TriggerClientEvent("elc:setLightKindState", vid, lightkind)
end)

RegisterServerEvent("elc:broadcastStageChange")
AddEventHandler('elc:broadcastStageChange', function(vid, dir)

	if elc_status[vid] ~= nil then
		if (dir == 1) then
			if elc_status[vid].stage == 0 then
				elc_status[vid].stage = 1
			elseif elc_status[vid].stage == 1 then
				elc_status[vid].stage = 2
			elseif elc_status[vid].stage == 2 then
				elc_status[vid].stage = 3
			elseif elc_status[vid].stage == 3 then
				elc_status[vid].stage = 0
			end
		elseif (dir == -1) then
			if elc_status[vid].stage == 2 then
				elc_status[vid].stage = 1
			elseif elc_status[vid].stage == 3 then
				elc_status[vid].stage = 2
			elseif elc_status[vid].stage == 0 then
				elc_status[vid].stage = 3
			elseif elc_status[vid].stage == 1 then
				elc_status[vid].stage = 0
			end
		end
	end

    TriggerClientEvent("elc:updateStageValue", -1, vid, dir)
end)

RegisterServerEvent("elc:broadcastButtonChange")
AddEventHandler('elc:broadcastButtonChange', function(vid, data)
	elc_status[vid].panel.buttons[data.button] = not elc_status[vid].panel.buttons[data.button]
    TriggerClientEvent("elc:updateButtonValues", -1, vid, data)
end)

RegisterNetEvent("elc:broadcastColorChange")
AddEventHandler("elc:broadcastColorChange", function(color, vid)
	elc_status[vid].color = color
	TriggerClientEvent("elc:updateVehicleColor", -1, color, vid)
end)

RegisterNetEvent("elc:broadcastHornChange")
AddEventHandler("elc:broadcastHornChange", function(state)
	TriggerClientEvent("elc:playHornSound", -1, source, state)
end)

RegisterNetEvent("elc:broadcastSirenChange")
AddEventHandler("elc:broadcastSirenChange", function(siren)
	TriggerClientEvent("elc:playSirenSound", -1, source, siren)
end)