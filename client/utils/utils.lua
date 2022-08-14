local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
        enum.destructor(enum.handle)
        end
        enum.destructor = nil
        enum.handle = nil
    end
}
  
local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
        disposeFunc(iter)
        return
        end
        
        local enum = {handle = iter, destructor = disposeFunc}
        setmetatable(enum, entityEnumerator)
        
        local next = true
        repeat
        coroutine.yield(id)
        next, id = moveFunc(iter)
        until not next
        
        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end

function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end
 
function colorToTable(color)
    local t = {}

    if (color == "red") then
        t[1] = 255
        t[2] = 60
        t[3] = 60
    elseif (color == "blue") then
        t[1] = 60
        t[2] = 60
        t[3] = 255
    elseif (color == "white") then
        t[1] = 244
        t[2] = 245
        t[3] = 244
    elseif (color == "amber") then
        t[1] = 250
        t[2] = 185
        t[3] = 0
    end

    return t
end

function lightColorToTable(color)
    local t = {}

    if (color == "red") then
        t[1] = 255
        t[2] = 0
        t[3] = 0
    elseif (color == "blue") then
        t[1] = 0
        t[2] = 80
        t[3] = 255
    elseif (color == "white") then
        t[1] = 255
        t[2] = 255
        t[3] = 255
    elseif (color == "amber") then
        t[1] = 250
        t[2] = 185
        t[3] = 0
    end

    return t
end

function ShowNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function playSoundFile(fname, vol)
    if vol == nil then
        vol = 1.0
    end
    
    SendNUIMessage({
        type = "sound", 
        sound = fname, 
        volume = vol
    }) -- 0.04
end

function math.clamp(num, max, min)
    if (num >= max) then
        num = max
    elseif (num <= min) then
        num = min
    end

    return num
end

function RotAnglesToVec(rot) -- input vector3

    local z = math.rad(rot.z)

    local x = math.rad(rot.x)

    local num = math.abs(math.cos(x))

    return vector3(-math.sin(z)*num, math.cos(z)*num, math.sin(x))

end

function miscNameToID(miscName)
  miscNames = {
    ["misc_a"] = 0,
    ["misc_b"] = 1,
    ["misc_c"] = 2,
    ["misc_d"] = 25,
    ["misc_e"] = 27,
    ["misc_f"] = 3,
    ["misc_g"] = 5,
    ["misc_h"] = 6,
    ["misc_i"] = 7,
    ["misc_j"] = 8,
    ["misc_k"] = 9,
    ["misc_l"] = 10,
    ["misc_m"] = 26,
    ["misc_n"] = 37,
    ["misc_o"] = 33,
    ["misc_p"] = 28,
    ["misc_q"] = 29,
    ["misc_r"] = 30,
    ["misc_s"] = 31,
    ["misc_t"] = 32,
    ["misc_u"] = 34,
    ["misc_v"] = 35,
    ["misc_w"] = 36,
    ["misc_x"] = 43,
    ["misc_y"] = 39,
    ["misc_z"] = 40,
    ["misc_1"] = 41,
    ["misc_2"] = 42
  }

  return miscNames[miscName]
end

function IDToMiscName(modkitID)
  miscNames = {
    [0] = "misc_a",
    [1] = "misc_b",
    [2] = "misc_c",
    [25] = "misc_d",
    [27] = "misc_e",
    [3] = "misc_f",
    [5] = "misc_g",
    [6] = "misc_h",
    [7] = "misc_i",
    [8] = "misc_j",
    [9] = "misc_k",
    [10] = "misc_l",
    [26] = "misc_m",
    [37] = "misc_n",
    [33] = "misc_o",
    [28] = "misc_p",
    [29] = "misc_q",
    [30] = "misc_r",
    [31] = "misc_s",
    [32] = "misc_t",
    [34] = "misc_u",
    [35] = "misc_v",
    [36] = "misc_w",
    [43] = "misc_x",
    [39] = "misc_y",
    [40] = "misc_z",
    [41] = "misc_1",
    [42] = "misc_2"
  }

  return miscNames[modkitID]
end

function _drawTxt(text, r, g, b, a, x, y, w, h, c, f)
    SetTextColour(r, g, b, a)
    SetTextFont(f)
    SetTextScale(w, h)
    SetTextWrap(0.0, 1.0)
    SetTextCentre(c)
    SetTextDropshadow(0, 0, 0, 0, 0)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function startMessage(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    SetNotificationMessage("ELC", "ctd", false, 4, "~b~Emergency Vehicle Control", "~g~Version v2022.05.4")
    DrawNotification(false, true)
end