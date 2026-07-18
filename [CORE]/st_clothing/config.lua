Config = Config or {}

-- New hud, which utilise images as clothing
-- The old one, is in plain text

Config.NewHud = false

-- Increases faces with 45 for using Onx faces.

Config.OnxFaces = false

-- The position of notification
-- Types from Ox Lib

-- 'top'
-- 'top-right'
-- 'top-left'
-- 'bottom'
-- 'bottom-right'
-- 'bottom-left'
-- 'center-right'
-- 'center-left'

Config.NotifyPosition = "top-right"

-- This is NOT recommended that, this can be used to bug several aspects of the game.
-- If you need a player to change gender, give them the PED model.

Config.CanChangeGender = false

-- If you Previous used Illenium, please use the same size here.
-- Sets how long a Outfit code will be

Config.OutfitCodeLength = 10

-- Your admin rang, to manage peds for players

Config.AdminGroup = "admin"

-- Your Payment methode

Config.PaymentType = "bank"

-- How long cooldown before reloading skin again

Config.ReloadSkinCooldown = 5000

-- If the players face should autofix for the mask.

Config.AutoFixMasks = false

-- Mask fixer settings.
-- These values are used by client/maskFixer.lua.
Config.MaskFixer = {
    -- Male mask drawables that should skip face/head shrinking.
    SkipFaceChangeMale = {
        [148] = true, [237] = true, [238] = true, [240] = true, [242] = true, [243] = true, [244] = true, [245] = true,
        [246] = true, [247] = true, [248] = true, [249] = true, [250] = true, [251] = true, [252] = true,
        [253] = true, [254] = true, [259] = true, [260] = true, [263] = true, [264] = true, [265] = true,
        [267] = true, [271] = true, [272] = true, [273] = true, [274] = true, [275] = true, [276] = true,
        [277] = true, [278] = true, [281] = true, [282] = true, [283] = true, [284] = true,
    },

    -- Female mask drawables that should skip face/head shrinking.
    SkipFaceChangeFemale = {
        [73] = true,
        [120] = true,
        [121] = true,
        [190] = true,
        [238] = true,
        [239] = true,
        [243] = true,
        [248] = true,
        [249] = true,
        [251] = true,
        [253] = true,
    },

    -- Face feature indexes that should be captured/restored for mask corrections.
    FaceFixIndexes = { 8, 9, 10, 13, 19 },

    -- Optional target values per face feature index for advanced custom logic.
    FaceFixValues = {
        [8]  = 0.0,
        [9]  = -0.85,
        [10] = -1.0,
        [13] = -0.75,
        [19] = -0.45,
    },
}

-- Color codes in Hex code for the UI.
-- If you want to edit more, you can edit CSS directly in /web/css/custom-styles.css

Config.Themes = {
    mainColor = "#fff",
    paymentColor = "#fff",
}

-- The CDN Url, to minimize the load on your server, and to make it faster for the players to load the images.
Config.CdnUrl = "false"

-- Please specify addon peds here.

Config.AddonPeds = {
    -- ["konrad_ped"] = true,
}

-- If you have custom peds, and need to set a converted image from a normal ped
-- So like a custom ped named `konrad_ped` which is from `u_m_y_chip` will take the image from `u_m_y_chip`.
-- If not inspired by native ped, just add a custom image in the build folder.

Config.PedConvertImage = {
    -- ["konrad_ped"] = "u_m_y_chip",
}

-- Enable prices in the clothing menu.

Config.HasPrices = false

-- Sets the prices for each category.

Config.CategoryPrices = {
    ["category_clothing"] = 20,
    ["category_access"] = 20,
    ["category_hair"] = 20,
}

-- Here you can set prices for each component.
-- Like in the example component id is 11 (torso) and number 5 in torso is 200$.

Config.ComponentPrices = {
    [11] = {
        [5] = 200,
    }
}

-- Here you can set prices for each prop.
-- Like in the example prop id is 0 (helmet) and number 5 in helmet is 200$.

Config.PropsPrices = {
    [0] = {
        [5] = 200,
    }
}

-- Set restrictions on what can open on the different openings
-- Leave empty or nil, to leave everything open.

--[[
    Different Categories:
        - category_peds (Overview over users peds)
        - category_face (Facial customization)
        - category_skin (Skin customization)
        - category_hair (Hair customization)
        - category_makeup (Makeup customization)
        - category_clothing (Clothing)
        - category_access (Accessories)
    
    
    ATTENTION!!!
    If using Multichar, you can only add access to a player which is created.
    So by limiting Peds to neither is NOT advised
]]

