Scenes = Scenes or {}
Scenes['mrpd'] = {
    playerSpawn = { x = 444.08, y = -1020.48, z = 28.5}, -- A hidden spot where you will be spawned during character selection, make sure is out of cam focus {x, y, z}
    camTransitionMS = 1700, -- Time in MS for cam transition
    weather = {hour = 23, minutes = 30, weather = "CLEAR"}, -- Daytime and weather conditions
    characters = { -- Player characters coords, animations, vehicle coords for each character, camera coords
    -- Make sure to have the same amount of character coords as slots available
        [1] = {
            ped = { x = 998.65, y = -3170.12, z = -34.08, heading = 6.44},
            animation = {dict = "amb@prop_human_bum_shopping_cart@male@idle_a", anim = "idle_c"},
            camera = { x = 998.54, y = -3168.05, z = -33.67, rotX = 1.26, rotY = 0.0, rotZ = -165.29, fov = 60.0 },
        },
        [2] = {
            ped = { x = 999.83, y = -3167.34, z = -34.08, heading = 305.31},
            animation = {dict = "amb@world_human_drinking@beer@male@idle_a", anim = "idle_a"},
            camera = { x = 1001.24, y = -3166.45, z = -33.64, rotX = -2.52, rotY = 0.0, rotZ = 133.16, fov = 52.5 },
            prop = {model = `prop_amb_beer_bottle`, bone = 28422, offsets = {0.0, 0.0, 0.06, 0.0, 15.0, 0.0}},
        },
        [3] = {
            ped = { x = 1005.75, y = -3165.09, z = -33.63, heading = 276.33},
            animation = {dict = "timetable@ron@ig_3_couch", anim = "base"},
            camera = { x = 1007.56, y = -3164.73, z = -33.54, rotX = -8.31, rotY = 0.0, rotZ = 106.77, fov = 43.0 },
        },
        [4] = {
            ped = { x = 1006.37, y = -3167.51, z = -34.08, heading = 327.75},
            scenario = 'WORLD_HUMAN_DRUG_DEALER',
            camera = { x = 1008.23, y = -3166.39, z = -33.52, rotX = -3.15, rotY = 0.0, rotZ = 124.97, fov = 35.0 },
        },
        [5] = {
            ped = { x = 1007.75, y = -3168.12, z = -33.63, heading = 3.09},
            animation = {dict = "timetable@tracy@sleep@", anim = "base"},
            camera = { x = 1008.53, y = -3166.48, z = -34.37, rotX = 1.57, rotY = 0.0, rotZ = 165.67, fov = 40.5 },
        },
    }
}