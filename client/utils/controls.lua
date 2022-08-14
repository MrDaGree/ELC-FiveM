keyModifier = false
controlLock = false

RegisterCommand('stage', function()
    vehicle = GetVehiclePedIsIn(PlayerPedId())
    local isELC, model = isVehicleELC(vehicle, false)

    if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
        vid = NetworkGetNetworkIdFromEntity(vehicle)

        if (NetworkDoesNetworkIdExist(vid)) then
          if (elc_status[vid] ~= nil) then
            if getVehicleConfigData(model).interface.activationtype == "auto" then
              if elc_status[vid].stage == 0 then
                handleStageChangeDown(vid)

                TriggerServerEvent("elc:broadcastStageChange", vid, -1)
              elseif elc_status[vid].stage == 3 then
                handleStageChangeUp(vid)

                TriggerServerEvent("elc:broadcastStageChange", vid, 1)
              end
            else
              if (keyModifier or getVehicleConfigData(model).interface.activationtype == "euro") then
                  handleStageChangeDown(vid)

                  TriggerServerEvent("elc:broadcastStageChange", vid, -1)
              else
                  handleStageChangeUp(vid)

                  TriggerServerEvent("elc:broadcastStageChange", vid, 1)
              end
            end
          end
        end
    end
end, false)

prmlShown = true
seclShown = false

RegisterCommand('primarypatternchange', function()
    vehicle = GetVehiclePedIsIn(PlayerPedId())
    local isELC, model = isVehicleELC(vehicle, false)

    if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
        vid = NetworkGetNetworkIdFromEntity(vehicle)

        if (NetworkDoesNetworkIdExist(vid)) then
          if (elc_status[vid] ~= nil) then
            if prmlShown then
                if keyModifier then
                    changeVehiclePatternDown(vid, "front", model)
                else
                    changeVehiclePatternUp(vid, "front", model)
                end
            else
                if seclShown then
                    SendNUIMessage({
                        type = 'updatePatternDisplay',
                        pattern = elc_status[vid].prmlPat
                    })
                    seclShown = false
                    prmlShown = true
                end
            end

            playSoundFile("lever_0to1_2to1")
          end
        end
    end
end, false)

RegisterCommand('secondarypatternchange', function()
    vehicle = GetVehiclePedIsIn(PlayerPedId())
    local isELC, model = isVehicleELC(vehicle, false)

    if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
        vid = NetworkGetNetworkIdFromEntity(vehicle)

        if (NetworkDoesNetworkIdExist(vid)) then
          if (elc_status[vid] ~= nil) then
            if seclShown then
                if keyModifier then
                    changeVehiclePatternDown(vid, "rear", model)
                else
                    changeVehiclePatternUp(vid, "rear", model)
                end
            else
                if prmlShown then
                    SendNUIMessage({
                        type = 'updatePatternDisplay',
                        pattern = elc_status[vid].seclPat
                    })
                    seclShown = true
                    prmlShown = false
                end
            end

            playSoundFile("lever_0to1_2to1")
          end
        end
    end
end, false)

RegisterCommand('+sirentoneone', function()
    vehicle = GetVehiclePedIsIn(PlayerPedId())
    local isELC, model = isVehicleELC(vehicle, false)

    if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
        vid = NetworkGetNetworkIdFromEntity(vehicle)

        if (NetworkDoesNetworkIdExist(vid)) then
          if (elc_status[vid] ~= nil) then
            if elc_status[vid].soundcontroller.sirens.srntone1.id == nil then
              TriggerServerEvent("elc:broadcastSirenChange", 1)
            else
              TriggerServerEvent("elc:broadcastSirenChange", 0)
            end

            clearSirenButtons()

            SendNUIMessage({
                type = 'updateButton',
                on = not elc_status[vid].soundcontroller.sirens.srntone1.enabled,
                button = "wail"
            })

            playSoundFile("lever_0to1_2to1")
          end
        end
    end
end, false)

