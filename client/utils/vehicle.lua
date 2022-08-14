elc_status = {}

local buttons = {
    "ta_left",
    "ta_center",
    "ta_right"
}

RegisterNetEvent("elc:updateStageValue")
AddEventHandler("elc:updateStageValue", function(vid, dir)
    if elc_status[vid] ~= nil then
        if (dir == 1) then
            if elc_status[vid].stage == 0 then
                stageOneChangeLogic(vid)
            elseif elc_status[vid].stage == 1 then
                stageTwoChangeLogic(vid)
            elseif elc_status[vid].stage == 2 then
                stageThreeChangeLogic(vid)
            elseif elc_status[vid].stage == 3 then
                stageZeroChangeLogic(vid)
            end
        elseif (dir == -1) then
            if elc_status[vid].stage == 2 then
                stageOneChangeLogic(vid)
            elseif elc_status[vid].stage == 3 then
                stageTwoChangeLogic(vid)
            elseif elc_status[vid].stage == 0 then
                stageThreeChangeLogic(vid)
            elseif elc_status[vid].stage == 1 then
                stageZeroChangeLogic(vid)
            end
        end

        if (GetVehiclePedIsIn(PlayerPedId(), false) == NetworkGetEntityFromNetworkId(vid)) then
            SendNUIMessage({
                type = 'updateStageDisplay',
                stage = elc_status[vid].stage
            })
        end
    end
end)

RegisterNetEvent("elc:setLightKindState")
AddEventHandler("elc:setLightKindState", function(vid, lightkind)
    for k,light in pairs(elc_status[vid].lights[lightkind]) do
        light:IsPatternRunning(true)
    end
end)

RegisterNetEvent("elc:setStageValue")
AddEventHandler("elc:setStageValue", function(vid, stage)
    if elc_status[vid] ~= nil then
        if stage == 0 then
            stageZeroChangeLogic(vid)
        elseif stage == 1 then
            stageOneChangeLogic(vid)
        elseif stage == 2 then
            stageTwoChangeLogic(vid)
        elseif stage == 3 then
            stageThreeChangeLogic(vid)
        end

        if (GetVehiclePedIsIn(PlayerPedId(), false) == NetworkGetEntityFromNetworkId(vid)) then
            SendNUIMessage({
                type = 'updateStageDisplay',
                stage = elc_status[vid].stage
            })
        end

        elcReady = true
    end
end)


RegisterNetEvent("elc:updateVehicleData")
AddEventHandler("elc:updateVehicleData", function(vid, data)
    for k,v in pairs(data) do
        elc_status[vid][k] = v
    end

    TriggerEvent("elc:updateVehicleColor", elc_status[vid].color, vid)

    TriggerServerEvent("elc:getStageData", vid)
    TriggerServerEvent("elc:getButtonData", vid)
end)

function stageZeroChangeLogic(vid)
    TriggerServerEvent("elc:broadcastSirenChange", 0)

    elc_status[vid].stage = 0
    elc_status[vid].secondary = false
    elc_status[vid].primary = false

    for k,v in pairs(elc_status[vid].lights) do
        if (k ~= "steadyburn" and k ~= "traf") then
            for i,va in pairs(v) do
                va:IsPatternRunning(false)
            end
        end
    end

    SetVehicleSiren(NetworkGetEntityFromNetworkId(vid), false)
end

function stageOneChangeLogic(vid)
    elc_status[vid].stage = 1
    elc_status[vid].secondary = false
    elc_status[vid].primary = false

    for k,light in pairs(elc_status[vid].lights.rear) do
        light:IsPatternRunning(true)
    end

    for k,light in pairs(elc_status[vid].lights.front) do
        light:IsPatternRunning(false)
    end

    SetVehicleSiren(NetworkGetEntityFromNetworkId(vid), false)
end

function stageTwoChangeLogic(vid)
    elc_status[vid].stage = 2
    elc_status[vid].secondary = true
    elc_status[vid].primary = false
    
    for k,light in pairs(elc_status[vid].lights.rear) do
        light:IsPatternRunning(false)
    end

    for k,light in pairs(elc_status[vid].lights.front) do
        light:IsPatternRunning(true)
    end

    SetVehicleSiren(NetworkGetEntityFromNetworkId(vid), false)
