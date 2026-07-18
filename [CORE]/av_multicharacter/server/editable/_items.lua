while not Config.Framework do Wait(0) end

local usingOX = GetResourceState("ox_inventory") == "started"
local usingQS = GetResourceState("qs-inventory") == "started"
local usingOrigen = GetResourceState("origen_inventory") == "started"
local usingCodem = GetResourceState("codem-inventory") == "started"

function GiveStarterItems(source)
    if not Config.GiveItems then return end
    dbug("GiveStarterItems()")
    if usingOX then
        while not exports['ox_inventory']:GetInventory(source) do
            Wait(100)
        end
    end
    if Config.StarterItems and next(Config.StarterItems) then
        dbug("Give Items to player...")
        for i = 1, #Config.StarterItems do
            local added = false
            local item = Config.StarterItems[i]
            local metadata = item.metadata and type(item.metadata) == 'function' and item.metadata(source) or {}
            dbug("addItem(source, item, amount, metadata)", source, item.name, item.amount, json.encode(metadata))
            if not added and usingOX then
                exports['ox_inventory']:AddItem(source, item.name, item.amount, metadata)
                added = true
            end
            if not added and usingQS then
                exports['qs-inventory']:AddItem(source, item.name, item.amount, nil, metadata)
                added = true
            end
            if not added and usingOrigen then
                exports['origen_inventory']:addItem(source, item.name, item.amount, metadata)
                added = true
            end
            if not added and usingCodem then
                exports['codem-inventory']:AddItem(source, item.name, item.amount, metadata)
                added = true
            end
            if not added then -- Use default Framework addItem function
                AddItem(source, item.name, item.amount, metadata)
            end
        end
    end
end