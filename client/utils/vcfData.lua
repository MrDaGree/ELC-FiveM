vehicleFileData = {}
local vehicleFilesLoaded = false

RegisterNetEvent("elc:loadVehicleDataList")
AddEventHandler("elc:loadVehicleDataList", function(vehicleFileNames)
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
        vehicleFilesLoaded = true
    end
  end
end)

function hasVehicleFilesLoaded()
    return vehicleFilesLoaded
end

function getVehicleConfigData(model)
    return vehicleFileData[model]
end

function getVCFVersion(model)
  return (getVehicleConfigData(model).version ~= nil and getVehicleConfigData(model).version or 0)
end

function getVCFInterfaceSettings(model)
  return getVehicleConfigData(model).interface
end

function getVCFGlobalSettings(model)
  if getVCFVersion(model) ~= 1.0 then
    return getVehicleConfigData(model).misc
  elseif getVCFVersion(model) == 1.0 then
    return getVehicleConfigData(model).settings
  end
end

function getVCFPatternLibrary(model)
  if getVCFVersion(model) ~= 1.0 then
    return getVCFGlobalSettings(model).patterntype
  elseif getVCFVersion(model) == 1.0 then
    return getVCFGlobalSettings(model).pattern_library
  end
end

function getVCFSteadyburnSettings(model)
  return getVCFGlobalSettings(model).steadyburn
end

function getVCFCruiseLightSettings(model)
  return getVCFGlobalSettings(model).cruiselights
end

function getVCFUseTrafficAdvisor(model)
  return getVCFGlobalSettings(model).usetrafficadvisor
end

function getVCFDfltSirenActivation(model)
  return (getVCFGlobalSettings(model).default_siren_activate_stage ~= nil and getVehicleConfigData(model).default_siren_activate_stage or 3)
end

function getVCFAlleyLightingSettings(model)
  if getVCFVersion(model) ~= 1.0 then
    settings = {
      enabled = getVCFGlobalSettings(model).alleylighting.enabled,
      miscs = {
        left = getVCFGlobalSettings(model).alleylighting.miscs[0],
        right = getVCFGlobalSettings(model).alleylighting.miscs[1],
      }
    }

    return settings
  elseif getVCFVersion(model) == 1.0 then
    return getVCFGlobalSettings(model).alleylighting
  end
end

function getVCFLightColors(model)
  return getVCFGlobalSettings(model).lightcolors
end

function getPatternLibrary(model)
  if getVCFVersion(model) ~= 1.0 then
    return getVCFGlobalSettings(model).patterntype
  elseif getVCFVersion(model) == 1.0 then
    return getVCFGlobalSettings(model).pattern_library
  end
end

function getTrafPatternLibrary(model)
  if getVCFVersion(model) ~= 1.0 then
    return getVCFGlobalSettings(model).patterntype
  elseif getVCFVersion(model) == 1.0 then
    return (getVehicleConfigData(model).traffic_advisor.pattern_library ~= nil and getVehicleConfigData(model).traffic_advisor.pattern_library or nil)
  end
end

function getStgOneInfo(model)
  if getVCFVersion(model) ~= 1.0 then
    return getVehicleConfigData(model).rear
  elseif getVCFVersion(model) == 1.0 then
    return getVehicleConfigData(model).stage_one
  end
end

function getStgTwoInfo(model)
  if getVCFVersion(model) ~= 1.0 then
    return getVehicleConfigData(model).front
  elseif getVCFVersion(model) == 1.0 then
    return getVehicleConfigData(model).stage_two
  end
end

function getTrafInfo(model)
  if getVCFVersion(model) ~= 1.0 then
    return getVehicleConfigData(model).trafficadvisor
  elseif getVCFVersion(model) == 1.0 then
    return getVehicleConfigData(model).traffic_advisor
  end
end

function getStartPattern(model, stg)
  if stg == 1 then
    return getStgOneInfo(model).startpattern
  elseif stg == 2 then
    return getStgTwoInfo(model).startpattern
  end
end

function getParkPattern(model, stg)
  if stg == 1 then
    return getStgOneInfo(model).parkpatern
  elseif stg == 2 then
    return getStgTwoInfo(model).parkpatern
  end
end

function getStgOneMiscSetup(model)
  if getVCFVersion(model) ~= 1.0 then
    return getStgOneInfo(model).setup
  elseif getVCFVersion(model) == 1.0 then

    misc_setup = {}

    for _,v in pairs(getStgOneInfo(model).miscs) do
      data = getVehicleConfigData(model).miscs.setup[v]

      if data ~= nil then
        misc_info = {
          color = data.color,
          offset = data.offset.x,
          rotation = data.rotation,
          side = data.color
        }

        misc_setup[v] = misc_info
      end
    end
    return misc_setup
  end
end

function getStgTwoMiscSetup(model)
  if getVCFVersion(model) ~= 1.0 then
    return getStgTwoInfo(model).setup
  elseif getVCFVersion(model) == 1.0 then

    misc_setup = {}

    for _,v in pairs(getStgTwoInfo(model).miscs) do
      data = getVehicleConfigData(model).miscs.setup[v]

      if data ~= nil then
        misc_info = {
          color = data.color,
          offset = data.offset.x,
          rotation = data.rotation,
          side = data.color
        }

        misc_setup[v] = misc_info
      end
    end

    return misc_setup
  end
end

function getTrafMiscSetup(model)
  if getVCFVersion(model) ~= 1.0 then
    return getTrafInfo(model).setup
  elseif getVCFVersion(model) == 1.0 then

    misc_setup = {}

    for _,v in pairs(getTrafInfo(model).miscs) do
      data = getVehicleConfigData(model).miscs.setup[v]

      if data ~= nil then
        misc_info = {
          color = data.color,
          offset = data.offset.x,
        }

        misc_setup[v] = misc_info
      end
    end

    return misc_setup
  end
end

function isVehicleELC(vehicle)
    if DoesEntityExist(vehicle) then
      if vehicle and not IsEntityDead(vehicle) then
          for k,v in pairs(vehicleFileData) do
              if GetEntityModel(vehicle) == GetHashKey(k) then
                  return true, k
              end
          end
      end
    end
    
    return false
end