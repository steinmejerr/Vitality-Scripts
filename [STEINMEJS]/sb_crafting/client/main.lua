local ESX = exports.es_extended:getSharedObject()
local spawnedStations = {}
local placing = false
local shopPed
local uiOpen = false

local function notify(description, type)
    lib.notify({ title = 'Crafting', description = description, type = type or 'inform' })
end

local function loadModel(model)
    if not IsModelInCdimage(model) then return false end
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        Wait(0)
        if GetGameTimer() > timeout then return false end
    end
    return true
end

local function closeUi()
    if not uiOpen then return end
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function openShop()
    local data = lib.callback.await('sb_crafting:getShopData', false)
    if not data then return end
    uiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openShop', data = data })
end

local function openCrafting(stationId)
    local data = lib.callback.await('sb_crafting:getCraftingData', false)
    if not data then return end
    data.stationId = stationId
    uiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openCrafting', data = data })
end

local function deleteStationObject(id)
    local station = spawnedStations[id]
    if not station then return end
    if DoesEntityExist(station.object) then
        exports.ox_target:removeLocalEntity(station.object)
        DeleteEntity(station.object)
    end
    spawnedStations[id] = nil
end

local function spawnStation(station)
    if spawnedStations[station.id] then return end
    if not loadModel(Config.StationProp) then return end

    local c = station.coords
    local object = CreateObjectNoOffset(Config.StationProp, c.x, c.y, c.z, false, false, false)
    SetEntityHeading(object, station.heading + 0.0)
    FreezeEntityPosition(object, true)
    SetEntityInvincible(object, true)
    SetEntityAsMissionEntity(object, true, true)

    exports.ox_target:addLocalEntity(object, {
        {
            name = ('sb_crafting_use_%s'):format(station.id),
            icon = 'fa-solid fa-hammer',
            label = 'Brug crafting station',
            distance = Config.InteractDistance,
            onSelect = function()
                openCrafting(station.id)
            end
        },
        {
            name = ('sb_crafting_pickup_%s'):format(station.id),
            icon = 'fa-solid fa-hand',
            label = 'Tag crafting station op',
            distance = Config.InteractDistance,
            canInteract = function()
                return lib.callback.await('sb_crafting:canPickup', false, station.id)
            end,
            onSelect = function()
                local confirm = lib.alertDialog({
                    header = 'Tag stationen op?',
                    content = 'Stationen bliver lagt tilbage i dit inventory.',
                    centered = true,
                    cancel = true
                })
                if confirm == 'confirm' then
                    TriggerServerEvent('sb_crafting:pickupStation', station.id)
                end
            end
        }
    })

    spawnedStations[station.id] = { object = object, data = station }
    SetModelAsNoLongerNeeded(Config.StationProp)
end

local function spawnShopPed()
    local npc = Config.Shop.npc
    if not loadModel(npc.model) then return end
    shopPed = CreatePed(0, npc.model, npc.coords.x, npc.coords.y, npc.coords.z - 1.0, npc.coords.w, false, false)
    SetEntityInvincible(shopPed, true)
    FreezeEntityPosition(shopPed, true)
    SetBlockingOfNonTemporaryEvents(shopPed, true)
    if npc.scenario then TaskStartScenarioInPlace(shopPed, npc.scenario, 0, true) end
    exports.ox_target:addLocalEntity(shopPed, {{
        name = 'sb_crafting_shop',
        icon = 'fa-solid fa-cart-shopping',
        label = 'Køb crafting station',
        distance = 2.2,
        onSelect = openShop
    }})
    SetModelAsNoLongerNeeded(npc.model)

    if Config.Shop.blip.enabled then
        local blip = AddBlipForCoord(npc.coords.x, npc.coords.y, npc.coords.z)
        SetBlipSprite(blip, Config.Shop.blip.sprite)
        SetBlipColour(blip, Config.Shop.blip.colour)
        SetBlipScale(blip, Config.Shop.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.Shop.blip.label)
        EndTextCommandSetBlipName(blip)
    end
end

