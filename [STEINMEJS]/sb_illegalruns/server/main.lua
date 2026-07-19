local ESX = exports.es_extended:getSharedObject()
local activeRuns = {}

MySQL.ready(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `sb_illegalruns_cooldowns` (
            `identifier` VARCHAR(80) NOT NULL,
            `expires_at` BIGINT NOT NULL DEFAULT 0,
            PRIMARY KEY (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])
end)

local function getIdentifier(xPlayer)
    return xPlayer.getIdentifier()
end

local function getCooldown(identifier)
    local expiresAt = MySQL.scalar.await('SELECT expires_at FROM sb_illegalruns_cooldowns WHERE identifier = ?', { identifier }) or 0
    return math.max(0, tonumber(expiresAt) - os.time())
end

lib.callback.register('sb_illegalruns:getMenuData', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end

    local remaining = getCooldown(getIdentifier(xPlayer))
    local runs = {}

    for key, run in pairs(Config.Runs) do
        runs[#runs + 1] = {
            id = key,
            label = run.label,
            description = run.description,
            icon = run.icon,
            rewardMin = run.reward.min,
            rewardMax = run.reward.max
        }
    end

    table.sort(runs, function(a, b) return a.label < b.label end)

    return {
        runs = runs,
        cooldown = remaining,
        activeRun = activeRuns[source] and activeRuns[source].id or nil,
        cooldownMinutes = Config.CooldownMinutes
    }
end)

lib.callback.register('sb_illegalruns:startRun', function(source, runId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local run = Config.Runs[runId]
    if not xPlayer or not run then return false, 'Runnet findes ikke.' end

    if Config.OneActiveRun and activeRuns[source] then
        return false, 'Du har allerede et aktivt run.'
    end

    local remaining = getCooldown(getIdentifier(xPlayer))
    if remaining > 0 then
        return false, ('Du kan tage et nyt run om %d minutter.'):format(math.ceil(remaining / 60))
    end

    activeRuns[source] = { id = runId, stage = 'pickup' }
    return true
end)

lib.callback.register('sb_illegalruns:pickup', function(source, runId)
    local active = activeRuns[source]
    if not active or active.id ~= runId or active.stage ~= 'pickup' then return false end

    local run = Config.Runs[runId]
    local ped = GetPlayerPed(source)
    if not run or ped == 0 then return false end

    local coords = GetEntityCoords(ped)
    local target = vec3(run.pickup.x, run.pickup.y, run.pickup.z)
    if #(coords - target) > 5.0 then return false end

    active.stage = 'delivery'
    return true
end)

lib.callback.register('sb_illegalruns:complete', function(source, runId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local active = activeRuns[source]
    local run = Config.Runs[runId]
    if not xPlayer or not active or active.id ~= runId or active.stage ~= 'delivery' or not run then return false end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local target = vec3(run.delivery.x, run.delivery.y, run.delivery.z)
    if #(coords - target) > 5.0 then return false end

    local reward = math.random(run.reward.min, run.reward.max)
    xPlayer.addAccountMoney(Config.PaymentAccount, reward, ('Illegal run: %s'):format(run.label))

    local expiresAt = os.time() + (Config.CooldownMinutes * 60)
    MySQL.query.await([[
        INSERT INTO sb_illegalruns_cooldowns (identifier, expires_at)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE expires_at = VALUES(expires_at)
    ]], { getIdentifier(xPlayer), expiresAt })

    activeRuns[source] = nil
    return true, reward
end)

AddEventHandler('playerDropped', function()
    activeRuns[source] = nil
end)
