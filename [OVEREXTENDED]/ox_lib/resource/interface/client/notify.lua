--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@alias NotificationPosition 'top' | 'top-right' | 'top-left' | 'bottom' | 'bottom-right' | 'bottom-left' | 'center-right' | 'center-left'
---@alias NotificationType 'info' | 'warning' | 'success' | 'error'
---@alias IconAnimationType 'spin' | 'spinPulse' | 'spinReverse' | 'pulse' | 'beat' | 'fade' | 'beatFade' | 'bounce' | 'shake'

---@class NotifyProps
---@field id? string
---@field title? string
---@field description? string
---@field duration? number
---@field showDuration? boolean
---@field position? NotificationPosition
---@field type? NotificationType
---@field style? { [string]: any }
---@field icon? string | { [1]: IconProp, [2]: string }
---@field iconAnimation? IconAnimationType
---@field iconColor? string
---@field alignIcon? 'top' | 'center'
---@field sound? { bank?: string, set: string, name: string }

local settings = require 'resource.settings'

local notifySoundEnabled = GetResourceKvpInt('ox_lib:notifySound') ~= 0

-- Sound is enabled by default until the player explicitly disables it.
if GetResourceKvpString('ox_lib:notifySoundSet') == nil then
    notifySoundEnabled = true
    SetResourceKvpInt('ox_lib:notifySound', 1)
    SetResourceKvp('ox_lib:notifySoundSet', '1')
end

local defaultNotifySound = {
    name = 'SELECT',
    set = 'HUD_FRONTEND_DEFAULT_SOUNDSET'
}

local function openNotifySettings()
    lib.registerContext({
        id = 'ox_lib_notify_settings',
        title = 'Notifikationer',
        options = {
            {
                title = 'Notify-lyd',
                description = notifySoundEnabled and 'Lyden er slået til' or 'Lyden er slået fra',
                icon = notifySoundEnabled and 'volume-high' or 'volume-xmark',
                iconColor = notifySoundEnabled and '#36e374' or '#f05a5a',
                onSelect = function()
                    notifySoundEnabled = not notifySoundEnabled
                    SetResourceKvpInt('ox_lib:notifySound', notifySoundEnabled and 1 or 0)

                    lib.notify({
                        title = 'Notify-lyd',
                        description = notifySoundEnabled and 'Lyden er nu slået til' or 'Lyden er nu slået fra',
                        type = notifySoundEnabled and 'success' or 'info',
                        duration = 2500,
                        sound = notifySoundEnabled and defaultNotifySound or nil
                    })

                    SetTimeout(100, openNotifySettings)
                end
            }
        }
    })

    lib.showContext('ox_lib_notify_settings')
end

RegisterCommand('notify-settings', openNotifySettings, false)

---`client`
---@param data NotifyProps
---@diagnostic disable-next-line: duplicate-set-field
function lib.notify(data)
    local sound = notifySoundEnabled and (data.sound or defaultNotifySound)
    data.sound = nil
    data.position = 'top-right'

    SendNUIMessage({
        action = 'vitalityNotify',
        data = data
    })

    if not sound then return end

    if sound.bank then lib.requestAudioBank(sound.bank) end

    local soundId = GetSoundId()
    PlaySoundFrontend(soundId, sound.name, sound.set, true)
    ReleaseSoundId(soundId)

    if sound.bank then ReleaseNamedScriptAudioBank(sound.bank) end
end

---@class DefaultNotifyProps
---@field title? string
---@field description? string
---@field duration? number
---@field position? NotificationPosition
---@field status? 'info' | 'warning' | 'success' | 'error'
---@field id? number

---@param data DefaultNotifyProps
function lib.defaultNotify(data)
    -- Backwards compat for v3
    data.type = data.status
    if data.type == 'inform' then data.type = 'info' end
    return lib.notify(data --[[@as NotifyProps]])
end

RegisterNetEvent('ox_lib:notify', lib.notify)
RegisterNetEvent('ox_lib:defaultNotify', lib.defaultNotify)
