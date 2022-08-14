curVehicleStage = 1
panelOpen = false
local buttonChangedPanel = false
local _veh = nil

local buttons = {
    "prmlpat",
    "seclpat",
    "wrnlpat",
    "l_alley",
    "takedown",
    "r_alley",
    "cruiselight",
    "ta_left",
    "ta_center",
    "ta_right",
    "parkmode"
}

RegisterCommand('paneltoggle', function()
    local isELC, model = isVehicleELC(GetVehiclePedIsIn(PlayerPedId(), false))

    if (isELC) then
        vid = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(PlayerPedId()))

        if (NetworkDoesNetworkIdExist(vid)) then
          if (keyModifier) then
              panelOpen = not panelOpen
              buttonChangedPanel = not buttonChangedPanel

              if panelOpen then
                  SendNUIMessage({
                      type = 'openPanel',
                      light = {
                          red = getVehicleConfigData(model).interface.infopanelbuttonlightcolor.red,
                          green = getVehicleConfigData(model).interface.infopanelbuttonlightcolor.green,
                          blue = getVehicleConfigData(model).interface.infopanelbuttonlightcolor.blue,
                      },
                      name = GetCurrentResourceName(),
                      panelkey = controls['paneltoggle'].key
                  })
              else
                  SendNUIMessage({
                      type = 'closePanel'
                  })
              end

              playSoundFile("lever_0to1_2to1")
          else
            if panelOpen then
                SetNuiFocus(true, true)
                _veh = vid
            end
          end
        end
    end
end, false)

Citizen.CreateThread(function()
    SetNuiFocus(false, false)
    while not elcReady do Wait(10) end

    while true do

        vehPedIn = GetVehiclePedIsIn(PlayerPedId(), false)
        local isELC, model = isVehicleELC(vehPedIn)

        if (not isELC) then
          Wait(500)
        end

        if openPanelByDefault then
          if isELC and not panelOpen and not buttonChangedPanel and not IsPauseMenuActive() then
              _model = model
              _veh = NetworkGetNetworkIdFromEntity(vehPedIn)

              if (NetworkDoesNetworkIdExist(_veh)) then
                if elc_status[_veh] ~= nil then
                    SendNUIMessage({
                        type = 'openPanel',
                        light = {
                            red = getVehicleConfigData(model).interface.infopanelbuttonlightcolor.red,
                            green = getVehicleConfigData(model).interface.infopanelbuttonlightcolor.green,
                            blue = getVehicleConfigData(model).interface.infopanelbuttonlightcolor.blue,
                        },
                        name = GetCurrentResourceName(),
                        panelkey = controls['paneltoggle'].key
                    })
                    panelOpen = true

                    if buttonChangedPanel then
                        SendNUIMessage({
                            type = 'closePanel'
                        })

                        panelOpen = false
                    end
                end
              end
          end
        end

        if (not IsPedInAnyVehicle(PlayerPedId(), false) and panelOpen) or (panelOpen and IsPauseMenuActive()) then
            SendNUIMessage({
                type = 'closePanel'
            })
            panelOpen = false
        end

        Wait(2500)
    end
end)

RegisterNetEvent("elc:setButtonData")
AddEventHandler("elc:setButtonData", function(vid, data)
    for k,v in pairs(data) do
        if (v) then
            if (k == "#prml" or k == "#secl" or k == "#ta_left" or k == "#ta_center" or k == "#ta_right") then
                panelButtonLogic(vid, {button = k})
            end
        end
    end
end)

RegisterNetEvent("elc:updateButtonValues")
AddEventHandler("elc:updateButtonValues", function(vid, data)
    panelButtonLogic(vid, data)
end)

function isPanelButtonEnabled(button)
    if (elc_status[_veh].panel.buttons[button] ~= nil) then
        return elc_status[_veh].panel.buttons[button]
    end

    return false
end

