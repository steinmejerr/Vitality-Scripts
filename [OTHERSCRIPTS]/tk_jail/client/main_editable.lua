tabletObject = nil

function TabletAnim()
    local ped = PlayerPedId()
    local anim = Config.TabletAnim

    if not IsEntityPlayingAnim(ped, anim.dict, anim.name, 3) then
        LoadDict(anim.dict)
        TaskPlayAnim(ped, anim.dict, anim.name, 6.0, 3.0, -1, 49, 1.0, false, false, false)
    end

    if not tabletObject then
        LoadModel(Config.TabletAnim.model)

        local coords = GetEntityCoords(ped)
        tabletObject = CreateObject(Config.TabletAnim.model, coords.x, coords.y, coords.z, true, true, true)
        AttachEntityToEntity(tabletObject, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.03, 0.0, 0.0, 0.0, true, true, false, true, 0, true)
    end
end

function StopTabletAnim()
    local ped = PlayerPedId()
    local anim = Config.TabletAnim

    if IsEntityPlayingAnim(ped, anim.dict, anim.name, 3) then
        ClearPedTasks(ped)
    end

    if tabletObject then
        if DoesEntityExist(tabletObject) then
            DeleteEntity(tabletObject)
        end

        tabletObject = nil
    end
end

function LoadDict(dict)
    if HasAnimDictLoaded(dict) then
        return true
    end

    RequestAnimDict(dict)
    local timer = GetGameTimer() + 5000

    while not HasAnimDictLoaded(dict) and timer > GetGameTimer() do
        Wait(10)
    end

    if not HasAnimDictLoaded(dict) then
        error(('Failed to load anim dict "%s"'):format(dict))
    end

    return HasAnimDictLoaded(dict)
end

function LoadModel(model)
    if HasModelLoaded(model) then
        return true
    end

    RequestModel(model)
    local timer = GetGameTimer() + 5000

    while not HasModelLoaded(model) and timer > GetGameTimer() do
        Wait(10)
    end

    if not HasModelLoaded(model) then
        error(('Failed to load model "%s"'):format(model))
    end

    return HasModelLoaded(model)
end

function Notify(text, notifyType)
    if Config.NotificationType == 'mythic' then
        exports['mythic_notify']:DoHudText(notifyType, text)
    else
        ShowNotification(text, notifyType)
    end
end

function DrawScreenText(text, x, y, scale)
	SetTextFont(4)
	SetTextScale(scale, scale)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()

	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(x, y)
end

local function GetLineCount(str)
    local lines = 1
    for i = 1, #str do
        local c = str:sub(i, i)
        if c == '\n' then lines = lines + 1 end
    end

    return lines
end

