Scenes = Scenes or {}
Scenes['coke_lab'] = {
    playerSpawn = { x = 1090.7, y = -3188.14, z = -38.99}, -- A hidden spot where you will be spawned during character selection, make sure is out of cam focus {x, y, z}
    camTransitionMS = 1200, -- Time in MS for cam transition
    weather = {hour = 23, minutes = 30, weather = "CLEAR"}, -- Daytime and weather conditions
    characters = { -- Player characters coords, animations, vehicle coords for each character, camera coords
    -- Make sure to have the same amount of character coords as slots available
        [1] = {
            ped = { x = 1087.18, y = -3194.39, z = -38.99, heading = 90.33},
            animation = {dict = "anim@heists@prison_heiststation@cop_reactions", anim = "cop_b_idle"},
            camera = { x = 1087.03, y = -3192.54, z = -38.87, rotX = -0.63, rotY = 0.0, rotZ = -175.62, fov = 55.0 },
        },
        [2] = {
            ped = { x = 1090.56, y = -3196.56, z = -38.99, heading = 2.26},
            animation = {dict = "anim@amb@business@coc@coc_unpack_cut@", anim = "fullcut_cycle_v6_cokepacker"},
            camera = { x = 1089.86, y = -3194.66, z = -38.91, rotX = 2.52, rotY = 0.0, rotZ = -153.38, fov = 46.5 },
        },
        [3] = {
            ped = { x = 1093.04, y = -3196.59, z = -38.99, heading = 4.21},
            animation = {dict = "anim@amb@business@coc@coc_unpack_cut@", anim = "fullcut_cycle_v5_cokepacker"},
            camera = { x = 1092.11, y = -3194.55, z = -38.87, rotX = 0.57, rotY = 0.0, rotZ = -144.63, fov = 46.5 },
        },
        [4] = {
            ped = { x = 1095.4, y = -3196.56, z = -38.99, heading = 1.71},
            animation = {dict = "anim@amb@business@coc@coc_unpack_cut@", anim = "fullcut_cycle_v4_cokepacker"},
            camera = { x = 1094.31, y = -3194.36, z = -38.85, rotX = 0.57, rotY = 0.0, rotZ = -145.07, fov = 46.5 },
        },
        [5] = {
            ped = { x = 1100.7, y = -3198.83, z = -38.99, heading = 182.48},
            animation = {dict = "anim@amb@business@coc@coc_unpack_cut@", anim = "fullcut_cycle_v6_cokepacker"},
            camera = { x = 1098.26, y = -3197.94, z = -38.59, rotX = -1.76, rotY = 0.0, rotZ = -116.53, fov = 37.5 },
        },
    }
}