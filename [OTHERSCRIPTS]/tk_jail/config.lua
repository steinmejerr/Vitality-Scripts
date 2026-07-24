Config = {}

Config.Framework = 'esx' -- esx/qb
Config.NotificationType = 'esx' -- esx/qb/mythic
Config.Locale = 'en' -- en/fi
Config.ImagePath = 'nui://ox_inventory/web/images' -- path for images used in trading (for QB: nui://qb-inventory/html/images) (for ox_inventory: nui://ox_inventory/web/images)
Config.DebugMode = false -- false/true

Config.Inventory = 'ox' -- default / ox / quasar
Config.JailCigaretteItem = 'cigarette'

Config.HelpNotification = true -- false / true, use help notification (top left) instead of the 3D text (only used if ox_lib and ox_target set to false) !! if set to true, go to locales/en.lua and change interact_button = '[E] ' to interact_button = '~INPUT_CONTEXT~ '
Config.UseOxLib = true -- false / true, remember to add " shared_script '@ox_lib/init.lua' " to fxmanifest.lua if set to true
Config.UseOxTarget = true -- false / true

Config.InteractKey = 38 -- key used for interactions (https://docs.fivem.net/docs/game-references/controls/)
Config.CancelKey = 73 -- key used for canceling stuff (exiting bed, getting rid of broom in hand, etc.) (https://docs.fivem.net/docs/game-references/controls/)

Config.EnableLockup = true -- true / false

Config.Command = {
    enable = true, -- false / true, enable the /jailmdt command
    needItem = false, -- true/false, should you need Config.TabletItem when using the /jailmdt command
}
Config.TabletItem = 'prison_mdt'
Config.TabletAnim = {
    dict = 'amb@world_human_seat_wall_tablet@female@base',
    name = 'base',
    model = `prop_cs_tablet`,
}
Config.ShowJailInMDT = true -- true / false, show "jail" in MDT "Jail type" selection menu
Config.MDTTimeMultiplier = 1 -- multiplier to use for time set in jail mdt
Config.MaxJailTime = 0 -- maximum jail time in minutes (0 = no limit)
Config.UseNameSelector = false -- false / true, show nearby player names in MDT home instead of player id + closest player switch
Config.MDTNameSelectorDistance = 10.0 -- max distance for showing nearby players in MDT name selector
Config.MDTCoords = { -- coords where you can open the prison MDT (you won't need the item)
    --vec3(-1419.87, -436.3, 36.05)
}
Config.DisableFugitivePage = false -- false / true, disable the fugitive page in the MDT

Config.AdminGroups = { -- group names that count as admins (can use jail commands, etc.)
    admin = true,
}
Config.TeleportIfAdmin = true -- should you be teleported back to prison when going too far even if you are an admin

Config.PoliceJobs = {
    jail = { -- jobs that can use jail command
        police = 0, -- job name, min grade
    },
    lockup = { -- jobs that can use lockup command
        police = 0,
    },
    unjail = { -- jobs that can use unjail command
        police = 0,
    },
    other = {
        police = 0,
    },
}

Config.Coords = {
    jail = {
        inside = vec4(1773.96, 2552.05, 45.57, 91.68),
        outside = vec4(1846.60, 2585.85, 45.67, 269.72),
        beds = {
            vec4(1762.34, 2584.95, 46.82, 92.30),
            vec4(1761.82, 2582.77, 46.82, 98.70),
            vec4(1761.52, 2587.26, 46.82, 101.87),
            vec4(1757.22, 2587.39, 46.81, 268.94),
            vec4(1757.43, 2585.51, 46.76, 267.44),
            vec4(1757.21, 2583.26, 46.81, 270.27),
            vec4(1757.38, 2581.23, 46.81, 265.16),
        },
        search = {
            vec3(1622.97, 2482.71, 45.65),
            vec3(1625.87, 2480.39, 45.65),
            vec3(1628.40, 2478.01, 45.65),
            vec3(1631.19, 2468.78, 45.65),
            vec3(1628.85, 2466.15, 45.65),
            vec3(1624.45, 2461.07, 45.65),
            vec3(1617.52, 2459.72, 45.65),
            vec3(1614.89, 2461.75, 45.65),
            vec3(1612.01, 2464.10, 45.65),
            vec3(1609.47, 2466.55, 45.65),
            vec3(1604.00, 2470.75, 45.65),
            vec3(1601.45, 2473.23, 45.65),
            vec3(1598.71, 2475.57, 45.65),
            vec3(1596.00, 2477.48, 45.65),
            vec3(1595.61, 2484.64, 45.65),
            vec3(1597.91, 2487.33, 45.65),
            vec3(1600.06, 2489.98, 45.65),
            vec3(1602.14, 2492.59, 45.65),
            vec3(1611.61, 2491.38, 45.65),
            vec3(1614.79, 2489.64, 45.65),
            vec3(1617.35, 2487.41, 45.65),
        },
        chooseTask = {
            {coords = vec4(1609.87, 2472.57, 45.65, 141.40), obj = `tr_prop_tr_planning_board_01a`}
        },
        trading = {
            {coords = vec4(1665.0571, 2568.6677, 45.5648, 180.2381), ped = `s_m_y_prisoner_01`}
        },
        takeTray = {
            vector3(1731.80, 2586.76, 45.42),
        },
        takeFood = {
            vector3(1740.59, 2586.74, 45.42),
            vector3(1737.16, 2586.74, 45.42),
        },
        deliverFood = {
            vector3(1739.20, 2574.94, 45.42),
            vector3(1739.10, 2571.50, 45.42),
            vector3(1739.19, 2566.17, 45.42),
            vector3(1734.17, 2566.09, 45.42),
            vector3(1734.09, 2571.55, 45.42),
            vector3(1734.12, 2574.89, 45.42),
            vector3(1734.18, 2578.41, 45.42),
            vector3(1734.07, 2581.96, 45.42),
            vector3(1739.19, 2578.56, 45.42),
            vector3(1739.10, 2582.12, 45.42),
            vector3(1741.15, 2581.92, 45.42),
            vector3(1741.20, 2578.41, 45.42),
            vector3(1741.17, 2574.78, 45.42),
            vector3(1741.08, 2571.47, 45.42),
            vector3(1741.13, 2566.14, 45.44),
            vector3(1746.18, 2566.17, 45.49),
            vector3(1746.14, 2571.47, 45.42),
            vector3(1746.14, 2574.85, 45.42),
            vector3(1746.17, 2578.62, 45.42),
            vector3(1746.24, 2582.10, 45.42),
            vector3(1747.94, 2586.79, 45.42),
            vector3(1745.86, 2586.66, 45.42),
            vector3(1731.99, 2582.08, 45.42),
            vector3(1731.98, 2578.53, 45.42),
            vector3(1732.00, 2574.99, 45.42),
            vector3(1732.01, 2571.59, 45.42),
            vector3(1732.01, 2566.15, 45.42),
            vector3(1726.98, 2566.03, 45.42),
            vector3(1726.97, 2571.50, 45.42),
            vector3(1727.04, 2575.02, 45.42),
            vector3(1726.97, 2578.52, 45.42),
            vector3(1726.94, 2582.10, 45.42),
            vector3(1725.38, 2586.65, 45.42),
            vector3(1727.40, 2586.55, 45.42),
        },
        takeBroom = {
            vector3(1588.90, 2549.76, 45.63)
        },
        clean = {
            vector3(1768.70, 2487.82, 45.65),
            vector3(1777.55, 2486.24, 45.65),
            vector3(1758.70, 2493.20, 45.65),
            vector3(1747.99, 2483.02, 48.80),
            vector3(1744.62, 2480.70, 48.80),
            vector3(1681.88, 2447.55, 45.65),
            vector3(1609.60, 2485.05, 45.65),
            vector3(1609.24, 2471.94, 48.80),
            vector3(1623.82, 2460.95, 48.80),
            vector3(1731.95, 2643.30, 45.57),
            vector3(1735.36, 2625.65, 45.57),
            vector3(1749.94, 2638.36, 45.57),
        },
        washDishes = {
            vector3(1740.11, 2589.37, 45.42),
            vector3(1741.49, 2589.33, 45.42),
        },
        cell = {
            vector3(1622.93, 2482.03, 45.65),
            vector3(1625.91, 2479.64, 45.65),
            vector3(1628.37, 2477.43, 45.65),
            vector3(1630.46, 2468.95, 45.65),
            vector3(1628.30, 2466.11, 45.65),
            vector3(1623.76, 2461.14, 45.65),
            vector3(1617.31, 2460.13, 45.65),
            vector3(1614.81, 2462.22, 45.65),
            vector3(1612.07, 2464.79, 45.65),
            vector3(1609.40, 2466.84, 45.65),
            vector3(1604.07, 2471.50, 45.65),
            vector3(1601.19, 2473.52, 45.65),
            vector3(1598.50, 2475.91, 45.65),
            vector3(1595.77, 2478.34, 45.65),
            vector3(1595.96, 2484.93, 45.65),
            vector3(1598.34, 2487.63, 45.65),
            vector3(1600.80, 2489.86, 45.65),
            vector3(1602.71, 2492.85, 45.65),
            vector3(1612.18, 2491.31, 45.65),
            vector3(1614.82, 2489.20, 45.65),
            vector3(1617.66, 2487.05, 45.65),
        },
        electricalWork = {
            vector3(1737.70, 2504.61, 45.57),
            vector3(1760.80, 2517.19, 45.57),
            vector3(1718.52, 2527.79, 45.57),
            vector3(1700.28, 2475.00, 45.56),
            vector3(1664.77, 2501.58, 45.57),
            vector3(1630.33, 2527.00, 45.57),
            vector3(1634.69, 2553.65, 45.57),
            vector3(1629.60, 2564.37, 45.57),
        },
        garden = {
            vector3(1736.75, 2513.42, 45.88),
            vector3(1757.89, 2510.34, 45.57),
            vector3(1771.64, 2556.03, 45.59),
            vector3(1617.91, 2562.82, 45.57),
            vector3(1618.37, 2547.68, 45.57),
            vector3(1631.13, 2509.28, 45.57),
            vector3(1647.48, 2496.07, 45.57),
            vector3(1680.24, 2488.87, 45.57),
            vector3(1699.23, 2485.32, 45.56),

        },
        trash = {
            {coords = vec3(1698.1238, 2500.6812, 45.5648), obj = `prop_pile_dirt_03`, offset = vec3(0.0, 0.0, -0.4), dist = 5.0},
            {coords = vec3(1653.0190, 2511.9290, 45.5648), obj = `prop_rub_pile_01`, offset = vec3(0.0, 0.0, -0.4)},
            {coords = vec3(1605.0726, 2558.5869, 45.5649), obj = `prop_pile_dirt_03`, offset = vec3(0.0, 0.0, -0.4), dist = 5.0},
            {coords = vec3(1756.7240, 2554.4441, 45.5650), obj = `prop_rub_pile_02`, offset = vec3(0.0, 0.0, -0.4)},
            {coords = vec3(1803.1504, 2557.8848, 45.4887), obj = `prop_pile_dirt_07_cr`, offset = vec3(0.0, 0.0, -0.4)},
            {coords = vec3(1803.5133, 2586.4871, 45.5033), obj = `prop_pile_dirt_06`, offset = vec3(0.0, 0.0, -0.4)},
        },
        farm = {
            {coords = vec4(1736.0011, 2513.4644, 45.5650, 353.2136), obj = `prop_plant_int_06b`},
            {coords = vec4(1754.1221, 2520.8467, 45.5650, 75.2968), obj = `prop_plant_int_06b`},
        },
        gymEquipment = {
            {coords = vec4(1643.2102, 2527.9575, 45.5649, 233.1983), anim = 'chinup'},
            {coords = vec4(1648.9636, 2529.7866, 45.5649, 231.4831), anim = 'chinup'},
            {coords = vec4(1746.5917, 2481.6497, 45.7407, 117.2088), anim = 'chinup'},
            {coords = vec4(1744.0376, 2479.3667, 45.7593, 124.2948), anim = 'yoga'},
            {coords = vec4(1743.0878, 2480.7957, 45.7593, 119.2467), anim = 'yoga'},
            {coords = vec4(1744.8198, 2477.8904, 45.7592, 123.7085), anim = 'yoga'},
            {coords = vec4(1744.0696, 2482.7209, 45.7406, 35.2196), anim = 'weights'},
            {coords = vec4(1748.9055, 2539.2463, 43.5854, 118.1770), anim = 'weights'},
            {coords = vec4(1747.6646, 2541.4792, 43.5855, 121.2392), anim = 'weights'},
            {coords = vec4(1746.4828, 2543.7578, 43.5855, 119.8471), anim = 'weights'},
            {coords = vec4(1638.9906, 2527.9548, 45.5648, 9.8168), anim = 'weights'},
        },
        tattoo = {
            {coords = vector4(1734.17, 2677.72, 45.81, 174.13), ped = `u_m_y_tattoo_01`}
        },
        distanceChecks = {
            {coords = vec3(1691.0688, 2581.4453, 45.5648), dist = 185}
        }
    },
    lockup = {
        cells = {
            {coords = vec4(478.0039, -1014.0449, 26.2732, 0.0), dist = 2.0, name = 'PD Cell 1', outside = vec4(489.9900, -1007.8348, 27.9475, 265.9652)}, -- you can add specific outside coords for certain cells with "outside", if not set, the outside value below will be used
            {coords = vec4(480.9711, -1013.9343, 26.2732, 0.0), dist = 2.0},
            {coords = vec4(483.8827, -1013.8624, 26.2732, 0.0), dist = 2.0},
            {coords = vec4(487.1088, -1013.9053, 26.2732, 0.0), dist = 2.0},
            {coords = vec4(485.4856, -1005.9135, 26.2732, 190.0), dist = 4.0},
        },
        outside = vec4(491.2402, -1002.3777, 27.8318, 270.3093),
    },
}

Config.Interact = { -- interact distances for different actions
    plant = 2,
    explosive = 2,
    fence = 2,
    utensils = 2,
    beds = 2,
    search = 2,
    takeTray = 2,
    takeFood = 2,
    deliverFood = 2,
    takeBroom = 2,
    clean = 2,
    electricalWork = 2,
    washDishes = 2,
    garden = 2,
    cell = 2,
    reclaim = 2,
    gym = 2,
    drug = 1.5,
    hack = 2,
    chooseTask = 2,
    trading = 2,
    trash = 2,
    ped = 2,
    roulette = 2,
    tattoo = 2,
    ankleMonitor = 2,
    mdt = 2,
}

Config.Tasks = { -- settings for tasks
    serve_food = {
        reward = {
            money = {chance = 25, amount = {min = 10, max = 50}, account = 'money'}, -- chance to find money, amount, account money goes to
            time = {chance = 100, amount = {min = 1, max = 2}}, -- chance to get time off sentence when task completed, amount
            item = {
                chance = 25, -- change to find an item when task completed
                items = {
                    {name = 'cigarette', chance = 25, amount = {min = 1, max = 3}}, -- name, chance to find this item, amount
                    {name = 'burger', chance = 25, amount = {min = 1, max = 1}},
                    {name = 'water', chance = 25, amount = {min = 1, max = 1}},
                    {name = 'jail_chemicals', chance = 5, amount = {min = 1, max = 2}},
                    {name = 'plastic_knife', chance = 25, amount = {min = 1, max = 1}},
                    {name = 'plastic_spoon', chance = 25, amount = {min = 1, max = 1}},
                    {name = 'plastic_fork', chance = 25, amount = {min = 1, max = 1}},
                }
            },
        },
        complete = {
            tasksNeeded = #Config.Coords.jail.deliverFood, -- tasks needed to complete (dont change)
            timeBonus = {min = 1, max = 3}, -- how many minutes should be deducted from all players doing this task when all task spots are done
        },
        blip = {
            coords = Config.Coords.jail.deliverFood, -- coords for blips
            remove = true, -- should blip be removed when a spot is done
        },
        maxPlayers = 10, -- max players in group
        kickIfIdle = true, -- should players that are doing any tasks be kicked
    },
    sweep_floors = {
        reward = {
            money = {chance = 25, amount = {min = 10, max = 50}, account = 'money'},
            time = {chance = 100, amount = {min = 1, max = 2}},
            item = {
                chance = 25,
                items = {
                    {name = 'cigarette', chance = 25, amount = {min = 1, max = 3}},
                    {name = 'jail_chemicals', chance = 5, amount = {min = 1, max = 3}},
                    {name = 'phone', chance = 5, amount = {min = 1, max = 1}},
                    {name = 'battery', chance = 0.5, amount = {min = 1, max = 1}},
                    {name = 'weapon_flashlight', chance = 1, amount = {min = 1, max = 1}},
                    {name = 'plastic_scrap', chance = 50, amount = {min = 1, max = 1}},
                },
            },
        },
        complete = {
            tasksNeeded = #Config.Coords.jail.clean,
            timeBonus = {min = 1, max = 3},
        },
        blip = {
            coords = Config.Coords.jail.clean,
            remove = true,
        },
        maxPlayers = 10,
        kickIfIdle = true,
    },
    electrical = {
        reward = {
            money = {chance = 25, amount = {min = 10, max = 50}, account = 'money'},
            time = {chance = 100, amount = {min = 1, max = 2}},
            item = {
                chance = 25,
                items = {
                    {name = 'cigarette', chance = 25, amount = {min = 1, max = 3}},
                    {name = 'electric_cable', chance = 25, amount = {min = 1, max = 2}},
                    {name = 'battery', chance = 1, amount = {min = 1, max = 1}},
                    {name = 'tape', chance = 10, amount = {min = 1, max = 2}},
                    {name = 'weapon_flashlight', chance = 1, amount = {min = 1, max = 1}},
                    {name = 'metal_pipe', chance = 0.5, amount = {min = 1, max = 1}},
                    {name = 'radio', chance = 0.1, amount = {min = 1, max = 1}},
                    {name = 'electronic_scrap', chance = 50, amount = {min = 1, max = 1}},
                }
            },
        },
        complete = {
            tasksNeeded = #Config.Coords.jail.electricalWork,
            timeBonus = {min = 1, max = 3},
        },
        blip = {
            coords = Config.Coords.jail.electricalWork,
            remove = true,
        },
        maxPlayers = 10,
        kickIfIdle = true,
    },
    wash_dishes = {
        reward = {
            money = {chance = 25, amount = {min = 10, max = 50}, account = 'money'},
            time = {chance = 100, amount = {min = 1, max = 2}},
            item = {
                chance = 25,
                items = {
                    {name = 'cigarette', chance = 25, amount = {min = 1, max = 3}},
                    {name = 'plastic_spoon', chance = 25, amount = {min = 1, max = 1}},
                    {name = 'plastic_knife', chance = 25, amount = {min = 1, max = 1}},
                    {name = 'plastic_fork', chance = 25, amount = {min = 1, max = 1}},
                    {name = 'plastic_scrap', chance = 50, amount = {min = 1, max = 2}},
                    {name = 'jail_chemicals', chance = 5, amount = {min = 1, max = 2}},
                },
            },
        },
        complete = {
            tasksNeeded = 10,
            timeBonus = {min = 1, max = 3},
        },
        blip = {
            coords = Config.Coords.jail.washDishes,
            remove = false,
        },
        dontRemoveSpots = true,
        maxPlayers = 10,
        kickIfIdle = true,
    },
    trash = {
        reward = {
            money = {chance = 25, amount = {min = 10, max = 50}, account = 'money'},
            time = {chance = 100, amount = {min = 1, max = 2}},
            item = {
                chance = 25,
                items = {
                    {name = 'cigarette', chance = 25, amount = {min = 1, max = 3}},
                    {name = 'battery', chance = 1, amount = {min = 1, max = 1}},
                    {name = 'jail_lighter', chance = 0.01, amount = {min = 1, max = 1}},
                    {name = 'metal_scrap', chance = 25, amount = {min = 1, max = 1}},
                    {name = 'plastic_scrap', chance = 50, amount = {min = 1, max = 1}},
                    {name = 'electronic_scrap', chance = 25, amount = {min = 1, max = 1}},
                    {name = 'chemicals', chance = 5, amount = {min = 1, max = 1}},
                    {name = 'weapon_flashlight', chance = 1, amount = {min = 1, max = 1}},
                    {name = 'slammer', chance = 5, amount = {min = 1, max = 1}},
                    {name = 'tape', chance = 5, amount = {min = 1, max = 1}},
                    {name = 'tin_foil', chance = 5, amount = {min = 1, max = 1}},
                },
            },
        },
        complete = {
            tasksNeeded = #Config.Coords.jail.trash,
            timeBonus = {min = 1, max = 3},
        },
        blip = {
            coords = Config.Coords.jail.trash,
            remove = true,
        },
        maxPlayers = 10,
        kickIfIdle = true,
    },
    garden = {
        reward = {
            money = {chance = 25, amount = {min = 10, max = 50}, account = 'money'},
            time = {chance = 100, amount = {min = 1, max = 2}},
            item = {
                chance = 25,
                items = {
                    {name = 'cigarette', chance = 25, amount = {min = 1, max = 3}},
                    {name = 'weapon_knife', chance = 0.5, amount = {min = 1, max = 1}},
                    {name = 'tape', chance = 10, amount = {min = 1, max = 1}},
                    {name = 'gunpowder', chance = 10, amount = {min = 1, max = 1}},
                    {name = 'prisunflower_seed', chance = 10, amount = {min = 1, max = 1}},
                    {name = 'plastic_scrap', chance = 50, amount = {min = 1, max = 1}},
                },
            },
        },
        complete = {
            tasksNeeded = #Config.Coords.jail.garden,
            timeBonus = {min = 1, max = 3},
        },
        blip = {
            coords = Config.Coords.jail.garden,
            remove = true,
        },
        maxPlayers = 10,
        kickIfIdle = true,
    },
}

Config.PassTimeOffline = { -- should jail time pass offline
    jail = false,
    lockup = false,
}

Config.Reward = { -- give money rewards to player for jailing
    --[[jail {
        account = 'bank',
        amount = 100,
    },
    lockup = {
        account = 'bank',
        amount = 100,
    },]]
}

Config.TeleportAnim = { -- change teleport anim
    jail = 'mugshot', -- switchout / mugshot / none
    lockup = 'switchout',
}
Config.TeleportOnlyNearby = false -- false / true, should you only be able to use teleport option in jail MDT when jailing the closest player
Config.TeleportOnUnjail = true -- true / false, should you be teleported outside when unjailed

Config.Mugshot = { -- settings for mugshot
    coords = vector4(1827.97, 2595.92, 45.89, 179.55),
    anim = {
        dict = 'mp_character_creation@lineup@male_a',
        name = 'loop_raised'
    }
}

Config.TakeItems = { -- should items be taken from the player when put in jail
    jail = true,
    lockup = true,
}

Config.ItemsToNotTake = {
    --id = true,
}

Config.ItemsToNotReturn = {
    --WEAPON_PISTOL = true,
}

Config.Reclaim = {
    allowWithSentence = true,  -- should you be able to reclaim items when you have an active sentence
    coords = { -- coords where you can reclaim your items from
        vec3(1840.4368, 2579.3962, 46.0143),
    }
}

if Config.Framework == 'qb' then
    Config.Clothes = { -- clothes for jail and lockup (qb)
        jail = {
            male = {
                outfitData = {
                    ['t-shirt'] = {item = 15, texture = 0},
                    ['torso2'] = {item = 146, texture = 0},
                    ['decals'] = {item = 0, texture = 0},
                    ['arms'] = {item = 0, texture = 0},
                    ['pants'] = {item = 3, texture = 7},
                    ['shoes'] = {item = 12, texture = 12},
                    ['vest'] = {item = 0, texture = 0},
                    ['accessory'] = {item = 0, texture = 0},
                },
            },
            female = {
                outfitData = {
                    ['t-shirt'] = {item = 3, texture = 0},
                    ['torso2'] = {item = 38, texture = 3},
                    ['decals'] = {item = 0, texture = 0},
                    ['arms'] = {item = 2, texture = 0},
                    ['pants'] = {item = 3, texture = 15},
                    ['shoes'] = {item = 66, texture = 5},
                },
            },
        },
        lockup = {
            male = {
                outfitData = {
                    ['t-shirt'] = {item = 15, texture = 0},
                    ['torso2'] = {item = 146, texture = 0},
                    ['decals'] = {item = 0, texture = 0},
                    ['arms'] = {item = 0, texture = 0},
                    ['pants'] = {item = 3, texture = 7},
                    ['shoes'] = {item = 12, texture = 12},
                },
            },
            female = {
                outfitData = {
                    ['t-shirt'] = {item = 3, texture = 0},
                    ['torso2'] = {item = 38, texture = 3},
                    ['decals'] = {item = 0, texture = 0},
                    ['arms'] = {item = 2, texture = 0},
                    ['pants'] = {item = 3, texture = 15},
                    ['shoes'] = {item = 66, texture = 5},
                },
            },
        }
    }
else
    Config.Clothes = { -- clothes for jail and lockup (esx)
        jail = {
            male = {
                tshirt_1 = 15,  tshirt_2 = 0,
                torso_1  = 146, torso_2  = 0,
                decals_1 = 0,   decals_2 = 0,
                arms     = 0,   pants_1  = 3,
                pants_2  = 7,   shoes_1  = 12,
                shoes_2  = 12, 	helmet_1 = -1,
                helmet_2 = 0, 	bags_1 = -1,
                mask_1 = 0, 	mask_2 = 0,
                bproof_1 = 0, 	bproof_2 = 0,
                chain_1 = 0,    chain_2 = 0,
            },
            female = {
                tshirt_1 = 3,   tshirt_2 = 0,
                torso_1  = 38,  torso_2  = 3,
                decals_1 = 0,   decals_2 = 0,
                arms     = 2,   pants_1  = 3,
                pants_2  = 15,  shoes_1  = 66,
                shoes_2  = 5,
            },
        },
        lockup = {
            male = {
                tshirt_1 = 15,  tshirt_2 = 0,
                torso_1  = 146, torso_2  = 0,
                decals_1 = 0,   decals_2 = 0,
                arms     = 0,   pants_1  = 3,
                pants_2  = 7,   shoes_1  = 12,
                shoes_2  = 12, 	helmet_1 = -1,
                helmet_2 = 0, 	bags_1 = -1,
                mask_1 = 0, 	mask_2 = 0,
                bproof_1 = 0, 	bproof_2 = 0,
            },
            female = {
                tshirt_1 = 3,   tshirt_2 = 0,
                torso_1  = 38,  torso_2  = 3,
                decals_1 = 0,   decals_2 = 0,
                arms     = 2,   pants_1  = 3,
                pants_2  = 15,  shoes_1  = 66,
                shoes_2  = 5,
            },
        }
    }
end

Config.UseCommandWhenDead = { -- should you be able to use commands when dead
    jail = false,
    lockup = false,
    unjail = false,
}

Config.Beds = { -- jail bed settings
    healInterval = 2000, -- how often should the bed heal the player, in milliseconds
    healDone = 1000 * 120 -- how long to wait before calling HealingDone function, last number time in minutes
}

Config.Anims = { -- animation settings
    collectFood = {
        duration = 2000,
    },
    sweepFloor = {
        dict = 'missfbi_s4mop',
        name = 'idle_scrub_small_player',
        duration = 5000,
    },
    electricalWork = {
        scenario = 'WORLD_HUMAN_WELDING',
        duration = 5000,
    },
    washDishes = {
        dict = 'timetable@floyd@clean_kitchen@base',
        name = 'base',
        duration = 5000,
        prop = {
            model = `prop_sponge_01`,
            bone = 28422,
            pos = vec3(0.0, 0.0, -0.01),
            rot = vec3(90.0, 0.0, 0.0),
        }
    },
    trashWork = {
        dict = 'random@burial',
        name = 'a_burial',
        duration = 5000,
        prop = {
            model = `prop_tool_shovel`,
            bone = 28422,
            pos = vec3(0.0, 0.0, 0.24),
            rot = vec3(0.0, 0.0, 0.0),
        }
    },
    gardenWork = {
        {
            dict = 'amb@world_human_gardener_leaf_blower@base',
            name = 'base',
            duration = 5000,
            prop = {
                model = `prop_leaf_blower_01`,
                bone = 28422,
                pos = vec3(0.0, 0.0, 0.0),
                rot = vec3(0.0, 0.0, 0.0),
            }
        },
        {
            dict = 'anim@amb@drug_field_workers@rake@male_a@base',
            name = 'base',
            duration = 5000,
            prop = {
                model = `prop_tool_rake`,
                bone = 28422,
                pos = vec3(0.0, 0.0, -0.03),
                rot = vec3(0.0, 0.0, 0.0),
            }
        },
    },
    chinup = {
        scenario = 'PROP_HUMAN_MUSCLE_CHIN_UPS',
        duration = 10000,
    },
    yoga = {
        scenario = 'WORLD_HUMAN_YOGA',
        duration = 10000,
    },
    weights = {
        dict = 'amb@world_human_muscle_free_weights@male@barbell@base',
        name = 'base',
        duration = 10000,
        prop = {
            model = `prop_curl_bar_01`,
            bone = 28422,
            pos = vec3(0.0, 0.0, 0.0),
            rot = vec3(0.0, 0.0, 0.0),
        }
    },
}

Config.TradingItems = { -- items in the trading shop
    {
        name = 'burger', amount = 1,
        neededItems = {
            {name = 'cigarette', amount = 1},
        }
    },
    {
        name = 'water',
        amount = 1,
        neededItems = {
            {name = 'cigarette', amount = 1},
        }
    },
    {
        name = 'money',
        amount = 5,
        neededItems = {
            {name = 'cigarette', amount = 1},
        }
    },
    {
        name = 'WEAPON_KNIFE',
        amount = 1,
        neededItems = {
            {name = 'cigarette', amount = 500},
        }
    },
    {
        name = 'WEAPON_CROWBAR',
        amount = 1,
        neededItems = {
            {name = 'cigarette', amount = 250},
        }
    },
    {
        name = 'jail_lab_tools',
        amount = 1,
        neededItems = {
            {name = 'cigarette', amount = 500},
        }
    },
    {
        name = 'jail_lighter',
        amount = 1,
        neededItems = {
            {name = 'cigarette', amount = 2500},
        }
    },
    {
        name = 'jail_explosive',
        amount = 1,
        neededItems = {
            {name = 'cigarette', amount = 5000},
        }
    },
    {
        name = 'electronic_scrap',
        amount = 10,
        neededItems = {
            {name = 'battery', amount = 1},
        }
    },
    {
        name = 'electronic_scrap',
        amount = 4,
        neededItems = {
            {name = 'electric_cable', amount = 1},
        }
    },
    {
        name = 'metal_scrap',
        amount = 5,
        neededItems = {
            {name = 'metal_pipe', amount = 1},
        }
    },
    {
        name = 'jail_lighter',
        amount = 1,
        neededItems = {
            {name = 'tin_foil', amount = 5},
            {name = 'tape', amount = 5},
            {name = 'plastic_scrap', amount = 50},
        }
    },
    {
        name = 'jail_explosive',
        amount = 1,
        neededItems = {
            {name = 'plastic_scrap', amount = 50},
            {name = 'electronic_scrap', amount = 50},
            {name = 'gunpowder', amount = 25},
            {name = 'tape', amount = 5},
            {name = 'electric_cable', amount = 6},
        }
    },
    {
        name = 'jail_shovel',
        amount = 1,
        neededItems = {
            {name = 'metal_scrap', amount = 50},
            {name = 'metal_pipe', amount = 5},
            {name = 'tape', amount = 5},
        }
    },
    {
        name = 'fence_cutters',
        amount = 1,
        neededItems = {
            {name = 'metal_scrap', amount = 25},
            {name = 'metal_pipe', amount = 5},
            {name = 'tape', amount = 5},
        }
    },
    {
        name = 'freedom_chip',
        amount = 1,
        neededItems = {
            {name = 'metal_scrap', amount = 25},
            {name = 'metal_pipe', amount = 5},
            {name = 'tape', amount = 5},
        }
    },
}

Config.MissionPeds = { -- settings for the peds that you can talk to
    {
        coords = vec4(1750.3644, 2535.4270, 43.5854, 3.8527),
        ped = `s_m_y_prismuscl_01`,
        anim = { -- you can add animations for the ped
            dict = 'amb@world_human_muscle_flex@arms_at_side@base',
            name = 'base',
            flag = 49,
        },
        name = 'Deacon Lowe', -- name to show in UI
        options = {
            description = 'What do you want?', -- initial description for ped
            buttons = {
                {
                    label = 'How do I grow my muscles like you?', -- button label
                    onClick = { -- change text with onClick
                        description = 'Try getting your hands on slammer, I have used that myself but I have run out of it.', -- new description when button is clicked
                        buttons = {
                            {
                                label = 'Where can I get that?',
                                onClick = {
                                    description = 'I can not tell you.',
                                    buttons = {
                                        {
                                            label = 'Alright, thank you',
                                            close = true, -- should ui be closed
                                        },
                                    }
                                },
                            },
                            {
                                label = 'Leave',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Is the gym equipment good?',
                    onClick = {
                        description = 'Try it out, it can help you build up strength.',
                        buttons = {
                            {
                                label = 'Alright, thank you',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Wanna buy some slammer?',
                    onClick = {
                        description = 'Sure, how much you got?',
                        buttons = {
                            {
                                label = 'Sell 10x slammer',
                                need = {
                                    {name = 'slammer', amount = 10},
                                },
                                get = {
                                    {name = 'cigarette', amount = 10},
                                },
                                event = 'sellItems',
                            },
                            {
                                label = 'Nothing, sorry...',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Leave',
                    close = true,
                },
            }
        }
    },
    {
        coords = vec4(1753.0610, 2494.2703, 49.6931, 298.8349),
        ped = `ig_rashcosvki`,
        name = '?',
        options = {
            description = 'What do you want?',
            buttons = {
                {
                    label = 'Could you help me get out of here?',
                    onClick = {
                        description = 'No, go away.',
                        buttons = {
                            {
                                label = 'What if I give you some cigarettes?',
                                onClick = {
                                    description = 'Alright, get me 50 cigarettes and I\'ll help you out.',
                                    buttons = {
                                        {
                                            label = 'Give cigarettes',
                                            need = { -- items needed to run event
                                                {name = 'cigarette', amount = 50},
                                            },
                                            event = 'guardName', -- nui callback name to run
                                            close = true,
                                        },
                                        {
                                            label = 'Leave',
                                            close = true,
                                        },
                                    },
                                }
                            },
                            {
                                label = 'My apologies',
                                close = true,
                            },
                        },
                    },
                },
                {
                    label = 'Leave',
                    close = true,
                },
            }
        }
    },
    {
        coords = vec4(1749.2681, 2491.4119, 49.6931, 134.5436),
        ped = `s_m_y_prisoner_01`,
        name = 'Zac Russell',
        options = {
            description = 'What do you want?',
            buttons = {
                {
                    label = 'Why are you here?',
                    onClick = {
                        description = 'I got a sentence for drug trafficking.',
                        buttons = {
                            {
                                label = 'Can you help me get drugs?',
                                onClick = {
                                    description = 'Possibly, bring me 50 cigarettes and we can talk.',
                                    buttons = {
                                        {
                                            label = 'Give cigarettes',
                                            need = {
                                                {name = 'cigarette', amount = 50},
                                            },
                                            event = 'drugLocation',
                                            close = true,
                                        },
                                        {
                                            label = 'Leave',
                                            close = true,
                                        },
                                    },
                                }
                            },
                            {
                                label = 'Leave',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'What should I do here?',
                    onClick = {
                        description = 'People often like doing the jobs as that makes the guards happy and you might get out earlier. However, I have heard that would be able to bribe one of the guards to get access to a security card that might help you escape.',
                        buttons = {
                            {
                                label = 'What is the name of the guard?',
                                onClick = {
                                    description = 'I unfortunately do not know.',
                                    buttons = {
                                        {
                                            label = 'Alright, thank you',
                                            close = true,
                                        },
                                    },
                                }
                            },
                            {
                                label = 'What do I need to give him?',
                                onClick = {
                                    description = 'That\'s something that I haven\'t been told.',
                                    buttons = {
                                        {
                                            label = 'Alright, thank you',
                                            close = true,
                                        },
                                    },
                                }
                            },
                            {
                                label = 'Leave',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Leave',
                    close = true,
                },
            }
        }
    },
    {
        coords = vec4(1776.0874, 2481.0474, 49.6930, 116.7120),
        ped = `csb_rashcosvki`,
        name = 'Rayan',
        options = {
            description = 'What do you want?',
            buttons = {
                {
                    label = 'Can you make me an explosive?',
                    onClick = {
                        description = 'Get me 2500 cigarettes and I you will have your hands on an explosive that can get you out of here.',
                        buttons = {
                            {
                                label = 'Give cigarettes',
                                need = {
                                    {name = 'cigarette', amount = 2500},
                                },
                                get = {
                                    {name = 'jail_explosive', amount = 1},
                                },
                                event = 'sellItems',
                            },
                            {
                                label = 'Leave',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Leave',
                    close = true,
                },
            }
        }
    },
    {
        coords = vec4(1775.5137, 2540.6643, 45.5651, 97.6614),
        ped = `u_m_y_prisoner_01`,
        name = 'Bennett',
        options = {
            description = 'What do you want?',
            buttons = {
                {
                    label = 'I have some stuff for sale',
                    onClick = {
                        description = 'Go ahead.',
                        buttons = {
                            {
                                label = 'Sell 3x spoon',
                                need = {
                                    {name = 'plastic_spoon', amount = 3},
                                },
                                get = {
                                    {name = 'cigarette', amount = 1},
                                },
                                event = 'sellItems',
                            },
                            {
                                label = 'Sell 3x fork',
                                need = {
                                    {name = 'plastic_fork', amount = 3},
                                },
                                get = {
                                    {name = 'cigarette', amount = 1},
                                },
                                event = 'sellItems',
                            },
                            {
                                label = 'Sell 3x knife',
                                need = {
                                    {name = 'plastic_knife', amount = 3},
                                },
                                get = {
                                    {name = 'cigarette', amount = 1},
                                },
                                event = 'sellItems',
                            },
                            {
                                label = 'Leave',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Leave',
                    close = true,
                },
            }
        }
    },
    {
        coords = vec4(1694.8303, 2538.7893, 45.5648, 270.5960),
        ped = `u_m_y_prisoner_01`,
        name = 'Ayden Mosley',
        options = {
            description = 'What do you want?',
            buttons = {
                {
                    label = 'I have some stuff for sale',
                    onClick = {
                        description = 'Go ahead.',
                        buttons = {
                            {
                                label = 'Sell 2x electric cable',
                                need = {
                                    {name = 'electric_cable', amount = 2},
                                },
                                get = {
                                    {name = 'cigarette', amount = 1},
                                },
                                event = 'sellItems',
                            },
                            {
                                label = 'Sell 1x battery',
                                need = {
                                    {name = 'battery', amount = 1},
                                },
                                get = {
                                    {name = 'cigarette', amount = 1},
                                },
                                event = 'sellItems',
                            },
                            {
                                label = 'Leave',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Leave',
                    close = true,
                },
            }
        }
    },
    {
        coords = vec4(1616.4855, 2524.2119, 45.5648, 273.9997),
        ped = `u_m_y_prisoner_01`,
        name = 'Schneider',
        options = {
            description = 'What do you want?',
            buttons = {
                {
                    label = 'I have some stuff for sale',
                    onClick = {
                        description = 'Go ahead.',
                        buttons = {
                            {
                                label = 'Sell 5x metal scrap',
                                need = {
                                    {name = 'metal_scrap', amount = 5},
                                },
                                get = {
                                    {name = 'cigarette', amount = 5},
                                },
                                event = 'sellItems',
                            },
                            {
                                label = 'Sell 5x plastic scrap',
                                need = {
                                    {name = 'plastic_scrap', amount = 5},
                                },
                                get = {
                                    {name = 'cigarette', amount = 5},
                                },
                                event = 'sellItems',
                            },
                            {
                                label = 'Sell 5x electronical scrap',
                                need = {
                                    {name = 'electronic_scrap', amount = 5},
                                },
                                get = {
                                    {name = 'cigarette', amount = 5},
                                },
                                event = 'sellItems',
                            },
                            {
                                label = 'Leave',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Leave',
                    close = true,
                },
            }
        }
    },
    {
        coords = vec4(1705.9189, 2522.2810, 45.5648, 21.9905),
        ped = `u_m_y_prisoner_01`,
        name = 'Roberto Mayer',
        options = {
            description = 'What do you want?',
            buttons = {
                {
                    label = 'I have some stuff for sale',
                    onClick = {
                        description = 'Go ahead.',
                        buttons = {
                            {
                                label = 'Sell 1x phone',
                                need = {
                                    {name = 'phone', amount = 1},
                                },
                                get = {
                                    {name = 'cigarette', amount = 1},
                                },
                                event = 'sellItems',
                            },
                            {
                                label = 'Sell 1x flashlight',
                                need = {
                                    {name = 'weapon_flashlight', amount = 1},
                                },
                                get = {
                                    {name = 'cigarette', amount = 5},
                                },
                                event = 'sellItems',
                            },
                            {
                                label = 'Sell 1x knife',
                                need = {
                                    {name = 'weapon_knife', amount = 1},
                                },
                                get = {
                                    {name = 'cigarette', amount = 10},
                                },
                                event = 'sellItems',
                            },
                            {
                                label = 'Leave',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Leave',
                    close = true,
                },
            }
        }
    },
    {
        coords = vec4(1768.1965, 2476.2056, 45.7407, 13.7707),
        ped = `u_m_y_prisoner_01`,
        name = 'Jayson Curtis',
        options = {
            description = 'What do you want?',
            buttons = {
                {
                    label = 'Trade cigarettes for cash',
                    onClick = {
                        description = 'Sounds good, give me all your cigarettes and I will give you a fair price for them.',
                        buttons = {
                            {
                                label = 'Hand over all cigarettes',
                                event = 'tradeCigarettesForCash',
                                close = true,
                            },
                            {
                                label = 'Leave',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Leave',
                    close = true,
                },
            }
        }
    },
    {
        coords = vec4(1775.7355, 2489.5977, 45.7407, 100.9153),
        ped = `mp_m_securoguard_01`,
        name = 'Freddie Mason',
        options = {
            description = 'I am working, do not bother me.',
            buttons = {
                {
                    label = 'I got something you might want',
                    onClick = {
                        description = 'And what would that be?',
                        buttons = {
                            {
                                label = 'Give items',
                                need = {
                                    {name = 'money', amount = 25000},
                                    {name = 'ifak', amount = 1},
                                },
                                get = {
                                    {name = 'jail_security_card', amount = 1},
                                },
                                event = 'sellItems',
                                close = true,
                            },
                            {
                                label = 'Leave',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Leave',
                    close = true,
                },
            }
        }
    },
    {
        coords = vec4(1790.9510, 2546.2805, 45.6731, 43.9006),
        ped = `csb_prolsec`,
        name = 'Nicholas Morris',
        options = {
            description = 'Get back to work kid....',
            buttons = {
                {
                    label = 'Leave',
                    close = true,
                },
            }
        }
    },
    {
        coords = vec4(1767.7284, 2573.5088, 45.7299, 140.9021),
        ped = `s_m_y_autopsy_01`,
        name = 'Dr. Jamie Dawson',
        options = {
            description = 'How can I help you?',
            buttons = {
                {
                    label = 'Can you help me with an injury?',
                    onClick = {
                        description = 'I am busy right now, go lay in on of the beds.',
                        buttons = {
                            {
                                label = 'Leave',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Who are you?',
                    onClick = {
                        description = 'I am Dr. Jamie Dawson, I am the leading doctor in this prison.',
                        buttons = {
                            {
                                label = 'Leave',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Can you sell me equipment?',
                    onClick = {
                        description = 'I have a IFAK on sale for 1000€.',
                        buttons = {
                            {
                                label = 'Purchase IFAK',
                                need = {
                                    {name = 'money', amount = 1000},
                                },
                                get = {
                                    {name = 'ifak', amount = 1},
                                },
                                event = 'sellItems',
                                close = true,
                            },
                            {
                                label = 'Leave',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'How do I escape?',
                    onClick = {
                        description = 'You really think that I would know that?',
                        buttons = {
                            {
                                label = 'Leave',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Leave',
                    close = true,
                },
            }
        }
    },
    {
        coords = vec4(1751.0955, 2500.4792, 45.5650, 13.4505),
        ped = `s_m_m_gardener_01`,
        name = 'Gardener',
        options = {
            description = 'How can I help you?',
            buttons = {
                {
                    label = 'Sell & buy',
                    onClick = {
                        description = 'I can sell you prisunflower seeds for 50€ each and a watering can for 250€. I can also buy your prisunflowers for 50€ each.',
                        buttons = {
                            {
                                label = 'Purchase 1x prisunflower seed',
                                need = {
                                    {name = 'money', amount = 50},
                                },
                                get = {
                                    {name = 'prisunflower_seed', amount = 1},
                                },
                                event = 'sellItems',
                            },
                            {
                                label = 'Purchase 1x watering can',
                                need = {
                                    {name = 'money', amount = 250},
                                },
                                get = {
                                    {name = 'watering_can', amount = 1},
                                },
                                event = 'sellItems',
                            },
                            {
                                label = 'Sell 1x prisunflower',
                                need = {
                                    {name = 'prisunflower', amount = 1},
                                },
                                get = {
                                    {name = 'money', amount = 50},
                                },
                                event = 'sellItems',
                            },
                            {
                                label = 'Leave',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Tips',
                    onClick = {
                        description = 'I am glad you asked. Listen carefully! First, purchase some prisunflower seeds from me. After that, just plant them in the soil next to the trees. Make sure to the water your plants or they might die. When they look ready, just pick them up and come talk to me. I can purchase prisunflowers from you for a fair price!',
                        buttons = {
                            {
                                label = 'Alright, thank you',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Leave',
                    close = true,
                },
            }
        }
    },
    {
        coords = vec4(2519.8687, 2614.1741, 37.9569, 184.1309),
        ped = `ig_g`,
        name = '?',
        canInteractAnywhere = true,
        options = {
            description = 'Who are you? What do you want?',
            buttons = {
                {
                    label = 'I heard that you are selling a chip?',
                    onClick = {
                        description = 'That is right, 40k€ and you will get your hands on one of them.',
                        buttons = {
                            {
                                label = 'Purchase 1x chip',
                                need = {
                                    {name = 'money', amount = 40000},
                                },
                                get = {
                                    {name = 'freedom_chip', amount = 1},
                                },
                                event = 'sellItems',
                            },
                            {
                                label = 'I\'m afraid I dont have enough money...',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Sorry for bothering...',
                    close = true,
                },
            }
        }
    },
    {
        coords = vec4(1771.5732, 2495.7097, 45.7408, 165.3098),
        ped = `ig_floyd`,
        name = 'Bobby Reynolds',
        options = {
            description = 'Want to learn about the different jobs? I got you!',
            buttons = {
                {
                    label = 'Trash work',
                    onClick = {
                        description = 'Go outside and look for the big trash piles and dig through them. Sometimes you might event find something useful.',
                        buttons = {
                            {
                                label = 'Thank you!',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Electrical work',
                    onClick = {
                        description = 'The prison electricity is sometimes not working quite right, go to the electrical boxes and get the electricity fixed.',
                        buttons = {
                            {
                                label = 'Thank you!',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Food delivering',
                    onClick = {
                        description = 'Prisoners are hungry, go to the cafeteria, grab a tray and some food and serve it to the tables.',
                        buttons = {
                            {
                                label = 'Thank you!',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Dish washing',
                    onClick = {
                        description = 'Go to the cafeteria, find the sink and start washing the dishes.',
                        buttons = {
                            {
                                label = 'Thank you!',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Sweeping the floors',
                    onClick = {
                        description = 'Inmates leave all kinds of trash behind. Frist, get a broom from the cafeteria. After that, start sweeping the floors.',
                        buttons = {
                            {
                                label = 'Thank you!',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'Garden work',
                    onClick = {
                        description = 'The prison\'s vegetation needs care; go outside and take care of it.',
                        buttons = {
                            {
                                label = 'Thank you!',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'I\'m good, thanks',
                    close = true,
                },
            }
        }
    },
    {
        coords = vec4(1787.7001, 2564.3413, 45.6731, 91.0833),
        ped = `u_m_y_prisoner_01`,
        name = '?',
        options = {
            description = 'What do you want?',
            buttons = {
                {
                    label = 'Who are you?',
                    onClick = {
                        description = 'I am not giving you my name. However, if you have any items that you want to sharpen, let me know. I can sharpen your knives, spoons and forks for a small price.',
                        buttons = {
                            {
                                label = 'Sharpen 1x knife',
                                need = {
                                    {name = 'plastic_knife', amount = 1},
                                    {name = 'cigarette', amount = 1},
                                },
                                get = {
                                    {name = 'sharpened_plastic_knife', amount = 1},
                                },
                                event = 'sellItems',
                            },
                            {
                                label = 'Sharpen 1x spoon',
                                need = {
                                    {name = 'plastic_spoon', amount = 1},
                                    {name = 'cigarette', amount = 1},
                                },
                                get = {
                                    {name = 'sharpened_plastic_spoon', amount = 1},
                                },
                                event = 'sellItems',
                            },
                            {
                                label = 'Sharpen 1x fork',
                                need = {
                                    {name = 'plastic_fork', amount = 1},
                                    {name = 'cigarette', amount = 1},
                                },
                                get = {
                                    {name = 'sharpened_plastic_fork', amount = 1},
                                },
                                event = 'sellItems',
                            },
                            {
                                label = 'I\'m good, thanks',
                                close = true,
                            },
                        }
                    },
                },
                {
                    label = 'I\'m sorry, nothing',
                    close = true,
                },
            }
        }
    },
}

Config.Blips = { -- settings for blips
    prison = {
        enable = true, -- true / false, do you want to have a blip for the prison
        sprite = 189, -- https://docs.fivem.net/docs/game-references/blips/
        scale = 1.0, -- this needs to be a float (eg. 1.0, 1.2, 2.0)
        color = 29, -- https://docs.fivem.net/docs/game-references/blips/ (Scroll to the bottom)
        display = 6, -- https://docs.fivem.net/natives/?_0x9029B2F3DA924928
        coords = vec3(1846.1117, 2585.8928, 46.5308),
    },
    task = {
        enable = true,
        sprite = 8,
        scale = 0.7,
        color = 3,
        display = 6,
    },
    ankleMonitor = {
        enable = true,
        sprite = 58,
        scale = 0.8,
        color = 1,
        display = 6,
    },
    escape = {
        enable = true,
        sprite = 119,
        scale = 1.0,
        color = 1,
        display = 6,
        duration = 1000 * 30, -- how long should the escape blip show for, last number time in seconds
    },
}

Config.AnkleMonitor = { -- ankle monitor settings
    item = 'ankle_monitor',
    wait = 1000, -- wait for the ankle monitor blip update loop
    anim = {
        dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
        name = 'machinic_loop_mechandplayer',
        duration = 5000,
        flag = 1,
    },
    prop = {
        model = `v_serv_radio`,
        bone = 14201,
        pos = vec3(0.0038271505184184, 0.10174279978602, -0.0449863487731),
        rot = vec3(16.094871808607, 5.1044700929328, -80.033455665855),
    },
    remove = {
        item = 'power_saw',
        anim = {
            dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
            name = 'machinic_loop_mechandplayer',
            duration = 10000,
            flag = 1,
        },
    }
}

Config.Farming = { -- farming settings
    plant = {
        item = 'prisunflower_seed',
        stages = {
            {model = `prop_plant_fern_01a`, offset = vec3(0.0, 0.0, -1.35), time = 1000 * 60 * 10}, -- time = time it takes to grow to next stage, last number time in minutes
            {model = `prop_plant_fern_01b`, offset = vec3(0.0, 0.0, -1.35), time = 1000 * 60 * 10},
            {model = `prop_plant_fern_02a`, offset = vec3(0.0, 0.0, -1.1), time = 1000 * 60 * 10},
            {model = `prop_plant_fern_02b`, offset = vec3(0.0, 0.0, -1.1), time = 1000 * 60 * 10},
        },
        anim = {
            scenario = 'WORLD_HUMAN_GARDENER_PLANT',
            duration = 5000,
        },
    },
    watering = {
        item = 'watering_can',
        key = 38,
        dieTime = 1000 * 60 * 15, -- how fast should the plant die if it isn't watered
        anim = {
            dict = 'missfbi3_waterboard',
            name = 'waterboard_loop_player',
            duration = 10000,
            prop = {
                model = `prop_wateringcan`,
                bone = 0x8CBD,
                pos = vec3(0.15, 0.0, 0.4),
                rot = vec3(0.0, -180.0, -140.0),
            }
        }
    },
    collect = {
        item = {name = 'prisunflower', amount = {min = 1, max = 3}},
        key = 47,
        anim = {
            dict = 'amb@prop_human_movie_studio_light@base',
            name = 'base',
            duration = 10000,
        }
    },
}

Config.Drug = { -- settings for making drug
    coords = {
        vec4(1767.7545, 2578.0681, 45.5609, 199.3035),
    },
    item = 'slammer',
    itemsNeeded = {
        {name = 'jail_lab_tools', amount = 1, keep = true},
        {name = 'jail_chemicals', amount = 3},
    },
    anim = {
        dict = 'anim@amb@business@coc@coc_unpack_cut@',
        name = 'fullcut_cycle_cokecutter',
        duration = 10000,
    },
    showTextWithoutItems = false, -- should make drug text show even when you dont have items needed
}

Config.Roulette = { -- roulette settings
    coords = {
        {coords = vec4(1738.7531, 2543.9873, 43.5855, 116.0), obj = `vw_prop_casino_roulette_01b`},
        {coords = vec4(1743.0519, 2546.2114, 43.5854, 116.0), obj = `vw_prop_casino_roulette_01b`},
    },
    item = 'cigarette',
    maxAmount = 50, -- max bet
    cooldown = 1000 * 3, -- how fast should roulette table roll when first bet placed
    rollDisplayTime = 1000 * 3, -- how long should the table show the "rolling..." text
    winDisplayTime = 1000 * 3, -- how long should the table show the "table rolled" text
    pay = { -- pay multipliers for red, black and green
        r = 2,
        b = 2,
        g = 14,
    }
}

Config.Escape = { -- escape settings
    enable = true, -- enable escaping
    explosive = {
        item = 'jail_explosive',
        policeNeeded = 1,
        locations = { -- you can restrict where you should be able to place the explosive
            --{coords = vec3(1742.46, 2517.01, 45.56), dist = 2.0}
        },
        model = `ch_prop_ch_explosive_01a`,
        anim = {
            dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
            name = 'machinic_loop_mechandplayer',
            duration = 3000,
            flag = 1,
        },
        blowUpTime = 5000,
        fadeScreen = true,
        outCoords = {
            vec4(1822.1707, 2515.6523, 44.7389, 253.6780),
            vec4(1831.7644, 2645.9795, 44.4536, 251.0934),
            vec4(1796.0201, 2745.1492, 44.4197, 333.2970),
            vec4(1638.7908, 2749.9583, 44.3950, 46.7884),
            vec4(1535.1233, 2593.5588, 44.4146, 70.4930),
            vec4(1535.4878, 2570.2229, 44.4932, 98.3105),
            vec4(1616.6733, 2419.1238, 44.4937, 171.4810),
            vec4(1741.7479, 2405.6733, 44.5366, 206.7959),
            vec4(1817.6090, 2466.7288, 44.4183, 227.8322),
        },
        escapeAnim = {
            dict = 'move_injured_ground',
            name = 'front_loop',
            duration = 5000,
            flag = 1,
        },
    },
    lighter = {
        item = 'jail_lighter',
        ptfx = {
            asset = 'scr_ornate_heist',
            name = 'scr_heist_ornate_thermal_burn',
        },
        anim = {
            dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
            name = 'machinic_loop_mechandplayer',
            duration = 3000,
            flag = 1,
        },
    },
    utensils = {
        items = {'sharpened_plastic_fork', 'sharpened_plastic_knife', 'sharpened_plastic_spoon'},
        policeNeeded = 1,
        amountNeeded = 150,
        anim = {
            dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
            name = 'machinic_loop_mechandplayer',
            duration = 10000,
            flag = 1,
        },
        fadeScreen = true,
        outCoords = {
            vec4(1822.1707, 2515.6523, 44.7389, 253.6780),
            vec4(1831.7644, 2645.9795, 44.4536, 251.0934),
            vec4(1796.0201, 2745.1492, 44.4197, 333.2970),
            vec4(1638.7908, 2749.9583, 44.3950, 46.7884),
            vec4(1535.1233, 2593.5588, 44.4146, 70.4930),
            vec4(1535.4878, 2570.2229, 44.4932, 98.3105),
            vec4(1616.6733, 2419.1238, 44.4937, 171.4810),
            vec4(1741.7479, 2405.6733, 44.5366, 206.7959),
            vec4(1817.6090, 2466.7288, 44.4183, 227.8322),
        },
        escapeAnim = {
            dict = 'move_injured_ground',
            name = 'front_loop',
            duration = 5000,
            flag = 1,
        },
    },
    hack = {
        policeNeeded = 1,
        items = {'jail_security_card', 'freedom_chip'},
        locations = {
            {coords = vec3(1772.8054, 2491.2681, 49.6660), item = 'jail_security_card'},
            {coords = vec3(1841.8787, 2615.5002, 45.6371), item = 'freedom_chip'},
        },
        anim = {
            dict = 'amb@prop_human_movie_studio_light@base',
            name = 'base',
            duration = 10000,
        },
        disabledTime = 1000 * 60 * 15,
        showTextWithoutItems = false,
    },
    fence = {
        items = {'jail_shovel', 'fence_cutters'},
        locations = {
            {inCoords = vec3(1720.6711, 2488.3921, 45.5648), outCoords = vec4(1721.7970, 2487.7800, 45.5649, 225.8444), item = 'jail_shovel', removeItem = true},
            {inCoords = vec3(1746.3358, 2420.2395, 45.4316), outCoords = vec4(1747.1479, 2419.0269, 45.1142, 196.3225), item = 'fence_cutters', removeItem = true},
            {inCoords = vec3(1752.8929, 2411.2341, 45.4062), outCoords = vec4(1753.1614, 2409.9746, 45.4518, 191.5596), item = 'fence_cutters', removeItem = true, escape = true},
        },
        outCoords = {
            vec4(1753.1614, 2409.9746, 45.4518, 191.5596),
        },
        anim = {
            jail_shovel = {
                dict = 'random@burial',
                name = 'a_burial',
                duration = 10000,
                prop = {
                    model = `prop_tool_shovel`,
                    bone = 28422,
                    pos = vec3(0.0, 0.0, 0.24),
                    rot = vec3(0.0, 0.0, 0.0),
                },
            },
            fence_cutters = {
                dict = 'amb@prop_human_movie_studio_light@base',
                name = 'base',
                duration = 5000,
            },
        }
    },
}

Config.Search = {
    cooldown = 1000 * 60 * 5,
    anim = {
        dict = 'missexile3',
        name = 'ex03_dingy_search_case_base_michael',
        duration = 5000,
        flag = 1,
    },
    findChance = 50,
    items = {
        {name = 'cigarette', amount = {min = 1, max = 2}, chance = 50},
        {name = 'phone', amount = {min = 1, max = 1}, chance = 1},
        {name = 'radio', amount = {min = 1, max = 1}, chance = 0.01},
        {name = 'metal_pipe', amount = {min = 1, max = 1}, chance = 0.01},
        {name = 'gunpowder', amount = {min = 1, max = 1}, chance = 5},
        {name = 'slammer', amount = {min = 1, max = 1}, chance = 1},
        {name = 'burger', amount = {min = 1, max = 1}, chance = 5},
        {name = 'water', amount = {min = 1, max = 1}, chance = 5},
        {name = 'plastic_scrap', amount = {min = 1, max = 1}, chance = 25},
        {name = 'metal_scrap', amount = {min = 1, max = 1}, chance = 25},
        {name = 'electronic_scrap', amount = {min = 1, max = 1}, chance = 25},
    }
}