RegisterCommand('-sirentoneone', function()
    vehicle = GetVehiclePedIsIn(PlayerPedId())
    local isELC, model = isVehicleELC(vehicle, false)

    if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
        vid = NetworkGetNetworkIdFromEntity(vehicle)

        if (NetworkDoesNetworkIdExist(vid)) then
          if (elc_status[vid] ~= nil) then
            if (elc_status[vid].mantone) then        
                TriggerServerEvent("elc:broadcastSirenChange", 0)

                clearSirenButtons()
            end
          end
        end
    end
end, false)

RegisterCommand('+sirentonetwo', function()
    vehicle = GetVehiclePedIsIn(PlayerPedId())
    local isELC, model = isVehicleELC(vehicle, false)

    if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
        vid = NetworkGetNetworkIdFromEntity(vehicle)

        if (NetworkDoesNetworkIdExist(vid)) then
          if (elc_status[vid] ~= nil) then
            if elc_status[vid].soundcontroller.sirens.srntone2.id == nil then
              TriggerServerEvent("elc:broadcastSirenChange", 2)
            else
              TriggerServerEvent("elc:broadcastSirenChange", 0)
            end

            clearSirenButtons()
            
            SendNUIMessage({
                type = 'updateButton',
                on = not elc_status[vid].soundcontroller.sirens.srntone2.enabled,
                button = "yelp"
            })

            playSoundFile("lever_0to1_2to1")
          end
        end
    end
end, false)

RegisterCommand('-sirentonetwo', function()
    vehicle = GetVehiclePedIsIn(PlayerPedId())
    local isELC, model = isVehicleELC(vehicle, false)

    if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
        vid = NetworkGetNetworkIdFromEntity(vehicle)

        if (NetworkDoesNetworkIdExist(vid)) then
          if (elc_status[vid] ~= nil) then
            if (elc_status[vid].mantone) then        
                TriggerServerEvent("elc:broadcastSirenChange", 0)

                clearSirenButtons()
            end
          end
        end
    end
end, false)

RegisterCommand('+sirentonethree', function()
    vehicle = GetVehiclePedIsIn(PlayerPedId())
    local isELC, model = isVehicleELC(vehicle, false)

    if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
        vid = NetworkGetNetworkIdFromEntity(vehicle)

        if (NetworkDoesNetworkIdExist(vid)) then
          if (elc_status[vid] ~= nil) then
            if elc_status[vid].soundcontroller.sirens.srntone3.id == nil then
              TriggerServerEvent("elc:broadcastSirenChange", 3)
            else
              TriggerServerEvent("elc:broadcastSirenChange", 0)
            end

            clearSirenButtons()

            SendNUIMessage({
              type = 'updateButton',
              on = not elc_status[vid].soundcontroller.sirens.srntone3.enabled,
              button = "aux"
            })

            playSoundFile("lever_0to1_2to1")
          end
        end
    end
end, false)

RegisterCommand('-sirentonethree', function()
    vehicle = GetVehiclePedIsIn(PlayerPedId())
    local isELC, model = isVehicleELC(vehicle, false)

    if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
        vid = NetworkGetNetworkIdFromEntity(vehicle)

        if (NetworkDoesNetworkIdExist(vid)) then
          if (elc_status[vid] ~= nil) then
            if (elc_status[vid].mantone) then        
                TriggerServerEvent("elc:broadcastSirenChange", 0)

                clearSirenButtons()
            end
          end
        end
    end
end, false)

RegisterCommand('+modifier', function()
    local isELC, model = isVehicleELC(GetVehiclePedIsIn(PlayerPedId(), false))

    if (isELC) then
        keyModifier = true
    end
end, false)
RegisterCommand('-modifier', function()
    local isELC, model = isVehicleELC(GetVehiclePedIsIn(PlayerPedId(), false))

    if (isELC) then
        keyModifier = false
    end
end, false)

RegisterCommand('mantone', function()
    vehicle = GetVehiclePedIsIn(PlayerPedId())
    local isELC, model = isVehicleELC(vehicle, false)

    if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
        vid = NetworkGetNetworkIdFromEntity(vehicle)

        if (NetworkDoesNetworkIdExist(vid)) then
          TriggerServerEvent("elc:broadcastButtonChange", vid, {button = "#mantone"})

          playSoundFile("lever_0to1_2to1")
        end
    end
end, false)

