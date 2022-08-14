  
function debugPrint(msg, inLoop)
    local prefix = IsDuplicityVersion() and '(server)' or '(client)'
    if printDebugInformation then
        print(prefix .. ' ELC-FiveM: ' .. msg)
        if inLoop then
            Citizen.Wait(500)
        end
    end
end