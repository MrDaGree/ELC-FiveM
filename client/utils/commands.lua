RegisterCommand("elc", function(source, args, raw)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsUsing(ped)
    local isELC, model = isVehicleELC(GetVehiclePedIsIn(PlayerPedId(), false))

    if (isELC and GetPedInVehicleSeat(veh, -1) == ped) then
      if (NetworkDoesNetworkIdExist(vid)) then
          local vid = NetworkGetNetworkIdFromEntity(veh)
          if #args < 1 then
              ShowNotification("~w~Available Commands")
              ShowNotification("~b~elc toggleautosiren\n~b~elc lap/laptop\n~b~elc color ~r~bb/rb/br/rr/rw/ww/wr/amber\n~b~elc changedist ~r~prml secl traf")
              ShowNotification("~b~Blue = command.\n~r~Red = required.")
          else

              local cmd = string.lower(table.remove(args, 1))

              if (cmd == "color") then
                  colorChangeLogic(args, vid)
              elseif (cmd == "max") then
                maximizePerformance = not maximizePerformance
                print(maximizePerformance)
              elseif(cmd =='lap')or(cmd =='laptop')then
                  if(lapscreen==nil)then
                      lapscreen=false
                  end
                  lapscreen=not lapscreen
                  if(lapscreen)then
                      AddReplaceTexture(model,'ptbcf19','elc','ptboff')
                  elseif(not lapscreen)then
                      RemoveReplaceTexture(model,'ptbcf19')
                  end
                  ShowNotification('Laptop screen set to %s for %s',lapscreen,model)
              elseif (cmd == "changedist") then
                  local prml = tonumber(args[1])
                  local secl = tonumber(args[2])
                  local traf = tonumber(args[3])

                  if (prml == nil or secl == nil or traf == nil) then
                      ShowNotification("~r~Please enter a valid number.")
                      return
                  end

                  prmlLoadDist = prml
                  seclLoadDist = secl
                  trafLoadDist = traf

                  ShowNotification("~w~Primary Dist: ~b~" .. prml .. "\n~w~Secondary Dist: ~b~" .. secl .. "\n~w~Trafic Adv. Dist: ~b~" .. traf)
              elseif (cmd == "help") then
                  ShowNotification("~w~Available Commands")
                  ShowNotification("~b~elc toggleautosiren\n~b~elc lap/laptop\n~b~elc color ~r~bb/rb/br/rr/rw/ww/wr/amber\n~b~elc changedist ~r~prml secl traf")
                  ShowNotification("~b~Blue = command.\n~r~Red = required.")
              else
                  ShowNotification("~r~Please enter a valid command.")
              end
          end
      else
          ShowNotification("~r~You must be in a ELC vehicle.")
      end
    end
end)


