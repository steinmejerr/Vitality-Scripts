local ESX = exports['es_extended']:getSharedObject()

local shopPed
local nuiOpen = false
local detectorActive = false
local detectorObject
local currentTarget
local currentZone
local searching = false
local lastSignal = 0

local function notify(description, notifyType)
    lib.notify({
        title = 'Metaldetektor',
        description = description,
        type = notifyType or 'inform',
        position = 'top-right'
    })
end

local function loadModel(model)
    if not IsModelInCdimage(model) then return false end
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(0) end
    return HasModelLoaded(model)
end

local function deleteDetectorObject()
    if detectorObject and DoesEntityExist(detectorObject) then
        DeleteEntity(detectorObject)
    end
    detectorObject = nil
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

        if not loadModel(Config.Detector.model) then
            notify('Metaldetektor-modellen kunne ikke indlæses.', 'error')
            return
        end

        detectorObject = CreateObject(Config.Detector.model, 0.0, 0.0, 0.0, true, true, false)
        AttachEntityToEntity(
            detectorObject,
            ped,
            GetPedBoneIndex(ped, Config.Detector.bone),
            Config.Detector.offset.x,
            Config.Detector.offset.y,
            Config.Detector.offset.z,
            Config.Detector.rotation.x,
            Config.Detector.rotation.y,
            Config.Detector.rotation.z,
            true, true, false, true, 1, true
        )
        SetModelAsNoLongerNeeded(Config.Detector.model)
        detectorActive = true
        notify('Metaldetektoren er aktiveret.', 'success')
    else
        detectorActive = false
        currentTarget = nil
        currentZone = nil
        deleteDetectorObject()
        notify('Metaldetektoren er pakket væk.', 'inform')
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

local function requestTarget()
    local coords = GetEntityCoords(PlayerPedId())
    local target = lib.callback.await('sb_metaldetecting:server:getTarget', false, {
        x = coords.x,
        y = coords.y,
        z = coords.z
    })

    if target then
        currentTarget = vec3(target.x, target.y, target.z)
        currentZone = target.zone
    else
        currentTarget = nil
        currentZone = nil
    end
end

local function digTarget()
    if searching or not currentTarget then return end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    if #(coords - currentTarget) > Config.Search.minFindDistance + 0.35 then return end

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
            zone = currentZone,
            x = currentTarget.x,
            y = currentTarget.y,
            z = currentTarget.z
        })

        if result and result.success then
            notify(('Du fandt %sx %s.'):format(result.amount, result.label), 'success')
            currentTarget = nil
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
    if result and result.success then notify(result.message, 'success') end
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
    createShopPed()

    while true do
        if not detectorActive then
            Wait(800)
        else
            Wait(0)
            local ped = PlayerPedId()

            if IsPedInAnyVehicle(ped, false) or IsEntityDead(ped) then
                setDetectorActive(false)
            elseif not currentTarget then
                Wait(500)
                requestTarget()
            else
                local coords = GetEntityCoords(ped)
                local distance = #(coords - currentTarget)

                if distance <= Config.Search.maxSignalDistance then
                    local interval = math.floor(math.max(160, math.min(1400, distance * 95)))
                    if GetGameTimer() - lastSignal >= interval then
                        PlaySoundFrontend(-1, Config.Search.signalSound.name, Config.Search.signalSound.set, true)
                        lastSignal = GetGameTimer()
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
                else
                    lib.hideTextUI()
                end
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    deleteDetectorObject()
    if shopPed and DoesEntityExist(shopPed) then DeleteEntity(shopPed) end
    lib.hideTextUI()
    SetNuiFocus(false, false)
end)
