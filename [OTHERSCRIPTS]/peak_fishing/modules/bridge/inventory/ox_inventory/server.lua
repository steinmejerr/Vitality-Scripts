local inventory = {}

---@param playerId number
---@param item string
---@param amount number
---@return boolean
function inventory.removeItem(playerId, item, amount)
    return exports.ox_inventory:RemoveItem(playerId, item, amount)
end

---@param playerId number | string
---@param item string
---@param amount number
---@param metadata table|nil
---@return boolean
function inventory.addItem(playerId, item, amount, metadata)
    return exports.ox_inventory:AddItem(playerId, item, amount, metadata)
end

---@param playerId number
---@param slot number
---@return table|nil
function inventory.getSlot(playerId, slot)
    return exports.ox_inventory:GetSlot(playerId, slot)
end

---@param stashId string | number
---@return table|nil
function inventory.getInventory(stashId)
    return exports.ox_inventory:GetInventory(stashId)
end

---@param playerId number
---@param slot number
---@param metadata table
---@return boolean
function inventory.setMetadata(playerId, slot, metadata)
    return exports.ox_inventory:SetMetadata(playerId, slot, metadata)
end

---@param playerId number
---@param item string
---@param amount number
---@param metadata table|nil
---@return boolean
function inventory.canCarryItem(playerId, item, amount, metadata)
    return exports.ox_inventory:CanCarryItem(playerId, item, amount, metadata)
end

---@param playerId number
---@param weight number
---@return boolean, number
function inventory.canCarryWeight(playerId, weight)
    return exports.ox_inventory:CanCarryWeight(playerId, weight)
end

---@param prefix string
---@param items table
---@param coords vector3
---@return boolean
function inventory.customDrop(prefix, items, coords)
    return exports.ox_inventory:CustomDrop(prefix, items, coords)
end

---@param stashId string
---@param label string
---@param maxWeight number
---@param slots number
---@return boolean
function inventory.registerStash(stashId, label, maxWeight, slots)
    return exports.ox_inventory:RegisterStash(stashId, label, maxWeight, slots)
end

---@param playerId number
---@param type string
---@param data table
---@return boolean
function inventory.forceOpenInventory(playerId, type, data)
    return exports.ox_inventory:forceOpenInventory(playerId, type, data)
end

---@param hookName string
---@param callback function
---@param options table
---@return boolean
function inventory.registerHook(hookName, callback, options)
    return exports.ox_inventory:registerHook(hookName, callback, options)
end

---@param playerId number
---@param item string
---@param metadata table|nil
---@param strict boolean|nil
---@return table|nil
function inventory.getItem(playerId, item, metadata, strict)
    return exports.ox_inventory:GetItem(playerId, item, metadata, strict)
end

---@param playerId number
---@param item string
---@return number
function inventory.getItemCount(playerId, item)
    return exports.ox_inventory:GetItemCount(playerId, item)
end

---@param playerId number
---@param item string
---@return number|nil
function inventory.getSlotIdWithItem(playerId, item)
    return exports.ox_inventory:GetSlotIdWithItem(playerId, item)
end

return inventory

