function soundcontroller(vehicle, model)
    soundData = {}

    soundData._vehicle = vehicle

    soundData.horn = {}
    soundData.horn.id = nil
    soundData.horn.enabled = false
    soundData.horn.audiobank = (getVehicleConfigData(model).sounds.mainhorn.audiobank == nil and 0 or getVehicleConfigData(model).sounds.mainhorn.audiobank)
    soundData.horn.soundset = (getVehicleConfigData(model).sounds.mainhorn.soundset == nil and 0 or getVehicleConfigData(model).sounds.mainhorn.soundset)
    soundData.horn.audiohash = (getVehicleConfigData(model).sounds.mainhorn.soundset == nil and "SIRENS_AIRHORN" or getVehicleConfigData(model).sounds.mainhorn.audiostring)

    if soundData.horn.soundset ~= 0 then
      RequestScriptAudioBank(soundData.horn.audiobank, false)
    end
    soundData.horn.interrupt =  getVehicleConfigData(model).sounds.mainhorn.interruptssiren

    soundData.sirens = {}
    soundData.curTone = 0
    soundData.lastTone = 0

    soundData.sirens.srntone1 = {}
    soundData.sirens.srntone1.id = nil
    soundData.sirens.srntone1.enabled = false
    soundData.sirens.srntone1.audiobank = (getVehicleConfigData(model).sounds.srntone1.audiobank == nil and 0 or getVehicleConfigData(model).sounds.srntone1.audiobank)
    soundData.sirens.srntone1.soundset = (getVehicleConfigData(model).sounds.srntone1.soundset == nil and 0 or getVehicleConfigData(model).sounds.srntone1.soundset)
    soundData.sirens.srntone1.audiohash = (getVehicleConfigData(model).sounds.srntone1.audiostring == nil and "VEHICLES_HORNS_SIREN_1" or getVehicleConfigData(model).sounds.srntone1.audiostring)
    soundData.sirens.srntone1.allowuse = getVehicleConfigData(model).sounds.srntone1.allowuse

    if soundData.sirens.srntone1.soundset ~= 0 then
      RequestScriptAudioBank(soundData.sirens.srntone1.audiobank, false)
    end

    soundData.sirens.srntone2 = {}
    soundData.sirens.srntone2.id = nil
    soundData.sirens.srntone2.enabled = false
    soundData.sirens.srntone2.audiobank = (getVehicleConfigData(model).sounds.srntone2.audiobank == nil and 0 or getVehicleConfigData(model).sounds.srntone2.audiobank)
    soundData.sirens.srntone2.soundset = (getVehicleConfigData(model).sounds.srntone2.soundset == nil and 0 or getVehicleConfigData(model).sounds.srntone2.soundset)
    soundData.sirens.srntone2.audiohash = (getVehicleConfigData(model).sounds.srntone2.audiostring == nil and "VEHICLES_HORNS_SIREN_2" or getVehicleConfigData(model).sounds.srntone2.audiostring)
    soundData.sirens.srntone2.allowuse = getVehicleConfigData(model).sounds.srntone2.allowuse

    if soundData.sirens.srntone2.soundset ~= 0 then
      RequestScriptAudioBank(soundData.sirens.srntone2.audiobank, false)
    end

    soundData.sirens.srntone3 = {}
    soundData.sirens.srntone3.id = nil
    soundData.sirens.srntone3.enabled = false
    soundData.sirens.srntone3.audiobank = (getVehicleConfigData(model).sounds.srntone3.audiobank == nil and 0 or getVehicleConfigData(model).sounds.srntone3.audiobank)
    soundData.sirens.srntone3.soundset = (getVehicleConfigData(model).sounds.srntone3.soundset == nil and 0 or getVehicleConfigData(model).sounds.srntone3.soundset)
    soundData.sirens.srntone3.audiohash = (getVehicleConfigData(model).sounds.srntone3.audiostring == nil and "VEHICLES_HORNS_SIREN_3" or getVehicleConfigData(model).sounds.srntone3.audiostring)
    soundData.sirens.srntone3.allowuse = getVehicleConfigData(model).sounds.srntone3.allowuse

    if soundData.sirens.srntone3.soundset ~= 0 then
      RequestScriptAudioBank(soundData.sirens.srntone3.audiobank, false)
    end

    function soundData:PlayHorn(toggle)
        if toggle and not self.horn.id ~= nil then
            if self.horn.interrupt and self.lastTone ~= self.curTone then
                self:PlaySiren(0)
            end

            StopSound(self.horn.id)
            ReleaseSoundId(self.horn.id)
            self.horn.id = nil            
            self.horn.enabled = false

            self.horn.id = GetSoundId()
            PlaySoundFromEntity(self.horn.id, self.horn.audiohash, self._vehicle, self.horn.soundset, 0, 0)
            self.horn.enabled = true
        else
            if self.horn.interrupt then
                self:PlaySiren(self.lastTone)
            end

            StopSound(self.horn.id)
            ReleaseSoundId(self.horn.id)
            self.horn.id = nil            
            self.horn.enabled = false
        end
    end

    function soundData:isSirenPlaying()
        local isPlaying = false

        for k,v in pairs(self.sirens) do
            if (v.enabled) then
                isPlaying = true
                siren = v
            end
        end

        return isPlaying, siren

    end

    function soundData:GetCurrentSirenTone()
        return self.curTone
    end

    function soundData:PlaySiren(siren)
        if siren ~= 0 then
            for k,v in pairs(self.sirens) do
                if (v.enabled) then
                    v.enabled = false
                    StopSound(v.id)
                    ReleaseSoundId(v.id)
                    v.id = nil
                end
            end
            if (siren ~= self.curTone) then
              if (siren == 1) then
                  if soundData.sirens.srntone1.allowuse then
                      self.sirens.srntone1.id = GetSoundId()
                      PlaySoundFromEntity(self.sirens.srntone1.id, self.sirens.srntone1.audiohash, self._vehicle, self.sirens.srntone1.soundset, 0, 0)
                      self.sirens.srntone1.enabled = true
                  end
              elseif (siren == 2) then
                  if soundData.sirens.srntone2.allowuse then
                      self.sirens.srntone2.id = GetSoundId()
                      PlaySoundFromEntity(self.sirens.srntone2.id, self.sirens.srntone2.audiohash, self._vehicle, self.sirens.srntone2.soundset, 0, 0)
                      self.sirens.srntone2.enabled = true
                  end
              elseif (siren == 3) then
                  if soundData.sirens.srntone3.allowuse then
                      self.sirens.srntone3.id = GetSoundId()
                      PlaySoundFromEntity(self.sirens.srntone3.id, self.sirens.srntone3.audiohash, self._vehicle, self.sirens.srntone3.soundset, 0, 0)
                      self.sirens.srntone3.enabled = true
                  end
              end
            end

            self.lastTone = self.curTone
            self.curTone = siren
        else
            for k,v in pairs(self.sirens) do
                if (v.enabled) then
                    v.enabled = false
                    StopSound(v.id)
                    ReleaseSoundId(v.id)
                    v.id = nil
                end
            end

            self.lastTone = self.curTone
            self.curTone = 0
        end
    end


    return soundData
