if GetResourceState('ox_target') ~= 'started' then return end

local interaction = {}

---@param entity number
---@param data table
function interaction.addLocalEntity(entity, data)
    exports.ox_target:addLocalEntity(entity, {
        name = data.name,
        label = data.label,
        icon = data.icon,
        debug = data.debug,
        distance = data.distance,
        onSelect = data.onSelect
    })
end

---@param entity number
---@param id string
function interaction.removeLocalEntity(entity, id)
    exports.ox_target:removeLocalEntity(entity, id)
end

return interaction 