RegisterCommand('sirencycle', function()
    vehicle = GetVehiclePedIsIn(PlayerPedId())
    local isELC, model = isVehicleELC(vehicle, false)

    if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
        vid = NetworkGetNetworkIdFromEntity(vehicle)

        if (NetworkDoesNetworkIdExist(vid)) then
          if (elc_status[vid] ~= nil) then
            if (not elc_status[vid].mantone) then
                siren = elc_status[vid].soundcontroller:GetCurrentSirenTone() + 1
                if (siren >= 4) then siren = 0 end

                TriggerServerEvent("elc:broadcastSirenChange", siren)

                clearSirenButtons()

                SendNUIMessage({
                    type = 'updateButton',
                    on = siren == 1,
                    button = "wail"
                })
                SendNUIMessage({
                    type = 'updateButton',
                    on = siren == 2,
                    button = "yelp"
                })
                SendNUIMessage({
                    type = 'updateButton',
                    on = siren == 3,
                    button = "aux"
                })
            end

            playSoundFile("lever_0to1_2to1")
          end
        end
    end
end, false)

RegisterCommand('+sirentoggle', function()
    vehicle = GetVehiclePedIsIn(PlayerPedId())
    local isELC, model = isVehicleELC(vehicle, false)

    if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
        vid = NetworkGetNetworkIdFromEntity(vehicle)

        if (NetworkDoesNetworkIdExist(vid)) then
          if (elc_status[vid] ~= nil) then
            if elc_status[vid].soundcontroller.sirens.srntone1.id == nil then
              TriggerServerEvent("elc:broadcastSirenChange", 1)
            else
              TriggerServerEvent("elc:broadcastSirenChange", 0)
            end

            clearSirenButtons()

            SendNUIMessage({
                type = 'updateButton',
                on = not elc_status[vid].soundcontroller.sirens.srntone1.enabled,
                button = "wail"
            })

            playSoundFile("lever_0to1_2to1")
          end
        end
    end
end, false)

RegisterCommand('-sirentoggle', function()
    vehicle = GetVehiclePedIsIn(PlayerPedId())
    local isELC, model = isVehicleELC(vehicle, false)

    if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
        vid = NetworkGetNetworkIdFromEntity(vehicle)

        if (NetworkDoesNetworkIdExist(vid)) then
          if (elc_status[vid] ~= nil) then
            if (elc_status[vid].mantone) then
                TriggerServerEvent("elc:broadcastSirenChange", 0)

                clearSirenButtons()
            end
          end
        end
    end
end, false)

RegisterCommand('toggleta-center', function()
    vehicle = GetVehiclePedIsIn(PlayerPedId())
    local isELC, model = isVehicleELC(vehicle, false)

    if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
        vid = NetworkGetNetworkIdFromEntity(vehicle)

        if (NetworkDoesNetworkIdExist(vid)) then
          TriggerServerEvent("elc:broadcastButtonChange", vid, {button = "#ta_center"})
          playSoundFile("lever_0to1_2to1")
        end
    end
end, false)

RegisterCommand('toggleta-left', function()
  vehicle = GetVehiclePedIsIn(PlayerPedId())
  local isELC, model = isVehicleELC(vehicle, false)

  if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
      vid = NetworkGetNetworkIdFromEntity(vehicle)

      if (NetworkDoesNetworkIdExist(vid)) then
        TriggerServerEvent("elc:broadcastButtonChange", vid, {button = "#ta_left"})
        playSoundFile("lever_0to1_2to1")
      end
  end
end, false)

RegisterCommand('toggleta-right', function()
  vehicle = GetVehiclePedIsIn(PlayerPedId())
  local isELC, model = isVehicleELC(vehicle, false)

  if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
      vid = NetworkGetNetworkIdFromEntity(vehicle)

      if (NetworkDoesNetworkIdExist(vid)) then
        TriggerServerEvent("elc:broadcastButtonChange", vid, {button = "#ta_right"})
        playSoundFile("lever_0to1_2to1")
      end
  end
end, false)

