local ESX = exports['es_extended']:getSharedObject()

local function notify(src, description, kind)
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Jobcenter',
        description = description,
        type = kind or 'inform'
    })
end

local function isAdmin(src)
    if src == 0 then return true end
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end

    local group = xPlayer.getGroup and xPlayer.getGroup() or xPlayer.group
    for i = 1, #(Config.AdminGroups or {}) do
        if group == Config.AdminGroups[i] then return true end
    end

    return IsPlayerAceAllowed(src, 'sb_jobcenter.admin')
end

local function decodeRequirements(value)
    if type(value) == 'table' then return value end
    if not value or value == '' then return {} end
    local ok, decoded = pcall(json.decode, value)
    return ok and type(decoded) == 'table' and decoded or {}
end

local function rowToJob(row)
    return {
        id = row.id,
        job = row.job_name,
        grade = tonumber(row.job_grade) or 0,
        label = row.label,
        category = row.category,
        description = row.description or '',
        icon = row.icon or 'fa-solid fa-briefcase',
        color = row.color or '#35df75',
        salary = row.salary or 'Ikke angivet',
        location = {
            x = tonumber(row.location_x) or 0.0,
            y = tonumber(row.location_y) or 0.0,
            z = tonumber(row.location_z) or 0.0
        },
        mapOverride = row.map_x and row.map_y and {
            x = tonumber(row.map_x),
            y = tonumber(row.map_y)
        } or nil,
        requirements = decodeRequirements(row.requirements)
    }
end

local function getJobs()
    local rows = MySQL.query.await('SELECT * FROM sb_jobcenter_jobs ORDER BY sort_order ASC, label ASC') or {}
    local jobs = {}
    for i = 1, #rows do jobs[#jobs + 1] = rowToJob(rows[i]) end
    return jobs
end

local function getJob(jobId)
    local row = MySQL.single.await('SELECT * FROM sb_jobcenter_jobs WHERE id = ? LIMIT 1', { jobId })
    return row and rowToJob(row) or nil
end

local function createTables()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `sb_jobcenter_jobs` (
            `id` varchar(64) NOT NULL,
            `job_name` varchar(64) NOT NULL,
            `job_grade` int NOT NULL DEFAULT 0,
            `label` varchar(100) NOT NULL,
            `category` varchar(64) NOT NULL DEFAULT 'Andet',
            `description` text NULL,
            `icon` varchar(100) NOT NULL DEFAULT 'fa-solid fa-briefcase',
            `color` varchar(16) NOT NULL DEFAULT '#35df75',
            `salary` varchar(100) NOT NULL DEFAULT 'Ikke angivet',
            `location_x` double NOT NULL,
            `location_y` double NOT NULL,
            `location_z` double NOT NULL,
            `map_x` decimal(8,4) NULL,
            `map_y` decimal(8,4) NULL,
            `requirements` longtext NULL,
            `sort_order` int NOT NULL DEFAULT 0,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])
end

