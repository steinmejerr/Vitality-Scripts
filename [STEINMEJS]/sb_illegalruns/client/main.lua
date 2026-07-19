local npc
local activeRun
local packageObject
local routeBlip
local pickupZone
local pickupObject
local pickupObjectTarget
local pickupVehicle
local deliveryZone
local runVehicle
local runVehicleTarget
local carryingPackage = false
local packageInVehicle = false
local cargoObjects = {}

local function notify(description, type)
    lib.notify({ title = 'Illegal Runs', description = description, type = type or 'inform' })
end

local function removeBlip()
    if routeBlip and DoesBlipExist(routeBlip) then RemoveBlip(routeBlip) end
    routeBlip = nil
end

local function setRoute(coords, label)
    removeBlip()
    routeBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(routeBlip, Config.Blip.sprite)
    SetBlipColour(routeBlip, Config.Blip.colour)
    SetBlipScale(routeBlip, Config.Blip.scale)
    SetBlipRoute(routeBlip, true)
    SetBlipRouteColour(routeBlip, Config.Blip.routeColour)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(label)
    EndTextCommandSetBlipName(routeBlip)
end

local function clearZones()
    if pickupZone then exports.ox_target:removeZone(pickupZone) pickupZone = nil end
    if pickupObjectTarget and pickupObject and DoesEntityExist(pickupObject) then
        exports.ox_target:removeLocalEntity(pickupObject, pickupObjectTarget)
    end
    pickupObjectTarget = nil
    if pickupObject and DoesEntityExist(pickupObject) then DeleteEntity(pickupObject) end
    pickupObject = nil
    if pickupVehicle and DoesEntityExist(pickupVehicle) then
        SetEntityAsMissionEntity(pickupVehicle, true, true)
        DeleteVehicle(pickupVehicle)
    end
    pickupVehicle = nil
    if deliveryZone then exports.ox_target:removeZone(deliveryZone) deliveryZone = nil end
end

local function removePackage()
    if packageObject and DoesEntityExist(packageObject) then DeleteEntity(packageObject) end
    packageObject = nil
    carryingPackage = false
end

