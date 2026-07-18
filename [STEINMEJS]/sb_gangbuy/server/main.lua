local ESX = exports.es_extended:getSharedObject()
local activeMissions = {}
local activeOrders = {}
local actionLocks = {}
local Runtime = { gangs = {}, products = {}, missions = {} }

local function notify(source, description, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Kontakten',
        description = description,
        type = type or 'inform'
    })
end

local function isAdmin(source)
    if source == 0 then return true end
    if Config.Admin and Config.Admin.acePermission and IsPlayerAceAllowed(source, Config.Admin.acePermission) then return true end
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    local group = xPlayer.getGroup and xPlayer.getGroup() or xPlayer.group
    return Config.Admin and Config.Admin.allowedGroups and Config.Admin.allowedGroups[group] == true
end

local function getCharacterIdentifier(xPlayer)
    if Config.ProgressPerCharacter then return xPlayer.identifier end
    return GetPlayerIdentifierByType(xPlayer.source, 'license') or xPlayer.identifier
end

local function reloadRuntime()
    Runtime.gangs, Runtime.products, Runtime.missions = {}, {}, {}

    for _, row in ipairs(MySQL.query.await('SELECT job_name, label, minimum_grade FROM sb_gangbuy_gangs') or {}) do
        Runtime.gangs[row.job_name] = { label = row.label, minimumGrade = tonumber(row.minimum_grade) or 0 }
    end

    for _, row in ipairs(MySQL.query.await('SELECT * FROM sb_gangbuy_products') or {}) do
        Runtime.products[row.id] = {
            label = row.label,
            description = row.description,
            item = row.item_name,
            amount = tonumber(row.amount) or 1,
            price = tonumber(row.price) or 0,
            requiredLevel = tonumber(row.required_level) or 1,
            requiredGrade = tonumber(row.required_grade) or 0,
            deliveryMinutes = { min = tonumber(row.delivery_min) or 1, max = tonumber(row.delivery_max) or 1 },
            icon = row.icon
        }
    end

    for _, row in ipairs(MySQL.query.await('SELECT * FROM sb_gangbuy_missions') or {}) do
        Runtime.missions[row.id] = {
            label = row.label,
            description = row.description,
            requiredLevel = tonumber(row.required_level) or 1,
            requiredGrade = tonumber(row.required_grade) or 0,
            xp = tonumber(row.xp_reward) or 0,
            money = tonumber(row.money_reward) or 0,
            waitSeconds = { min = tonumber(row.wait_min) or 10, max = tonumber(row.wait_max) or 10 },
            icon = row.icon
        }
    end
end

local function seedRuntimeTables()
    if (MySQL.scalar.await('SELECT COUNT(*) FROM sb_gangbuy_gangs') or 0) == 0 then
        for job, gang in pairs(Config.AllowedGangs or {}) do
            MySQL.insert.await('INSERT INTO sb_gangbuy_gangs (job_name, label, minimum_grade) VALUES (?, ?, ?)', { job, gang.label or job, gang.minimumGrade or 0 })
        end
    end
    if (MySQL.scalar.await('SELECT COUNT(*) FROM sb_gangbuy_products') or 0) == 0 then
        for id, p in pairs(Config.Products or {}) do
            MySQL.insert.await([[INSERT INTO sb_gangbuy_products
                (id,label,description,item_name,amount,price,required_level,required_grade,delivery_min,delivery_max,icon)
                VALUES (?,?,?,?,?,?,?,?,?,?,?)]],
                { id,p.label,p.description or '',p.item,p.amount or 1,p.price or 0,p.requiredLevel or 1,p.requiredGrade or 0,p.deliveryMinutes.min,p.deliveryMinutes.max,p.icon or 'fa-solid fa-box' })
        end
    end
    if (MySQL.scalar.await('SELECT COUNT(*) FROM sb_gangbuy_missions') or 0) == 0 then
        for id, m in pairs(Config.Missions or {}) do
            MySQL.insert.await([[INSERT INTO sb_gangbuy_missions
                (id,label,description,required_level,required_grade,xp_reward,money_reward,wait_min,wait_max,icon)
                VALUES (?,?,?,?,?,?,?,?,?,?)]],
                { id,m.label,m.description or '',m.requiredLevel or 1,m.requiredGrade or 0,m.xp or 0,m.money or 0,m.waitSeconds.min,m.waitSeconds.max,m.icon or 'fa-solid fa-box' })
        end
    end
    reloadRuntime()
end

MySQL.ready(function()
    seedRuntimeTables()
end)

