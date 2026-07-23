local phoneOpen = false
local dealing = false
local selectedProduct = nil
local currentOffer = nil
local customerPed = nil
local customerBlip = nil
local offerToken = 0
local activeDealId = nil
local offerScheduled = false
local phoneProp = nil
local startPhoneAnimation
local stopPhoneAnimation

local function notify(description, type)
    lib.notify({
        title = 'Drug Phone',
        description = description,
        type = type or 'inform',
        position = 'top-right'
    })
end

local function randomFrom(list)
    return list[math.random(1, #list)]
end

local function setPhoneFocus(state)
    phoneOpen = state
    SetNuiFocus(state, state)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = state and 'open' or 'close' })
    if state then
        startPhoneAnimation()
    else
        stopPhoneAnimation()
    end
end

local function getProductPayload()
    local payload = {}
    for id, product in pairs(Config.Products) do
        payload[#payload + 1] = {
            id = id,
            label = product.label,
            item = product.item,
            icon = product.icon,
            minAmount = product.minAmount,
            maxAmount = product.maxAmount,
            active = dealing and selectedProduct == id
        }
    end
    table.sort(payload, function(a, b) return a.label < b.label end)
    return payload
end

local function syncPhone()
    SendNUIMessage({
        action = 'sync',
        data = {
            products = getProductPayload(),
            dealing = dealing,
            selectedProduct = selectedProduct,
            offer = currentOffer
        }
    })
end

local function openPhone()
    setPhoneFocus(true)
    syncPhone()
end

exports('useDrugPhone', function()
    if IsEntityDead(PlayerPedId()) then return end
    openPhone()
end)

RegisterNetEvent('sb_drugphone:client:usePhone', openPhone)

local function cleanupCustomer(deletePed)
    if customerBlip and DoesBlipExist(customerBlip) then
        RemoveBlip(customerBlip)
    end
    customerBlip = nil

    if customerPed and DoesEntityExist(customerPed) then
        exports.ox_target:removeLocalEntity(customerPed, 'sb_drugphone_deal')
        ClearPedTasks(customerPed)
        FreezeEntityPosition(customerPed, false)
        SetBlockingOfNonTemporaryEvents(customerPed, false)
        if deletePed then
            DeleteEntity(customerPed)
        else
            TaskWanderStandard(customerPed, 10.0, 10)
            SetEntityAsNoLongerNeeded(customerPed)
        end
    end

    customerPed = nil
    activeDealId = nil
end

local function stopDealing(message)
    dealing = false
    selectedProduct = nil
    currentOffer = nil
    offerToken = offerToken + 1
    offerScheduled = false
    cleanupCustomer(false)
    syncPhone()
    if message then notify(message, 'inform') end
end

local function loadModel(model)
    if not IsModelInCdimage(model) or not IsModelValid(model) then return false end
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        Wait(25)
        if GetGameTimer() > timeout then return false end
    end
    return true
end

local function loadAnimDict(dict)
    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(dict) do
        Wait(25)
        if GetGameTimer() > timeout then return false end
    end
    return true
end