local function importLegacyJobs()
    local count = tonumber(MySQL.scalar.await('SELECT COUNT(*) FROM sb_jobcenter_jobs')) or 0
    if count > 0 or type(Config.Jobs) ~= 'table' or #Config.Jobs == 0 then return end

    for i = 1, #Config.Jobs do
        local job = Config.Jobs[i]
        local location = job.location
        MySQL.insert.await([[
            INSERT IGNORE INTO sb_jobcenter_jobs
            (id, job_name, job_grade, label, category, description, icon, color, salary, location_x, location_y, location_z, map_x, map_y, requirements, sort_order)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ]], {
            job.id, job.job, job.grade or 0, job.label, job.category or 'Andet', job.description or '',
            job.icon or 'fa-solid fa-briefcase', job.color or '#35df75', job.salary or 'Ikke angivet',
            location.x, location.y, location.z,
            job.mapOverride and job.mapOverride.x or nil,
            job.mapOverride and job.mapOverride.y or nil,
            json.encode(job.requirements or {}), i
        })
    end

    print(('[sb_jobcenter] Importerede %s eksisterende jobs til databasen.'):format(#Config.Jobs))
end

MySQL.ready(function()
    createTables()
    importLegacyJobs()
end)

lib.callback.register('sb_jobcenter:getJobs', function()
    return getJobs()
end)

lib.callback.register('sb_jobcenter:isAdmin', function(source)
    return isAdmin(source)
end)

lib.callback.register('sb_jobcenter:adminSaveJob', function(source, data)
    if not isAdmin(source) then return { success = false, message = 'Du har ikke adgang.' } end
    if type(data) ~= 'table' then return { success = false, message = 'Ugyldige data.' } end

    local id = tostring(data.id or ''):lower():gsub('[^%w_%-]', '')
    local jobName = tostring(data.job or ''):lower():gsub('[^%w_%-]', '')
    local grade = math.max(0, math.floor(tonumber(data.grade) or 0))
    local label = tostring(data.label or '')
    local coords = data.location

    if id == '' or jobName == '' or label == '' or type(coords) ~= 'table' then
        return { success = false, message = 'ID, ESX-job, navn og lokation skal udfyldes.' }
    end

    if not ESX.DoesJobExist(jobName, grade) then
        return { success = false, message = ('ESX-jobbet "%s" med grade %s findes ikke.'):format(jobName, grade) }
    end

    local oldId = tostring(data.oldId or '')
    if oldId ~= '' and oldId ~= id then
        local duplicate = MySQL.scalar.await('SELECT 1 FROM sb_jobcenter_jobs WHERE id = ? LIMIT 1', { id })
        if duplicate then return { success = false, message = 'Det nye job-ID er allerede i brug.' } end
        MySQL.update.await('DELETE FROM sb_jobcenter_jobs WHERE id = ?', { oldId })
    end

    MySQL.query.await([[
        INSERT INTO sb_jobcenter_jobs
        (id, job_name, job_grade, label, category, description, icon, color, salary, location_x, location_y, location_z, map_x, map_y, requirements, sort_order)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            job_name = VALUES(job_name), job_grade = VALUES(job_grade), label = VALUES(label),
            category = VALUES(category), description = VALUES(description), icon = VALUES(icon),
            color = VALUES(color), salary = VALUES(salary), location_x = VALUES(location_x),
            location_y = VALUES(location_y), location_z = VALUES(location_z),
            requirements = VALUES(requirements), sort_order = VALUES(sort_order)
    ]], {
        id, jobName, grade, label, tostring(data.category or 'Andet'), tostring(data.description or ''),
        tostring(data.icon or 'fa-solid fa-briefcase'), tostring(data.color or '#35df75'),
        tostring(data.salary or 'Ikke angivet'), tonumber(coords.x), tonumber(coords.y), tonumber(coords.z),
        data.map and tonumber(data.map.x) or nil, data.map and tonumber(data.map.y) or nil,
        json.encode(data.requirements or {}), math.floor(tonumber(data.sortOrder) or 0)
    })

    return { success = true, message = ('%s er gemt.'):format(label), job = getJob(id) }
end)

lib.callback.register('sb_jobcenter:adminDeleteJob', function(source, jobId)
    if not isAdmin(source) then return { success = false, message = 'Du har ikke adgang.' } end
    local affected = MySQL.update.await('DELETE FROM sb_jobcenter_jobs WHERE id = ?', { tostring(jobId or '') })
    return affected > 0 and { success = true, message = 'Jobbet er slettet.' }
        or { success = false, message = 'Jobbet blev ikke fundet.' }
end)

lib.callback.register('sb_jobcenter:adminSaveMap', function(source, jobId, x, y)
    if not isAdmin(source) then return false end
    x = math.max(0.0, math.min(100.0, tonumber(x) or -1.0))
    y = math.max(0.0, math.min(100.0, tonumber(y) or -1.0))
    return (MySQL.update.await('UPDATE sb_jobcenter_jobs SET map_x = ?, map_y = ? WHERE id = ?', { x, y, jobId }) or 0) > 0
end)

RegisterNetEvent('sb_jobcenter:selectJob', function(jobId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local selected = getJob(jobId)
    if not xPlayer or not selected then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local center = vector3(Config.JobCenter.ped.coords.x, Config.JobCenter.ped.coords.y, Config.JobCenter.ped.coords.z)
    if #(coords - center) > 10.0 then return end

    if not ESX.DoesJobExist(selected.job, selected.grade) then
        notify(src, ('Jobbet "%s" findes ikke i ESX-databasen.'):format(selected.job), 'error')
        return
    end

    xPlayer.setJob(selected.job, selected.grade)
    TriggerClientEvent('sb_jobcenter:jobSelected', src, selected.job, selected.label)
end)
