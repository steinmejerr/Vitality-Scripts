function Notify(src, text, notifyType)
    if Config.NotificationType == 'mythic' then
        TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = notifyType, text = text})
    else
        ShowNotification(src, text, notifyType)
    end
end

local webhookLink = ''
local policeWebhookLink = '' -- can be used to send a prison escape alert to police discord

function Webhook(message, police)
    local link = police and policeWebhookLink or webhookLink
    if not link or link == '' then return end

    local msg = {{["color"] = Config.WebhookColor, ["title"] = "**".. _U('webhook_title') .."**", ["description"] = message, ["footer"] = { ["text"] = os.date("%d.%m.%y Time: %X")}}}
    PerformHttpRequest(link, function(err, text, headers) end, 'POST', json.encode({embeds = msg}), { ['Content-Type'] = 'application/json' })
end

function CreateCommands()
    RegisterCommand('jail', function(source, args, raw)
        local targetId = tonumber(args[1])
        local time = tonumber(args[2])

        JailCommand(source, targetId, time, 'jail')
    end, false)

    RegisterCommand('unjail', function(source, args, raw)
        local targetId = tonumber(args[1])
        UnjailCommand(source, targetId)
    end, false)

    if not Config.EnableLockup then return end

    RegisterCommand('lockup', function(source, args, raw)
        local targetId = tonumber(args[1])
        local time = tonumber(args[2])
        local cellIndex = tonumber(args[3])

        if cellIndex and not Config.Coords.lockup.cells[cellIndex] then return end

        JailCommand(source, targetId, time, 'lockup', cellIndex)
    end, false)
end

function PlayerJailed(jailerId, targetId, time, sentenceType, cellIndex, notes) -- called when a player is jailed

end

function PlayerUnjailed(jailerId, targetId, sentenceType) -- called when a player is unjailed
    if Config.DebugMode then print('PlayerUnjailed called', jailerId, targetId, sentenceType) end
end

function TaskRemoveTime(playerId, amount, timeLeft)
    RemoveJailTime(playerId, amount)
end

function TaskBonusRemoveTime(playerId, amount, timeLeft)
    RemoveJailTime(playerId, amount)
end

function RegisterOxStash(identifier)
    if Config.Inventory ~= 'ox' then return end

    local name = ('jail_stash_%s'):format(identifier)
    exports.ox_inventory:RegisterStash(name, _U('stash'), 24, 100000)
end

---@param src number the player who placed the ankle monitor
---@param targetId number the player who the ankle monitor was placed on
function AddedAnkleMonitorToPlayer(src, targetId)

end

---@param src number|nil the player who removed the ankle monitor or nil if called by export
---@param targetId number the player who the ankle monitor was removed from
function RemovedAnkleMonitorFromPlayer(src, targetId)

end

local reclaiming = {}

RegisterCallback('tk_jail:reclaimItems', function(src, cb)
    local xPlayer = GetPlayerFromId(src)
    if not xPlayer then cb(false) return end

    local identifier = GetIdentifier(xPlayer)

    if reclaiming[identifier] then
        cb(false)
        return
    end
    reclaiming[identifier] = true

    local items = GetPlayerJailItems(identifier)

    if not items or not next(items) then
        reclaiming[identifier] = nil
        cb(true)
        return
    end

    if not UpdatePlayerJailItems(identifier) then
        reclaiming[identifier] = nil
        cb(false)
        return
    end

    for _,v in pairs(items) do
        if not Config.ItemsToNotReturn[v.name] then
            AddItem(xPlayer, v.name, v.amount, v.metadata)
        end
    end

    reclaiming[identifier] = nil
    cb(true)
end)

RegisterNetEvent('tk_jail:missionPedEvent', function(pedIndex, indexes, buttonIndex, eventType)
    local src = source
    local xPlayer = GetPlayerFromId(src)
    local pedData = GetPedData(pedIndex, indexes, buttonIndex)

    if pedData.need then
        for _,v in pairs(pedData.need) do
            if GetItemAmount(xPlayer, v.name) < v.amount then
                Notify(src, _U('missing_items'), 'error')
                return
            end
        end

        for _,v in pairs(pedData.need) do
            RemoveItem(xPlayer, v.name, v.amount)
        end
    end

    if pedData.get then
        for _,v in pairs(pedData.get) do
            AddItem(xPlayer, v.name, v.amount)
        end
    end

    if eventType == 'drugLocation' then
        Notify(src, 'Prisoner: Don\'t trust everyone around here', 'error')
    elseif eventType == 'guardName' then
        Notify(src, 'Prisoner: Guard named Freddie Mason, he is located in the cell block. Get him a medkit and a lot of money and he might help you with getting out.', 'inform')
    end
end)