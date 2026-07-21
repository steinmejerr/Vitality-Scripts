local bridge = {}

---@param source integer
---@return table
function bridge.getPlayer(source)
    return exports.qbx_core:GetPlayer(source)
end

---@param identifier string
---@return integer | false
function bridge.getSourceFromIdentifier(identifier)
    local player = exports.qbx_core:GetPlayerByCitizenId(identifier)

    return player and player.PlayerData.source or false
end

---@param player table
---@return string
function bridge.getPlayerIdentifier(player)
    return player.PlayerData.citizenid
end

---@param player table
---@return string
function bridge.getPlayerName(player)
    return ('%s %s'):format(player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname)
end

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local source = source
    
    OnPlayerLoaded(source)
end)

return bridge