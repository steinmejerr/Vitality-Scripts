if Config.Framework ~= 'esx' then return end

ESX = exports["es_extended"]:getSharedObject()

TriggerCallback = ESX.TriggerServerCallback

function ShowNotification(text)
    ESX.ShowNotification(text)
end

function GetIdentifier()
    return ESX.PlayerData.identifier
end

function GetCharName()
    ESX.PlayerData = ESX.GetPlayerData()
    return ('%s %s'):format(ESX?.PlayerData?.firstName, ESX?.PlayerData?.lastName)
end

function GetDateOfBirth()
    return ESX?.PlayerData?.dateofbirth
end

function GetJobName()
    return ESX.PlayerData.job.name
end

function GetGrade()
    return ESX.PlayerData.job.grade
end

function GetGradeLabel()
    return ESX.PlayerData.job.grade_label
end

function GetItemLabel(item)
    local p = promise.new()
    TriggerCallback('tk_jail:getItemLabel', function(label)
        p:resolve(label)
    end, item)
    return Citizen.Await(p)
end

function GetItemAmount(item)
    for _,v in pairs(ESX.GetPlayerData().inventory) do
        if v.name == item then
            return v.count or v.amount
        end
    end

    return 0
end

function GetClosestPlayer()
    return ESX.Game.GetClosestPlayer()
end

function OpenDialog(label)
    local p = promise.new()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'jail_dialog', {
        title = label,
    }, function (data, menu)
        p:resolve(data.value)
        menu.close()
    end, function (data, menu)
        p:resolve(nil)
        menu.close()
    end)
    return Citizen.Await(p)
end

function OpenTasksMenu(oldTask, taskData)
    local elements = {
        {label = _U('none')}
    }

    for k,v in pairs(taskData) do
        elements[#elements+1] = {label = _U('task', _U(k), #v.players, Config.Tasks[k].maxPlayers), value = k}
    end

    if Config.DebugMode then print('open task menu esx', oldTask, taskData, json.encode(elements)) end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'choose_task', {
        title =  _U('choose_task'),
        align = Config.MenuAlign,
        elements = elements
    }, function(data, menu)
        menu.close()
        TriggerServerEvent('tk_jail:chooseTask', {task = data.current.value, oldTask = oldTask})
    end, function(data, menu)
        menu.close()
    end)
end

function OpenStashItemsMenu()
    if Config.UseOxLib then
        OxOpenStashItemsMenu()
        return
    end

    local elements = {
        {label = _U('take_items'), value = 'take_items'},
        {label = _U('put_items'), value = 'put_items'},
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stash', {
        title =  _U('stash'),
        align = Config.MenuAlign,
        elements = elements
    }, function(data, menu)
        if data.current.value == 'take_items' then
            StashTakeItems()
        elseif data.current.value == 'put_items' then
            StashPutItems()
        end
    end, function(data, menu)
        menu.close()
    end)
end

function StashPutItems()
    local inventory = GetPlayerInventory()
    local elements = {}

    for _,v in pairs(inventory) do
        table.insert(elements, {
            label = _U('menu_item_label', v.label, v.amount),
            value = v.name,
            amount = v.amount
        })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stash_put_items', {
        title =  _U('your_inventory'),
        align = Config.MenuAlign,
        elements = elements
    }, function(data, menu)
        local amount = string.upper(string.sub(data.current.value, 0, 7)) == 'WEAPON_' and data.current.amount or tonumber(OpenDialog(_U('amount'), 'number'))
        TriggerServerEvent('tk_jail:putItem', data.current.value, amount)
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

function StashTakeItems()
    local items = GetStashItems()
    local elements = {}

    for k,v in pairs(items) do
        table.insert(elements, {
            label = _U('menu_item_label', v.label, v.amount),
            value = v.name,
            amount = v.amount,
            index = k,
        })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stash_take_items', {
        title =  _U('stash_items'),
        align = Config.MenuAlign,
        elements = elements
    }, function(data, menu)
        local amount = string.upper(string.sub(data.current.value, 0, 7)) == 'WEAPON_' and data.current.amount or tonumber(OpenDialog(_U('amount'), 'number'))
        TriggerServerEvent('tk_jail:takeItem', data.current.value, amount, data.current.index)
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

RegisterNetEvent('esx:playerLoaded', function(playerData)
    ESX.PlayerData = playerData

    PlayerLoaded()
end)

RegisterNetEvent('esx:setJob', function(job)
    Wait(500)
    ESX.PlayerData.job = job

    JobUpdated()
end)

CreateThread(function()
    repeat Wait(2000) until ESX and ESX.PlayerData and ESX.PlayerData.job

    frameworkLoaded = true
end)