local function getGangAccess(xPlayer)
    if not xPlayer or not xPlayer.job then return false end
    local gang = Runtime.gangs[xPlayer.job.name]
    if not gang then return false end
    local grade = tonumber(xPlayer.job.grade) or 0
    if grade < (gang.minimumGrade or 0) then return false end
    return true, gang, grade
end

local function getLevelFromXp(xp)
    local level = 1
    for lvl, data in pairs(Config.Levels) do
        if xp >= data.xp and lvl > level then level = lvl end
    end
    return level
end

local function getProgress(identifier)
    local row = MySQL.single.await('SELECT xp, completed_missions FROM sb_gangbuy_progress WHERE identifier = ?', { identifier })
    if not row then
        MySQL.insert.await('INSERT INTO sb_gangbuy_progress (identifier, xp, completed_missions) VALUES (?, 0, 0)', { identifier })
        return { xp = 0, completed_missions = 0, level = 1 }
    end
    row.xp = tonumber(row.xp) or 0
    row.completed_missions = tonumber(row.completed_missions) or 0
    row.level = getLevelFromXp(row.xp)
    return row
end

local function getNextLevel(level)
    return Config.Levels[level + 1] and Config.Levels[level + 1].xp or nil
end

local function serializeProducts(level, grade)
    local result = {}
    for key, product in pairs(Runtime.products) do
        result[#result + 1] = {
            id=key,label=product.label,description=product.description,amount=product.amount,price=product.price,
            requiredLevel=product.requiredLevel,requiredGrade=product.requiredGrade,deliveryMin=product.deliveryMinutes.min,
            deliveryMax=product.deliveryMinutes.max,icon=product.icon,
            unlocked=level >= product.requiredLevel and grade >= product.requiredGrade
        }
    end
    table.sort(result, function(a,b) return a.requiredLevel == b.requiredLevel and a.label < b.label or a.requiredLevel < b.requiredLevel end)
    return result
end

local function serializeMissions(level, grade)
    local result = {}
    for key, mission in pairs(Runtime.missions) do
        result[#result + 1] = {
            id=key,label=mission.label,description=mission.description,requiredLevel=mission.requiredLevel,
            requiredGrade=mission.requiredGrade,xp=mission.xp,money=mission.money,waitMin=mission.waitSeconds.min,
            waitMax=mission.waitSeconds.max,icon=mission.icon,
            unlocked=level >= mission.requiredLevel and grade >= mission.requiredGrade
        }
    end
    table.sort(result, function(a,b) return a.requiredLevel == b.requiredLevel and a.label < b.label or a.requiredLevel < b.requiredLevel end)
    return result
end

local function orderForClient(order)
    if not order then return nil end
    return { id=order.id,productId=order.productId,label=order.label,amount=order.amount,readyAt=order.readyAt,expiresAt=order.expiresAt,status=order.status,coords=order.status == 'ready' and order.coords or nil }
end