Config.Restrictions = {
    ["command"] = nil, -- By doing this, you are complete disabling this methode.
    ["plastic"] = {
        ["category_clothing"] = true,
        ["category_access"] = true,
        ["category_hair"] = true,
    },
    ["barber"] = {
        ["category_peds"] = true,
        ["category_face"] = true,
        ["category_clothing"] = true,
        ["category_access"] = true,
    },
    ["clothes"] = {
        ["category_face"] = true,
        ["category_skin"] = true,
        ["category_hair"] = true,
    },
}

-- Specify the clothing command here

Config.Command = "clothing"

-- Should wardrobes open with the command

Config.CommandWardrobe = false

-- If /clothing command only should be enable near a store

Config.OnlyEnableCommandNearStore = false

-- The distance to the nearest store

Config.NearestStoreDistance = 20.0

-- If /clothing command should use the nearest store as permissions

Config.UseNearestStore = true

-- If Markers should be enabled or not.

Config.EnableMarkers = true

-- Which key to interact with the different kinds of Stores

Config.EnteractKey = "E"

-- Marker style for the stores.

Config.Size = { x = 0.7, y = 0.7, z = 0.7 }
Config.Color = { r = 240, g = 52, b = 52 }
Config.Type = 20

-- Which stores to have a coord where you can interact with the style of clothing/store.

Config.Stores = {
    ["plastic"] = {
        name = 'Plastikkirug',
        interactLabel = 'Åbn plastikkirugen',
        hasWardrobe = false,
        spriteType = 362,
        spriteColour = 0,
        spriteScale = 0.8,
        StoresCoords = {
            {pos = vector3(357.33, -601.94, 42.28), hasBlip = true}, 
        }
    },
    ["barber"] = {
        name = 'Frisør',
        interactLabel = 'Åbn frisøren',
        hasWardrobe = false,
        spriteType = 71,
        spriteColour = 51,
        spriteScale = 0.8,
        StoresCoords = {
            {pos = vector3(-814.308, -183.823, 36.568), hasBlip = true}, 
            {pos = vector3(136.826, -1708.373, 28.291), hasBlip = true}, 
            {pos = vector3(-1282.604, -1116.757, 5.990), hasBlip = true}, 
            {pos = vector3(1931.513, 3729.671, 31.844), hasBlip = true}, 
            {pos = vector3(1212.840, -472.921, 65.208), hasBlip = true}, 
            {pos = vector3(-32.885, -152.319, 56.076), hasBlip = true}, 
            {pos = vector3(-278.077, 6228.463, 30.695), hasBlip = true}, 
            {pos = vector3(111.67, -1302.51, 28.3), hasBlip = false}, 
        }
    },
    ["clothes"] = {
        name = 'Tøjbutik',
        interactLabel = 'Åbn tøjbutikken',
        hasWardrobe = true,
        spriteType = 366,
        spriteColour = 47,
        spriteScale = 1.0,
        StoresCoords = {
            {pos = vector3(72.254, -1399.102, 28.376), hasBlip = true},
            {pos = vector3(-709.72, -152.24, 36.43), hasBlip = true},
            {pos = vector3(-163.61, -303.07, 38.75), hasBlip = true},
            {pos = vector3(428.694, -800.106, 28.491), hasBlip = true},
            {pos = vector3(-829.413, -1073.710, 10.328), hasBlip = true},
            {pos = vector3(-1450.23, -237.47, 48.83), hasBlip = true},
            {pos = vector3(11.632, 6514.224, 30.877), hasBlip = true},
            {pos = vector3(124.91, -224.13, 53.57), hasBlip = true},
            {pos = vector3(1696.291, 4829.312, 41.063), hasBlip = true},
            {pos = vector3(614.88, 2763.41, 41.10), hasBlip = true},
            {pos = vector3(1190.550, 2713.441, 37.222), hasBlip = true},
            {pos = vector3(-1192.40, -768.36, 16.34), hasBlip = true},
            {pos = vector3(-3171.43, 1043.59, 19.88), hasBlip = true},
            {pos = vector3(-1108.441, 2708.923, 18.107), hasBlip = true},
            {pos = vector3(458.34, -999.08, 29.72), hasBlip = false},
            {pos = vector3(1839.68, 3677.68, 37.94), hasBlip = false},
            {pos = vector3(-452.73, 6016.12, 30.73), hasBlip = false},
            {pos = vector3(379.41, -1408.27, 31.95), hasBlip = false},
            {pos = vector3(1115.52, -3161.18, -37.80), hasBlip = false},
            {pos = vector3(107.54, -1306.74, 28.3), hasBlip = false},
            {pos = vector3(-731.90, -1311.47, 4.00), hasBlip = false},
            {pos = vector3(1748.88, 2482.93, 44.74), hasBlip = false},
            {pos = vector3(1833.96, 2570.84, 45.03), hasBlip = false},
            {pos = vector3(284.34, -1170.51, 28.29), hasBlip = false},
            {pos = vector3(-1382.29, -632.44, 29.82), hasBlip = false},
            {pos = vector3(-566.49, -914.92, 22.87), hasBlip = false},
            {pos = vector3(-590.66, -925.80, 27.70), hasBlip = false},
            {pos = vector3(922.19, 28.46, 70.85), hasBlip = false},
            {pos = vector3(2514.97, -344.52, 100.91), hasBlip = false},
            {pos = vector3(2522.25, -330.46, 93.11), hasBlip = false},
            {pos = vector3(-571.87, 209.79, 82.31), hasBlip = false},
            {pos = vector3(1787.28, 3653.49, 33.87), hasBlip = false},
            {pos = vector3(298.94, -598.25, 42.31), hasBlip = false},
        }
    },
}

