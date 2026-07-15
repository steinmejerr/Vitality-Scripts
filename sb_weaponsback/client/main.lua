local attachedObjects = {}
local syncedWeapons = {}
local lastOwnWeapons = {}
local oxInventoryAvailable = false

local function debugPrint(...)
    if Config.Debug then
        print('[sb_weaponsback]', ...)
    end
end

local function requestModel(model)
    if HasModelLoaded(model) then
        return true
    end

    RequestModel(model)
    local timeout = GetGameTimer() + 5000

    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(0)
    end

    return HasModelLoaded(model)
end

local function deleteObjectSafe(object)
    if not object or object == 0 or not DoesEntityExist(object) then
        return
    end

    DetachEntity(object, true, true)
    SetEntityAsMissionEntity(object, true, true)
    DeleteObject(object)
end

local function clearPlayerObjects(serverId)
    local entries = attachedObjects[serverId]

    if not entries then
        return
    end

    for _, object in pairs(entries) do
        deleteObjectSafe(object)
    end

    attachedObjects[serverId] = nil
end

local function clearAllObjects()
    for serverId in pairs(attachedObjects) do
        clearPlayerObjects(serverId)
    end
end

local function arraysEqual(first, second)
    if #first ~= #second then
        return false
    end

    for index = 1, #first do
        if first[index] ~= second[index] then
            return false
        end
    end

    return true
end

local function getOxInventoryWeapons()
    local result = {}
    local inventory = exports.ox_inventory:GetPlayerItems()

    if type(inventory) ~= 'table' then
        return result
    end

    local selectedWeapon = GetSelectedPedWeapon(PlayerPedId())

    for _, slot in pairs(inventory) do
        if slot and slot.name then
            local weaponHash = joaat(string.upper(slot.name))

            if Config.Weapons[weaponHash] and weaponHash ~= selectedWeapon then
                result[#result + 1] = weaponHash

                if #result >= Config.MaxVisibleWeapons then
                    break
                end
            end
        end
    end

    return result
end

local function getNativeWeapons()
    local result = {}
    local ped = PlayerPedId()
    local selectedWeapon = GetSelectedPedWeapon(ped)

    for weaponHash in pairs(Config.Weapons) do
        if HasPedGotWeapon(ped, weaponHash, false) and weaponHash ~= selectedWeapon then
            result[#result + 1] = weaponHash

            if #result >= Config.MaxVisibleWeapons then
                break
            end
        end
    end

    return result
end

local function getOwnedBackWeapons()
    if Config.RemoveOnDeath and IsEntityDead(PlayerPedId()) then
        return {}
    end

    if Config.HideWhileInVehicle and IsPedInAnyVehicle(PlayerPedId(), false) then
        return {}
    end

    if oxInventoryAvailable then
        local success, weapons = pcall(getOxInventoryWeapons)

        if success then
            return weapons
        end

        debugPrint('ox_inventory read failed:', weapons)
    end

    return getNativeWeapons()
end

local function attachWeaponToPed(serverId, ped, weaponHash, slotIndex)
    local settings = Config.Weapons[weaponHash]

    if not settings or not DoesEntityExist(ped) then
        return
    end

    if not requestModel(settings.model) then
        debugPrint(('Could not load model %s'):format(settings.model))
        return
    end

    local object = CreateObject(settings.model, 0.0, 0.0, 0.0, false, false, false)

    if object == 0 then
        return
    end

    SetEntityCollision(object, false, false)
    SetEntityCompletelyDisableCollision(object, false, false)

    local bone = GetPedBoneIndex(ped, settings.bone or Config.DefaultBone)
    local pos = settings.position
    local rot = settings.rotation
    
    local spacing = (slotIndex - 1) * 0.025

    AttachEntityToEntity(
        object,
        ped,
        bone,
        pos.x,
        pos.y - spacing,
        pos.z,
        rot.x,
        rot.y,
        rot.z,
        true,
        true,
        false,
        true,
        2,
        true
    )

    SetModelAsNoLongerNeeded(settings.model)

    attachedObjects[serverId] = attachedObjects[serverId] or {}
    attachedObjects[serverId][weaponHash] = object
end

local function refreshPlayerWeapons(serverId)
    clearPlayerObjects(serverId)

    local player = GetPlayerFromServerId(serverId)

    if player == -1 then
        return
    end

    local ped = GetPlayerPed(player)

    if not DoesEntityExist(ped) then
        return
    end

    local weapons = syncedWeapons[serverId] or {}

    for index, weaponHash in ipairs(weapons) do
        attachWeaponToPed(serverId, ped, weaponHash, index)
    end
end

RegisterNetEvent('sb_weaponsback:client:updatePlayerWeapons', function(serverId, weapons)
    serverId = tonumber(serverId)

    if not serverId or type(weapons) ~= 'table' then
        return
    end

    syncedWeapons[serverId] = weapons
    refreshPlayerWeapons(serverId)
end)

RegisterNetEvent('sb_weaponsback:client:fullSync', function(allWeapons)
    if type(allWeapons) ~= 'table' then
        return
    end

    syncedWeapons = allWeapons
    clearAllObjects()

    for serverId in pairs(syncedWeapons) do
        refreshPlayerWeapons(tonumber(serverId))
    end
end)

RegisterNetEvent('sb_weaponsback:client:removePlayer', function(serverId)
    serverId = tonumber(serverId)

    if not serverId then
        return
    end

    syncedWeapons[serverId] = nil
    clearPlayerObjects(serverId)
end)

CreateThread(function()
    oxInventoryAvailable = Config.UseOxInventory and GetResourceState('ox_inventory') == 'started'
    TriggerServerEvent('sb_weaponsback:server:requestSync')

    while true do
        local weapons = getOwnedBackWeapons()

        table.sort(weapons)

        if not arraysEqual(weapons, lastOwnWeapons) then
            lastOwnWeapons = weapons
            TriggerServerEvent('sb_weaponsback:server:updateWeapons', weapons)
        end

        Wait(Config.UpdateInterval)
    end
end)

CreateThread(function()
    while true do
        Wait(Config.SyncInterval)

        for serverId in pairs(syncedWeapons) do
            serverId = tonumber(serverId)
            local player = GetPlayerFromServerId(serverId)

            if player == -1 then
                clearPlayerObjects(serverId)
            else
                local ped = GetPlayerPed(player)
                local entries = attachedObjects[serverId]
                local needsRefresh = not entries

                if entries then
                    for _, object in pairs(entries) do
                        if not DoesEntityExist(object) or GetEntityAttachedTo(object) ~= ped then
                            needsRefresh = true
                            break
                        end
                    end
                end

                if needsRefresh then
                    refreshPlayerWeapons(serverId)
                end
            end
        end
    end
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    clearAllObjects()
end)
