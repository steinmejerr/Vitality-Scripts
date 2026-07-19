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

local notifySoundEnabled = GetResourceKvpInt('ox_lib:notifySound') ~= 0
local settingsOpen = false

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

local function closeNotifySettings()
    if not settingsOpen then return end

    settingsOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'vitalityNotifySettingsClose' })
end

local function openNotifySettings()
    if settingsOpen then return end

    settingsOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'vitalityNotifySettingsOpen',
        soundEnabled = notifySoundEnabled
    })
end

RegisterCommand('notify-settings', openNotifySettings, false)

RegisterNUICallback('vitalityNotifySettingsSave', function(data, cb)
    notifySoundEnabled = data and data.soundEnabled == true
    SetResourceKvpInt('ox_lib:notifySound', notifySoundEnabled and 1 or 0)
    SetResourceKvp('ox_lib:notifySoundSet', '1')

    closeNotifySettings()

    lib.notify({
        title = 'Indstillinger gemt',
        description = notifySoundEnabled and 'Notify-lyd er slået til.' or 'Notify-lyd er slået fra.',
        type = 'success',
        duration = 2500,
        sound = notifySoundEnabled and defaultNotifySound or nil
    })

    cb({ success = true })
end)

RegisterNUICallback('vitalityNotifySettingsClose', function(_, cb)
    closeNotifySettings()
    cb({ success = true })
end)

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