local function getAdminData()
    local gangs, products, missions = {}, {}, {}
    for job,g in pairs(Runtime.gangs) do gangs[#gangs+1] = { jobName=job,label=g.label,minimumGrade=g.minimumGrade } end
    for id,p in pairs(Runtime.products) do products[#products+1] = { id=id,label=p.label,description=p.description,item=p.item,amount=p.amount,price=p.price,requiredLevel=p.requiredLevel,requiredGrade=p.requiredGrade,deliveryMin=p.deliveryMinutes.min,deliveryMax=p.deliveryMinutes.max,icon=p.icon } end
    for id,m in pairs(Runtime.missions) do missions[#missions+1] = { id=id,label=m.label,description=m.description,requiredLevel=m.requiredLevel,requiredGrade=m.requiredGrade,xp=m.xp,money=m.money,waitMin=m.waitSeconds.min,waitMax=m.waitSeconds.max,icon=m.icon } end
    table.sort(gangs,function(a,b)return a.label<b.label end)
    table.sort(products,function(a,b)return a.label<b.label end)
    table.sort(missions,function(a,b)return a.label<b.label end)
    return { allowed=true, mode='admin', gangs=gangs, products=products, missions=missions }
end

lib.callback.register('sb_gangbuy:server:getAdminData', function(source)
    if not isAdmin(source) then return { allowed=false } end
    return getAdminData()
end)

local function cleanId(value)
    value = tostring(value or ''):lower():gsub('%s+','_'):gsub('[^%w_%-]','')
    return value:sub(1,60)
end

lib.callback.register('sb_gangbuy:server:adminSave', function(source, payload)
    if not isAdmin(source) then return { success=false, message='Du har ikke adgang.' } end
    local kind, data, originalId = payload.kind, payload.data or {}, payload.originalId

    if kind == 'gang' then
        local job = cleanId(data.jobName)
        if job == '' or tostring(data.label or '') == '' then return { success=false,message='Jobnavn og navn skal udfyldes.' } end
        if originalId and originalId ~= job then MySQL.update.await('DELETE FROM sb_gangbuy_gangs WHERE job_name = ?', { originalId }) end
        MySQL.prepare.await([[INSERT INTO sb_gangbuy_gangs (job_name,label,minimum_grade) VALUES (?,?,?)
            ON DUPLICATE KEY UPDATE label=VALUES(label),minimum_grade=VALUES(minimum_grade)]], { job,tostring(data.label),math.max(0,tonumber(data.minimumGrade) or 0) })
    elseif kind == 'product' then
        local id = cleanId(data.id)
        if id == '' or tostring(data.label or '') == '' or tostring(data.item or '') == '' then return { success=false,message='ID, navn og item skal udfyldes.' } end
        local dmin,dmax = math.max(0,tonumber(data.deliveryMin) or 0),math.max(0,tonumber(data.deliveryMax) or 0)
        if dmax < dmin then dmax=dmin end
        if originalId and originalId ~= id then MySQL.update.await('DELETE FROM sb_gangbuy_products WHERE id = ?', { originalId }) end
        MySQL.prepare.await([[INSERT INTO sb_gangbuy_products (id,label,description,item_name,amount,price,required_level,required_grade,delivery_min,delivery_max,icon)
            VALUES (?,?,?,?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE label=VALUES(label),description=VALUES(description),item_name=VALUES(item_name),amount=VALUES(amount),price=VALUES(price),required_level=VALUES(required_level),required_grade=VALUES(required_grade),delivery_min=VALUES(delivery_min),delivery_max=VALUES(delivery_max),icon=VALUES(icon)]],
            { id,tostring(data.label),tostring(data.description or ''),tostring(data.item),math.max(1,tonumber(data.amount) or 1),math.max(0,tonumber(data.price) or 0),math.max(1,tonumber(data.requiredLevel) or 1),math.max(0,tonumber(data.requiredGrade) or 0),dmin,dmax,tostring(data.icon or 'fa-solid fa-box') })
    elseif kind == 'mission' then
        local id = cleanId(data.id)
        if id == '' or tostring(data.label or '') == '' then return { success=false,message='ID og navn skal udfyldes.' } end
        local wmin,wmax = math.max(0,tonumber(data.waitMin) or 0),math.max(0,tonumber(data.waitMax) or 0)
        if wmax < wmin then wmax=wmin end
        if originalId and originalId ~= id then MySQL.update.await('DELETE FROM sb_gangbuy_missions WHERE id = ?', { originalId }) end
        MySQL.prepare.await([[INSERT INTO sb_gangbuy_missions (id,label,description,required_level,required_grade,xp_reward,money_reward,wait_min,wait_max,icon)
            VALUES (?,?,?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE label=VALUES(label),description=VALUES(description),required_level=VALUES(required_level),required_grade=VALUES(required_grade),xp_reward=VALUES(xp_reward),money_reward=VALUES(money_reward),wait_min=VALUES(wait_min),wait_max=VALUES(wait_max),icon=VALUES(icon)]],
            { id,tostring(data.label),tostring(data.description or ''),math.max(1,tonumber(data.requiredLevel) or 1),math.max(0,tonumber(data.requiredGrade) or 0),math.max(0,tonumber(data.xp) or 0),math.max(0,tonumber(data.money) or 0),wmin,wmax,tostring(data.icon or 'fa-solid fa-box') })
    else
        return { success=false,message='Ukendt type.' }
    end
    reloadRuntime()
    return { success=true,message='Gemt.',data=getAdminData() }
end)

lib.callback.register('sb_gangbuy:server:adminDelete', function(source, payload)
    if not isAdmin(source) then return { success=false,message='Du har ikke adgang.' } end
    local id = tostring(payload.id or '')
    if payload.kind == 'gang' then MySQL.update.await('DELETE FROM sb_gangbuy_gangs WHERE job_name = ?', { id })
    elseif payload.kind == 'product' then MySQL.update.await('DELETE FROM sb_gangbuy_products WHERE id = ?', { id })
    elseif payload.kind == 'mission' then MySQL.update.await('DELETE FROM sb_gangbuy_missions WHERE id = ?', { id })
    else return { success=false,message='Ukendt type.' } end
    reloadRuntime()
    return { success=true,message='Slettet.',data=getAdminData() }
end)

RegisterCommand((Config.Admin and Config.Admin.command) or 'gangbuyadmin', function(source)
    if not isAdmin(source) then return notify(source,'Du har ikke adgang.','error') end
    TriggerClientEvent('sb_gangbuy:client:openAdmin', source)
end, false)

lib.callback.register('sb_gangbuy:server:getMenuData', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local allowed, gang, grade = getGangAccess(xPlayer)
    if not allowed then return { allowed=false } end
    local identifier = getCharacterIdentifier(xPlayer)
    local progress = getProgress(identifier)
    local mission, order = activeMissions[source], activeOrders[source]
    if order and order.status == 'waiting' and os.time() >= order.readyAt then order.status='ready'; TriggerClientEvent('sb_gangbuy:client:orderReady',source,orderForClient(order)) end
    return {
        allowed=true, mode='player',
        player={name=xPlayer.getName(),gang=gang.label or xPlayer.job.label,gradeLabel=xPlayer.job.grade_label or tostring(grade),grade=grade,xp=progress.xp,level=progress.level,nextLevelXp=getNextLevel(progress.level),completedMissions=progress.completed_missions},
        products=serializeProducts(progress.level,grade),missions=serializeMissions(progress.level,grade),
        activeMission=mission and {id=mission.id,label=mission.label,status=mission.status,readyAt=mission.readyAt,coords=mission.status=='ready' and mission.coords or nil} or nil,
        activeOrder=orderForClient(order),missionCooldown=math.max(0,(Player(source).state.sbGangbuyMissionCooldown or 0)-os.time())
    }
end)

lib.callback.register('sb_gangbuy:server:buyProduct', function(source, productId)
    if actionLocks[source] then return {success=false,message='Vent et øjeblik.'} end
    actionLocks[source]=true
    local xPlayer=ESX.GetPlayerFromId(source); local allowed,_,grade=getGangAccess(xPlayer); local product=Runtime.products[productId]
    if not allowed or not product then actionLocks[source]=nil return {success=false,message='Du har ikke adgang.'} end
    if activeOrders[source] then actionLocks[source]=nil return {success=false,message='Du har allerede en aktiv ordre.'} end
    local progress=getProgress(getCharacterIdentifier(xPlayer))
    if progress.level<product.requiredLevel or grade<product.requiredGrade then actionLocks[source]=nil return {success=false,message='Dit level eller din rang er for lav.'} end
    local account=xPlayer.getAccount(Config.PaymentAccount)
    if not account or account.money<product.price then actionLocks[source]=nil return {success=false,message='Du har ikke råd.'} end
    xPlayer.removeAccountMoney(Config.PaymentAccount,product.price,'Gangbuy ordre')
    local minutes=math.random(product.deliveryMinutes.min,product.deliveryMinutes.max); local readyAt=os.time()+(minutes*60); local coords=Config.DeliveryLocations[math.random(#Config.DeliveryLocations)]
    local orderId=MySQL.insert.await([[INSERT INTO sb_gangbuy_orders (identifier,gang_job,product_id,item_name,amount,price,status,ready_at,expires_at) VALUES (?,?,?,?,?,?,'waiting',FROM_UNIXTIME(?),FROM_UNIXTIME(?))]],{getCharacterIdentifier(xPlayer),xPlayer.job.name,productId,product.item,product.amount,product.price,readyAt,readyAt+(Config.OrderExpireMinutes*60)})
    activeOrders[source]={id=orderId,productId=productId,label=product.label,item=product.item,amount=product.amount,price=product.price,readyAt=readyAt,expiresAt=readyAt+(Config.OrderExpireMinutes*60),coords=coords,status='waiting'}
    actionLocks[source]=nil
    return {success=true,order=orderForClient(activeOrders[source]),message=('Ordren er klar om cirka %s minutter.'):format(minutes)}
end)

lib.callback.register('sb_gangbuy:server:startMission', function(source, missionId)
    local xPlayer=ESX.GetPlayerFromId(source); local allowed,_,grade=getGangAccess(xPlayer); local mission=Runtime.missions[missionId]
    if not allowed or not mission then return {success=false,message='Du har ikke adgang.'} end
    if activeMissions[source] then return {success=false,message='Du har allerede en aktiv opgave.'} end
    local cooldown=Player(source).state.sbGangbuyMissionCooldown or 0
    if cooldown>os.time() then return {success=false,message=('Du kan tage en ny opgave om %s minutter.'):format(math.ceil((cooldown-os.time())/60))} end
    local progress=getProgress(getCharacterIdentifier(xPlayer))
    if progress.level<mission.requiredLevel or grade<mission.requiredGrade then return {success=false,message='Dit level eller din rang er for lav.'} end
    local wait=math.random(mission.waitSeconds.min,mission.waitSeconds.max); local coords=Config.DeliveryLocations[math.random(#Config.DeliveryLocations)]
    activeMissions[source]={id=missionId,label=mission.label,xp=mission.xp,money=mission.money,status='waiting',readyAt=os.time()+wait,coords=coords}
    return {success=true,mission={id=missionId,label=mission.label,status='waiting',readyAt=os.time()+wait},message='Pakken bliver gjort klar. Du får GPS, når den er klar.'}
end)

lib.callback.register('sb_gangbuy:server:collectOrder', function(source, orderId)
    local xPlayer=ESX.GetPlayerFromId(source); local allowed=getGangAccess(xPlayer); local order=activeOrders[source]
    if not allowed or not order or order.id~=tonumber(orderId) then return {success=false,message='Ordren blev ikke fundet.'} end
    if os.time()<order.readyAt then return {success=false,message='Ordren er ikke klar endnu.'} end
    if os.time()>order.expiresAt then MySQL.update.await("UPDATE sb_gangbuy_orders SET status='expired' WHERE id=?",{order.id}); activeOrders[source]=nil return {success=false,message='Ordren er udløbet.'} end
    local canCarry=not Config.UseOxInventory or exports.ox_inventory:CanCarryItem(source,order.item,order.amount)
    if not canCarry then return {success=false,message='Du har ikke plads i inventory.'} end
    if Config.UseOxInventory then exports.ox_inventory:AddItem(source,order.item,order.amount) else xPlayer.addInventoryItem(order.item,order.amount) end
    MySQL.update.await("UPDATE sb_gangbuy_orders SET status='collected', collected_at=NOW() WHERE id=?",{order.id}); activeOrders[source]=nil
    return {success=true,message=('Du fik %sx %s.'):format(order.amount,order.label)}
end)

lib.callback.register('sb_gangbuy:server:collectMission', function(source, missionId)
    local xPlayer=ESX.GetPlayerFromId(source); local allowed=getGangAccess(xPlayer); local mission=activeMissions[source]
    if not allowed or not mission or mission.id~=missionId then return {success=false,message='Opgaven blev ikke fundet.'} end
    if os.time()<mission.readyAt then return {success=false,message='Pakken er ikke klar endnu.'} end
    local identifier=getCharacterIdentifier(xPlayer)
    MySQL.update.await('UPDATE sb_gangbuy_progress SET xp=xp+?, completed_missions=completed_missions+1, updated_at=NOW() WHERE identifier=?',{mission.xp,identifier})
    xPlayer.addAccountMoney(Config.PaymentAccount,mission.money,'Gangbuy mission')
    MySQL.insert.await('INSERT INTO sb_gangbuy_mission_history (identifier,gang_job,mission_id,xp_reward,money_reward) VALUES (?,?,?,?,?)',{identifier,xPlayer.job.name,mission.id,mission.xp,mission.money})
    activeMissions[source]=nil; Player(source).state:set('sbGangbuyMissionCooldown',os.time()+(Config.MissionCooldownMinutes*60),true)
    local progress=getProgress(identifier)
    return {success=true,message=('Opgave klaret: +%s XP og $%s.'):format(mission.xp,mission.money),level=progress.level,xp=progress.xp,nextLevelXp=getNextLevel(progress.level)}
end)

RegisterNetEvent('sb_gangbuy:server:checkReady', function()
    local src=source; local mission=activeMissions[src]
    if mission and mission.status=='waiting' and os.time()>=mission.readyAt then mission.status='ready'; TriggerClientEvent('sb_gangbuy:client:missionReady',src,{id=mission.id,label=mission.label,coords=mission.coords}) end
    local order=activeOrders[src]
    if order and order.status=='waiting' and os.time()>=order.readyAt then order.status='ready'; TriggerClientEvent('sb_gangbuy:client:orderReady',src,orderForClient(order)) end
end)

AddEventHandler('playerDropped', function() activeMissions[source]=nil; activeOrders[source]=nil; actionLocks[source]=nil end)
