local attachedObjects = {}
local syncedWeapons = {}
local lastOwnWeapons = {}
local oxInventoryAvailable = false
local placementOverrides = {}
local forceSync = false

local function debugPrint(...)
    if Config.Debug then
        print('[sb_weaponsback]', ...)
    end
end

local function notify(description, notifyType)
    lib.notify({
        title = 'Våbenplacering',
        description = description,
        type = notifyType or 'inform',
        position = 'top-right'
    })
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

local function getStoredPlacement(weaponHash)
    local cached = placementOverrides[weaponHash]
    if cached then
        return cached
    end

    local stored = GetResourceKvpString(('placement_%s'):format(weaponHash))
    local placement = stored == 'front' and 'front' or 'back'
    placementOverrides[weaponHash] = placement
    return placement
end

local function setStoredPlacement(weaponHash, placement)
    placement = placement == 'front' and 'front' or 'back'
    placementOverrides[weaponHash] = placement
    SetResourceKvp(('placement_%s'):format(weaponHash), placement)
    forceSync = true
end

local function entriesEqual(first, second)
    if #first ~= #second then
        return false
    end

    for index = 1, #first do
        local a = first[index]
        local b = second[index]

        if not a or not b or a.hash ~= b.hash or a.placement ~= b.placement then
            return false
        end
    end

    return true
end

local function addWeaponEntry(result, weaponHash)
    result[#result + 1] = {
        hash = weaponHash,
        placement = getStoredPlacement(weaponHash)
    }
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
                addWeaponEntry(result, weaponHash)

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
            addWeaponEntry(result, weaponHash)

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

local function getOwnedSupportedHashes()
    local result = {}

    if oxInventoryAvailable then
        local success, inventory = pcall(function()
            return exports.ox_inventory:GetPlayerItems()
        end)

        if success and type(inventory) == 'table' then
            local seen = {}

            for _, slot in pairs(inventory) do
                if slot and slot.name then
                    local hash = joaat(string.upper(slot.name))
                    if Config.Weapons[hash] and not seen[hash] then
                        seen[hash] = true
                        result[#result + 1] = hash
                    end
                end
            end
        end
    else
        local ped = PlayerPedId()
        for hash in pairs(Config.Weapons) do
            if HasPedGotWeapon(ped, hash, false) then
                result[#result + 1] = hash
            end
        end
    end

    table.sort(result)
    return result
end

local function attachWeaponToPed(serverId, ped, entry, slotIndex)
    local weaponHash = type(entry) == 'table' and tonumber(entry.hash) or tonumber(entry)
    local settings = weaponHash and Config.Weapons[weaponHash]

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

    local category = settings.category or 'rifle'
    local requestedPlacement = type(entry) == 'table' and entry.placement or settings.placement
    local placementName = requestedPlacement == 'front' and 'front' or 'back'
    local weaponPlacements = Config.WeaponPlacements and Config.WeaponPlacements[weaponHash]
    local categoryPlacements = Config.Placements[category] or Config.Placements.rifle
    local placement = (weaponPlacements and weaponPlacements[placementName]) or categoryPlacements[placementName] or categoryPlacements.back
    local bone = GetPedBoneIndex(ped, placement.bone or Config.DefaultBone)
    local pos = placement.position
    local rot = placement.rotation
    local spacingDirection = placementName == 'front' and 1 or -1
    local spacing = (slotIndex - 1) * 0.025 * spacingDirection

    AttachEntityToEntity(
        object,
        ped,
        bone,
        pos.x,
        pos.y + spacing,
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

    for index, entry in ipairs(weapons) do
        attachWeaponToPed(serverId, ped, entry, index)
    end
end

local function openPlacementChoice(weaponHash)
    local settings = Config.Weapons[weaponHash]
    if not settings then
        return
    end

    local current = getStoredPlacement(weaponHash)
    local menuId = ('sb_weaponsback_choice_%s'):format(weaponHash)

    lib.registerContext({
        id = menuId,
        title = settings.label or 'Våben',
        menu = 'sb_weaponsback_main',
        options = {
            {
                title = 'På ryggen',
                description = current == 'back' and 'Valgt placering' or 'Placér våbnet på ryggen',
                icon = 'person-rifle',
                iconColor = current == 'back' and '#52ffaa' or nil,
                onSelect = function()
                    setStoredPlacement(weaponHash, 'back')
                    notify(('%s vises nu på ryggen.'):format(settings.label or 'Våbnet'), 'success')
                end
            },
            {
                title = 'På maven/brystet',
                description = current == 'front' and 'Valgt placering' or 'Placér våbnet foran på kroppen',
                icon = 'vest',
                iconColor = current == 'front' and '#52ffaa' or nil,
                onSelect = function()
                    setStoredPlacement(weaponHash, 'front')
                    notify(('%s vises nu foran på kroppen.'):format(settings.label or 'Våbnet'), 'success')
                end
            }
        }
    })

    lib.showContext(menuId)
end

local function openPlacementMenu()
    local hashes = getOwnedSupportedHashes()

    if #hashes == 0 then
        notify('Du har ingen understøttede våben i dit inventory.', 'error')
        return
    end

    local options = {}

    for _, weaponHash in ipairs(hashes) do
        local settings = Config.Weapons[weaponHash]
        local placement = getStoredPlacement(weaponHash)

        options[#options + 1] = {
            title = settings.label or ('Våben %s'):format(weaponHash),
            description = placement == 'front' and 'Placering: Mave/bryst' or 'Placering: Ryg',
            icon = placement == 'front' and 'vest' or 'person-rifle',
            arrow = true,
            onSelect = function()
                openPlacementChoice(weaponHash)
            end
        }
    end

    lib.registerContext({
        id = 'sb_weaponsback_main',
        title = Config.Menu.title,
        options = options
    })

    lib.showContext('sb_weaponsback_main')
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

RegisterCommand(Config.Menu.command, openPlacementMenu, false)
RegisterKeyMapping(Config.Menu.command, 'Åbn våbenplacering', 'keyboard', Config.Menu.key)

CreateThread(function()
    oxInventoryAvailable = Config.UseOxInventory and GetResourceState('ox_inventory') == 'started'
    TriggerServerEvent('sb_weaponsback:server:requestSync')

    while true do
        local weapons = getOwnedBackWeapons()

        table.sort(weapons, function(a, b)
            return a.hash < b.hash
        end)

        if forceSync or not entriesEqual(weapons, lastOwnWeapons) then
            forceSync = false
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
