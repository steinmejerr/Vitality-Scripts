local ESX = exports['es_extended']:getSharedObject()

local shopPed
local nuiOpen = false
local detectorActive = false
local detectorObject
local previousWeapon
local currentTarget
local currentTargetId
local currentZone
local searching = false
local lastSignal = 0
local lastScanSound = 0
local zoneBlips = {}
local hasDetectorItem = false
local lastDetectorUse = 0


local function playDetectorSound(soundType, volume, frequency, duration)
    SendNUIMessage({
        action = 'detectorSound',
        soundType = soundType,
        volume = volume,
        frequency = frequency,
        duration = duration
    })
end

local function notify(description, notifyType)
    lib.notify({
        title = 'Metaldetektor',
        description = description,
        type = notifyType or 'inform',
        position = 'top-right'
    })
end

local function clearDetectorFeedback()
    lib.hideTextUI()
    SendNUIMessage({ action = 'stopDetectorSound' })
    lastSignal = 0
    lastScanSound = 0
end

local function loadModel(model)
    if not IsModelInCdimage(model) then return false end
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(0)
    end
    return HasModelLoaded(model)
end


local function deleteDetectorObject()
    local ped = PlayerPedId()

    if detectorObject and DoesEntityExist(detectorObject) then
        DetachEntity(detectorObject, true, true)
        DeleteEntity(detectorObject)
    end

    detectorObject = nil

    if previousWeapon then
        SetCurrentPedWeapon(ped, previousWeapon, true)
    else
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
    end

    ClearPedSecondaryTask(ped)
    previousWeapon = nil
end

local function loadAnimDict(dict)
    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do
        Wait(0)
    end
    return HasAnimDictLoaded(dict)
end

local function createDetectorObject(ped)
    local model = Config.Detector.model
    if not loadModel(model) then
        return false
    end

    detectorObject = CreateObject(model, GetEntityCoords(ped), true, true, false)

    if not detectorObject or detectorObject == 0 or not DoesEntityExist(detectorObject) then
        SetModelAsNoLongerNeeded(model)
        detectorObject = nil
        return false
    end

    local bone = GetPedBoneIndex(ped, Config.Detector.bone)
    AttachEntityToEntity(
        detectorObject,
        ped,
        bone,
        Config.Detector.offset.x,
        Config.Detector.offset.y,
        Config.Detector.offset.z,
        Config.Detector.rotation.x,
        Config.Detector.rotation.y,
        Config.Detector.rotation.z,
        true,
        true,
        false,
        true,
        1,
        true
    )

    SetModelAsNoLongerNeeded(model)

    local animation = Config.Detector.animation
    if animation and animation.dict and animation.clip and loadAnimDict(animation.dict) then
        TaskPlayAnim(ped, animation.dict, animation.clip, 3.0, 3.0, -1, animation.flag or 49, 0.0, false, false, false)
    end

    return DoesEntityExist(detectorObject)
end

local function setDetectorActive(state)
    if state == detectorActive then return end

    if state then
        local hasItem = lib.callback.await('sb_metaldetecting:server:hasDetector', false)
        if not hasItem then
            notify('Du har ikke en metaldetektor.', 'error')
            return
        end

        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            notify('Du kan ikke bruge metaldetektoren i et køretøj.', 'error')
            return
        end

        previousWeapon = GetSelectedPedWeapon(ped)
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)

        if not createDetectorObject(ped) then
            previousWeapon = nil
            notify('Metaldetektor-modellen kunne ikke indlæses.', 'error')
            return
        end

        detectorActive = true
        notify('Metaldetektoren er aktiveret.', 'success')
    else
        detectorActive = false
        currentTarget = nil
        currentTargetId = nil
        currentZone = nil
        clearDetectorFeedback()
        deleteDetectorObject()
        notify('Metaldetektoren er pakket væk.', 'inform')
    end
end


local function useDetectorItem()
    local now = GetGameTimer()
    if now - lastDetectorUse < 1000 then return end
    lastDetectorUse = now
    setDetectorActive(not detectorActive)
end

exports('useMetalDetector', function()
    useDetectorItem()
end)

RegisterNetEvent('sb_metaldetecting:client:useDetector', function()
    useDetectorItem()
end)

local function clearZoneBlips()
    for _, blips in pairs(zoneBlips) do
        if blips.radius and DoesBlipExist(blips.radius) then
            RemoveBlip(blips.radius)
        end
        if blips.icon and DoesBlipExist(blips.icon) then
            RemoveBlip(blips.icon)
        end
    end
    zoneBlips = {}
end

