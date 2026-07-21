local ESX = exports.es_extended:getSharedObject()
local uiOpen = false
local activeSession = nil
local activePed = nil
local tradeInProgress = false
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

local function loadAnimDict(dict)
    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 5000

    while not HasAnimDictLoaded(dict) do
        Wait(0)
        if GetGameTimer() > timeout then return false end
    end

    return true
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

local function hideUiForTrade()
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hideForTrade' })
end

local function attachCashProp(ped)
    local model = Config.TradeAnimation.cashProp
    if not loadModel(model) then return nil end

    local coords = GetEntityCoords(ped)
    local prop = CreateObjectNoOffset(model, coords.x, coords.y, coords.z, false, false, false)
    local bone = GetPedBoneIndex(ped, 57005)

    AttachEntityToEntity(prop, ped, bone, 0.10, 0.015, -0.025, -80.0, 0.0, 15.0, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(model)

    return prop
end

local function playTradeAnimation(ped)
    local playerPed = PlayerPedId()
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return false end
    if not loadAnimDict(Config.TradeAnimation.dict) then return false end

    local originalHeading = GetEntityHeading(ped)
    local wasFrozen = IsEntityPositionFrozen(ped)

    ClearPedTasks(ped)
    TaskTurnPedToFaceEntity(playerPed, ped, 700)
    TaskTurnPedToFaceEntity(ped, playerPed, 700)
    Wait(700)

    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    -- Først giver spilleren de sorte penge til NPC'en.
    local playerCash = attachCashProp(playerPed)
    TaskPlayAnim(playerPed, Config.TradeAnimation.dict, Config.TradeAnimation.clip, 8.0, -8.0, Config.TradeAnimation.duration, 48, 0.0, false, false, false)
    TaskPlayAnim(ped, Config.TradeAnimation.dict, Config.TradeAnimation.clip, 8.0, -8.0, Config.TradeAnimation.duration, 48, 0.0, false, false, false)
    Wait(Config.TradeAnimation.duration)

    if playerCash and DoesEntityExist(playerCash) then DeleteEntity(playerCash) end
    ClearPedTasks(playerPed)
    ClearPedTasks(ped)
    Wait(Config.TradeAnimation.pauseBetween)

    -- Derefter giver NPC'en de rene kontanter tilbage.
    local npcCash = attachCashProp(ped)
    TaskPlayAnim(ped, Config.TradeAnimation.dict, Config.TradeAnimation.clip, 8.0, -8.0, Config.TradeAnimation.duration, 48, 0.0, false, false, false)
    TaskPlayAnim(playerPed, Config.TradeAnimation.dict, Config.TradeAnimation.clip, 8.0, -8.0, Config.TradeAnimation.duration, 48, 0.0, false, false, false)
    Wait(Config.TradeAnimation.duration)

    if npcCash and DoesEntityExist(npcCash) then DeleteEntity(npcCash) end
    ClearPedTasks(playerPed)
    ClearPedTasks(ped)

    if not wasFrozen then FreezeEntityPosition(ped, false) end
    SetEntityHeading(ped, originalHeading)
    SetBlockingOfNonTemporaryEvents(ped, false)
    RemoveAnimDict(Config.TradeAnimation.dict)

    return true
end

local function closeUi()
    if tradeInProgress then return end
    if not uiOpen and not activeSession then return end

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
                return not uiOpen and not tradeInProgress and canUsePed(entity)
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
    local session = activeSession
    local ped = activePed

    if tradeInProgress then
        cb({ success = false, message = 'Handlen er allerede i gang.' })
        return
    end

    if not session or not ped or not DoesEntityExist(ped) then
        cb({ success = false, message = 'Handlen er ikke længere aktiv.' })
        return
    end

    local distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(ped))
    if distance > (Config.TargetDistance + 1.5) then
        closeUi()
        cb({ success = false, message = 'Du gik for langt væk fra personen.' })
        return
    end

    tradeInProgress = true
    hideUiForTrade()

    CreateThread(function()
        local animationPlayed = playTradeAnimation(ped)

        if not animationPlayed then
            tradeInProgress = false
            activeSession = nil
            activePed = nil
            notify('Handlen kunne ikke gennemføres.', 'error')
            cb({ success = false, message = 'Animationen kunne ikke startes.' })
            return
        end

        local result = lib.callback.await('sb_moneylaundering:launder', false, session, amount)

        tradeInProgress = false
        activeSession = nil
        activePed = nil

        if result and result.success then
            notify(('Du modtog %s kr. kontant.'):format(result.payoutFormatted), 'success')
        else
            notify(result and result.message or 'Handlen kunne ikke gennemføres.', 'error')
        end

        cb(result or { success = false, message = 'Handlen kunne ikke gennemføres.' })
    end)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    tradeInProgress = false
    ClearPedTasks(PlayerPedId())
    closeUi()
    exports.ox_target:removeGlobalPed('sb_moneylaundering_ambient_npc')
end)