local function attachPackage()
    removePackage()
    lib.requestModel(Config.PackageProp)
    packageObject = CreateObject(Config.PackageProp, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(packageObject, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.12, 0.0, -0.18, 250.0, 120.0, 40.0, true, true, false, true, 1, true)
    carryingPackage = true
end


local function removeCargoVisuals()
    for i = #cargoObjects, 1, -1 do
        local object = cargoObjects[i]
        if object and DoesEntityExist(object) then
            DeleteEntity(object)
        end
        cargoObjects[i] = nil
    end
end

local function createCargoVisuals(vehicle)
    removeCargoVisuals()
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end

    lib.requestModel(Config.CargoVisuals.prop)

    local position = Config.CargoVisuals.position
    local object = CreateObject(Config.CargoVisuals.prop, 0.0, 0.0, 0.0, false, false, false)

    if object and object ~= 0 then
        SetEntityCollision(object, false, false)
        AttachEntityToEntity(
            object,
            vehicle,
            0,
            position.x,
            position.y,
            position.z,
            position.rx or 0.0,
            position.ry or 0.0,
            position.rz or 0.0,
            false,
            false,
            false,
            false,
            2,
            true
        )
        cargoObjects[1] = object
    end

    SetModelAsNoLongerNeeded(Config.CargoVisuals.prop)
end

local function getTrunkCoords(vehicle)
    -- Vans som Speedo bruger bagdøre i stedet for en almindelig 'boot'-bone.
    -- Brug derfor først en af bagdørene og fald tilbage til køretøjets bagende.
    local rearBones = { 'door_dside_r', 'door_pside_r', 'boot' }

    for i = 1, #rearBones do
        local boneIndex = GetEntityBoneIndexByName(vehicle, rearBones[i])
        if boneIndex ~= -1 then
            return GetWorldPositionOfEntityBone(vehicle, boneIndex)
        end
    end

    local minDim, _ = GetModelDimensions(GetEntityModel(vehicle))
    return GetOffsetFromEntityInWorldCoords(vehicle, 0.0, minDim.y - 0.35, 0.0)
end

local function nearTrunk(vehicle, maxDistance)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return false end
    return #(GetEntityCoords(cache.ped) - getTrunkCoords(vehicle)) <= (maxDistance or 3.0)
end

local function deleteRunVehicle()
    if runVehicleTarget and runVehicle and DoesEntityExist(runVehicle) then
        exports.ox_target:removeLocalEntity(runVehicle, runVehicleTarget)
    end
    runVehicleTarget = nil

    if runVehicle and DoesEntityExist(runVehicle) then
        SetEntityAsMissionEntity(runVehicle, true, true)
        DeleteVehicle(runVehicle)
    end
    runVehicle = nil
    packageInVehicle = false
    removeCargoVisuals()
end

local function addVehicleTarget(vehicle)
    runVehicleTarget = { 'sb_illegalruns_store_package', 'sb_illegalruns_take_package' }

    exports.ox_target:addLocalEntity(vehicle, {
        {
            name = 'sb_illegalruns_store_package',
            icon = 'fa-solid fa-box',
            label = 'Læg pakken på ladet',
            distance = 3.0,
            canInteract = function(entity)
                return entity == runVehicle and carryingPackage and not packageInVehicle
            end,
            onSelect = function(data)
                if not nearTrunk(data.entity, 3.0) then return notify('Gå tættere på bagagerummet.', 'error') end
                if GetVehicleDoorLockStatus(data.entity) > 1 then return notify('Bilen er låst.', 'error') end

                SetVehicleDoorOpen(data.entity, 5, false, false)
                local done = lib.progressCircle({ duration = 3500, label = 'Lægger pakken på ladet...', canCancel = true, disable = { move = true, car = true, combat = true } })
                if not done then SetVehicleDoorShut(data.entity, 5, false) return end

                local success = lib.callback.await('sb_illegalruns:storePackage', false, activeRun, VehToNet(data.entity), GetVehicleNumberPlateText(data.entity))
                SetVehicleDoorShut(data.entity, 5, false)
                if not success then return notify('Pakken kunne ikke lægges i bilen.', 'error') end

                removePackage()
                packageInVehicle = true
                createCargoVisuals(data.entity)
                local run = Config.Runs[activeRun]
                setRoute(run.delivery, 'Aflever pakken')
                notify('Pakken er på ladet. Kør til afleveringsstedet.', 'success')
            end
        },
        {
            name = 'sb_illegalruns_take_package',
            icon = 'fa-solid fa-box-open',
            label = 'Tag pakken af ladet',
            distance = 3.0,
            canInteract = function(entity)
                return entity == runVehicle and packageInVehicle and not carryingPackage
            end,
            onSelect = function(data)
                if not nearTrunk(data.entity, 3.0) then return notify('Gå tættere på bagagerummet.', 'error') end
                if GetVehicleDoorLockStatus(data.entity) > 1 then return notify('Bilen er låst.', 'error') end

                SetVehicleDoorOpen(data.entity, 5, false, false)
                local done = lib.progressCircle({ duration = 3000, label = 'Tager pakken ud...', canCancel = true, disable = { move = true, car = true, combat = true } })
                if not done then SetVehicleDoorShut(data.entity, 5, false) return end

                local success = lib.callback.await('sb_illegalruns:takePackage', false, activeRun, VehToNet(data.entity), GetVehicleNumberPlateText(data.entity))
                SetVehicleDoorShut(data.entity, 5, false)
                if not success then return notify('Pakken kunne ikke tages ud.', 'error') end

                packageInVehicle = false
                removeCargoVisuals()
                attachPackage()
                notify('Tag pakken med hen til afleveringsstedet.', 'success')
            end
        }
    })
end

local function spawnRunVehicle(runId)
    lib.requestModel(Config.RunVehicle.model)

    local spawn = Config.RunVehicle.spawn
    if IsAnyVehicleNearPoint(spawn.x, spawn.y, spawn.z, 3.0) then
        return false, 'Der holder allerede et køretøj på pladsen.'
    end

    runVehicle = CreateVehicle(Config.RunVehicle.model, spawn.x, spawn.y, spawn.z, spawn.w, true, true)
    if not runVehicle or runVehicle == 0 then return false, 'Køretøjet kunne ikke oprettes.' end

    SetEntityAsMissionEntity(runVehicle, true, true)
    SetVehicleOnGroundProperly(runVehicle)
    SetVehicleEngineOn(runVehicle, false, true, false)
    SetVehicleDoorsLocked(runVehicle, 1)

    -- Behold køretøjets normale GTA-nummerplade.
    local plate = GetVehicleNumberPlateText(runVehicle)
    Entity(runVehicle).state:set('vehicleLock', { lock = 1, sound = false }, true)

    local netId = VehToNet(runVehicle)
    SetNetworkIdCanMigrate(netId, true)

    local registered, message = lib.callback.await('sb_illegalruns:registerVehicle', false, runId, netId, plate)
    if not registered then
        deleteRunVehicle()
        return false, message or 'Kunne ikke give dig nøgler til bilen.'
    end

    addVehicleTarget(runVehicle)

    -- Placér spilleren direkte på førersædet, når bilen og nøglerne er klar.
    SetPedIntoVehicle(cache.ped, runVehicle, -1)
    SetVehicleEngineOn(runVehicle, true, true, false)

    return true
end

local function createDeliveryZone(runId)
    local run = Config.Runs[runId]
    if not run then return end

    deliveryZone = exports.ox_target:addSphereZone({
        coords = vec3(run.delivery.x, run.delivery.y, run.delivery.z),
        radius = 1.6,
        options = {{
            name = 'sb_illegalruns_delivery',
            icon = 'fa-solid fa-handshake',
            label = 'Aflever pakken',
            canInteract = function()
                return carryingPackage and not packageInVehicle
            end,
            onSelect = function()
                if not lib.progressCircle({ duration = Config.DeliveryDuration, label = 'Afleverer pakken...', canCancel = true, disable = { move = true, car = true, combat = true } }) then return end
                local completed, reward = lib.callback.await('sb_illegalruns:complete', false, runId)
                if not completed then return notify('Tag pakken af ladet, før du afleverer den.', 'error') end

                removePackage()
                clearZones()
                removeBlip()
                activeRun = nil
                if Config.RunVehicle.deleteOnComplete then deleteRunVehicle() end
                notify(('Run gennemført. Du modtog %s kr. i sorte penge.'):format(lib.math.groupdigits(reward)), 'success')
            end
        }}
    })
end

local function startDelivery(runId)
    local run = Config.Runs[runId]
    if not run then return end

    lib.requestModel(Config.CargoVisuals.prop)

    -- Kassen står ved afhentningsstedet. Spilleren skal køre Bisonen hen til den.
    pickupObject = CreateObject(
        Config.CargoVisuals.prop,
        run.pickup.x,
        run.pickup.y,
        run.pickup.z,
        true,
        true,
        false
    )

    if not pickupObject or pickupObject == 0 then
        return notify('Kassen kunne ikke oprettes.', 'error')
    end

    SetEntityAsMissionEntity(pickupObject, true, true)
    SetEntityHeading(pickupObject, run.pickup.w or 0.0)
    PlaceObjectOnGroundProperly(pickupObject)
    FreezeEntityPosition(pickupObject, true)
    SetModelAsNoLongerNeeded(Config.CargoVisuals.prop)

    pickupObjectTarget = 'sb_illegalruns_load_crate'
    exports.ox_target:addLocalEntity(pickupObject, {{
        name = pickupObjectTarget,
        icon = 'fa-solid fa-truck-ramp-box',
        label = 'Læs på Bisonen',
        distance = 2.5,
        canInteract = function()
            if not runVehicle or not DoesEntityExist(runVehicle) or packageInVehicle then return false end
            return #(GetEntityCoords(runVehicle) - GetEntityCoords(pickupObject)) <= Config.PickupVehicleDistance
        end,
        onSelect = function()
            if not runVehicle or not DoesEntityExist(runVehicle) then
                return notify('Bisonen er ikke i nærheden.', 'error')
            end

            if not pickupObject or not DoesEntityExist(pickupObject) then
                return notify('Kassen mangler.', 'error')
            end

            if #(GetEntityCoords(runVehicle) - GetEntityCoords(pickupObject)) > Config.PickupVehicleDistance then
                return notify('Kør Bisonen tættere på kassen.', 'error')
            end

            local done = lib.progressCircle({
                duration = Config.PickupDuration,
                label = 'Lægger kassen på ladet...',
                canCancel = true,
                disable = { move = true, car = true, combat = true }
            })
            if not done then return end

            local success = lib.callback.await(
                'sb_illegalruns:loadPickupIntoVehicle',
                false,
                runId,
                VehToNet(runVehicle),
                GetVehicleNumberPlateText(runVehicle)
            )
            if not success then return notify('Kassen kunne ikke læsses på Bisonen.', 'error') end

            if pickupObjectTarget and pickupObject and DoesEntityExist(pickupObject) then
                exports.ox_target:removeLocalEntity(pickupObject, pickupObjectTarget)
            end
            pickupObjectTarget = nil
            if pickupObject and DoesEntityExist(pickupObject) then DeleteEntity(pickupObject) end
            pickupObject = nil

            packageInVehicle = true
            createCargoVisuals(runVehicle)
            setRoute(run.delivery, 'Aflever pakken')
            createDeliveryZone(runId)
            notify('Kassen er på ladet. Kør til afleveringsstedet.', 'success')
        end
    }})
end

local function openMenu()
    local data = lib.callback.await('sb_illegalruns:getMenuData', false)
    if not data then return end
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', data = data })
end

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb(true)
end)