local function createZoneBlips()
    if next(zoneBlips) then return end

    for _, zone in ipairs(Config.Zones) do
        local radiusBlip = AddBlipForRadius(zone.center.x, zone.center.y, zone.center.z, zone.radius)
        SetBlipColour(radiusBlip, Config.ZoneBlips.radiusColour)
        SetBlipAlpha(radiusBlip, Config.ZoneBlips.radiusAlpha)

        local iconBlip = AddBlipForCoord(zone.center.x, zone.center.y, zone.center.z)
        SetBlipSprite(iconBlip, Config.ZoneBlips.sprite)
        SetBlipColour(iconBlip, Config.ZoneBlips.colour)
        SetBlipScale(iconBlip, Config.ZoneBlips.scale)
        SetBlipAsShortRange(iconBlip, Config.ZoneBlips.shortRange)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(zone.label)
        EndTextCommandSetBlipName(iconBlip)

        zoneBlips[zone.id] = {
            radius = radiusBlip,
            icon = iconBlip
        }
    end
end

local function updateDetectorOwnership()
    local owned = lib.callback.await('sb_metaldetecting:server:hasDetector', false) == true
    hasDetectorItem = owned

    if owned then
        createZoneBlips()
    else
        clearZoneBlips()
        if detectorActive then
            setDetectorActive(false)
        end
    end
end

local function openShop(defaultTab)
    local data = lib.callback.await('sb_metaldetecting:server:getShopData', false)
    if not data then
        notify('Shoppen kunne ikke indlæses.', 'error')
        return
    end

    nuiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        defaultTab = defaultTab or 'shop',
        detector = data.detector,
        inventory = data.inventory
    })
end

local function closeShop()
    nuiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function createShopPed()
    if not loadModel(Config.Shop.ped.model) then return end

    local c = Config.Shop.ped.coords
    shopPed = CreatePed(4, Config.Shop.ped.model, c.x, c.y, c.z - 1.0, c.w, false, true)
    SetEntityInvincible(shopPed, true)
    FreezeEntityPosition(shopPed, true)
    SetBlockingOfNonTemporaryEvents(shopPed, true)
    TaskStartScenarioInPlace(shopPed, Config.Shop.ped.scenario, 0, true)

    exports.ox_target:addLocalEntity(shopPed, {
        {
            name = 'sb_metaldetecting_shop',
            icon = 'fa-solid fa-magnifying-glass',
            label = 'Åbn metaldetektor-shop',
            onSelect = function() openShop('shop') end
        },
        {
            name = 'sb_metaldetecting_sell',
            icon = 'fa-solid fa-coins',
            label = 'Sælg fund',
            onSelect = function() openShop('sell') end
        }
    })

    if Config.Shop.blip.enabled then
        local blip = AddBlipForCoord(c.x, c.y, c.z)
        SetBlipSprite(blip, Config.Shop.blip.sprite)
        SetBlipColour(blip, Config.Shop.blip.colour)
        SetBlipScale(blip, Config.Shop.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.Shop.blip.label)
        EndTextCommandSetBlipName(blip)
    end
end

local function distance2D(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return math.sqrt((dx * dx) + (dy * dy))
end

local function requestTarget()
    local coords = GetEntityCoords(PlayerPedId())
    local target = lib.callback.await('sb_metaldetecting:server:getTarget', false, {
        x = coords.x,
        y = coords.y,
        z = coords.z
    })

    if target then
        currentTarget = vec3(target.x, target.y, target.z)
        currentTargetId = target.id
        currentZone = target.zone
    else
        currentTarget = nil
        currentTargetId = nil
        currentZone = nil
    end
end

local function digTarget()
    if searching or not currentTarget then return end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    if distance2D(coords, currentTarget) > Config.Search.minFindDistance + 0.35 then return end

    searching = true
    FreezeEntityPosition(ped, true)

    local completed = lib.progressCircle({
        duration = Config.Search.digDuration,
        position = 'bottom',
        label = 'Graver fundet op...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = {
            dict = 'amb@world_human_gardener_plant@male@base',
            clip = 'base',
            flag = 1
        }
    })

    FreezeEntityPosition(ped, false)

    if completed then
        local result = lib.callback.await('sb_metaldetecting:server:collectTarget', false, {
            id = currentTargetId,
            zone = currentZone,
            x = currentTarget.x,
            y = currentTarget.y,
            z = currentTarget.z
        })

        if result and result.success then
            notify(('Du fandt %sx %s.'):format(result.amount, result.label), 'success')
            currentTarget = nil
            currentTargetId = nil
            currentZone = nil
            Wait(700)
            requestTarget()
        else
            notify(result and result.message or 'Fundet kunne ikke samles op.', 'error')
        end
    end

    searching = false
