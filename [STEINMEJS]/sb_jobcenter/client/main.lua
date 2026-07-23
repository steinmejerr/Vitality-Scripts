local ESX = exports['es_extended']:getSharedObject()
local jobCenterPed
local uiOpen = false
local currentJobs = {}
local adminCalibration = false

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function worldToMap(coords)
    local calibration = Config.MapCalibration
    local world, image = calibration.world, calibration.image
    local normalizedX = (coords.x - world.minX) / (world.maxX - world.minX)
    local normalizedY = (world.maxY - coords.y) / (world.maxY - world.minY)
    return {
        x = clamp(image.left + normalizedX * (image.right - image.left), 0.0, 100.0),
        y = clamp(image.top + normalizedY * (image.bottom - image.top), 0.0, 100.0)
    }
end

local function notify(description, kind)
    lib.notify({ title = 'Jobcenter', description = description, type = kind or 'inform' })
end

local function closeUI()
    if not uiOpen then return end
    uiOpen = false
    adminCalibration = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function refreshJobs()
    local jobs = lib.callback.await('sb_jobcenter:getJobs', false) or {}
    currentJobs = {}
    for i = 1, #jobs do
        local job = jobs[i]
        job.location = vector3(job.location.x, job.location.y, job.location.z)
        job.map = job.mapOverride or worldToMap(job.location)
        currentJobs[#currentJobs + 1] = job
    end
    return currentJobs
end

local function findJob(id)
    for i = 1, #currentJobs do
        if currentJobs[i].id == id then return currentJobs[i] end
    end
end

local function openUI(calibrateId, adminMode)
    if uiOpen then return end
    refreshJobs()
    uiOpen = true
    adminCalibration = calibrateId ~= nil
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        jobs = currentJobs,
        currentJob = ESX.PlayerData.job and ESX.PlayerData.job.name or 'unemployed',
        admin = adminMode == true
    })
    if calibrateId then
        Wait(150)
        SendNUIMessage({ action = 'calibrateJob', id = calibrateId })
    end
end

local function requirementsToText(requirements)
    return table.concat(requirements or {}, '\n')
end