startPhoneAnimation = function()
    local ped = PlayerPedId()
    if phoneProp and DoesEntityExist(phoneProp) then DeleteEntity(phoneProp) end
    phoneProp = nil

    local model = `prop_phone_ing`
    if not loadModel(model) then return end
    if not loadAnimDict('cellphone@') then
        SetModelAsNoLongerNeeded(model)
        return
    end

    phoneProp = CreateObject(model, 1.0, 1.0, 1.0, false, false, false)
    AttachEntityToEntity(phoneProp, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    TaskPlayAnim(ped, 'cellphone@', 'cellphone_text_read_base', 3.0, -1.0, -1, 49, 0.0, false, false, false)
    SetModelAsNoLongerNeeded(model)
end

stopPhoneAnimation = function()
    local ped = PlayerPedId()
    StopAnimTask(ped, 'cellphone@', 'cellphone_text_read_base', 2.0)
    if phoneProp and DoesEntityExist(phoneProp) then
        DetachEntity(phoneProp, true, true)
        DeleteEntity(phoneProp)
    end
    phoneProp = nil
end

local function playMessageSound()
    PlaySoundFrontend(-1, 'Text_Arrive_Tone', 'Phone_SoundSet_Default', true)
end

local function performDeal()
    if not customerPed or not DoesEntityExist(customerPed) or not currentOffer or not activeDealId then return end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local customerCoords = GetEntityCoords(customerPed)
    if #(playerCoords - customerCoords) > Config.MaxDealDistance then
        return notify('Du er for langt væk fra kunden.', 'error')
    end

    TaskTurnPedToFaceEntity(playerPed, customerPed, 700)
    TaskTurnPedToFaceEntity(customerPed, playerPed, 700)
    Wait(700)

    local completed = lib.progressBar({
        duration = Config.DealProgress,
        label = ('Sælger %sx %s...'):format(currentOffer.amount, currentOffer.productLabel),
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = 'mp_common', clip = 'givetake1_a' }
    })

    if not completed then
        ClearPedTasks(playerPed)
        ClearPedTasks(customerPed)
        return notify('Handlen blev afbrudt.', 'error')
    end

    TriggerServerEvent('sb_drugphone:server:completeDeal', activeDealId)
end

local function spawnCustomer(location, dealId)
    cleanupCustomer(false)

    local model = randomFrom(Config.CustomerModels)
    if not loadModel(model) then
        notify('Kunden kunne ikke indlæses.', 'error')
        return
    end

    customerPed = CreatePed(4, model, location.x, location.y, location.z - 1.0, location.w, false, false)
    SetEntityAsMissionEntity(customerPed, true, true)
    SetBlockingOfNonTemporaryEvents(customerPed, true)
    SetPedFleeAttributes(customerPed, 0, false)
    SetPedCanRagdoll(customerPed, true)
    TaskStartScenarioInPlace(customerPed, 'WORLD_HUMAN_STAND_MOBILE', 0, true)
    SetModelAsNoLongerNeeded(model)

    customerBlip = AddBlipForEntity(customerPed)
    SetBlipSprite(customerBlip, 480)
    SetBlipColour(customerBlip, 2)
    SetBlipScale(customerBlip, 0.82)
    SetBlipRoute(customerBlip, true)
    SetBlipRouteColour(customerBlip, 2)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Kunde')
    EndTextCommandSetBlipName(customerBlip)

    activeDealId = dealId

    exports.ox_target:addLocalEntity(customerPed, {
        {
            name = 'sb_drugphone_deal',
            icon = 'fa-solid fa-handshake',
            label = 'Gennemfør handel',
            distance = 2.2,
            canInteract = function(entity)
                return entity == customerPed and currentOffer ~= nil and activeDealId ~= nil
            end,
            onSelect = performDeal
        }
    })

    CreateThread(function()
        local thisPed = customerPed
        local expires = GetGameTimer() + Config.CustomerLifetime
        while customerPed == thisPed and DoesEntityExist(thisPed) and GetGameTimer() < expires do
            Wait(1000)
        end
        if customerPed == thisPed and DoesEntityExist(thisPed) then
            notify('Kunden blev træt af at vente.', 'error')
            currentOffer = nil
            cleanupCustomer(false)
            syncPhone()
        end
    end)
end

