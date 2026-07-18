Scenes = Scenes or {}
Scenes['gabz_tuning'] = {
    playerSpawn = {x = 129.6, y = -3013.67, z = 7.04}, -- A hidden spot where you will be spawned during character selection, make sure is out of cam focus {x, y, z}
    camTransitionMS = 1700, -- Time in MS for cam transition
    weather = {hour = 21, minutes = 30, weather = "CLEAR"}, -- Daytime and weather conditions
    characters = { -- Player characters coords, animations, vehicle coords for each character, camera coords
    -- Make sure to have the same amount of character coords as slots available
        [1] = {
            ped = {x = 146.9, y = -3037.33, z = 7.04, heading = 42.4},
            animation = {dict = "random@street_race", anim = "_car_b_lookout"},
            vehicle = {x = 149.06, y = -3037.47, z = 6.69, heading = 42.67},
            camera = {x = 144.04, y = -3035.77, z = 6.94, rotX = 3.65, rotY = 0.0, rotZ = -110.11, fov = 35.0}
        },
        [2] = {
            ped = {x = 148.89, y = -3041.47, z = 7.04, heading = 52.84},
            scenario = "WORLD_HUMAN_GUARD_STAND",
            vehicle = {x = 149.86, y = -3043.76, z = 6.68, heading = 247.62},
            camera = {x = 145.99, y = -3040.21, z = 6.64, rotX = 7.43, rotY = 0.0, rotZ = -130.20, fov = 39.0}
        },
        [3] = {
            ped = {x = 139.85, y = -3046.85, z = 7.04, heading = 1.26},
            scenario = "WORLD_HUMAN_SMOKING",
            vehicle = {x = 141.16, y = -3048.48, z = 6.68, heading = 269.58},
            camera = {x = 140.70, y = -3044.16, z = 7.04, rotX = 1.63, rotY = 0.0, rotZ = 180.72, fov = 45.0}
        },
        [4] = {
            ped = {x = 133.85, y = -3046.27, z = 7.04, heading = 312.94},
            scenario = "WORLD_HUMAN_STAND_MOBILE",
            vehicle = {x = 132.07, y = -3048.03, z = 6.68, heading = 316.86},
            camera = {x = 136.21, y = -3044.49, z = 7.04, rotX = 1.44, rotY = 0.0, rotZ = 134.11, fov = 38.0}
        },
        [5] = {
            ped = {x = 130.86, y = -3039.25, z = 7.04, heading = 291.8},
            animation = {dict = "anim@amb@nightclub@lazlow@ig1_vip@", anim = "clubvip_base_laz"},
            vehicle = {x = 131.89, y = -3040.2, z = 6.68, heading = 346.19},
            camera = {x = 135.14, y = -3038.35, z = 6.64, rotX = 6.28, rotY = 4.0, rotZ = 112.89, fov = 50.0},
        },
    }
}