end

function stageThreeChangeLogic(vid)
    elc_status[vid].stage = 3
    elc_status[vid].primary = true

    for k,light in pairs(elc_status[vid].lights.rear) do
        light:syncLights()
        light:IsPatternRunning(true)
    end

    for k,light in pairs(elc_status[vid].lights.front) do
        light:syncLights()
        light:IsPatternRunning(true)
    end

    SetVehicleSiren(NetworkGetEntityFromNetworkId(vid), true)
    SetVehicleHasMutedSirens(NetworkGetEntityFromNetworkId(vid), true)
end

function isInSpecificELCVehiclePRML(veh)
    local isELC, model = isVehicleELC(veh)

    if (isELC and not getVehicleConfigData(model).misc.usetrafficadvisor) then
        return GetVehiclePedIsUsing(PlayerPedId()) == veh
    end
    
    return false
end

function isInSpecificELCVehicleTA(veh)
    local isELC, model = isVehicleELC(veh)

    if (isELC) then
        return GetVehiclePedIsUsing(PlayerPedId()) == veh
    end
    
    return false
end

RegisterNetEvent("elc:createELCVehicleData")
AddEventHandler("elc:createELCVehicleData", function(vid)
    local vehicle = NetworkGetEntityFromNetworkId(vid)
    local _, model = isVehicleELC(vehicle)

    while not getVehicleConfigData(model) do Wait(0) end

    if getVehicleConfigData(model) ~= nil then
        if elc_status[vid] == nil then
            
            if (not IsEntityDead(vehicle))then

                SetVehicleModKit(vehicle, 0)
                SetEntityAsMissionEntity(vehicle, true, true)
                SetVehicleHasBeenOwnedByPlayer(vehicle, true)

                SetVehRadioStation(vehicle, "OFF")
                SetVehicleRadioEnabled(vehicle, false)

                local prml, secl = GetVehicleColours(vehicle)

                SetVehicleDashboardColour(vehicle, 88)

                vehicle_colors = getVCFLightColors(model)

                if (vehicle_colors.left == "red") then
                    SetVehicleColours(vehicle, prml, 150)
                elseif (vehicle_colors.left == "blue") then
                    SetVehicleColours(vehicle, prml, 73)
                elseif (vehicle_colors.left == "amber") then
                    SetVehicleColours(vehicle, prml, 88)
                end
    
                if (vehicle_colors.right == "red") then
                    SetVehicleInteriorColour(vehicle, 150)
                elseif (vehicle_colors.right == "blue") then
                    SetVehicleInteriorColour(vehicle, 73)
                elseif (vehicle_colors.right == "amber") then
                    SetVehicleInteriorColour(vehicle, 88)
                end

                NetworkRegisterEntityAsNetworked(vehicle)
            end

            elc_status[vid] = {}
            elc_status[vid].model = model
            elc_status[vid].stage = 0
            elc_status[vid].ready = false
            elc_status[vid].passenerControl = false
            elc_status[vid].cruiselight = false
            elc_status[vid].steadyburn = false
            elc_status[vid].mantone = false
            elc_status[vid].primary = false
            elc_status[vid].secondary = false
            elc_status[vid].trafadv = false
            elc_status[vid].traftype = "center"
            elc_status[vid].leftAlley = false
            elc_status[vid].rightAlley = false
            elc_status[vid].parkmode = false
            elc_status[vid].color = vehicle_colors.left:sub(1, 1) .. vehicle_colors.right:sub(1, 1)

            elc_status[vid].panel = {}
            elc_status[vid].panel.buttons = {
                ["prmlpat"] = true,
                ["seclpat"] = false,
                ["wrnlpat"] = false,
                ["l_alley"] = false,
                ["takedown"] = false,
                ["r_alley"] = false,
                ["cruiselght"] = false,
                ["ta_left"] = false,
                ["ta_center"] = false,
                ["ta_right"] = false,
                ["parkmode"] = false,
            }

            elc_status[vid].lights = {}
            elc_status[vid].prmlPat = getStartPattern(model, 2)
            elc_status[vid].seclPat = getStartPattern(model, 1)

            elc_status[vid].lights.front = {}
            for misc, val in pairs(getStgTwoMiscSetup(model)) do
              id = miscNameToID(misc)
              table.insert(elc_status[vid].lights.front, prmllight(vehicle, id, lightColorToTable(vehicle_colors[val.color]), getLightPattern(model, id, elc_status[vid].prmlPat), val.offset, val.rotation, val.side ~= nil and val.side or val.color))
            end

            elc_status[vid].lights.rear = {}
            for misc, val in pairs(getStgOneMiscSetup(model)) do
              id = miscNameToID(misc)
              table.insert(elc_status[vid].lights.rear, prmllight(vehicle, id, lightColorToTable(vehicle_colors[val.color]), getLightPattern(model, id, elc_status[vid].seclPat), val.offset, val.rotation, val.side ~= nil and val.side or val.color))
            end

            if getVCFUseTrafficAdvisor(model) then
              elc_status[vid].lights.traf = {}

              for misc, val in pairs(getTrafMiscSetup(model)) do
                id = miscNameToID(misc)
                table.insert(elc_status[vid].lights.traf, taLight(vehicle, id, lightColorToTable(vehicle_colors[val.color]), getTrafLightPattern(id, model, 2), val.offset))
              end
            end

            elc_status[vid].lights.steadyburn = {}
            if getVCFSteadyburnSettings(model) ~= nil then
              if getVCFSteadyburnSettings(model).enabled then
                table.insert(elc_status[vid].lights.steadyburn, steadyBurnLight(vehicle, miscNameToID(getVCFSteadyburnSettings(model).steadyburn_misc)))
              end
            end

            elc_status[vid].soundcontroller = soundcontroller(vehicle, model)

            elc_status[vid].ready = true

            if (GetVehiclePedIsIn(PlayerPedId(), false) == vehicle) then
                SendNUIMessage({
                    type = 'updatePatternDisplay',
                    pattern = elc_status[vid].prmlPat
                })
            end
            
            TriggerServerEvent("elc:getVehicleData", vid)
        end
    end
end)