RegisterCommand('steadyburntoggle', function()
    vehicle = GetVehiclePedIsIn(PlayerPedId())
    local isELC, model = isVehicleELC(vehicle, false)

    if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
        vid = NetworkGetNetworkIdFromEntity(vehicle)

        if (NetworkDoesNetworkIdExist(vid)) then
          TriggerServerEvent("elc:broadcastButtonChange", vid, {button = "#stdyburn"})
          playSoundFile("lever_0to1_2to1")
        end
    end
end, false)

RegisterCommand('togglecruise', function()
    vehicle = GetVehiclePedIsIn(PlayerPedId())
    local isELC, model = isVehicleELC(vehicle, false)

    if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
        vid = NetworkGetNetworkIdFromEntity(vehicle)

        if (NetworkDoesNetworkIdExist(vid)) then
          TriggerServerEvent("elc:broadcastButtonChange", vid, {button = "#cruiselght"})
          playSoundFile("lever_0to1_2to1")
        end
    end
end, false)

RegisterCommand('toggleleftalley', function()
    vehicle = GetVehiclePedIsIn(PlayerPedId())
    local isELC, model = isVehicleELC(vehicle, false)

    if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
        vid = NetworkGetNetworkIdFromEntity(vehicle)

        if (NetworkDoesNetworkIdExist(vid)) then
          TriggerServerEvent("elc:broadcastButtonChange", vid, {button = "#l_alley"})
          playSoundFile("lever_0to1_2to1")
        end
    end
end, false)

RegisterCommand('togglerightalley', function()
    vehicle = GetVehiclePedIsIn(PlayerPedId())
    local isELC, model = isVehicleELC(vehicle, false)

    if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
        vid = NetworkGetNetworkIdFromEntity(vehicle)

        if (NetworkDoesNetworkIdExist(vid)) then
          TriggerServerEvent("elc:broadcastButtonChange", vid, {button = "#r_alley"})
          playSoundFile("lever_0to1_2to1")
        end
    end
end, false)

RegisterCommand('toggletakedowns', function()
    vehicle = GetVehiclePedIsIn(PlayerPedId())
    local isELC, model = isVehicleELC(vehicle, false)

    if (isELC and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not IsPauseMenuActive() and not controlLock) then
        vid = NetworkGetNetworkIdFromEntity(vehicle)

        if (NetworkDoesNetworkIdExist(vid)) then
          TriggerServerEvent("elc:broadcastButtonChange", vid, {button = "#takedown"})
          playSoundFile("lever_0to1_2to1")
        end
    end
end, false)

RegisterCommand('toggleELCDebug', function()
    runDebug = not runDebug
    print("ELC Debug: " .. tostring(runDebug))
end, false)

RegisterCommand('toggleelclock', function()
  controlLock = not controlLock
  playSoundFile("lever_0to1_2to1")
end, false)

RegisterKeyMapping('stage', 'ELC Stage', controls['stage'].type, controls['stage'].key)
RegisterKeyMapping('primarypatternchange', 'ELC Front Pattern Change', controls['frontpatternchange'].type, controls['frontpatternchange'].key)
RegisterKeyMapping('secondarypatternchange', 'ELC Rear Pattern Change', controls['rearpatternchange'].type, controls['rearpatternchange'].key)
RegisterKeyMapping('+sirentoneone', 'ELC Siren Tone 1', controls['sirentoneone'].type, controls['sirentoneone'].key)
RegisterKeyMapping('+sirentonetwo', 'ELC Siren Tone 2', controls['sirentonetwo'].type, controls['sirentonetwo'].key)
RegisterKeyMapping('+sirentonethree', 'ELC Siren Tone 3', controls['sirentonethree'].type, controls['sirentonethree'].key)
RegisterKeyMapping('sirencycle', 'ELC Siren Cycle', controls['sirencycle'].type, controls['sirencycle'].key)
RegisterKeyMapping('+sirentoggle', 'ELC Siren Toggle', controls['sirentoggle'].type, controls['sirentoggle'].key)
RegisterKeyMapping('paneltoggle', 'ELC Panel Toggle', controls['paneltoggle'].type, controls['paneltoggle'].key)
RegisterKeyMapping('+modifier', 'ELC Modifier', controls['modifier'].type, controls['modifier'].key)
RegisterKeyMapping('mantone', 'ELC Manual Tone Toggle', controls['mantonetoggle'].type, controls['mantonetoggle'].key)
RegisterKeyMapping('togglecruise', 'ELC Cruise Toggle', controls['cruisetoggle'].type, controls['cruisetoggle'].key)
RegisterKeyMapping('steadyburntoggle', 'ELC Steady Burn Toggle', controls['steadyburntoggle'].type, controls['steadyburntoggle'].key)
RegisterKeyMapping('toggleta-right', 'ELC TA Right', controls['toggleta-right'].type, controls['toggleta-right'].key)
RegisterKeyMapping('toggleta-center', 'ELC TA Center', controls['toggleta-center'].type, controls['toggleta-center'].key)
RegisterKeyMapping('toggleta-left', 'ELC TA Left', controls['toggleta-left'].type, controls['toggleta-left'].key)
RegisterKeyMapping('toggleleftalley', 'ELC Left Alley Toggle', controls['toggleleftalley'].type, controls['toggleleftalley'].key)
RegisterKeyMapping('togglerightalley', 'ELC Right Alley Toggle', controls['togglerightalley'].type, controls['togglerightalley'].key)
RegisterKeyMapping('toggletakedowns', 'ELC Takedown Toggle', controls['toggletakedowns'].type, controls['toggletakedowns'].key)
RegisterKeyMapping('toggleelclock', 'Lock ELC Buttons', controls['lock'].type, controls['lock'].key)

