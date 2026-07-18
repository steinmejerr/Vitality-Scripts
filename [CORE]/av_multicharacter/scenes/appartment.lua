Scenes = Scenes or {}
Scenes['appartment'] = {
    playerSpawn = {x = -907.9578, y = -432.5489, z = 120.2045}, -- A hidden spot where you will be spawned during character selection, make sure is out of cam focus {x, y, z}
    camTransitionMS = 1700, -- Time in MS for cam transition
    weather = {hour = 23, minutes = 30, weather = "THUNDER"}, -- Daytime and weather conditions
    characters = { -- Player characters coords, animations, vehicle coords for each character, camera coords
    -- Make sure to have the same amount of character coords as slots available
        [1] = {
            ped = { x = -909.45, y = -437.29, z = 120.2, heading = 59.22},
            animation = {dict = "timetable@ron@ig_3_couch", anim = "base"},
            camera = { x = -912.41, y = -437.62, z = 120.31, rotX = -4.66, rotY = 0.0, rotZ = -77.16, fov = 30.0 },
        },
        [2] = {
            ped = { x = -907.85, y = -443.02, z = 120.2, heading = 25.89},
            scenario = "WORLD_HUMAN_LEANING",
            camera = { x = -908.29, y = -441.47, z = 120.67, rotX = -3.84, rotY = 0.0, rotZ = -152.88, fov = 43.0 },
        },
        [3] = {
            ped = { x = -916.95, y = -446.41, z = 120.2, heading = 113.61},
            animation = {dict = "anim@amb@carmeet@checkout_engine@", anim = "female_c_idle_d"},
            camera = { x = -915.24, y = -448.22, z = 120.89, rotX = -4.6, rotY = 0.0, rotZ = 62.86, fov = 33.5 },
        },
        [4] = {
            ped = { x = -916.23, y = -442.78, z = 120.23, heading = 337.9},
            animation = {dict = "misscarsteal4@actor", anim = "actor_berating_loop"},
            camera = { x = -918.72, y = -441.05, z = 120.81, rotX = -5.35, rotY = 0.0, rotZ = -115.15, fov = 33.5 },
        },
        [5] = {
            ped = { x = -915.62, y = -440.87, z = 120.23, heading = 164.32},
            animation = {dict = "missheistdockssetup1leadinoutig_1", anim = "lsdh_ig_1_argue_wade"},
            camera = { x = -917.05, y = -441.25, z = 120.68, rotX = -5.17, rotY = 0.0, rotZ = -86.61, fov = 80.0 },
        },
    }
}