end

RegisterCommand(Config.Detector.toggleCommand, function()
    setDetectorActive(not detectorActive)
end, false)

RegisterKeyMapping(Config.Detector.toggleCommand, 'Aktivér metaldetektor', 'keyboard', Config.Detector.toggleKey)

RegisterNUICallback('close', function(_, cb)
    closeShop()
    cb(true)
end)

RegisterNUICallback('buyDetector', function(_, cb)
    local result = lib.callback.await('sb_metaldetecting:server:buyDetector', false)
    cb(result or { success = false, message = 'Købet kunne ikke gennemføres.' })
    if result and result.success then
        notify(result.message, 'success')
        updateDetectorOwnership()
    end
end)

RegisterNUICallback('sellItem', function(data, cb)
    local result = lib.callback.await('sb_metaldetecting:server:sellItem', false, data.item)
    cb(result or { success = false, message = 'Salget kunne ikke gennemføres.' })
    if result then notify(result.message, result.success and 'success' or 'error') end
end)

RegisterNUICallback('sellAll', function(_, cb)
    local result = lib.callback.await('sb_metaldetecting:server:sellAll', false)
    cb(result or { success = false, message = 'Salget kunne ikke gennemføres.' })
    if result then notify(result.message, result.success and 'success' or 'error') end
end)


CreateThread(function()
    Wait(1500)

    while true do
        updateDetectorOwnership()
        Wait(Config.ZoneBlips.inventoryCheckInterval)
    end
end)

CreateThread(function()
    createShopPed()

    while true do
        if not detectorActive then
            clearDetectorFeedback()
            Wait(800)
        else
            Wait(0)
            local ped = PlayerPedId()

            DisablePlayerFiring(PlayerId(), true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, Config.Search.scanControl, true)
            DisableControlAction(0, 37, true)

            if IsPedInAnyVehicle(ped, false) or IsEntityDead(ped) then
                setDetectorActive(false)
            else
                local scanning = IsDisabledControlPressed(0, Config.Search.scanControl)

                if not scanning then
                    lib.showTextUI('[Højreklik] Hold for at søge', {
                        position = 'right-center',
                        icon = 'magnifying-glass'
                    })
                elseif not currentTarget then
                    local now = GetGameTimer()
                    local scanSound = Config.Search.scanSound
                    if now - lastScanSound >= scanSound.interval then
                        playDetectorSound('scan', scanSound.volume, scanSound.frequency, scanSound.duration)
                        lastScanSound = now
                    end

                    lib.showTextUI('Søger efter signal...', {
                        position = 'right-center',
                        icon = 'satellite-dish'
                    })
                    Wait(350)
                    requestTarget()
                else
                    local coords = GetEntityCoords(ped)
                    local distance = distance2D(coords, currentTarget)
                    local now = GetGameTimer()
                    local scanSound = Config.Search.scanSound

                    if now - lastScanSound >= scanSound.interval then
                        playDetectorSound('scan', scanSound.volume, scanSound.frequency, scanSound.duration)
                        lastScanSound = now
                    end

                    if distance <= Config.Search.maxSignalDistance then
                        local signal = Config.Search.signalSound
                        local closeness = 1.0 - math.min(1.0, math.max(0.0, distance / Config.Search.maxSignalDistance))
                        local interval = math.floor(signal.farInterval - ((signal.farInterval - signal.nearInterval) * closeness))
                        local volume = signal.farVolume + ((signal.nearVolume - signal.farVolume) * closeness)
                        local frequency = signal.farFrequency + ((signal.nearFrequency - signal.farFrequency) * closeness)

                        if now - lastSignal >= interval then
                            playDetectorSound('signal', volume, frequency, signal.duration)
                            lastSignal = now
                        end
                    end

                    if distance <= Config.Search.minFindDistance then
                        lib.showTextUI('[E] Grav fundet op', {
                            position = 'right-center',
                            icon = 'trowel'
                        })
                        if IsControlJustPressed(0, Config.Search.interactKey) then
                            lib.hideTextUI()
                            digTarget()
                        end
                    elseif distance <= Config.Search.maxSignalDistance then
                        lib.showTextUI('Signal registreret – bevæg dig langsomt', {
                            position = 'right-center',
                            icon = 'wave-square'
                        })
                    else
                        lib.showTextUI('Intet signal i nærheden', {
                            position = 'right-center',
                            icon = 'magnifying-glass'
                        })
                    end
                end
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    deleteDetectorObject()
    clearZoneBlips()
    if shopPed and DoesEntityExist(shopPed) then DeleteEntity(shopPed) end
    clearDetectorFeedback()
    SetNuiFocus(false, false)
end)