RegisterNetEvent('sb_crafting:startPlacement', function()
    if placing then return end
    if not loadModel(Config.StationProp) then return notify('Proppen kunne ikke indlæses.', 'error') end

    placing = true
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local preview = CreateObjectNoOffset(Config.StationProp, coords.x, coords.y, coords.z, false, false, false)
    SetEntityAlpha(preview, 180, false)
    SetEntityCollision(preview, false, false)
    FreezeEntityPosition(preview, true)

    lib.showTextUI('[E] Placér  •  [←/→] Drej  •  [↑/↓] Højde  •  [BACKSPACE] Annuller', {
        position = 'bottom-center',
        icon = 'hammer'
    })

    while placing do
        Wait(0)
        ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)
        local forward = GetEntityForwardVector(ped)
        local placeCoords = pCoords + (forward * 2.0)
        local found, groundZ = GetGroundZFor_3dCoord(placeCoords.x, placeCoords.y, placeCoords.z + 2.0, false)
        local z = found and groundZ or placeCoords.z
        local current = GetEntityCoords(preview)
        local heightOffset = current.z - z
        if math.abs(heightOffset) > 1.0 then heightOffset = 0.0 end

        SetEntityCoordsNoOffset(preview, placeCoords.x, placeCoords.y, z + heightOffset, false, false, false)
        SetEntityHeading(preview, heading)

        if IsControlJustPressed(0, Config.Placement.controls.rotateLeft) then
            heading = heading + Config.Placement.rotationStep
        elseif IsControlJustPressed(0, Config.Placement.controls.rotateRight) then
            heading = heading - Config.Placement.rotationStep
        elseif IsControlPressed(0, Config.Placement.controls.heightUp) then
            SetEntityCoordsNoOffset(preview, placeCoords.x, placeCoords.y, GetEntityCoords(preview).z + Config.Placement.heightStep, false, false, false)
        elseif IsControlPressed(0, Config.Placement.controls.heightDown) then
            SetEntityCoordsNoOffset(preview, placeCoords.x, placeCoords.y, GetEntityCoords(preview).z - Config.Placement.heightStep, false, false, false)
        elseif IsControlJustPressed(0, Config.Placement.controls.confirm) then
            local finalCoords = GetEntityCoords(preview)
            placing = false
            lib.hideTextUI()
            DeleteEntity(preview)
            TriggerServerEvent('sb_crafting:placeStation', { x = finalCoords.x, y = finalCoords.y, z = finalCoords.z }, heading)
        elseif IsControlJustPressed(0, Config.Placement.controls.cancel) then
            placing = false
            lib.hideTextUI()
            DeleteEntity(preview)
            notify('Placeringen blev annulleret.', 'error')
        end
    end
    SetModelAsNoLongerNeeded(Config.StationProp)
end)

RegisterNetEvent('sb_crafting:addStation', spawnStation)
RegisterNetEvent('sb_crafting:removeStation', deleteStationObject)

RegisterNUICallback('close', function(_, cb)
    closeUi()
    cb(1)
end)

RegisterNUICallback('buyStation', function(_, cb)
    TriggerServerEvent('sb_crafting:buyStation')
    closeUi()
    cb(1)
end)

RegisterNUICallback('craft', function(data, cb)
    local response = lib.callback.await('sb_crafting:startCraft', false, data.recipeId, data.amount)
    if not response or not response.success then
        notify(response and response.message or 'Crafting kunne ikke startes.', 'error')
        return cb({ success = false })
    end

    closeUi()
    local completed = lib.progressCircle({
        duration = response.duration,
        label = ('Laver %s...'):format(response.label),
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disable = { move = true, car = true, combat = true },
        anim = { dict = 'mini@repair', clip = 'fixing_a_ped' }
    })
    if completed then TriggerServerEvent('sb_crafting:finishCraft', response.token) end
    cb({ success = completed == true })
end)

CreateThread(function()
    Wait(1000)
    spawnShopPed()
    local stations = lib.callback.await('sb_crafting:getStations', false) or {}
    for i = 1, #stations do spawnStation(stations[i]) end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    closeUi()
    if placing then lib.hideTextUI() end
    if shopPed and DoesEntityExist(shopPed) then DeleteEntity(shopPed) end
    for id in pairs(spawnedStations) do deleteStationObject(id) end
end)
