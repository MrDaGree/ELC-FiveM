function prmllight(vehicle, modkit, color, pattern, offset, rot, side)
    lightData = {}

    lightData._id = NetworkGetNetworkIdFromEntity(vehicle)
    lightData._vehicle = vehicle
    lightData._modkit = modkit
    lightData._state = false
    lightData._patternRunning = false
    lightData._pattern = pattern
    lightData._cruiseLight = false
    lightData._alleyLight = false

    lightData.count = 1
    lightData.flashrate = 0

    lightData.offset = offset
    lightData.side = side

    lightData.red = color[1]
    lightData.green = color[2]
    lightData.blue = color[3]

    lightData.oldred = color[1]
    lightData.oldgreen = color[2]
    lightData.oldblue = color[3]
    
    SetVehicleMod(vehicle, modkit, 0, false)

    if (rot == nil) then
      if lightData.offset > 0 then
        lightData.rotation = 0
      else
        lightData.rotation = 180
      end
    else
      lightData.rotation = rot
    end

    function lightData:RunDebug()
        self.dir = GetEntityForwardVector(self._vehicle)
        local textLabel = GetModTextLabel(self._vehicle, self._modkit, 0)
        local boneIndex = GetEntityBoneIndexByName(self._vehicle, textLabel)
        local lightPos = GetWorldPositionOfEntityBone(self._vehicle, boneIndex)
        local lightRot = GetWorldRotationOfEntityBone(self._vehicle, boneIndex)

        local trueLightPos = 0
        trueLightPos = lightPos + self.dir*self.offset

        DrawMarker(0, trueLightPos.x, trueLightPos.y, lightPos.z+.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.1, 0.1, self.red, self.green, self.blue, 100, false, true, 2, false, false, false, false)
    end

    function lightData:SetState(state)
        if self._state ~= state then
            self._state = state
            if (state) then
                SetVehicleMod(self._vehicle, self._modkit, 1, false)
            else
                SetVehicleMod(self._vehicle, self._modkit, 0, false)
            end
        end
    end

    function lightData:IsPatternRunning(value)
        if (value ~= nil) then
            self._patternRunning = value
            if (not self._patternRunning) then
                self:CleanUp();
                self.count = 1;
                self.flashrate = 0;
            else
                self.flashrate = GetGameTimer()
            end
        else
            return self._patternRunning
        end
    end

    function lightData:CleanUp()
        if (self._state) then
            self:SetState(false)
        end
    end

    function lightData:revertLightColor()
        self.red = self.oldred
        self.green = self.oldgreen
        self.blue = self.oldblue
    end

    function lightData:ChangeLightColor(color)
        self.oldred = self.red
        self.oldgreen = self.green
        self.oldblue = self.blue

        self.red = color[1]
        self.green = color[2]
        self.blue = color[3]
    end
    
    function lightData:GetColorString()
        return "" .. self.red .. "," .. self.green .. "," .. self.blue
    end

    function lightData:DrawEnvLight(model)
      
      self.dir = GetEntityForwardVector(self._vehicle)
        Citizen.CreateThread(function()
            for i=1,lightDensity do
                local textLabel = GetModTextLabel(self._vehicle, self._modkit, 0)
                local boneIndex = GetEntityBoneIndexByName(self._vehicle, textLabel)
                local lightPos = GetWorldPositionOfEntityBone(self._vehicle, boneIndex)
                local lightRot = GetWorldRotationOfEntityBone(self._vehicle, boneIndex)

                if (lightRot ~= vector3(0, 0, 0)) then
                    local trueLightPos = 0
                    trueLightPos = lightPos + self.dir*self.offset

                    local realRot = lightRot + vector3(0.0, 0.0, self.rotation)
                    local _realRot = RotAnglesToVec(realRot)

                    if self.offset > 0 then
                      DrawSpotLightWithShadow(trueLightPos.x, trueLightPos.y, lightPos.z, _realRot.x, _realRot.y, _realRot.z, self.red, self.green, self.blue, envLightDistance, envLightBrightness, 50.3, 100.0, 120.6, self._id + self._modkit + lightDensity)
                    elseif self.offset < 0 then
                      DrawSpotLightWithShadow(trueLightPos.x, trueLightPos.y, lightPos.z, _realRot.x, _realRot.y, _realRot.z, self.red, self.green, self.blue, envLightDistance, envLightBrightness, 50.3, 100.0, 120.6, self._id + self._modkit + lightDensity)
                    end

                    Wait(5)
                end
            end
        end)
    end

    function lightData:ChangeLightPattern(pattern)
        self.count = 1
        self._pattern = pattern
    end

    function lightData:syncLights()
        self.count = 1
    end

    function lightData:DrawCorona()
        self.dir = GetEntityForwardVector(self._vehicle)
        local lightPos = GetWorldPositionOfEntityBone(self._vehicle, GetEntityBoneIndexByName(self._vehicle, GetModTextLabel(self._vehicle, self._modkit, 0)))
        local trueLightPos = 0
        trueLightPos = lightPos + self.dir*-(self.offset/2)

        local ped = PlayerPedId()
        local camRot = GetGameplayCamRelativeHeading()
        local vehRot = GetEntityRotation(self._vehicle)
        local outsideVehCamRot = GetEntityHeading(ped) - vehRot.z + camRot

        if (HasEntityClearLosToEntity(self._vehicle, ped, 17)) then
            if (GetVehiclePedIsIn(ped, false) == self._vehicle) then
                if (self.side == "left") then
                    if (self._alleyLight) then
                        if (-160 <= camRot and -20 >= camRot) then
                            SetDrawOrigin(trueLightPos.x, trueLightPos.y, lightPos.z, 0)
                            DrawSprite("elc", "corona", 0.0, 0.0, 0.035, 0.065, 0.0, 255, 255, 160, 255)
                        end
                    end
                elseif (self.side == "right") then
                    if (self._alleyLight) then
                        if (160 >= camRot and 20 <= camRot) then
                            SetDrawOrigin(trueLightPos.x, trueLightPos.y, lightPos.z, 0)
                            DrawSprite("elc", "corona", 0.0, 0.0, 0.035, 0.065, 0.0, 255, 255, 160, 255)
                        end
                    end
                else

                end
            else
                local dist = GetDistanceBetweenCoords(GetEntityCoords(ped), lightPos, true)
                local size = math.clamp(dist / 500, 0.05, 0.035)
                local alpha = math.clamp(dist * 2, 25, 0)
                if (self.side == "left") then
                    if (self._alleyLight) then
                        if (-160 <= outsideVehCamRot and -20 >= outsideVehCamRot) or (350 >= outsideVehCamRot and 180 <= outsideVehCamRot) then
                            SetDrawOrigin(trueLightPos.x, trueLightPos.y, lightPos.z, 0)
                            DrawSprite("elc", "corona", 0.0, 0.0, size, size + 0.02, 0.0, 255, 255, 160, 255 - alpha)
                        end
                    end
                elseif (self.side == "right") then
                    if (self._alleyLight) then
                        if (175 >= outsideVehCamRot and 20 <= outsideVehCamRot) then
                            SetDrawOrigin(trueLightPos.x, trueLightPos.y, lightPos.z, 0)
                            DrawSprite("elc", "corona", 0.0, 0.0, size, size + 0.02, 0.0, 255, 255, 160, 255 - alpha)
                        end
                    end
                else

                end
            end
        end
    end

    function lightData:CruiseLightTicker(vehicle)
      self.dir = GetEntityForwardVector(self._vehicle)

      self._vehicle = vehicle
      self:SetState(true)
      SetVehicleEngineOn(self._vehicle, true, true, false)

      local lightPos = GetWorldPositionOfEntityBone(self._vehicle, GetEntityBoneIndexByName(self._vehicle, GetModTextLabel(self._vehicle, self._modkit, 0)))
      local lightRot = GetWorldRotationOfEntityBone(self._vehicle, GetEntityBoneIndexByName(self._vehicle, GetModTextLabel(self._vehicle, self._modkit, 0)))

      if (lightRot ~= vector3(0, 0, 0)) then

          if not maximizePerformance then
            local trueLightPos = 0
            trueLightPos = lightPos + self.dir*self.offset

            local realRot = lightRot + vector3(0.0, 0.0, self.rotation)
            local _realRot = RotAnglesToVec(realRot)

            if self.offset > 0 then
              DrawSpotLightWithShadow(trueLightPos.x, trueLightPos.y, lightPos.z, _realRot.x, _realRot.y, _realRot.z, self.red, self.green, self.blue, envLightDistance, envLightBrightness, 50.3, 100.0, 120.6, self._id + self._modkit + lightDensity)
            elseif self.offset < 0 then
              DrawSpotLightWithShadow(trueLightPos.x, trueLightPos.y, lightPos.z, _realRot.x, _realRot.y, _realRot.z, self.red, self.green, self.blue, envLightDistance, envLightBrightness, 50.3, 100.0, 120.6, self._id + self._modkit + lightDensity)
            end

            if self.flashrate == 0 then 
                self.flashrate = GetGameTimer()
            end
          end

          if (GetGameTimer() - self.flashrate) / flashBPM > 0.2 then
              if self:IsPatternRunning() then
                  self.count = self.count + 1

                  if self.count >= string.len(self._pattern) then
                      self.count = 1
                  end
              end

              self.flashrate = GetGameTimer()
          end
      end
    end

    function lightData:AlleyLightTicker(vehicle)
      local lightPos = GetWorldPositionOfEntityBone(self._vehicle, GetEntityBoneIndexByName(self._vehicle, GetModTextLabel(self._vehicle, self._modkit, 0)))
      local lightRot = GetWorldRotationOfEntityBone(self._vehicle, GetEntityBoneIndexByName(self._vehicle, GetModTextLabel(self._vehicle, self._modkit, 0)))

      if (lightRot ~= vector3(0, 0, 0)) then

          self:DrawCorona()

          if (self.side == "left") then
              local leftLightRot = lightRot + vector3(-15.0, 0.0, 90.0)
              local _leftLightRot = RotAnglesToVec(leftLightRot)
              local leftPos = GetOffsetFromEntityInWorldCoords(self._vehicle, -0.7, -0.35, 0)
              DrawSpotLightWithShadow(leftPos.x, leftPos.y, lightPos.z, _leftLightRot.x, _leftLightRot.y, _leftLightRot.z, 250, 250, 160, alleyLightDistance, alleyLightBrightness, 25.0, 26.5, 120.0, self._id + 2)
          end

          if (self.side == "right") then
              local rightLightRot = lightRot + vector3(-15.0, 0.0, -90.0)
              local _rightLightRot = RotAnglesToVec(rightLightRot)
              local rightPos = GetOffsetFromEntityInWorldCoords(self._vehicle, 0.7, -0.35, 0)
              DrawSpotLightWithShadow(rightPos.x, rightPos.y, lightPos.z, _rightLightRot.x, _rightLightRot.y, _rightLightRot.z, 250, 250, 160, alleyLightDistance, alleyLightBrightness, 25.0, 26.5, 120.0, self._id + 1)
          end

          ClearDrawOrigin()
      end
    end

    function lightData:LightTicker(vehicle, model)
        if (not self._cruiseLight and self:IsPatternRunning()) then
            self._vehicle = vehicle
            SetVehicleEngineOn(self._vehicle, true, true, false)
            gameTimer = GetGameTimer()
            if (gameTimer - self.flashrate) / flashBPM > 0.2 then
                if not self:IsPatternRunning() then
                    self:CleanUp()
                    return
                end
                if self.count <= string.len(self._pattern) then
                    if (string.sub(self._pattern, self.count, self.count) == '1') then
                        if not maximizePerformance then
                            self:DrawEnvLight(model)
                        end
                        self:SetState(true)
                        if not self:IsPatternRunning() then
                            self:CleanUp()
                            return
                        end
                    else
                        self:SetState(false)
                        if not self:IsPatternRunning() then
                            self:CleanUp()
                            return
                        end
                    end

                    self.count = self.count + 1

                    if self.count >= string.len(self._pattern) then
                        self.count = 1
                    end
                end

                self.flashrate = gameTimer
            end
        else
            self:CleanUp()
        end
    end

    return lightData