local function textToRequirements(text)
    local result = {}
    for line in tostring(text or ''):gmatch('[^\r\n,]+') do
        line = line:match('^%s*(.-)%s*$')
        if line ~= '' then result[#result + 1] = line end
    end
    return result
end

local function saveJobDialog(existing)
    local coords = existing and existing.location or GetEntityCoords(PlayerPedId())
    local input = lib.inputDialog(existing and ('Rediger ' .. existing.label) or 'Opret jobcenter-job', {
        { type = 'input', label = 'Job-ID', description = 'Unikt ID, fx taxi', required = true, default = existing and existing.id or '' },
        { type = 'input', label = 'ESX jobnavn', description = 'Skal findes i jobs-tabellen', required = true, default = existing and existing.job or '' },
        { type = 'number', label = 'Job grade', required = true, default = existing and existing.grade or 0, min = 0 },
        { type = 'input', label = 'Visningsnavn', required = true, default = existing and existing.label or '' },
        { type = 'input', label = 'Kategori', required = true, default = existing and existing.category or 'Service' },
        { type = 'textarea', label = 'Beskrivelse', required = true, default = existing and existing.description or '' },
        { type = 'input', label = 'Løntekst', required = true, default = existing and existing.salary or 'Varierer' },
        { type = 'input', label = 'Font Awesome ikon', required = true, default = existing and existing.icon or 'fa-solid fa-briefcase' },
        { type = 'color', label = 'Farve', required = true, default = existing and existing.color or '#35df75' },
        { type = 'textarea', label = 'Krav', description = 'Ét krav pr. linje', default = existing and requirementsToText(existing.requirements) or '' },
        { type = 'number', label = 'Rækkefølge', default = existing and existing.sortOrder or 0 },
        { type = 'checkbox', label = 'Brug min aktuelle position som joblokation', checked = not existing }
    })
    if not input then return end

    if input[12] then coords = GetEntityCoords(PlayerPedId()) end
    local response = lib.callback.await('sb_jobcenter:adminSaveJob', false, {
        oldId = existing and existing.id or nil,
        id = input[1], job = input[2], grade = input[3], label = input[4], category = input[5],
        description = input[6], salary = input[7], icon = input[8], color = input[9],
        requirements = textToRequirements(input[10]), sortOrder = input[11],
        location = { x = coords.x, y = coords.y, z = coords.z },
        map = existing and existing.mapOverride or nil
    })

    notify(response and response.message or 'Kunne ikke gemme jobbet.', response and response.success and 'success' or 'error')
    if response and response.success then
        refreshJobs()
        TriggerEvent('sb_jobcenter:openAdmin')
    end
end

local function openJobActions(job)
    lib.registerContext({
        id = 'sb_jobcenter_admin_job',
        title = job.label,
        menu = 'sb_jobcenter_admin',
        options = {
            { title = 'Rediger job', icon = 'pen', onSelect = function() saveJobDialog(job) end },
            { title = 'Brug min position som lokation', icon = 'location-dot', onSelect = function()
                local coords = GetEntityCoords(PlayerPedId())
                local response = lib.callback.await('sb_jobcenter:adminSaveJob', false, {
                    oldId = job.id, id = job.id, job = job.job, grade = job.grade, label = job.label,
                    category = job.category, description = job.description, salary = job.salary,
                    icon = job.icon, color = job.color, requirements = job.requirements,
                    sortOrder = job.sortOrder or 0, location = { x = coords.x, y = coords.y, z = coords.z },
                    map = job.mapOverride
                })
                notify(response.message, response.success and 'success' or 'error')
                refreshJobs()
            end },
            { title = 'Placér markør præcist på kortet', icon = 'map-location-dot', description = 'Klik på den korrekte placering', onSelect = function()
                lib.hideContext()
                openUI(job.id)
                notify('Klik på jobbets præcise placering på kortet.', 'inform')
            end },
            { title = 'Sæt GPS til lokation', icon = 'route', onSelect = function() SetNewWaypoint(job.location.x, job.location.y) end },
            { title = 'Slet job', icon = 'trash', iconColor = '#ff6b6b', onSelect = function()
                local confirm = lib.alertDialog({ header = 'Slet ' .. job.label .. '?', content = 'Dette kan ikke fortrydes.', centered = true, cancel = true })
                if confirm ~= 'confirm' then return end
                local response = lib.callback.await('sb_jobcenter:adminDeleteJob', false, job.id)
                notify(response.message, response.success and 'success' or 'error')
                refreshJobs()
                TriggerEvent('sb_jobcenter:openAdmin')
            end }
        }
    })
    lib.showContext('sb_jobcenter_admin_job')
end

local function openAdminUI(calibrateId)
    local allowed = lib.callback.await('sb_jobcenter:isAdmin', false)
    if not allowed then
        notify('Du har ikke adgang til jobcenter-administrationen.', 'error')
        return
    end

    if uiOpen then closeUI() end
    openUI(calibrateId, true)
end

AddEventHandler('sb_jobcenter:openAdmin', function(calibrateId)
    openAdminUI(calibrateId)
end)

RegisterCommand('jobcenteradmin', function()
    openAdminUI(nil)
end, false)

local function createPed()
    local data = Config.JobCenter.ped
    lib.requestModel(data.model)
    jobCenterPed = CreatePed(0, data.model, data.coords.x, data.coords.y, data.coords.z - 1.0, data.coords.w, false, false)
    SetEntityInvincible(jobCenterPed, true)
    FreezeEntityPosition(jobCenterPed, true)
    SetBlockingOfNonTemporaryEvents(jobCenterPed, true)
    TaskStartScenarioInPlace(jobCenterPed, data.scenario, 0, true)
    exports.ox_target:addLocalEntity(jobCenterPed, {{
        name = 'sb_jobcenter_open', icon = 'fa-solid fa-briefcase', label = 'Åbn jobcenter',
        distance = Config.JobCenter.targetDistance, onSelect = function() openUI() end
    }})
end

local function createBlip()
    local data = Config.JobCenter
    if not data.blip.enabled then return end
    local blip = AddBlipForCoord(data.ped.coords.x, data.ped.coords.y, data.ped.coords.z)
    SetBlipSprite(blip, data.blip.sprite); SetBlipColour(blip, data.blip.colour)
    SetBlipScale(blip, data.blip.scale); SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING'); AddTextComponentString(data.blip.label); EndTextCommandSetBlipName(blip)
end

RegisterNUICallback('close', function(_, cb) closeUI(); cb(1) end)
RegisterNUICallback('selectJob', function(data, cb) TriggerServerEvent('sb_jobcenter:selectJob', data.id); cb(1) end)
RegisterNUICallback('setWaypoint', function(data, cb)
    local job = findJob(data.id)
    if job then SetNewWaypoint(job.location.x, job.location.y); notify(('GPS sat til %s.'):format(job.label), 'success') end
    cb(1)
end)
RegisterNUICallback('adminGetCurrentPosition', function(_, cb)
    local coords = GetEntityCoords(PlayerPedId())
    cb({
        success = true,
        location = { x = coords.x, y = coords.y, z = coords.z },
        map = worldToMap(coords)
    })
end)

RegisterNUICallback('adminSaveJob', function(data, cb)
    local response = lib.callback.await('sb_jobcenter:adminSaveJob', false, data)
    if response and response.success then
        refreshJobs()
    end
    cb(response or { success = false, message = 'Kunne ikke gemme jobbet.' })
end)

RegisterNUICallback('adminDeleteJob', function(data, cb)
    local response = lib.callback.await('sb_jobcenter:adminDeleteJob', false, data and data.id)
    if response and response.success then
        refreshJobs()
    end
    cb(response or { success = false, message = 'Kunne ikke slette jobbet.' })
end)

RegisterNUICallback('adminStartCalibration', function(data, cb)
    if not data or not data.id or data.id == '' then
        cb({ success = false, message = 'Gem jobbet først, før markøren kan placeres.' })
        return
    end
    adminCalibration = true
    SendNUIMessage({ action = 'calibrateJob', id = data.id })
    cb({ success = true })
end)

RegisterNUICallback('saveMapOverride', function(data, cb)
    if not adminCalibration then cb(0) return end
    local success = lib.callback.await('sb_jobcenter:adminSaveMap', false, data.id, data.x, data.y)
    if success then
        local job = findJob(data.id)
        if job then job.mapOverride = { x = data.x, y = data.y }; job.map = job.mapOverride end
        notify('Kortmarkøren er gemt permanent i databasen.', 'success')
    else notify('Kortmarkøren kunne ikke gemmes.', 'error') end
    adminCalibration = false
    cb(success and 1 or 0)
end)

RegisterNetEvent('sb_jobcenter:jobSelected', function(_, label) closeUI(); notify(('Du arbejder nu som %s.'):format(label), 'success') end)
RegisterNetEvent('esx:playerLoaded', function(xPlayer) ESX.PlayerData = xPlayer end)
RegisterNetEvent('esx:setJob', function(job) ESX.PlayerData.job = job end)

CreateThread(function()
    while not ESX.PlayerData or not ESX.PlayerData.job do Wait(250) end
    createPed(); createBlip()
end)

CreateThread(function()
    while true do
        if uiOpen and IsControlJustReleased(0, 200) then closeUI() end
        Wait(uiOpen and 0 or 500)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    closeUI()
    if jobCenterPed and DoesEntityExist(jobCenterPed) then
        exports.ox_target:removeLocalEntity(jobCenterPed, 'sb_jobcenter_open')
        DeleteEntity(jobCenterPed)
    end
end)