Config.TattooShops = {
    {
        pos = vector3(322.73, 180.94, 103.58),
        hasBlip = true,
        name = "Inkhaus Tattoo"
    },
}

Config.TattooSettings = {
    ["vinewood_business"] = {
        companyName = "inkhaus",
        chairs = {
            {
                hasPlayerInChair = false,
                coords = vector4(325.12, 183.33, 103.36, 295.15823364258),
                offset = vector3(0.1, 0.88, -0.6),
                playerSource = 0,
                isPlayerWorking = false,
                workModel = "mxc_tattoo_prop_stool",
                workcoords = vector4(325.1, 184.32, 103.32, 271.47091674805),
                workoffset = vector3(0.2, -0.2, -0.6),
                workNeededTattoos = 0,
            },
        },
    },
}

-- Just Initial clothes for the player.
-- Only modify this, if you know what you are doing.

Config.InitialPlayerClothes = {
    Male = {
        Model = "mp_m_freemode_01",
        Components = {
            {
                component_id = 0, -- Face
                drawable = 0,
                texture = 0
            },
            {
                component_id = 1, -- Mask
                drawable = 0,
                texture = 0
            },
            {
                component_id = 2, -- Hair
                drawable = 0,
                texture = 0
            },
            {
                component_id = 3, -- Upper Body
                drawable = 0,
                texture = 0
            },
            {
                component_id = 4, -- Lower Body
                drawable = 0,
                texture = 0
            },
            {
                component_id = 5, -- Bag
                drawable = 0,
                texture = 0
            },
            {
                component_id = 6, -- Shoes
                drawable = 0,
                texture = 0
            },
            {
                component_id = 7, -- Scarf & Chains
                drawable = 0,
                texture = 0
            },
            {
                component_id = 8, -- Shirt
                drawable = 0,
                texture = 0
            },
            {
                component_id = 9, -- Body Armor
                drawable = 0,
                texture = 0
            },
            {
                component_id = 10, -- Decals
                drawable = 0,
                texture = 0
            },
            {
                component_id = 11, -- Jacket
                drawable = 0,
                texture = 0
            }
        },
        Props = {
            {
                prop_id = 0, -- Hat
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 1, -- Glasses
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 2, -- Ear
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 6, -- Watch
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 7, -- Bracelet
                drawable = -1,
                texture = -1
            }
        },
        Hair = {
            color = 0,
            highlight = 0,
            style = 0,
            texture = 0
        }
    },
    Female = {
        Model = "mp_f_freemode_01",
        Components = {
            {
                component_id = 0, -- Face
                drawable = 0,
                texture = 0
            },
            {
                component_id = 1, -- Mask
                drawable = 0,
                texture = 0
            },
            {
                component_id = 2, -- Hair
                drawable = 0,
                texture = 0
            },
            {
                component_id = 3, -- Upper Body
                drawable = 0,
                texture = 0
            },
            {
                component_id = 4, -- Lower Body
                drawable = 0,
                texture = 0
            },
            {
                component_id = 5, -- Bag
                drawable = 0,
                texture = 0
            },
            {
                component_id = 6, -- Shoes
                drawable = 0,
                texture = 0
            },
            {
                component_id = 7, -- Scarf & Chains
                drawable = 0,
                texture = 0
            },
            {
                component_id = 8, -- Shirt
                drawable = 0,
                texture = 0
            },
            {
                component_id = 9, -- Body Armor
                drawable = 0,
                texture = 0
            },
            {
                component_id = 10, -- Decals
                drawable = 0,
                texture = 0
            },
            {
                component_id = 11, -- Jacket
                drawable = 0,
                texture = 0
            }
        },
        Props = {
            {
                prop_id = 0, -- Hat
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 1, -- Glasses
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 2, -- Ear
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 6, -- Watch
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 7, -- Bracelet
                drawable = -1,
                texture = -1
            }
        },
        Hair = {
            color = 0,
            highlight = 0,
            style = 0,
            texture = 0
        }
    }
}