RegisterNetEvent("elc:updateVehicleColor")
AddEventHandler("elc:updateVehicleColor", function(color, vid)
    if elc_status[vid] ~= nil then
        local veh = NetworkGetEntityFromNetworkId(vid)

        if (color == "bb") then
            local prml, secl = GetVehicleColours(veh)
            SetVehicleColours(veh, prml, 73)
            SetVehicleDashboardColour(veh, 88)
            SetVehicleInteriorColour(veh, 73)

            for type,light in pairs(elc_status[vid].lights.front) do
                light:ChangeLightColor(lightColorToTable("blue"))
            end

            for type,light in pairs(elc_status[vid].lights.rear) do
                light:ChangeLightColor(lightColorToTable("blue"))
            end
            
        elseif (color == "rb") then
            local prml, secl = GetVehicleColours(veh)
            SetVehicleColours(veh, prml, 150)
            SetVehicleDashboardColour(veh, 88)
            SetVehicleInteriorColour(veh, 73)

            for type,light in pairs(elc_status[vid].lights.front) do
                if (light.side == "left") then
                    light:ChangeLightColor(lightColorToTable("red"))
                elseif (light.side == "right") then
                    light:ChangeLightColor(lightColorToTable("blue"))
                end
            end

            for type,light in pairs(elc_status[vid].lights.rear) do
                if (light.side == "left") then
                    light:ChangeLightColor(lightColorToTable("red"))
                elseif (light.side == "right") then
                    light:ChangeLightColor(lightColorToTable("blue"))
                end
            end
        elseif (color == "rr") then
            local prml, secl = GetVehicleColours(veh)
            SetVehicleColours(veh, prml, 150)
            SetVehicleDashboardColour(veh, 88)
            SetVehicleInteriorColour(veh, 150)

            for type,light in pairs(elc_status[vid].lights.front) do
                if (light.side == "left") then
                    light:ChangeLightColor(lightColorToTable("red"))
                elseif (light.side == "right") then
                    light:ChangeLightColor(lightColorToTable("red"))
                end
            end

            for type,light in pairs(elc_status[vid].lights.rear) do
                if (light.side == "left") then
                    light:ChangeLightColor(lightColorToTable("red"))
                elseif (light.side == "right") then
                    light:ChangeLightColor(lightColorToTable("red"))
                end
            end

        elseif (color == "br") then
            local prml, secl = GetVehicleColours(veh)
            SetVehicleColours(veh, prml, 73)
            SetVehicleDashboardColour(veh, 88)
            SetVehicleInteriorColour(veh, 150)

            for type,light in pairs(elc_status[vid].lights.front) do
                if (light.side == "left") then
                    light:ChangeLightColor(lightColorToTable("blue"))
                elseif (light.side == "right") then
                    light:ChangeLightColor(lightColorToTable("red"))
                end
            end

            for type,light in pairs(elc_status[vid].lights.rear) do
                if (light.side == "left") then
                    light:ChangeLightColor(lightColorToTable("blue"))
                elseif (light.side == "right") then
                    light:ChangeLightColor(lightColorToTable("red"))
                end
            end
        elseif (color == "ww") then
            local prml, secl = GetVehicleColours(veh)
            SetVehicleColours(veh, prml, 112)
            SetVehicleDashboardColour(veh, 88)
            SetVehicleInteriorColour(veh, 111)

            for type,light in pairs(elc_status[vid].lights.front) do
                if (light.side == "left") then
                    light:ChangeLightColor(lightColorToTable("white"))
                elseif (light.side == "right") then
                    light:ChangeLightColor(lightColorToTable("white"))
                end
            end

            for type,light in pairs(elc_status[vid].lights.rear) do
                if (light.side == "left") then
                    light:ChangeLightColor(lightColorToTable("white"))
                elseif (light.side == "right") then
                    light:ChangeLightColor(lightColorToTable("white"))
                end
            end
        elseif (color == "rw") then
            local prml, secl = GetVehicleColours(veh)
            SetVehicleColours(veh, prml, 150)
            SetVehicleDashboardColour(veh, 88)
            SetVehicleInteriorColour(veh, 111)

            for type,light in pairs(elc_status[vid].lights.front) do
                if (light.side == "left") then
                    light:ChangeLightColor(lightColorToTable("red"))
                elseif (light.side == "right") then
                    light:ChangeLightColor(lightColorToTable("white"))
                end
            end

            for type,light in pairs(elc_status[vid].lights.rear) do
                if (light.side == "left") then
                    light:ChangeLightColor(lightColorToTable("red"))
                elseif (light.side == "right") then
                    light:ChangeLightColor(lightColorToTable("white"))
                end
            end
        elseif (color == "wr") then
            local prml, secl = GetVehicleColours(veh)
            SetVehicleColours(veh, prml, 111)
            SetVehicleDashboardColour(veh, 88)
            SetVehicleInteriorColour(veh, 150)

            for type,light in pairs(elc_status[vid].lights.front) do
                if (light.side == "left") then
                    light:ChangeLightColor(lightColorToTable("white"))
                elseif (light.side == "right") then
                    light:ChangeLightColor(lightColorToTable("red"))
                end
            end

            for type,light in pairs(elc_status[vid].lights.rear) do
                if (light.side == "left") then
                    light:ChangeLightColor(lightColorToTable("white"))
                elseif (light.side == "right") then
                    light:ChangeLightColor(lightColorToTable("red"))
                end
            end
        elseif (color == "amber") then
            local prml, secl = GetVehicleColours(veh)
            SetVehicleColours(veh, prml, 88)
            SetVehicleDashboardColour(veh, 88)
            SetVehicleInteriorColour(veh, 88)

            for type,light in pairs(elc_status[vid].lights.front) do
                light:ChangeLightColor(lightColorToTable("amber"))
            end

            for type,light in pairs(elc_status[vid].lights.rear) do
                light:ChangeLightColor(lightColorToTable("amber"))
            end
        end

        elc_status[vid].color = color
    end
end)


function colorChangeLogic(args, vid)
    local color = string.lower(args[1])

    if (color == "bb") then
        ShowNotification("~w~ELC color changed to ~b~blue ~w~& ~b~blue")

        TriggerServerEvent("elc:broadcastColorChange", color, vid)
    elseif (color == "rb") then
        ShowNotification("~w~ELC color changed to ~r~red ~w~& ~b~blue")

        TriggerServerEvent("elc:broadcastColorChange", color, vid)
    elseif (color == "rr") then
        ShowNotification("~w~ELC color changed to ~r~red ~w~& ~r~red")

        TriggerServerEvent("elc:broadcastColorChange", color, vid)
    elseif (color == "br") then
        ShowNotification("~w~ELC color changed to ~b~blue ~w~& ~r~red")

        TriggerServerEvent("elc:broadcastColorChange", color, vid)
    elseif (color == "rw") then
        ShowNotification("~w~ELC color changed to ~r~red ~p~& ~w~white")

        TriggerServerEvent("elc:broadcastColorChange", color, vid)
    elseif (color == "ww") then
        ShowNotification("~w~ELC color changed to ~w~white ~p~& ~w~white")

        TriggerServerEvent("elc:broadcastColorChange", color, vid)
    elseif (color == "wr") then
        ShowNotification("~w~ELC color changed to ~w~white ~p~& ~r~red")

        TriggerServerEvent("elc:broadcastColorChange", color, vid)
    elseif (color == "amber") then
        ShowNotification("~w~ELC color changed to ~r~amber")

        TriggerServerEvent("elc:broadcastColorChange", color, vid)
    else
        ShowNotification("~r~Invalid color input, try again")
    end
end