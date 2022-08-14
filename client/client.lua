elcReady = true

Citizen.CreateThread(function()    
    RequestStreamedTextureDict("elc")
    while (not HasStreamedTextureDictLoaded("elc")) do Wait(0) end
    startMessage("Thank you for using ELC!")

    TriggerServerEvent("elc:ready")

    debugPrint("Waiting for vehicle data..")
    while (not hasVehicleFilesLoaded()) do
        Wait(0)
    end
    debugPrint("Vehicle data got, ELC Ready.")

    startMainELCLoop()
    startControlLoop()

end)

function startMainELCLoop()
    Citizen.CreateThread(function()
        while elcReady do
            if elc_status then
                for k,v in pairs(elc_status) do
                    if (v ~= nil) then
                      if (NetworkDoesNetworkIdExist(k)) then
                          if (v.ready) then
                              pCoords = GetEntityCoords(PlayerPedId())                          
                              local elc_vehicle = NetToVeh(k)
                              local vehCoords = GetEntityCoords(elc_vehicle)

                              mainDistCheck = #(vehCoords-pCoords) <= mainLoadDist
                              trafDistCheck = #(vehCoords-pCoords) <= trafLoadDist

                              if v.parkmode and mainDistCheck and getParkPattern(v.model, 2) ~= nil and getParkPattern(v.model, 1) ~= nil then
                                if GetEntitySpeed(elc_vehicle) == 0.0 and not IsPedGettingIntoAVehicle(PlayerPedId()) and GetPedUsingVehicleDoor(elc_vehicle, 0) == PlayerPedId() and v.prmlPat ~= getParkPattern(v.model, 2) then
                                  setVehiclePattern(k, "front", v.model, getParkPattern(v.model, 2))
                                  setVehiclePattern(k, "rear", v.model, getParkPattern(v.model, 1))

                                  SendNUIMessage({
                                      type = 'updatePatternDisplay',
                                      pattern = v.prmlPat
                                  })

                                  seclShown = false
                                  prmlShown = true
                                elseif GetEntitySpeed(elc_vehicle) == 0.0 and IsPedGettingIntoAVehicle(PlayerPedId()) and GetPedUsingVehicleDoor(elc_vehicle, 0) == PlayerPedId() and v.prmlPat == getParkPattern(v.model, 2) then
                                  setVehiclePattern(k, "front", v.model, v.lastprmlPat)
                                  setVehiclePattern(k, "rear", v.model, v.lastseclPat)

                                  SendNUIMessage({
                                      type = 'updatePatternDisplay',
                                      pattern = v.prmlPat
                                  })

                                  seclShown = false
                                  prmlShown = true
                                end
                              end

                              for type,lights in pairs(v.lights) do
                                  for i,light in ipairs(lights) do
                                      if type == "front" and mainDistCheck then
                                          light:LightTicker(elc_vehicle, v.model)

                                          if maximizePerformance then
                                            if (light._cruiseLight) then
                                              light:CruiseLightTicker(elc_vehicle, v.model)
                                            end
                                          end

                                          if runDebug then
                                              light:RunDebug()
                                          end
                                      elseif type == "rear" and mainDistCheck then
                                          light:LightTicker(elc_vehicle)

                                          if maximizePerformance then
                                            if (light._cruiseLight) then
                                              light:CruiseLightTicker(elc_vehicle, v.model)
                                            end
                                          end

                                          if runDebug then
                                              light:RunDebug()
                                          end
                                      elseif type == "traf" and trafDistCheck then
                                          light:LightTicker(elc_vehicle)

                                          if runDebug then
                                              light:RunDebug()
                                          end
                                      elseif type ~= "steadyburn" then
                                          light:CleanUp()
                                      end
                                  end
                              end
                          end
                        end
                    end
                end
            end

            Wait(60)
        end
    end)

    Citizen.CreateThread(function()
      while elcReady do
          if elc_status then
              for k,v in pairs(elc_status) do
                if (v ~= nil) then
                  if (NetworkDoesNetworkIdExist(k)) then
                      if (v.ready and (v.cruiselight or v.leftAlley or v.rightAlley)) then
                          pCoords = GetEntityCoords(PlayerPedId())                          
                          local elc_vehicle = NetToVeh(k)
                          local vehCoords = GetEntityCoords(elc_vehicle)

                          mainDistCheck = #(vehCoords-pCoords) <= mainLoadDist

                          if mainDistCheck then
                            for type,lights in pairs(v.lights) do
                                for i,light in ipairs(lights) do
                                    if (type == "front" or type == "rear") then
                                      if (light._cruiseLight and not maximizePerformance) then
                                        light:CruiseLightTicker(elc_vehicle)
                                      end
                                      
                                      
                                      if (light._alleyLight) then
                                        light:AlleyLightTicker(elc_vehicle)
                                      end
                                    end
                                end
                            end
                          end
                      end
                  end
                end
              end
          end

          Wait(0)
      end
    end)

    Citizen.CreateThread(function()
        while elcReady do
            if elc_status then
                for k,v in pairs(elc_status) do
                  if (v ~= nil) then
                    if (NetworkDoesNetworkIdExist(k)) then
                        local elc_vehicle = NetToVeh(k)
                        local vehCoords = GetEntityCoords(elc_vehicle)
                        if (v.ready) then
                            if (IsEntityDead(elc_vehicle)) then
                                if (v.soundcontroller:isSirenPlaying()) then
                                    v.soundcontroller:PlaySiren(0)
                                end
                                for type,lights in pairs(v.lights) do
                                    for i,light in ipairs(lights) do
                                        light:CleanUp()
                                    end
                                end

                                elc_status[k] = nil
                            end
                        end
                    end
                  end
                end
            end

            Wait(30000)
        end
    end)

    Citizen.CreateThread(function()
        while elcReady do            
            for vehicle in EnumerateVehicles() do
                local isELC, model = isVehicleELC(vehicle)
                if isELC then
                    vehicleDataLogic(vehicle)
                    
                    if (IsVehicleSirenOn(vehicle)) then
                      if (not IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1)) and GetPedInVehicleSeat(vehicle, -1) ~= 0) then
                        vid = NetworkGetNetworkIdFromEntity(vehicle)
                        if elc_status[vid].stage ~= 3 then

                          if (getVehicleConfigData(model).interface.activationtype == "euro") then
                            
                              handleStageChangeUp(vid)

                              TriggerServerEvent("elc:broadcastStageChange", vid, 1)
                          else
                              
                              handleStageChangeDown(vid)

                              TriggerServerEvent("elc:broadcastStageChange", vid, -1)
                          end
                        end
                      end
                    end
                end
            end
            Wait(10000)
        end
    end)
end

local orig = _G.Citizen.Trace
_G.Citizen.Trace = function(data)
    orig(data)
    if string.match(data, "SCRIPT ERROR") then
        if string.match(data, "fb71170b7e76acba") then
            error("\n\nModkits arent assigned to this vehicle!! Please fix.\n\n")
            startMessage("Modkits dont appear to be setup. Please fix.")
            elcReady = false
        end
        TriggerServerEvent("elc:catchError", data)
    end
end