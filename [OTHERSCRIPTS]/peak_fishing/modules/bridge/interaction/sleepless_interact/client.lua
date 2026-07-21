if GetResourceState('sleepless_interact') ~= 'started' then return end

local interaction = {}

---@param entity number
---@param data table
function interaction.addLocalEntity(entity, data)
    exports.sleepless_interact:addLocalEntity(entity, {
        label = data.label,
        name = data.id,
        onSelect = data.onSelect,
        canInteract = data.canInteract,
        distance = data.distance,
        icon = data.icon,
    })
end

---@param entity number
---@param id string
function interaction.removeLocalEntity(entity, id)
    exports.sleepless_interact:removeLocalEntity(entity, id)
end

return interaction 