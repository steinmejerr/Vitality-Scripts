Scenes = Scenes or {}
Scenes['hills'] = {
    playerSpawn = {x = -1704.4247, y = 488.3544, z = 129.0765}, -- A hidden spot where you will be spawned during character selection, make sure is out of cam focus {x, y, z}
    camTransitionMS = 1700, -- Time in MS for cam transition
    weather = {hour = 11, minutes = 30, weather = "EXTRASUNNY"}, -- Daytime and weather conditions
    characters = { -- Player characters coords, animations, vehicle coords for each character, camera coords
    -- Make sure to have the same amount of character coords as slots available
        [1] = {
            ped = { x = -1665.8, y = 494.66, z = 128.88, heading = 359.54, model = "mp_m_freemode_01" },
            animation = {dict = "random@street_race", anim = "_car_b_lookout"},
            vehicle = { x = -1664.71, y = 492.63, z = 128.15, heading = 0.0, model = "coquette4" },
            camera = { x = -1666.46, y = 498.37, z = 129.04, rotX = -1.45, rotY = 0.0, rotZ = -160.3, fov = 30.0 },
        },
        [2] = {
            ped = { x = -1669.85, y = 492.46, z = 128.88, heading = 359.47, model = "mp_m_freemode_01" },
            animation = {dict = "random@street_race", anim = "_car_b_lookout"},
            vehicle = { x = -1668.68, y = 490.47, z = 128.15, heading = 0.0, model = "coquette4" },
            camera = { x = -1670.87, y = 496.15, z = 129.03, rotX = -1.13, rotY = 0.0, rotZ = -155.14, fov = 30.0 },
        },
        [3] = {
            ped = { x = -1674.01, y = 489.89, z = 128.88, heading = 359.54, model = "mp_m_freemode_01" },
            animation = {dict = "random@street_race", anim = "_car_b_lookout"},
            vehicle = { x = -1672.82, y = 488.21, z = 128.15, heading = 0.0, model = "coquette4" },
            camera = { x = -1675.01, y = 493.9, z = 129.02, rotX = -1.13, rotY = 0.0, rotZ = -155.14, fov = 30.0 },
        },
        [4] = {
            ped = { x = -1678.39, y = 488.57, z = 128.88, heading = 0.0, model = "mp_m_freemode_01" },
            animation = {dict = "random@street_race", anim = "_car_b_lookout"},
            vehicle = { x = -1677.24, y = 486.41, z = 128.15, heading = 0.0, model = "coquette4" },
            camera = { x = -1679.28, y = 491.92, z = 129.02, rotX = -1.13, rotY = 0.0, rotZ = -155.14, fov = 30.0 },
        },
        [5] = {
            ped = { x = -1682.61, y = 486.42, z = 128.88, heading = 359.47, model = "mp_m_freemode_01" },
            animation = {dict = "random@street_race", anim = "_car_b_lookout"},
            vehicle = { x = -1681.5, y = 484.32, z = 128.15, heading = 0.0, model = "coquette4" },
            camera = { x = -1683.49, y = 489.81, z = 129.02, rotX = -1.13, rotY = 0.0, rotZ = -155.14, fov = 30.0 },
        },
    }
}