RegisterNUICallback('startRun', function(data, cb)
    local success, message = lib.callback.await('sb_illegalruns:startRun', false, data.id)
    if not success then cb({ success = false, message = message }) return end

    local spawned, spawnMessage = spawnRunVehicle(data.id)
    if not spawned then
        lib.callback.await('sb_illegalruns:cancelRun', false, data.id)
        cb({ success = false, message = spawnMessage })
        return
    end

    cb({ success = true })
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    activeRun = data.id
    local run = Config.Runs[data.id]
    setRoute(run.pickup, 'Hent kassen')
    startDelivery(data.id)
    notify('Bisonen står klar. Kør hen til kassen og læs den på ladet.', 'success')
end)

CreateThread(function()
    lib.requestModel(Config.Npc.model)
    npc = CreatePed(4, Config.Npc.model, Config.Npc.coords.x, Config.Npc.coords.y, Config.Npc.coords.z - 1.0, Config.Npc.coords.w, false, true)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    TaskStartScenarioInPlace(npc, Config.Npc.scenario, 0, true)

    exports.ox_target:addLocalEntity(npc, {{
        name = 'sb_illegalruns_npc',
        icon = Config.Npc.targetIcon,
        label = Config.Npc.targetLabel,
        distance = Config.InteractionDistance,
        onSelect = openMenu
    }})
end)

CreateThread(function()
    while true do
        if carryingPackage then
            DisableControlAction(0, 23, true)
            DisableControlAction(0, 75, true)
            Wait(0)
        else
            Wait(500)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    SetNuiFocus(false, false)
    clearZones()
    removeBlip()
    removePackage()
    deleteRunVehicle()
    if npc and DoesEntityExist(npc) then DeleteEntity(npc) end
end)
