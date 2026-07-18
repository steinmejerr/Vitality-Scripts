Scenes = Scenes or {}
Scenes['gabz_bennys'] = {
    playerSpawn = { x = -214.01, y = -1333.9, z = 34.99, heading = 186.72}, -- A hidden spot where you will be spawned during character selection, make sure is out of cam focus {x, y, z}
    camTransitionMS = 1700, -- Time in MS for cam transition
    weather = {hour = 21, minutes = 30, weather = "CLEAR"}, -- Daytime and weather conditions
    characters = { -- Player characters coords, animations, vehicle coords for each character, camera coords
    -- Make sure to have the same amount of character coords as slots available
        [1] = {
            ped = {x = -214.55, y = -1322.89, z = 31.3, heading = 154.37},
            animation = {dict = "random@street_race", anim = "_car_b_lookout"},
            vehicle = {x = -215.74, y = -1321.59, z = 30.58, heading = 178.1},
            camera = {x = -216.63, y = -1326.00, z = 31.00, rotX = 5.54, rotY = 1.0, rotZ = -17.00, fov = 45.0}
        },
        [2] = {
            ped = {x = -207.45, y = -1324.3, z = 31.3, heading = 128.03},
            scenario = "WORLD_HUMAN_SMOKING",
            vehicle = {x = -208.46, y = -1323.06, z = 30.58, heading = 156.83},
            camera = {x = -211.18, y = -1326.39, z = 31.30, rotX = -1.00, rotY = 2.0, rotZ = -44.09, fov = 48.0}
        },
        [3] = {
            ped = {x = -202.69, y = -1328.14, z = 31.3, heading = 92.86},
            scenario = "WORLD_HUMAN_LEANING",
            vehicle = {x = -201.58, y = -1327.09, z = 30.57, heading = 178.24},
            camera = {x = -205.09, y = -1327.17, z = 31.30, rotX = 2.51, rotY = 0.0, rotZ = -91.90, fov = 50.0}
        },
        [4] = {
            ped = {x = -210.48, y = -1336.19, z = 31.3, heading = 89.9},
            animation = {dict = "mini@repair", anim = "fixing_a_ped"},
            vehicle = {x = -208.47, y = -1336.17, z = 30.57, heading = 176.4},
            camera = {x = -210.67, y = -1331.49, z = 31.49, rotX = -2.51, rotY = 3.0, rotZ = -158.11, fov = 46.0}
        },
        [5] = {
            ped = {x = -215.6, y = -1334.76, z = 31.3, heading = 266.64},
            animation = {dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", anim = "machinic_loop_mechandplayer"},
            vehicle = {x = -214.11, y = -1335.98, z = 30.57, heading = 2.15},
            camera = {x = -212.43, y = -1331.43, z = 31.10, rotX = 2.14, rotY = 2.0, rotZ = 156.40, fov = 43.0}
        },
    }
}