end

function clearSirenButtons()

    local buttons = {
        "wail",
        "yelp",
        "aux"
    }

    for k,v in pairs(buttons) do
        SendNUIMessage({
            type = 'updateButton',
            on = false,
            button = v
        })
    end
end

RegisterNetEvent("elc:playHornSound")
AddEventHandler("elc:playHornSound", function(sender, state)
    local player_s = GetPlayerFromServerId(sender)
    local ped_s = GetPlayerPed(player_s)
    if DoesEntityExist(ped_s) and not IsEntityDead(ped_s) then
        if IsPedInAnyVehicle(ped_s, false) then
            vehicle = GetVehiclePedIsUsing(ped_s)
            local vid = NetworkGetNetworkIdFromEntity(vehicle)
            if (NetworkDoesNetworkIdExist(vid)) then
              if (elc_status[vid] ~= nil) then
                  elc_status[vid].soundcontroller:PlayHorn(state)
              end
            end
        end
    end
end)

RegisterNetEvent("elc:playSirenSound")
AddEventHandler("elc:playSirenSound", function(sender, siren)
    local player_s = GetPlayerFromServerId(sender)
    local ped_s = GetPlayerPed(player_s)
    if DoesEntityExist(ped_s) and not IsEntityDead(ped_s) then
        if IsPedInAnyVehicle(ped_s, false) then
            vehicle = GetVehiclePedIsUsing(ped_s)
            local vid = NetworkGetNetworkIdFromEntity(vehicle)
            if (NetworkDoesNetworkIdExist(vid)) then
              if (elc_status[vid] ~= nil) then
                  elc_status[vid].soundcontroller:PlaySiren(siren)
              end
            end
        end
    end
end)