local function createOffer(productId, token)
    offerScheduled = false
    local product = Config.Products[productId]
    if not product or not dealing or token ~= offerToken or currentOffer then return end

    local amount = math.random(product.minAmount, product.maxAmount)
    local unitPrice = math.random(product.minPrice, product.maxPrice)
    local request = randomFrom(Config.Messages.request):format(amount, product.label)

    currentOffer = {
        productId = productId,
        productLabel = product.label,
        amount = amount,
        unitPrice = unitPrice,
        total = amount * unitPrice,
        message = request,
        intro = randomFrom(Config.Messages.intro),
        expiresAt = GetGameTimer() + (Config.OfferExpiry * 1000)
    }

    syncPhone()
    playMessageSound()
    notify(('Ny besked: %sx %s'):format(amount, product.label), 'inform')

    CreateThread(function()
        Wait(Config.OfferExpiry * 1000)
        if currentOffer and currentOffer.productId == productId and currentOffer.expiresAt <= GetGameTimer() then
            currentOffer = nil
            syncPhone()
            notify('Kunden fandt en anden sælger.', 'error')
        end
    end)
end

local function scheduleNextOffer()
    if offerScheduled or not dealing or not selectedProduct or currentOffer or customerPed then return end
    offerScheduled = true
    offerToken = offerToken + 1
    local token = offerToken
    local delay = math.random(Config.NextOfferDelay.min, Config.NextOfferDelay.max) * 1000
    CreateThread(function()
        Wait(delay)
        createOffer(selectedProduct, token)
    end)
end

RegisterNUICallback('close', function(_, cb)
    setPhoneFocus(false)
    cb(true)
end)

RegisterNUICallback('startDealing', function(data, cb)
    if not Config.Products[data.productId] then
        cb({ ok = false })
        return
    end

    dealing = true
    selectedProduct = data.productId
    currentOffer = nil
    offerScheduled = false
    cleanupCustomer(false)
    syncPhone()
    scheduleNextOffer()
    notify(('Du sælger nu %s. Vent på en besked.'):format(Config.Products[selectedProduct].label), 'success')
    cb({ ok = true })
end)

RegisterNUICallback('stopDealing', function(_, cb)
    stopDealing('Du er ikke længere tilgængelig for kunder.')
    cb({ ok = true })
end)

RegisterNUICallback('rejectOffer', function(_, cb)
    currentOffer = nil
    offerScheduled = false
    syncPhone()
    scheduleNextOffer()
    cb({ ok = true })
end)

RegisterNUICallback('acceptOffer', function(_, cb)
    if not currentOffer then
        cb({ ok = false })
        return
    end

    local locationIndex = math.random(1, #Config.DealLocations)
    TriggerServerEvent('sb_drugphone:server:createDeal', {
        productId = currentOffer.productId,
        amount = currentOffer.amount,
        unitPrice = currentOffer.unitPrice,
        locationIndex = locationIndex
    })
    cb({ ok = true })
end)

RegisterNetEvent('sb_drugphone:client:dealCreated', function(dealId, locationIndex)
    if not currentOffer then return end
    local location = Config.DealLocations[locationIndex]
    if not location then return end

    currentOffer.accepted = true
    currentOffer.reply = randomFrom(Config.Messages.accepted)
    currentOffer.locationMessage = randomFrom(Config.Messages.location)
    syncPhone()
    setPhoneFocus(false)
    SetNewWaypoint(location.x, location.y)
    spawnCustomer(location, dealId)
    notify('Lokationen er markeret på din GPS.', 'success')
end)

RegisterNetEvent('sb_drugphone:client:dealResult', function(success, message)
    if success then
        notify(message, 'success')
        currentOffer = nil
        offerScheduled = false
        cleanupCustomer(false)
        syncPhone()
        scheduleNextOffer()
    else
        notify(message, 'error')
    end
end)

RegisterNetEvent('sb_drugphone:client:dealCancelled', function(message)
    notify(message or 'Handlen blev annulleret.', 'error')
    currentOffer = nil
    offerScheduled = false
    cleanupCustomer(false)
    syncPhone()
    scheduleNextOffer()
end)

CreateThread(function()
    while true do
        Wait(1000)
        if dealing and not currentOffer and not customerPed then
            scheduleNextOffer()
            Wait(5000)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    SetNuiFocus(false, false)
    stopPhoneAnimation()
    cleanupCustomer(true)
end)