end

function taLight(vehicle, modkit, color, pattern, offset)
    lightData = {}

    lightData._id = NetworkGetNetworkIdFromEntity(vehicle)
    lightData._vehicle = vehicle
    lightData._modkit = modkit
    lightData._state = false
    lightData._patternRunning = false
    lightData._pattern = pattern

    lightData.offset = offset

    lightData.count = 1
    lightData.flashrate = 0

    lightData.red = color[1]
    lightData.green = color[2]
    lightData.blue = color[3]

    lightData.oldred = color[1]
    lightData.oldgreen = color[2]
    lightData.oldblue = color[3]
    
    SetVehicleMod(vehicle, modkit, 0, false)

    function lightData:RunDebug()
        self.dir = GetEntityForwardVector(self._vehicle)
        local textLabel = GetModTextLabel(self._vehicle, self._modkit, 0)
        local boneIndex = GetEntityBoneIndexByName(self._vehicle, textLabel)
        local lightPos = GetWorldPositionOfEntityBone(self._vehicle, boneIndex)
        local lightRot = GetWorldRotationOfEntityBone(self._vehicle, boneIndex)
        local rearLightPos = nil

        local trueLightPos = 0
        trueLightPos = lightPos + self.dir*self.offset

        DrawMarker(0, trueLightPos.x, trueLightPos.y, lightPos.z+.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.1, 0.1, 255, 150, 150, 100, false, true, 2, false, false, false, false)
    end


    function lightData:SetState(state)
        if self._state ~= state then
            
            self._state = state
            if (state) then
                SetVehicleMod(self._vehicle, self._modkit, 1, false)
            else
                SetVehicleMod(self._vehicle, self._modkit, 0, false)
            end

            if (isInSpecificELCVehicleTA(self._vehicle)) then
                local lightRot = GetWorldRotationOfEntityBone(self._vehicle, GetEntityBoneIndexByName(self._vehicle, GetModTextLabel(self._vehicle, self._modkit, 0)))

                if (lightRot ~= vector3(0, 0, 0)) then
                    SendNUIMessage({
                        type = 'updateLight',
                        on = state,
                        light = self._modkit,
                        lightColor = self:GetColorString()
                    })
                end
            end
        end
    end

    function lightData:IsPatternRunning(value)
        if (value ~= nil) then
            self._patternRunning = value
            if (not self._patternRunning) then
                self:CleanUp();
                self.count = 1;
            else
                self.flashrate = GetGameTimer()
            end
        else
            return self._patternRunning
        end
    end

    function lightData:CleanUp()
        if (self._state) then
            self:SetState(false)
        end
    end

    function lightData:revertLightColor()
        self.red = self.oldred
        self.green = self.oldgreen
        self.blue = self.oldblue
    end

    function lightData:ChangeLightColor(color)
        self.oldred = self.red
        self.oldgreen = self.green
        self.oldblue = self.blue

        self.red = color[1]
        self.green = color[2]
        self.blue = color[3]
    end
    
    function lightData:GetColorString()
        return "" .. self.red .. "," .. self.green .. "," .. self.blue
    end

    function lightData:DrawEnvLight()
        Citizen.CreateThread(function()
            for i=1,lightDensity do
                local textLabel = GetModTextLabel(self._vehicle, self._modkit, 0)
                local boneIndex = GetEntityBoneIndexByName(self._vehicle, textLabel)
                local lightPos = GetWorldPositionOfEntityBone(self._vehicle, boneIndex)
                local lightRot = GetWorldRotationOfEntityBone(self._vehicle, boneIndex)

                if (lightRot ~= vector3(0, 0, 0)) then
                    local trueLightPos = 0
                    trueLightPos = lightPos + self.dir*self.offset

                    DrawSpotLightWithShadow(trueLightPos.x, trueLightPos.y, lightPos.z, self.dir.x * -1, self.dir.y * -1, self.dir.z, self.red, self.green, self.blue, envTALightDistance, envLightBrightness, 15.3, 100.0, 120.0, self._id + self._modkit + lightDensity)
                    Wait(10)
                end
            end
        end)
    end

    function lightData:ChangeLightPattern(pattern)
        self.count = 1
        self._pattern = pattern
    end

    function lightData:syncLights()
        self.count = 1
    end

    function lightData:LightTicker(vehicle)
        if (self:IsPatternRunning()) then
            self._vehicle = vehicle
            self.dir = GetEntityForwardVector(self._vehicle)
            SetVehicleEngineOn(self._vehicle, true, true, false)
            gameTimer = GetGameTimer()
            if (gameTimer - self.flashrate) / flashBPM > 0.2 then
                if not self:IsPatternRunning() then
                    self:CleanUp()
                    return
                end
                if self.count <= string.len(self._pattern) then
                    if (string.sub(self._pattern, self.count, self.count) == '1') then
                        if not maximizePerformance then
                            self:DrawEnvLight()
                        end
                        self:SetState(true)
                        if not self:IsPatternRunning() then
                            self:CleanUp()
                            return
                        end
                    else
                        self:SetState(false)
                        if not self:IsPatternRunning() then
                            self:CleanUp()
                            return
                        end
                    end

                    self.count = self.count + 1

                    if self.count >= string.len(self._pattern) then
                        self.count = 1
                    end
                end

                self.flashrate = gameTimer
            end
        else
            self:CleanUp()
        end
    end

    return lightData
end

function steadyBurnLight(vehicle, modkit)
    lightData = {}
    
    lightData._vehicle = vehicle
    lightData._modkit = modkit
    lightData._state = false
    
    SetVehicleMod(vehicle, modkit, 0, false)

    function lightData:SetState(state)
        if self._state ~= state then
            
            self._state = state
            self._state = state
            if (state) then
                SetVehicleMod(self._vehicle, self._modkit, 1, false)
            else
                SetVehicleMod(self._vehicle, self._modkit, 0, false)
            end
        end
    end

    function lightData:CleanUp()
        if (self._state) then
            self:SetState(false)
        end
    end

    return lightData
end