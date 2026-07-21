local utils = {}
local debugConfig = require 'config.shared.debug'

---@param message string
---@param type string
function utils.notify(message, type)
    lib.notify({ 
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
---@param icon string
function utils.showTextUI(message, icon)
    lib.showTextUI(message, {
        icon = icon or nil
    })
end

function utils.hideTextUI()
    lib.hideTextUI()
end

---@param message string
function utils.debugPrint(message)
    if not debugConfig.list.prints then return end

    print(('^1[DEBUG]^0 %s'):format(message))
end

---@param action string
---@param data table|string|boolean
function utils.sendNUIMessage(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

---@param config table
---@param onComplete function
---@param onCancel function
function utils.progressBar(config, onComplete, onCancel)
    if lib.progressCircle({
        duration = config.duration,
        label = config.label,
        position = 'bottom',
        useWhileDead = config.useWhileDead,
        canCancel = config.canCancel,
        disable = config.disable or {},
        anim = config.anim or {},
        prop = config.prop or {},
    }) then
        if onComplete then
            onComplete()
        end
    else
        if onCancel then
            onCancel()
        end
    end
end

---@param item string
---@return string | boolean
function utils.getItemIcon(item)
    if not item then return false end

    local path = ('nui://ox_inventory/web/images/%s.png'):format(item)

    return path
end

return utils