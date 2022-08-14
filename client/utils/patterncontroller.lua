patternData = {}

RegisterNetEvent("elc:loadPatternDataList")
AddEventHandler("elc:loadPatternDataList", function(patternFileNames)
  local loadedVehicles = 0
	for i=1, #patternFileNames do
		
		if (LoadResourceFile(GetCurrentResourceName(), "patterns/" .. patternFileNames[i]) ~= nil) then
			print("[ELC] Loading file data for " .. patternFileNames[i])

			loadPatternFile(patternFileNames[i])
      
      loadedVehicles = loadedVehicles + 1
		end

    if i == #patternFileNames then
        print("[ELC] Finished loading " .. loadedVehicles .. "/" .. #patternFileNames .. " files")
        vehicleFilesLoaded = true
    end
  end
end)

RegisterNetEvent("elc:updatePatternValue")
AddEventHandler("elc:updatePatternValue", function(vid, l_type, patid)
    local _, model = isVehicleELC(NetworkGetEntityFromNetworkId(vid))
    if (elc_status[vid] ~= nil) then
        if (l_type == "front") then
            elc_status[vid].prmlPat = patid
            for i,light in ipairs(elc_status[vid].lights.front) do
                light:ChangeLightPattern(getLightPattern(model, light._modkit, patid))
            end
        else
            elc_status[vid].seclPat = patid
            for i,light in ipairs(elc_status[vid].lights.rear) do
                light:ChangeLightPattern(getLightPattern(model, light._modkit, patid))
            end
        end
    end

    if (GetVehiclePedIsIn(PlayerPedId(), false) == NetworkGetEntityFromNetworkId(vid)) then
        SendNUIMessage({
            type = 'updatePatternDisplay',
            pattern = patid
        })
    end
end)

function loadPatternFile(fileName)
  typeName = string.sub(fileName, 1, string.len(fileName)-5)

  if patternData[typeName] == nil then
    patternData[typeName] = {}
  end

  content = LoadResourceFile(GetCurrentResourceName(), "patterns/" .. fileName)

  patternData[typeName] = json.decode(content)
end

function addPattern(type, pattern)
  refresh = false
  if patternData[typeName] == nil then
    patternData[type] = {}
    refresh = true
  end

  patternData[type][tostring(#patternData + 1)] = pattern

  SaveResourceFile(GetCurrentResourceName(), "patterns/" .. type .. ".json", json.encode(patternData[type], {indent = true}), #json.encode(patternData[type], {indent = true}))

  if refresh then
    print("[ELC] New Pattern type (" .. type .. ") has been added. In order for newly connecting players to get the pattern please run 'refresh' & 'restart " .. GetCurrentResourceName() .. "'" )
  end

  patternFileNames = findELCResource('patterns')
  TriggerClientEvent("elc:loadPatternDataList", -1, patternFileNames)
end

function getLightPattern(model, modkit, patid)
    local found, pat = doesPatternExistForModkit(model, modkit, patid)

    if found then
        return pat
    else
        return "NOT FOUND"
    end
end

function getTrafLightPattern(modkit, model, dir)
    local found, pat = doesPatternExistForTraf(modkit, model, dir)

    if found then
        return pat
    else
        return "NOT FOUND"
    end
end

function doesPatternExistForTraf(modkit, model, dir)
    if patternData[getTrafPatternLibrary(model)][tostring(dir)] ~= nil then
      return true, patternData[getTrafPatternLibrary(model)][tostring(dir)][IDToMiscName(modkit)]
    else
      return false
    end
end

function doesPatternExistForModkit(model, modkit, patid)
    if patternData[getPatternLibrary(model)][tostring(patid)] ~= nil then
      return true, patternData[getPatternLibrary(model)][tostring(patid)][IDToMiscName(modkit)]
    else
      return false
    end
end

function updateLightsPatterns(vid, l_type, patid, model)
    if (l_type == "front") then
        for i,light in ipairs(elc_status[vid].lights.front) do
            light:ChangeLightPattern(getLightPattern(model, light._modkit, patid))
        end
    elseif (l_type == "rear") then
        for i,light in ipairs(elc_status[vid].lights.rear) do
            light:ChangeLightPattern(getLightPattern(model, light._modkit, patid))
        end
    end

    TriggerServerEvent("elc:broadcastPatternChange", vid, l_type, patid)
end

function doesPatternsExist(l_type, pattern, model)
    if patternData[ getVCFPatternLibrary(model) ][tostring(pattern)] ~= nil then
        return true, #patternData[ getVCFPatternLibrary(model) ]
    else
        return false
    end

    return false
end


function getCurrentPatternForVehicle(vid, l_type)
    if (l_type == "front") then
        return elc_status[vid].prmlPat
    elseif (l_type == "rear") then
        return elc_status[vid].seclPat
    end
end

function setVehiclePattern(vid, l_type, model, pattern)
  if (l_type == "front") then
      local newPattern = pattern
      local exists, amt = doesPatternsExist(l_type, newPattern, model)
      if (exists) then
          elc_status[vid].lastprmlPat = elc_status[vid].prmlPat

          elc_status[vid].prmlPat = newPattern

          updateLightsPatterns(vid, l_type, newPattern, model)
      end
  elseif (l_type == "rear") then
      local newPattern = pattern
      local exists, amt = doesPatternsExist(l_type, newPattern, model)
      if (exists) then
          elc_status[vid].lastseclPat = elc_status[vid].seclPat

          elc_status[vid].seclPat = newPattern

          updateLightsPatterns(vid, l_type, newPattern, model)
      end
  end
end

function changeVehiclePatternUp(vid, l_type, model)
    if (l_type == "front") then
        local newPattern = getCurrentPatternForVehicle(vid, l_type) + 1
        local exists, amt = doesPatternsExist(l_type, newPattern, model)
        if (exists) then
            elc_status[vid].prmlPat = newPattern

            updateLightsPatterns(vid, l_type, newPattern, model)
        else
            elc_status[vid].prmlPat = 1

            updateLightsPatterns(vid, l_type, 1, model)
        end
    elseif (l_type == "rear") then
        local newPattern = getCurrentPatternForVehicle(vid, l_type) + 1
        local exists, amt = doesPatternsExist(l_type, newPattern, model)
        if (exists) then
            elc_status[vid].seclPat = newPattern

            updateLightsPatterns(vid, l_type, newPattern, model)

        else
            elc_status[vid].seclPat = 1

            updateLightsPatterns(vid, l_type, 1, model)
        end
    end
end

function changeVehiclePatternDown(vid, l_type, model)
    if (l_type == "front") then
        local newPattern = getCurrentPatternForVehicle(vid, l_type) - 1
        local exists, amt = doesPatternsExist(l_type, newPattern, model)
        if (exists) then
            elc_status[vid].prmlPat = newPattern

            updateLightsPatterns(vid, l_type, newPattern, model)
        else
            elc_status[vid].prmlPat = amt

            updateLightsPatterns(vid, l_type, amt, model)
        end
    elseif (l_type == "rear") then
        local newPattern = getCurrentPatternForVehicle(vid, l_type) - 1
        local exists, amt = doesPatternsExist(l_type, newPattern, model)
        if (exists) then
            elc_status[vid].seclPat = newPattern

            updateLightsPatterns(vid, l_type, newPattern, model)
        else
            elc_status[vid].seclPat = amt

            updateLightsPatterns(vid, l_type, amt, model)
        end
    end
end