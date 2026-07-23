local ESX = exports.es_extended:getSharedObject()
local uiOpen = false
local activeSession = nil
local activePed = nil
local tradeInProgress = false
local blockedModels = {}
local protectedTradePeds = {}

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


local function protectTradePed(ped)
    if not ped or not DoesEntityExist(ped) then return false end

    -- Ambient peds styres normalt af GTA's population manager og kan derfor
    -- blive fjernet få sekunder efter, at deres normale opgave er blevet afbrudt.
    -- Mission entity holder ped'en i live, mens spilleren stadig er i området.
    SetEntityAsMissionEntity(ped, true, true)
    protectedTradePeds[ped] = true
    return true
end

local function releaseProtectedPedWhenFarAway(ped)
    CreateThread(function()
        local startedAt = GetGameTimer()
        local minimumProtectionTime = 30000
        local maximumProtectionTime = 180000
        local releaseDistance = 80.0

        while protectedTradePeds[ped] and DoesEntityExist(ped) do
            Wait(2000)

            local elapsed = GetGameTimer() - startedAt
            local playerPed = PlayerPedId()
            local distance = #(GetEntityCoords(playerPed) - GetEntityCoords(ped))

            if (elapsed >= minimumProtectionTime and distance >= releaseDistance)
                or elapsed >= maximumProtectionTime then
                protectedTradePeds[ped] = nil
                SetEntityAsNoLongerNeeded(ped)
                return
            end
        end

        protectedTradePeds[ped] = nil
    end)
end

local function releaseTradePed(ped)
    if not ped or not DoesEntityExist(ped) then return end

    local resume = Config.TradeAnimation.pedResume or {}
    local delay = tonumber(resume.delay) or 650

    Wait(delay)

    if not DoesEntityExist(ped) then return end

    FreezeEntityPosition(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, false)
    SetPedCanRagdoll(ped, true)
    ResetEntityAlpha(ped)
    ClearPedTasks(ped)

    if not IsPedInAnyVehicle(ped, false) and not IsEntityDead(ped) then
        TaskWanderStandard(
            ped,
            tonumber(resume.wanderSpeed) or 10.0,
            tonumber(resume.pauseChance) or 10
        )
        SetPedKeepTask(ped, true)
    end

    -- Ped'en forbliver beskyttet, mens spilleren stadig er i nærheden, så den
    -- ikke forsvinder midt foran spilleren. Den frigives først langt væk.
    releaseProtectedPedWhenFarAway(ped)
end

local function playTradeAnimation(ped)
    local playerPed = PlayerPedId()
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return false end
    protectTradePed(ped)
    if not loadAnimDict(Config.TradeAnimation.dict) then return false end

    local turnDuration = tonumber(Config.TradeAnimation.turnDuration) or 700
    local animationDuration = tonumber(Config.TradeAnimation.duration) or 1450
    local pauseBetween = tonumber(Config.TradeAnimation.pauseBetween) or 180
    local totalDuration = turnDuration + (animationDuration * 2) + pauseBetween
    local animationFinished = false
    local animationSucceeded = true

    CreateThread(function()
        if not DoesEntityExist(ped) or IsEntityDead(ped) then
            animationSucceeded = false
            animationFinished = true
            return
        end

        ClearPedTasks(ped)
        TaskTurnPedToFaceEntity(playerPed, ped, turnDuration)
        TaskTurnPedToFaceEntity(ped, playerPed, turnDuration)
        Wait(turnDuration)

        if not DoesEntityExist(ped) then
            animationSucceeded = false
            animationFinished = true
            return
        end

        FreezeEntityPosition(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        -- Spilleren giver de sorte penge til NPC'en.
        local playerCash = attachCashProp(playerPed)
        TaskPlayAnim(playerPed, Config.TradeAnimation.dict, Config.TradeAnimation.clip, 8.0, -8.0, animationDuration, 48, 0.0, false, false, false)
        TaskPlayAnim(ped, Config.TradeAnimation.dict, Config.TradeAnimation.clip, 8.0, -8.0, animationDuration, 48, 0.0, false, false, false)
        Wait(animationDuration)

        if playerCash and DoesEntityExist(playerCash) then DeleteEntity(playerCash) end
        ClearPedTasks(playerPed)
        if DoesEntityExist(ped) then ClearPedTasks(ped) end
        Wait(pauseBetween)

        if not DoesEntityExist(ped) then
            animationSucceeded = false
            animationFinished = true
            return
        end

        -- NPC'en giver de rene kontanter tilbage.
        local npcCash = attachCashProp(ped)
        TaskPlayAnim(ped, Config.TradeAnimation.dict, Config.TradeAnimation.clip, 8.0, -8.0, animationDuration, 48, 0.0, false, false, false)
        TaskPlayAnim(playerPed, Config.TradeAnimation.dict, Config.TradeAnimation.clip, 8.0, -8.0, animationDuration, 48, 0.0, false, false, false)
        Wait(animationDuration)

        if npcCash and DoesEntityExist(npcCash) then DeleteEntity(npcCash) end
        ClearPedTasks(playerPed)
        if DoesEntityExist(ped) then ClearPedTasks(ped) end

        animationFinished = true
    end)

    local progressCompleted = lib.progressBar({
        duration = totalDuration,
        label = Config.TradeAnimation.progressLabel or 'Gennemfører handel...',
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            car = true,
            combat = true,
            mouse = false
        }
    })

    while not animationFinished do Wait(0) end
    RemoveAnimDict(Config.TradeAnimation.dict)

    if progressCompleted and animationSucceeded then
        CreateThread(function()
            releaseTradePed(ped)
        end)
        return true
    end

    if DoesEntityExist(ped) then
        FreezeEntityPosition(ped, false)
        SetBlockingOfNonTemporaryEvents(ped, false)
        ResetEntityAlpha(ped)
        ClearPedTasks(ped)
        TaskWanderStandard(ped, 10.0, 10)
        SetPedKeepTask(ped, true)
        releaseProtectedPedWhenFarAway(ped)
    end

    return false
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
    if activePed and DoesEntityExist(activePed) then
        FreezeEntityPosition(activePed, false)
        SetBlockingOfNonTemporaryEvents(activePed, false)
        ResetEntityAlpha(activePed)
        ClearPedTasks(activePed)
        TaskWanderStandard(activePed, 10.0, 10)
        SetPedKeepTask(activePed, true)
    end

    for ped in pairs(protectedTradePeds) do
        if DoesEntityExist(ped) then
            FreezeEntityPosition(ped, false)
            SetBlockingOfNonTemporaryEvents(ped, false)
            ClearPedTasks(ped)
            TaskWanderStandard(ped, 10.0, 10)
            SetPedKeepTask(ped, true)
            SetEntityAsNoLongerNeeded(ped)
        end
    end
    protectedTradePeds = {}
    closeUi()
    exports.ox_target:removeGlobalPed('sb_moneylaundering_ambient_npc')
end)
