if GetResourceState('interact') ~= 'started' then return end

local interaction = {}

---@param entity number
---@param data table
function interaction.addLocalEntity(entity, data)
    exports.interact:AddLocalEntityInteraction({
        entity = entity,
        name = data.name,
        id = data.id,
        distance = data.distance,
        interactDst = data.interactDst,
        ignoreLos = data.ignoreLos,
        options = {
            {
                label = data.label,
                action = data.onSelect
            }
        }
    })
end

---@param entity number
---@param id string
function interaction.removeLocalEntity(entity, id)
    exports.interact:RemoveLocalEntityInteraction(entity, id)
end

return interaction 