function panelButtonLogic(vid, data)
    if (NetworkDoesNetworkIdExist(vid)) then
      if (GetVehiclePedIsIn(PlayerPedId(), false) == NetworkGetEntityFromNetworkId(vid)) then
          inVehicle = true
      else
          inVehicle = false
      end

      
      if elc_status[vid] ~= nil then
          if (elc_status[vid].panel.buttons[string.sub(data.button,2)] ~= nil) then
              elc_status[vid].panel.buttons[string.sub(data.button,2)] = not elc_status[vid].panel.buttons[string.sub(data.button,2)]
          end

          if (elc_status[vid].panel.buttons[string.sub(data.button,2)] == nil) then
              elc_status[vid].panel.buttons[string.sub(data.button,2)] = true
          end

          if string.sub(data.button,2) == "prmlpat" then
              SendNUIMessage({
                  type = 'updatePatternDisplay',
                  pattern = getCurrentPatternForVehicle(vid, "front")
              })
          elseif string.sub(data.button,2) == "seclpat" then
              SendNUIMessage({
                  type = 'updatePatternDisplay',
                  pattern = getCurrentPatternForVehicle(vid, "rear")
              })
          elseif string.sub(data.button,2) == "wrnlpat" then

          end

          if string.sub(data.button,2) == "cruiselght" then
              if getVCFCruiseLightSettings(elc_status[vid].model).enabled then
                  elc_status[vid].cruiselight = not elc_status[vid].cruiselight

                  SendNUIMessage({
                      type = 'updateButton',
                      on = elc_status[vid].cruiselight,
                      button = string.sub(data.button,2),
                  })
                
                  if (elc_status[vid].cruiselight) then
                      for _, misc in pairs(getVCFCruiseLightSettings(elc_status[vid].model).miscs) do
                        for type, light in ipairs(elc_status[vid].lights.front) do
                          if light._modkit == miscNameToID(misc) then
                            light._cruiseLight = true
                          end
                        end

                        for type, light in ipairs(elc_status[vid].lights.rear) do
                          if light._modkit == miscNameToID(misc) then
                            light._cruiseLight = true
                          end
                        end
                      end
                  else
                      for _, misc in pairs(getVCFCruiseLightSettings(elc_status[vid].model).miscs) do
                        for type, light in ipairs(elc_status[vid].lights.front) do
                          if light._modkit == miscNameToID(misc) then
                            light._cruiseLight = false
                          end
                        end

                        for type, light in ipairs(elc_status[vid].lights.rear) do
                          if light._modkit == miscNameToID(misc) then
                            light._cruiseLight = false
                          end
                        end
                      end
                  end
              end
          end

          if string.sub(data.button,2) == "mantone" then
              if (not elc_status[vid].soundcontroller:isSirenPlaying()) then
                  elc_status[vid].mantone = not elc_status[vid].mantone
              else
                  SendNUIMessage({
                      type = 'updateButton',
                      on = false,
                      button = "mantone"
                  })
              end

              if (inVehicle) then
                  SendNUIMessage({
                      type = 'updateButton',
                      on = elc_status[vid].mantone,
                      button = string.sub(data.button,2),
                  })
              end
          end

          if string.sub(data.button,2) == "stdyburn" then
              if getVCFSteadyburnSettings(elc_status[vid].model).enabled then
                  elc_status[vid].steadyburn = not elc_status[vid].steadyburn

                  if (elc_status[vid].steadyburn) then
                      elc_status[vid].lights.steadyburn[1]:SetState(true)
                      
                      if (inVehicle) then
                          SendNUIMessage({
                              type = 'updateButton',
                              on = true,
                              button = string.sub(data.button,2)
                          })
                      end
                  elseif (not elc_status[vid].steadyburn) then
                      elc_status[vid].lights.steadyburn[1]:SetState(false)

                      if (inVehicle) then
                          SendNUIMessage({
                              type = 'updateButton',
                              on = false,
                              button = string.sub(data.button,2)
                          })
                      end
                  end
              end
          end

          if string.sub(data.button,2) == "int_light" then
            if (NetworkDoesNetworkIdExist(vid)) then
                veh = NetworkGetEntityFromNetworkId(vid)
                if (IsVehicleInteriorLightOn(veh)) then
                    SetVehicleInteriorlight(veh, false)

                    if (inVehicle) then
                        SendNUIMessage({
                            type = 'updateButton',
                            on = false,
                            button = string.sub(data.button,2)
                        })
                    end
                else
                    SetVehicleInteriorlight(veh, true)

                    if (inVehicle) then
                        SendNUIMessage({
                            type = 'updateButton',
                            on = true,
                            button = string.sub(data.button,2)
                        })
                    end
                end
              end
          end

          if string.sub(data.button,2) == "l_alley" then
              if getVCFAlleyLightingSettings(elc_status[vid].model).enabled then
                  elc_status[vid].leftAlley = not elc_status[vid].leftAlley

                  if (inVehicle) then
                    SendNUIMessage({
                        type = 'updateButton',
                        on = elc_status[vid].leftAlley,
                        button = string.sub(data.button,2)
                    })
                  end

                  if (elc_status[vid].leftAlley) then
                    for type, light in ipairs(elc_status[vid].lights.front) do
                      if light._modkit == miscNameToID(getVCFAlleyLightingSettings(elc_status[vid].model).miscs.left) then
                        light._alleyLight = true
                      end
                    end

                    for type, light in ipairs(elc_status[vid].lights.rear) do
                      if light._modkit == miscNameToID(getVCFAlleyLightingSettings(elc_status[vid].model).miscs.left) then
                        light._alleyLight = true
                      end
                    end
                  else
                    for type, light in ipairs(elc_status[vid].lights.front) do
                      if light._modkit == miscNameToID(getVCFAlleyLightingSettings(elc_status[vid].model).miscs.left) then
                        light._alleyLight = false
                      end
                    end

                    for type, light in ipairs(elc_status[vid].lights.rear) do
                      if light._modkit == miscNameToID(getVCFAlleyLightingSettings(elc_status[vid].model).miscs.left) then
                        light._alleyLight = false
                      end
                    end
                  end
              end
          end

          if string.sub(data.button,2) == "takedown" then
              elc_status[vid].tkdown = not elc_status[vid].tkdown

              if (elc_status[vid].tkdown) then
                  SetVehicleFullbeam(NetToVeh(vid), true)

                  if (inVehicle) then
                      SendNUIMessage({
                          type = 'updateButton',
                          on = true,
                          button = string.sub(data.button,2)
                      })
                  end
              else
                  SetVehicleFullbeam(NetToVeh(vid), false)

                  if (inVehicle) then
                      SendNUIMessage({
                          type = 'updateButton',
                          on = false,
                          button = string.sub(data.button,2)
                      })
                  end
              end
          end

          if string.sub(data.button,2) == "parkmode" then
              elc_status[vid].parkmode = not elc_status[vid].parkmode

              if (inVehicle) then
                  SendNUIMessage({
                      type = 'updateButton',
                      on = elc_status[vid].parkmode,
                      button = string.sub(data.button,2)
                  })
              end
          end

          if string.sub(data.button,2) == "r_alley" then
                if getVCFAlleyLightingSettings(elc_status[vid].model).enabled then
                  elc_status[vid].rightAlley = not elc_status[vid].rightAlley

                  if (inVehicle) then
                    SendNUIMessage({
                        type = 'updateButton',
                        on = elc_status[vid].rightAlley,
                        button = string.sub(data.button,2)
                    })
                  end

                  if (elc_status[vid].rightAlley) then
                    for type, light in ipairs(elc_status[vid].lights.front) do
                      if light._modkit == miscNameToID(getVCFAlleyLightingSettings(elc_status[vid].model).miscs.right) then
                        light._alleyLight = true
                      end
                    end

                    for type, light in ipairs(elc_status[vid].lights.rear) do
                      if light._modkit == miscNameToID(getVCFAlleyLightingSettings(elc_status[vid].model).miscs.right) then
                        light._alleyLight = true
                      end
                    end
                  else
                    for type, light in ipairs(elc_status[vid].lights.front) do
                      if light._modkit == miscNameToID(getVCFAlleyLightingSettings(elc_status[vid].model).miscs.right) then
                        light._alleyLight = false
                      end
                    end

                    for type, light in ipairs(elc_status[vid].lights.rear) do
                      if light._modkit == miscNameToID(getVCFAlleyLightingSettings(elc_status[vid].model).miscs.right) then
                        light._alleyLight = false
                      end
                    end
                  end
              end
          end

          if string.sub(data.button,2) == "ta_center" then
              if getVCFUseTrafficAdvisor(elc_status[vid].model) then
                  if elc_status[vid].traftype == "center" then
                    elc_status[vid].trafadv = not elc_status[vid].trafadv
                  else
                    elc_status[vid].trafadv = true
                  end

                  elc_status[vid].traftype = "center"

                  if (inVehicle) then
                      SendNUIMessage({
                          type = 'updateButton',
                          on = elc_status[vid].trafadv,
                          button = string.sub(data.button,2)
                      })
                  end
              
                  if (elc_status[vid].trafadv) then
                      for k,light in pairs(elc_status[vid].lights.traf) do
                          light:IsPatternRunning(true)
                          light:ChangeLightPattern(getTrafLightPattern(light._modkit, elc_status[vid].model, 2))
                      end

                      SendNUIMessage({
                        type = 'updateButton',
                        on = false,
                        button = "ta_right"
                      })

                      SendNUIMessage({
                        type = 'updateButton',
                        on = false,
                        button = "ta_left"
                      })
                  else
                      for k,light in pairs(elc_status[vid].lights.traf) do
                          light:IsPatternRunning(false)
                      end

                      SendNUIMessage({
                        type = 'updateButton',
                        on = elc_status[vid].trafadv,
                        button = "ta_right"
                      })
                      
                      SendNUIMessage({
                        type = 'updateButton',
                        on = elc_status[vid].trafadv,
                        button = "ta_center"
                      })

                      SendNUIMessage({
                        type = 'updateButton',
                        on = elc_status[vid].trafadv,
                        button = "ta_left"
                      })
                  end
              end
          end

          if string.sub(data.button,2) == "ta_left" then
              if getVCFUseTrafficAdvisor(elc_status[vid].model) then
                  if elc_status[vid].traftype == "left" then
                    elc_status[vid].trafadv = not elc_status[vid].trafadv
                  else
                    elc_status[vid].trafadv = true
                  end

                  elc_status[vid].traftype = "left"

                  if (inVehicle) then
                      SendNUIMessage({
                          type = 'updateButton',
                          on = elc_status[vid].trafadv,
                          button = string.sub(data.button,2)
                      })
                  end
              
                  if (elc_status[vid].trafadv) then
                      for k,light in pairs(elc_status[vid].lights.traf) do
                          light:IsPatternRunning(true)
                          light:ChangeLightPattern(getTrafLightPattern(light._modkit, elc_status[vid].model, 1))
                      end

                      SendNUIMessage({
                        type = 'updateButton',
                        on = false,
                        button = "ta_right"
                      })
                      
                      SendNUIMessage({
                        type = 'updateButton',
                        on = false,
                        button = "ta_center"
                      })
                  else
                      for k,light in pairs(elc_status[vid].lights.traf) do
                          light:IsPatternRunning(false)
                      end

                      SendNUIMessage({
                        type = 'updateButton',
                        on = elc_status[vid].trafadv,
                        button = "ta_right"
                      })
                      
                      SendNUIMessage({
                        type = 'updateButton',
                        on = elc_status[vid].trafadv,
                        button = "ta_center"
                      })

                      SendNUIMessage({
                        type = 'updateButton',
                        on = elc_status[vid].trafadv,
                        button = "ta_left"
                      })
                  end
              end
          end

          if string.sub(data.button,2) == "ta_right" then
              if getVCFUseTrafficAdvisor(elc_status[vid].model) then
                  if elc_status[vid].traftype == "right" then
                    elc_status[vid].trafadv = not elc_status[vid].trafadv
                  else
                    elc_status[vid].trafadv = true
                  end

                  elc_status[vid].traftype = "right"

                  if (inVehicle) then
                      SendNUIMessage({
                          type = 'updateButton',
                          on = elc_status[vid].trafadv,
                          button = string.sub(data.button,2)
                      })
                  end
              
                  if (elc_status[vid].trafadv) then
                      for k,light in pairs(elc_status[vid].lights.traf) do
                          light:IsPatternRunning(true)
                          light:ChangeLightPattern(getTrafLightPattern(light._modkit, elc_status[vid].model, 3))
                      end

                      SendNUIMessage({
                        type = 'updateButton',
                        on = false,
                        button = "ta_center"
                      })

                      SendNUIMessage({
                        type = 'updateButton',
                        on = false,
                        button = "ta_left"
                      })
                  else
                      for k,light in pairs(elc_status[vid].lights.traf) do
                          light:IsPatternRunning(false)
                      end

                      SendNUIMessage({
                        type = 'updateButton',
                        on = elc_status[vid].trafadv,
                        button = "ta_right"
                      })
                      
                      SendNUIMessage({
                        type = 'updateButton',
                        on = elc_status[vid].trafadv,
                        button = "ta_center"
                      })

                      SendNUIMessage({
                        type = 'updateButton',
                        on = elc_status[vid].trafadv,
                        button = "ta_left"
                      })
                  end
              end
          end

          if string.sub(data.button,2) == "rear" then
              elc_status[vid].secondary = not elc_status[vid].secondary

              if (elc_status[vid].secondary) then
                  for k,light in pairs(elc_status[vid].lights.rear) do
                      light:IsPatternRunning(true)
                  end
              else
                  for k,light in pairs(elc_status[vid].lights.rear) do
                      light:IsPatternRunning(false)
                  end
              end
          end

          if string.sub(data.button,2) == "front" then
              elc_status[vid].primary = not elc_status[vid].primary

              if (elc_status[vid].primary) then
                  for k,light in pairs(elc_status[vid].lights.front) do
                      light:IsPatternRunning(true)
                  end
              else
                  for k,light in pairs(elc_status[vid].lights.front) do
                      light:IsPatternRunning(false)
                  end
              end
          end
      end
    end
end

RegisterNUICallback('stopfocus', function(data, cb)
    SetNuiFocus(false, false)

    cb('ok')
end)

RegisterNUICallback('buttonpressed', function(data, cb)
    TriggerServerEvent("elc:broadcastButtonChange", _veh, data)

    SetNuiFocus(false, false)

    cb('ok')
end)