function vehicleDataLogic(vehicle)
    local vid = NetworkGetNetworkIdFromEntity(vehicle)
    local _, model = isVehicleELC(vehicle)

    if (NetworkDoesNetworkIdExist(vid)) then
      if getVehicleConfigData(model) ~= nil then
          if not IsEntityDead(vehicle) then
              if elc_status[vid] == nil then
                  TriggerServerEvent("elc:createVehicleDataForAll", vid, model)
              end
          else
              if elc_status[vid] ~= nil then
                  elc_status[vid] = nil
                  TriggerServerEvent("elc:removeVehicleCount")
              end
          end
      end
    end
end

function handleStageChangeDown(vid)
    if (GetVehiclePedIsIn(PlayerPedId(), false) == NetworkGetEntityFromNetworkId(vid)) then
      if elc_status[vid] ~= nil then
          if elc_status[vid].stage == 2 then
              playSoundFile("lever_0to1_2to1")
          elseif elc_status[vid].stage == 3 then
              playSoundFile("lever_1to2_3to2")
          elseif elc_status[vid].stage == 0 then
              playSoundFile("lever_0to3")

              clearSirenButtons()
          else
              playSoundFile("lever_3to0")
          end
      end
    end
end

function handleStageChangeUp(vid)
    if (GetVehiclePedIsIn(PlayerPedId(), false) == NetworkGetEntityFromNetworkId(vid)) then
      if elc_status[vid] ~= nil then
          if elc_status[vid].stage == 0 then
              playSoundFile("lever_0to1_2to1")
          elseif elc_status[vid].stage == 1 then
              playSoundFile("lever_0to1_2to1")            
          elseif elc_status[vid].stage == 2 then
              playSoundFile("lever_2to3")
          else
              playSoundFile("lever_3to0")

              clearSirenButtons()
          end
      end
    end
end