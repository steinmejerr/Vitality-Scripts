local bridge = {}
local playerLoaded = false

RegisterNetEvent('ND:characterUnloaded', function()
    playerLoaded = false

    OnPlayerUnload()
end)

RegisterNetEvent('ND:characterLoaded', function()
    playerLoaded = true

    OnPlayerLoaded()
end)

---@return boolean
function bridge.hasPlayerLoaded()
    return playerLoaded
end

return bridge