function Draw3DText(coords, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(coords, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 470
    local lineCount = GetLineCount(text)
    DrawRect(0.0, 0.0+0.0125*lineCount, 0.017+factor, 0.03*lineCount, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function DisplayHelpText(text)
    AddTextEntry('help_text', text)
    DisplayHelpTextThisFrame('help_text', false)
end

function ShowTextUI(text, coords)
    if Config.UseOxLib then
        lib.showTextUI(text, {position = 'right-center'})
    else
        exports['qb-core']:DrawText(text, 'left')
    end
end

function HideTextUI()
    if Config.UseOxLib then
        lib.hideTextUI()
    else
        exports['qb-core']:HideText()
    end
end

function CreatePrisonBlip()
    local settings = Config.Blips.prison
    if not settings?.enable then return end

    local blip = AddBlipForCoord(settings.coords)

    SetBlipSprite(blip, settings.sprite)
    SetBlipDisplay(blip, settings.display)
    SetBlipScale(blip, settings.scale)
    SetBlipColour(blip, settings.color)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(_U('prison'))
    EndTextCommandSetBlipName(blip)
end

local doingProgress = false

local function StopProgress(ped, anim, obj)
    if DoesEntityExist(obj) then DeleteEntity(obj) end

    if anim then
        ClearPedTasks(ped)
    end

    doingProgress = false
end

function DoProgress(anim, duration)
    local ped = PlayerPedId()

    if doingProgress or IsPedInAnyVehicle(ped, true) then return end
    doingProgress = true

    anim = type(anim) == 'table' and anim[math.random(#anim)] or anim

    if anim?.dict then LoadDict(anim.dict) end

    duration = anim?.duration or duration or 5000
    local startTime = GetGameTimer()
    local controls = {20, 21, 30, 31, 32, 33, 34, 35, 24, 48, 257, 25, 263, 22, 44, 37, 288, 289, 170, 167, 318, 137, 36, 47, 264, 257, 266, 267, 268, 269, 140, 141, 142, 143, 75, 73}

    local obj
    if anim?.prop?.model then
        local pos = anim.prop.pos or vec3(0.0, 0.0, 0.0)
        local rot = anim.prop.rot or vec3(0.0, 0.0, 0.0)

        LoadModel(anim.prop.model)
        local pC = GetEntityCoords(ped)
        obj = CreateObject(anim.prop.model, pC.x, pC.y, pC.z + 0.2, true, true, true)
        AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, anim.prop.bone), pos, rot, true, true, false, true, 1, true)
    end

    if anim?.scenario then
        TaskStartScenarioInPlace(ped, anim.scenario, 0, true)
    end

    while true do
        for _,v in pairs(controls) do DisableControlAction(0, v, true) end

        if anim?.dict and anim?.name and not IsEntityPlayingAnim(ped, anim.dict, anim.name, 3) then
            TaskPlayAnim(ped, anim.dict, anim.name, 2.0, 2.0, -1, anim.flag or 49, 0, false, false, false)
        end

        if IsDisabledControlJustPressed(0, 73) or IsEntityDead(ped) then
            StopProgress(ped, anim, obj)
            return false
        end

        if startTime + duration < GetGameTimer() then
            StopProgress(ped, anim, obj)
            return true
        end
        Wait(0)
    end
end

function DoMinigame(anim, task)
    return DoProgress(anim)
end

function AddSuggestions()
    TriggerEvent('chat:addSuggestion', '/jail', 'Jail a player', {
        { name = "ID", help = "Player ID" },
        { name = "Time", help = "Time (minutes) (optional)" }
    })

    TriggerEvent('chat:addSuggestion', '/unjail', 'Unjail a player', {
        { name = "ID", help = "Player ID" }
    })

    if not Config.EnableLockup then return end

    TriggerEvent('chat:addSuggestion', '/lockup', 'Put a player in lockup', {
        { name = "ID", help = "Player ID" },
        { name = "Time", help = "Time (minutes) (optional)" },
        { name = "Cell", help = "Cell Index (optional)" }
    })
end

function CreateBlip()
    local blip = AddBlipForCoord(Config.JailBlip.coords)

    SetBlipSprite(blip, Config.JailBlip.sprite)
    SetBlipDisplay(blip, Config.JailBlip.display)
    SetBlipScale(blip, Config.JailBlip.scale)
    SetBlipColour(blip, Config.JailBlip.color)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(_U('jail_blip'))
    EndTextCommandSetBlipName(blip)
end

function HealingDone()

end

function ToggleTalkingToNPC(isTalking) -- called when player starts/stops talking to a NPC in prison

end

---called when a player is being sent to jail/lockup and they are taking a mugshot
---@param jailType 'jail' | 'lockup'
function TakePlayerMugshot(jailType)

end

---@param changeType 'lockup' | 'jail' | 'unjail' | 'escape'
function ChangeClothes(changeType)
    if changeType == 'unjail' and GetResourceState('illenium-appearance') == 'started' then
        TriggerEvent('illenium-appearance:client:reloadSkin')
        return
    end

    if Config.Framework == 'qb' then
        if changeType == 'unjail' then
            TriggerServerEvent('qb-clothes:loadPlayerSkin')
            return
        end

        if not Config.Clothes?[changeType] then return end

        local gender = QBCore.Functions.GetPlayerData().charinfo.gender
        if gender == 0 then
            TriggerEvent('qb-clothing:client:loadOutfit', Config.Clothes[changeType].male)
        else
            TriggerEvent('qb-clothing:client:loadOutfit', Config.Clothes[changeType].female)
        end

        return
    end

    if changeType == 'unjail' then
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
            TriggerEvent('skinchanger:loadSkin', skin)
        end)

        return
    end

    if not Config.Clothes?[changeType] then return end

    TriggerEvent('skinchanger:getSkin', function(skin)
        if skin.sex == 0 then
            TriggerEvent('skinchanger:loadClothes', skin, Config.Clothes[changeType].male)
        else
            TriggerEvent('skinchanger:loadClothes', skin, Config.Clothes[changeType].female)
        end
    end)
end

function EscapePrison(escapeType)
    TriggerServerEvent('tk_jail:escapePrison', escapeType)
end

function OpenStashMenu(stashName)
    if Config.Inventory == 'ox' then
        exports.ox_inventory:openInventory('stash', stashName)
    elseif Config.Inventory == 'quasar' then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", stashName)
        TriggerEvent("inventory:client:SetCurrentStash", stashName)
    elseif Config.Framework == 'qb' then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", stashName, {
            maxweight = 100000,
            slots = 24,
        })
        TriggerEvent("inventory:client:SetCurrentStash", stashName)
    else
        OpenStashItemsMenu()
    end
