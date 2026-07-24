local config = require 'config.config_s'

SetConvarReplicated('ox:printlevel:' .. cache.resource, config.debug and 'debug' or 'info')

local toiletModel = joaat('prompt_prison_toilet')
---@type table<number, {coords: vector4, entity: number, netID: number, owner: number}>
local toilets = {}

---@param source number
---@return boolean, number
function distanceCheck(source)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local dist = #(playerCoords - vec3(1700.14, 2581.14, 53.44))
    return dist < 200.0, dist
end

---@param coords vector3
---@return {coords: vector4, entity: number, netID: number, owner: number}|nil, number
function getClosestToilet(coords)
    local closestToilet = nil
    local closestDist = math.huge

    for _, toilet in pairs(toilets) do
        local dist = #(vec3(coords.x, coords.y, coords.z) - vec3(toilet.coords.x, toilet.coords.y, toilet.coords.z))
        if dist < closestDist then
            closestDist = dist
            closestToilet = toilet
        end
    end
    return closestToilet, closestDist
end

---@param source number
---@return {coords: vector4, entity: number, netID: number, owner: number}|nil
function getToiletFromSource(source)
    for _, toilet in pairs(toilets) do
        if toilet.owner == source then
            return toilet
        end
    end
end

---@param source number
---@param coords vector4
---@return number? -- netid
lib.callback.register('prompt_prison_escape:createToiletObject', function(source, coords)
    lib.print.info('Player', source, 'requesting toilet object at', coords)
    
    if not config.isPlayerInPrion(source) then
        lib.print.warn('Player tried to create toilet object outside prison:', source)
        return
    end

    local isInRange, dist = distanceCheck(source)
    if not isInRange then
        lib.print.warn('Player tried to create toilet object out of range (' .. dist .. 'm):', source)
        return
    end

    local currentToilet = getToiletFromSource(source)
    if currentToilet then
        lib.print.debug('Player', source, 'already has toilet', currentToilet.id)
        if #(currentToilet.coords - GetEntityCoords(GetPlayerPed(source))) < 1.0 then
            lib.print.warn('Player tried to create toilet object too close to their existing one:', source)
            return
        end
        lib.print.info('Returning existing toilet netID', currentToilet.netID, 'to player', source)
        return currentToilet.netID
    end

    local closestToilet, closestDist = getClosestToilet(vec3(coords.x, coords.y, coords.z))
    if closestToilet and closestDist < 1.0 then
        lib.print.info('Found existing toilet', closestToilet.id, 'at distance', closestDist, '- owner:', closestToilet.owner or 'none')
        
        if not closestToilet.owner then
            lib.print.info('Player', source, 'claiming abandoned toilet', closestToilet.id, 'with', #(closestToilet.unscrewed or {}), 'screws unscrewed')
            closestToilet.owner = source
            
            if closestToilet.cleanupTimer then
                ClearTimeout(closestToilet.cleanupTimer)
                closestToilet.cleanupTimer = nil
                lib.print.debug('Cancelled cleanup timer for toilet', closestToilet.id)
            end
            
            return closestToilet.netID
        else
            lib.print.warn('Toilet', closestToilet.id, 'already owned by player', closestToilet.owner)
        end
        
        return closestToilet.netID
    end

    local randomID = math.random(100000, 999999)
    while toilets[randomID] do
        randomID = math.random(100000, 999999)
    end

    lib.print.info('Creating new toilet', randomID, 'for player', source)
    local entity = CreateObjectNoOffset(toiletModel, coords.x, coords.y, coords.z, true, false, false)
    
    -- Wait for entity to fully initialize before setting rotation
    Wait(100)
    FreezeEntityPosition(entity, true)
    SetEntityRotation(entity, 0.0, 0.0, coords.w, 2, true)
    
    Entity(entity).state:set('isPrisonToilet', true, true)
    Entity(entity).state:set('toiletHeading', coords.w, true) -- Store heading for client sync
    local netID = NetworkGetNetworkIdFromEntity(entity)
    toilets[randomID] = {
        coords = coords,
        entity = entity,
        netID = netID,
        owner = source,
        id = randomID,
    }

    lib.print.debug('Created toilet entity', entity, 'with netID', netID)
    TriggerClientEvent('prompt_prison_escape:toggleToiletVisibility', -1, false, vec3(coords.x, coords.y, coords.z), randomID)

    return netID
end)

lib.callback.register('prompt_prison_escape:unscrewProgress', function(source, screwIndex)
    lib.print.debug('Player', source, 'saving screw progress for screw', screwIndex)
    local toilet = getToiletFromSource(source)
    if not toilet then
        lib.print.warn('Player tried to save screw progress but has no toilet object:', source)
        return false
    end

    if not toilet.unscrewed then
        toilet.unscrewed = {}
        lib.print.debug('Initialized unscrewed table for toilet', toilet.id)
    end

    if not lib.table.contains(toilet.unscrewed, screwIndex) then
        table.insert(toilet.unscrewed, screwIndex)
        lib.print.info('Player', source, 'unscrewed screw #' .. screwIndex, '- Total:', #toilet.unscrewed .. '/4', 'on toilet', toilet.id)
    else
        lib.print.warn('Player', source, 'tried to unscrew already unscrewed screw #' .. screwIndex)
    end

    return true
end)

lib.callback.register('prompt_prison_escape:getUnscrewedState', function(source)
    lib.print.debug('Player', source, 'requesting unscrewed state')
    local toilet = getToiletFromSource(source)
    if not toilet then
        lib.print.debug('No toilet found for player', source)
        return {}
    end
    
    local state = toilet.unscrewed or {}
    lib.print.info('Returning', #state, 'unscrewed screws to player', source, '- screws:', json.encode(state))
    return state
end)

lib.callback.register('prompt_prison_escape:completeEscape', function(source)
    lib.print.info('Player', source, 'attempting to complete escape')
    local toilet = getToiletFromSource(source)
    if not toilet then
        lib.print.warn('Player tried to complete escape but has no toilet object:', source)
        return false
    end

    if not toilet.unscrewed or #toilet.unscrewed < 4 then
        lib.print.warn('Player', source, 'tried to complete escape without all screws unscrewed - has:', #(toilet.unscrewed or {}), '/4')
        return false
    end

    lib.print.info('Player', source, 'successfully escaped - cleaning up toilet', toilet.id)
    
    if toilet.entity and DoesEntityExist(toilet.entity) then
        DeleteEntity(toilet.entity)
        lib.print.debug('Deleted toilet entity', toilet.entity)
    end

    TriggerClientEvent('prompt_prison_escape:toggleToiletVisibility', -1, true, vec3(toilet.coords.x, toilet.coords.y, toilet.coords.z), toilet.id)
    toilets[toilet.id] = nil


    -- Lad det konfigurerede fængselssystem håndtere selve løsladelsen.
    -- For tk_jail bruges server-exporten unjail med teleport=false som standard,
    -- så spilleren forbliver ved flugtstedet.
    if config.onPlayerEscaped then
        local integrationSuccess = config.onPlayerEscaped(source, config)
        if integrationSuccess == false then
            lib.print.warn('Player', source, 'escaped, but jail integration could not release the player')
        end
    end

    TriggerEvent("prompt_prison_escape:playerEscaped", source)

    lib.print.info('Player', source, 'successfully completed prison escape - toilet removed')
    return true
end)

lib.callback.register('prompt_prison_escape:stopSitting', function(source)
    lib.print.debug('Player', source, 'stopping sitting')
    local toilet = getToiletFromSource(source)
    if not toilet then
        lib.print.warn('Player tried to stop sitting but has no toilet object:', source)
        return
    end

    local hasUnscrewed = toilet.unscrewed and #toilet.unscrewed > 0

    if hasUnscrewed then
        lib.print.info('Player', source, 'stopped sitting but unscrewed', #toilet.unscrewed, 'screws - keeping toilet', toilet.id)
        toilet.owner = nil
        toilet.lastUnscrewedCount = #toilet.unscrewed
        lib.print.debug('Toilet', toilet.id, 'owner removed, lastUnscrewedCount set to', toilet.lastUnscrewedCount)

        if toilet.cleanupTimer then
            ClearTimeout(toilet.cleanupTimer)
            lib.print.debug('Cleared existing cleanup timer for toilet', toilet.id)
        end

        lib.print.info('Setting 10 minute cleanup timer for toilet', toilet.id)
        toilet.cleanupTimer = SetTimeout(600000, function()
            local currentToilet = toilets[toilet.id]
            if currentToilet and currentToilet.lastUnscrewedCount == #(currentToilet.unscrewed or {}) then
                lib.print.info('Cleaning up abandoned toilet', toilet.id, 'after 10 minutes - no changes detected')

                if currentToilet.entity and DoesEntityExist(currentToilet.entity) then
                    DeleteEntity(currentToilet.entity)
                    lib.print.debug('Deleted abandoned toilet entity', currentToilet.entity)
                end

                TriggerClientEvent('prompt_prison_escape:toggleToiletVisibility', -1, true, vec3(currentToilet.coords.x, currentToilet.coords.y, currentToilet.coords.z), currentToilet.id)
                toilets[toilet.id] = nil
                lib.print.debug('Toilet', toilet.id, 'removed from toilets table')
            else
                lib.print.info('Toilet', toilet.id, 'was modified or removed - skipping cleanup')
            end
        end)
    else
        lib.print.info('Player', source, 'stopped sitting without unscrewing - cleaning toilet', toilet.id, 'immediately')

        if toilet.entity and DoesEntityExist(toilet.entity) then
            DeleteEntity(toilet.entity)
            lib.print.debug('Deleted toilet entity', toilet.entity)
        end

        TriggerClientEvent('prompt_prison_escape:toggleToiletVisibility', -1, true, vec3(toilet.coords.x, toilet.coords.y, toilet.coords.z), toilet.id)
        toilets[toilet.id] = nil
        lib.print.debug('Toilet', toilet.id, 'removed from toilets table')
    end

    lib.print.info('Player', source, 'successfully stopped sitting')
    return true
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then
        for id, toilet in pairs(toilets) do
            if toilet.cleanupTimer then
                ClearTimeout(toilet.cleanupTimer)
            end
            
            if toilet.entity and DoesEntityExist(toilet.entity) then
                DeleteEntity(toilet.entity)
            end
            toilets[id] = nil
        end
    end
end)