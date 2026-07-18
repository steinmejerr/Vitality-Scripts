HideUserHud = function()
    -- Hide the user interface
end

ShowUserHud = function()
    -- Show the user interface
end

Citizen.CreateThread(function()
    for k,v in pairs(Config.Stores) do
        for storeKey, store in pairs(v.StoresCoords) do
            if store.hasBlip then
                local x, y, z = table.unpack(store.pos)
                local blip = AddBlipForCoord(x,y,z)

                SetBlipSprite(blip, v.spriteType)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, v.spriteScale)
                SetBlipColour(blip, v.spriteColour)
                SetBlipAsShortRange(blip, true)
                
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(v.name)
                EndTextCommandSetBlipName(blip)
            end
        end
    end

    for _, store in pairs(Config.TattooShops) do
        local x, y, z = table.unpack(store.pos)
        local blip = AddBlipForCoord(x,y,z)

        SetBlipSprite(blip, 75)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 1)
        SetBlipAsShortRange(blip, true)
        
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(store.name)
        EndTextCommandSetBlipName(blip)
    end
end)

Citizen.CreateThread(function()
    while not hasInit do
        Wait(0);
    end

    if not Config.EnableMarkers then
        return
    end

    for k,v in pairs(Config.Stores) do
        for storeKey, store in pairs(v.StoresCoords) do
            local id = "clothing.." .. k .. "." .. storeKey
            st.create3DTextUIOnCoords(id, {
                {
                    id = id .. "open",
                    text = v.interactLabel,
                    displayDist = 10.0,
                    interactDist = 2.0,
                    key = "E",
                    keyNum = 38,
                    coords = vector3(store.pos.x, store.pos.y, store.pos.z + 1.0),
                    onSelect = function()
                        OpenClothingMenu(k, v.hasWardrobe)
                    end,
                    canInteract = function()
                        return not isInMenu and not cam and not DoesCamExist(cam)
                    end,
                },
            })
        end
    end

    for key, store in pairs(Config.TattooShops) do
        local id = "tattoo_shop_" .. key
        st.create3DTextUIOnCoords(id, {
            {
                id = id .. "open",
                text = "Åben Tatovør",
                displayDist = 10.0,
                interactDist = 2.0,
                key = "E",
                keyNum = 38,
                coords = vector3(store.pos.x, store.pos.y, store.pos.z),
                onSelect = function()
                    OpenTattooMenu()
                end,
                canInteract = function()
                    return not isInMenu and not cam and not DoesCamExist(cam)
                end,
            },
        })
    end
end)