end

function OpenTattooMenu() -- by default setup for illenium-appearance, change here if you use something else
    TriggerEvent('illenium-appearance:client:OpenTattooShop')
end

function OxOpenDialog(label, inputType)
    local value = lib.inputDialog(label, {
        {type = inputType, label = label},
    })

    return value?[1]
end

function OxOpenTasksMenu(oldTask, taskData)
    local elements = {
        {
            title = _U('none'),
            onSelect = function()
                TriggerServerEvent('tk_jail:chooseTask', {oldTask = oldTask})
            end
        }
    }

    for k,v in pairs(taskData) do
        elements[#elements+1] = {
            title = _U('task', _U(k), #v.players, Config.Tasks[k].maxPlayers),
            onSelect = function()
                TriggerServerEvent('tk_jail:chooseTask', {task = k, oldTask = oldTask})
            end
        }
    end

    if Config.DebugMode then print('open task menu', oldTask, taskData) end

    lib.registerContext({
        id = 'choose_task',
        title = _U('choose_task'),
        options = elements
    })

    lib.showContext('choose_task')
end

function OxOpenStashItemsMenu()
    local elements = {
        {
            title = _U('take_items'),
            onSelect = function()
                OxStashTakeItems()
            end
        },
        {
            title = _U('put_items'),
            onSelect = function()
                OxStashPutItems()
            end
        },
    }

    lib.registerContext({
        id = 'stash',
        title = _U('stash'),
        options = elements
    })

    lib.showContext('stash')
end

function OxStashPutItems()
    local inventory = GetPlayerInventory()
    local elements = {}

    for _,v in pairs(inventory) do
        table.insert(elements, {
            title = _U('menu_item_label', v.label, v.amount),
            onSelect = function()
                local amount = tonumber(OxOpenDialog(_U('amount'), 'number'))
                TriggerServerEvent('tk_jail:putItem', v.name, amount)
            end
        })
    end

    lib.registerContext({
        id = 'stash_put_items',
        title = _U('your_inventory'),
        options = elements
    })

    lib.showContext('stash_put_items')
end

function OxStashTakeItems()
    local items = GetStashItems()
    local elements = {}

    for k,v in pairs(items) do
        table.insert(elements, {
            label = _U('menu_item_label', v.label, v.amount),
            onSelect = function()
                local amount = tonumber(OxOpenDialog(_U('amount'), 'number'))
                TriggerServerEvent('tk_jail:takeItem', v.name, amount, k)
            end
        })
    end

    lib.registerContext({
        id = 'stash_take_items',
        title = _U('stash_items'),
        options = elements
    })

    lib.showContext('stash_take_items')
end

function OxRemoveEntityZone(entity)
    exports.ox_target:removeLocalEntity(entity)
end

function OxCreateEntityZone(entity, options)
    exports.ox_target:addLocalEntity(entity, options)
end

function OxRemoveBoxZone(zone)
    exports.ox_target:removeZone(zone)
end

function OxAddBoxZone(options)
    return exports.ox_target:addBoxZone(options)
end

function GetMugshotTime(time)
    return time
end

---Called before the anim is played
---@param targetId number
function StartedRemovingAnkleMonitor(targetId)

end

---Called after the anim is played with DoProgress
---@param targetId number
---@return boolean success
function CanRemoveAnkleMonitor(targetId)
    return true
end

RegisterNetEvent('tk_jail:escapeAlert', function(name, sentence, escapeType)
    if Config.Framework == 'esx' then
        ESX.ShowAdvancedNotification(_U('escape_alert_title'), '', _U('escape_alert_content', name, sentence), 'CHAR_CALL911', 1)
    elseif Config.Framework == 'qb' then
        TriggerServerEvent('police:server:policeAlert', _U('escape_alert_content', name, sentence))
    end
end)