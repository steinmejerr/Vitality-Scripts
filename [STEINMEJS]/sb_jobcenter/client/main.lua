local ESX = exports['es_extended']:getSharedObject()
local jobCenterPed
local uiOpen = false

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function worldToMap(coords)
    local calibration = Config.MapCalibration
    local world = calibration.world
    local image = calibration.image

    local normalizedX = (coords.x - world.minX) / (world.maxX - world.minX)
    local normalizedY = (world.maxY - coords.y) / (world.maxY - world.minY)

    return {
        x = clamp(image.left + normalizedX * (image.right - image.left), 0.0, 100.0),
        y = clamp(image.top + normalizedY * (image.bottom - image.top), 0.0, 100.0)
    }
end

local function notify(description, type)
    lib.notify({
        title = 'Jobcenter',
        description = description,
        type = type or 'inform'
    })
end

local function closeUI()
    if not uiOpen then return end
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end


local function buildJobs()
    local jobs = {}

    for i = 1, #Config.Jobs do
        local job = Config.Jobs[i]
        jobs[#jobs + 1] = {
            id = job.id,
            job = job.job,
            grade = job.grade,
            label = job.label,
            category = job.category,
            description = job.description,
            icon = job.icon,
            color = job.color,
            salary = job.salary,
            map = job.mapOverride or worldToMap(job.location),
            requirements = job.requirements
        }
    end

    return jobs
end

local function openUI()
    if uiOpen then return end
    uiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        jobs = buildJobs(),
        currentJob = ESX.PlayerData.job and ESX.PlayerData.job.name or 'unemployed'
    })
end

local function createPed()
    local data = Config.JobCenter.ped
    lib.requestModel(data.model)

    jobCenterPed = CreatePed(0, data.model, data.coords.x, data.coords.y, data.coords.z - 1.0, data.coords.w, false, false)
    SetEntityInvincible(jobCenterPed, true)
    FreezeEntityPosition(jobCenterPed, true)
    SetBlockingOfNonTemporaryEvents(jobCenterPed, true)
    TaskStartScenarioInPlace(jobCenterPed, data.scenario, 0, true)

    exports.ox_target:addLocalEntity(jobCenterPed, {
        {
            name = 'sb_jobcenter_open',
            icon = 'fa-solid fa-briefcase',
            label = 'Åbn jobcenter',
            distance = Config.JobCenter.targetDistance,
            onSelect = openUI
        }
    })
end

local function createBlip()
    local data = Config.JobCenter
    if not data.blip.enabled then return end

    local blip = AddBlipForCoord(data.ped.coords.x, data.ped.coords.y, data.ped.coords.z)
    SetBlipSprite(blip, data.blip.sprite)
    SetBlipColour(blip, data.blip.colour)
    SetBlipScale(blip, data.blip.scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(data.blip.label)
    EndTextCommandSetBlipName(blip)
end

RegisterNUICallback('close', function(_, cb)
    closeUI()
    cb(1)
end)

RegisterNUICallback('selectJob', function(data, cb)
    TriggerServerEvent('sb_jobcenter:selectJob', data.id)
    cb(1)
end)


RegisterNUICallback('setWaypoint', function(data, cb)
    for i = 1, #Config.Jobs do
        local job = Config.Jobs[i]
        if job.id == data.id then
            SetNewWaypoint(job.location.x, job.location.y)
            notify(('GPS sat til %s.'):format(job.label), 'success')
            break
        end
    end
    cb(1)
end)

RegisterNetEvent('sb_jobcenter:jobSelected', function(jobName, label)
    closeUI()
    notify(('Du arbejder nu som %s.'):format(label), 'success')
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

CreateThread(function()
    while not ESX.PlayerData or not ESX.PlayerData.job do
        Wait(250)
    end

    createPed()
    createBlip()
end)

CreateThread(function()
    while true do
        if uiOpen and IsControlJustReleased(0, 200) then
            closeUI()
        end
        Wait(uiOpen and 0 or 500)
    end
end)


RegisterCommand(Config.MapCommands.coordinates, function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local map = worldToMap(coords)
    local snippet = ("location = vector3(%.2f, %.2f, %.2f),"):format(coords.x, coords.y, coords.z)

    lib.setClipboard(snippet)
    notify(("Lokationen er kopieret. Kortposition: X %.2f%% / Y %.2f%%"):format(map.x, map.y), 'success')
    print(('[sb_jobcenter] %s -- automatisk kortposition: { x = %.2f, y = %.2f }'):format(snippet, map.x, map.y))
end, false)

RegisterCommand(Config.MapCommands.preview, function(_, args)
    local requestedId = args[1]

    if requestedId then
        local exists = false
        for i = 1, #Config.Jobs do
            if Config.Jobs[i].id == requestedId then
                exists = true
                break
            end
        end

        if not exists then
            notify(('Job-ID "%s" findes ikke.'):format(requestedId), 'error')
            return
        end
    end

    if not uiOpen then
        openUI()
    end

    if requestedId then
        Wait(100)
        SendNUIMessage({ action = 'previewJob', id = requestedId })
    end
end, false)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    closeUI()
    if jobCenterPed and DoesEntityExist(jobCenterPed) then
        exports.ox_target:removeLocalEntity(jobCenterPed, 'sb_jobcenter_open')
        DeleteEntity(jobCenterPed)
    end
end)