function startControlLoop()
    Citizen.CreateThread(function()
        while true do

            playerPed = PlayerPedId()

            if IsPedInAnyVehicle(playerPed, false) then

              local isELC, model = isVehicleELC(GetVehiclePedIsIn(playerPed, false))

              if (not isELC) then
                Wait(1500)
              end

              if (isELC) then
                  local veh = GetVehiclePedIsIn(playerPed, false)
                  local vid = NetworkGetNetworkIdFromEntity(veh)

                  
                  if (NetworkDoesNetworkIdExist(vid)) then
                    DisableControlAction(0, 86, true) -- INPUT_VEH_HORN	
                    DisableControlAction(0, 19, true) -- INPUT_CHARACTER_WHEEL 
                    DisableControlAction(0, 80, true) -- INPUT_VEH_CIN_CAM
                    DisableControlAction(0, 199, true)
                    DisableControlAction(0, 100, true)

                    if (IsDisabledControlJustPressed(0, 86)) then
                        TriggerServerEvent("elc:broadcastHornChange", true)

                        SendNUIMessage({
                            type = 'updateButton',
                            on = true,
                            button = "ahorn"
                        })
                    elseif (IsDisabledControlJustReleased(0, 86)) then
                        TriggerServerEvent("elc:broadcastHornChange", false)
                        SendNUIMessage({
                            type = 'updateButton',
                            on = false,
                            button = "ahorn"
                        })
                    end

                    if (IsControlJustPressed(0, 74)) then
                      if (elc_status[vid] ~= nil) then
                        local _, headlights, takedown = GetVehicleLightsState(veh)
                        if (headlights == 1 and takedown ~= 1) then
                            elc_status[vid].tkdown = true
                            SendNUIMessage({
                                type = 'updateButton',
                                on = true,
                                button = "takedown"
                            })
                        else
                            elc_status[vid].tkdown = false
                            SendNUIMessage({
                                type = 'updateButton',
                                on = false,
                                button = "takedown"
                            })
                        end

                        playSoundFile("lever_0to1_2to1")
                      end
                    end

                    if (not IsInputDisabled(0)) then
                        DisableControlAction(0, 73, true) -- xbox 'a'
                        DisableControlAction(0, 80, true) -- xbox 'b'
                        DisableControlAction(0, 99, true) -- xbox 'x'

                        DisableControlAction(0, 68, true) -- xbox LB
                        DisableControlAction(0, 69, true) -- xbox RB

                        DisableControlAction(0, 85, true) -- xbox 'dpad left'
                        DisableControlAction(0, 20, true) -- xbox 'dpad down'
                    end
                  end
              end

              Wait(0)
            else
              Wait(1500)
            end
        end
    end)
end