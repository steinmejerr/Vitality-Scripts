local npc
local activeRun
local packageObject
local routeBlip
local pickupZone
local deliveryZone

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
    if deliveryZone then exports.ox_target:removeZone(deliveryZone) deliveryZone = nil end
end

local function removePackage()
    if packageObject and DoesEntityExist(packageObject) then DeleteEntity(packageObject) end
    packageObject = nil
end

local function attachPackage()
    lib.requestModel(Config.PackageProp)
    packageObject = CreateObject(Config.PackageProp, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(packageObject, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.12, 0.0, -0.18, 250.0, 120.0, 40.0, true, true, false, true, 1, true)
end

local function startDelivery(runId)
    local run = Config.Runs[runId]
    if not run then return end

    pickupZone = exports.ox_target:addSphereZone({
        coords = vec3(run.pickup.x, run.pickup.y, run.pickup.z),
        radius = 1.5,
        options = {{
            name = 'sb_illegalruns_pickup',
            icon = 'fa-solid fa-box-open',
            label = 'Hent pakken',
            onSelect = function()
                if not lib.progressCircle({ duration = Config.PickupDuration, label = 'Henter pakken...', canCancel = true, disable = { move = true, car = true, combat = true } }) then return end
                local success = lib.callback.await('sb_illegalruns:pickup', false, runId)
                if not success then return notify('Pakken kunne ikke hentes.', 'error') end

                exports.ox_target:removeZone(pickupZone)
                pickupZone = nil
                attachPackage()
                setRoute(run.delivery, 'Aflever pakken')
                notify('Pakken er hentet. Kør til afleveringsstedet.', 'success')

                deliveryZone = exports.ox_target:addSphereZone({
                    coords = vec3(run.delivery.x, run.delivery.y, run.delivery.z),
                    radius = 1.6,
                    options = {{
                        name = 'sb_illegalruns_delivery',
                        icon = 'fa-solid fa-handshake',
                        label = 'Aflever pakken',
                        onSelect = function()
                            if not lib.progressCircle({ duration = Config.DeliveryDuration, label = 'Afleverer pakken...', canCancel = true, disable = { move = true, car = true, combat = true } }) then return end
                            local completed, reward = lib.callback.await('sb_illegalruns:complete', false, runId)
                            if not completed then return notify('Pakken kunne ikke afleveres.', 'error') end

                            removePackage()
                            clearZones()
                            removeBlip()
                            activeRun = nil
                            notify(('Run gennemført. Du modtog %s kr. i sorte penge.'):format(lib.math.groupdigits(reward)), 'success')
                        end
                    }}
                })
            end
        }}
    })
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
    cb({ success = success, message = message })
    if not success then return end

    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    activeRun = data.id
    local run = Config.Runs[data.id]
    setRoute(run.pickup, 'Hent pakken')
    startDelivery(data.id)
    notify('GPS er sat til afhentningsstedet.', 'success')
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

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    SetNuiFocus(false, false)
    clearZones()
    removeBlip()
    removePackage()
    if npc and DoesEntityExist(npc) then DeleteEntity(npc) end
end)
