local ESX = exports.es_extended:getSharedObject()
local uiOpen = false
local activeSession = nil
local activePed = nil
local blockedModels = {}

for i = 1, #(Config.AmbientNPCs.blockedModels or {}) do
    blockedModels[Config.AmbientNPCs.blockedModels[i]] = true
end

local function notify(description, notifyType)
    lib.notify({
        title = 'Hvidvask',
        description = description,
        type = notifyType or 'inform'
    })
end

local function closeUi()
    if not uiOpen then return end

    uiOpen = false
    activeSession = nil
    activePed = nil
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function canUsePed(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return false end
    if not IsEntityAPed(entity) or IsPedAPlayer(entity) then return false end
    if Config.AmbientNPCs.requireHuman and not IsPedHuman(entity) then return false end
    if Config.AmbientNPCs.requireAlive and IsEntityDead(entity) then return false end
    if Config.AmbientNPCs.onlyWalkingPeds and IsPedInAnyVehicle(entity, false) then return false end
    if blockedModels[GetEntityModel(entity)] then return false end
    if IsPedFleeing(entity) or IsPedInCombat(entity, PlayerPedId()) then return false end

    return true
end

local function openLaundering(entity)
    if uiOpen or not canUsePed(entity) then return end

    -- The selected ambient ped is validated locally. Many map peds are not
    -- networked, so the server cannot reliably resolve their entity/network id.
    local data = lib.callback.await('sb_moneylaundering:getData', false)

    if not data then
        return notify('Personen vil ikke handle lige nu.', 'error')
    end

    activeSession = data.session
    activePed = entity
    uiOpen = true

    if DoesEntityExist(entity) then
        TaskTurnPedToFaceEntity(entity, PlayerPedId(), 1000)
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        data = data
    })
end

CreateThread(function()
    exports.ox_target:addGlobalPed({
        {
            name = 'sb_moneylaundering_ambient_npc',
            icon = 'fa-solid fa-money-bill-transfer',
            label = 'Sælg sorte penge',
            distance = Config.TargetDistance,
            canInteract = function(entity)
                return not uiOpen and canUsePed(entity)
            end,
            onSelect = function(data)
                openLaundering(data.entity)
            end
        }
    })
end)

RegisterNUICallback('close', function(_, cb)
    closeUi()
    cb({ success = true })
end)

RegisterNUICallback('launder', function(data, cb)
    local amount = math.floor(tonumber(data.amount) or 0)

    if not activeSession then
        cb({ success = false, message = 'Handlen er ikke længere aktiv.' })
        return
    end

    if activePed and DoesEntityExist(activePed) then
        local distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(activePed))
        if distance > (Config.TargetDistance + 1.5) then
            closeUi()
            cb({ success = false, message = 'Du gik for langt væk fra personen.' })
            return
        end
    end

    local result = lib.callback.await('sb_moneylaundering:launder', false, activeSession, amount)

    if not result then
        cb({ success = false, message = 'Handlen kunne ikke gennemføres.' })
        return
    end

    if result.success then
        SendNUIMessage({
            action = 'transactionSuccess',
            data = result
        })
        notify(('Du modtog %s kr. kontant.'):format(result.payoutFormatted), 'success')
    elseif result.close then
        closeUi()
    end

    cb(result)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    closeUi()
    exports.ox_target:removeGlobalPed('sb_moneylaundering_ambient_npc')
end)
