local utils = {}
local debugConfig = require 'config.shared.debug'

---@param playerId integer
---@param message string
---@param type string
function utils.notify(playerId, message, type)
    lib.notify(playerId, { 
        position = 'top',
        title = 'Fishing',
        description = message, 
        style = {
            backgroundColor = '#141517',
            color = '#C1C2C5',
            ['.description'] = {
              color = '#909296'
            }
        },
        type = type 
    })
end

---@param message string
function utils.debugPrint(message)
    if not debugConfig.list.prints then return end

    print(('^1[DEBUG]^0 %s'):format(message))
end

---@param playerId integer
---@param location vector3
---@param maxDistance number
---@return boolean
function utils.checkDistance(playerId, location, maxDistance)
    if not (type(location) == 'vector3' or type(location) == 'vector4') then
        return false
    end

    local locationCoords = vec3(location.x, location.y, location.z)
    local ped = GetPlayerPed(playerId)
    local playerPos = GetEntityCoords(ped)

    local distance = #(playerPos - locationCoords)
    return distance < maxDistance
end

---@param playerId integer
function utils.handleExploit(playerId)
    -- If this is triggered, 90% of the time the player is cheating or doing something weird. Take precautions and investigate the player.

    ---@diagnostic disable-next-line: param-type-mismatch
    DropPlayer(playerId, 'Exploiting the server')
    utils.logPlayer(playerId, 'Exploiting the server')
end

---@param playerId integer
---@return integer
function utils.getCurrency(playerId)
    return exports.ox_inventory:GetItemCount(playerId, 'money')
end

---@param playerId integer
---@param amount number
---@return boolean
function utils.removeCurrency(playerId, amount)
    return exports.ox_inventory:RemoveItem(playerId, 'money', amount)
end

---@param playerId integer
---@param amount number
---@return boolean
function utils.addCurrency(playerId, amount)
    return exports.ox_inventory:AddItem(playerId, 'money', amount)
end

return utils