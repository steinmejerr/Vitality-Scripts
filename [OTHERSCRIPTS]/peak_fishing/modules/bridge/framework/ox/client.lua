local Ox = require '@ox_core.lib.init'
local bridge = {}
local player = Ox.GetPlayer()

AddEventHandler('ox:playerLoaded', function()
    OnPlayerLoaded()
end)

AddEventHandler('ox:playerLogout', function()
    OnPlayerUnload()
end)

---@return boolean
function bridge.hasPlayerLoaded()
    return player.charId ~= nil
end

return bridge