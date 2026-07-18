Scenes = Scenes or {}
Scenes['gabz_prison'] = {
    playerSpawn = { x = 1758.01, y = 2481.9, z = 45.74}, -- A hidden spot where you will be spawned during character selection, make sure is out of cam focus {x, y, z}
    camTransitionMS = 1700, -- Time in MS for cam transition
    weather = {hour = 23, minutes = 30, weather = "CLEAR"}, -- Daytime and weather conditions
    characters = { -- Player characters coords, animations, vehicle coords for each character, camera coords
    -- Make sure to have the same amount of character coords as slots available
        [1] = {
            ped = { x = 1777.06, y = 2482.66, z = 49.69, heading = 30.04, model = 's_m_y_prisoner_01'},
            scenario = "WORLD_HUMAN_SMOKING",
            camera = { x = 1774.13, y = 2487.71, z = 50.01, rotX = -0.31, rotY = 0.0, rotZ = -146.46, fov = 39.5 },
        },
        [2] = {
            ped = { x = 1774.38, y = 2480.33, z = 49.69, heading = 27.79, model = 's_m_y_prismuscl_01'},
            animation = {dict = "anim@amb@business@bgen@bgen_no_work@", anim = "sit_phone_phoneputdown_idle_nowork"},
            camera = { x = 1771.09, y = 2485.69, z = 50.01, rotX = -0.31, rotY = 0.0, rotZ = -146.46, fov = 39.5 },
        },
        [3] = {
            ped = { x = 1771.04, y = 2479.0, z = 49.69, heading = 27.98, model = 's_m_y_prisoner_01'},
            animation = {dict = "amb@world_human_muscle_free_weights@male@barbell@base", anim = "base"},
            camera = { x = 1767.93, y = 2483.6, z = 50.01, rotX = -0.31, rotY = 0.0, rotZ = -146.46, fov = 39.5 },
            prop = {model = `prop_curl_bar_01`, bone = 28422, offsets = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0}},
        },
        [4] = {
            ped = { x = 1766.41, y = 2479.23, z = 49.69, heading = 31.86, model = 'ig_rashcosvki'},
            animation = {dict = "anim@scripted@island@special_peds@dave@hs4_dave_stage3_ig7", anim = "base"},
            camera = { x = 1764.59, y = 2482.04, z = 50.02, rotX = -0.31, rotY = 0.0, rotZ = -146.46, fov = 39.5 },
        },
        [5] = {
            ped = { x = 1764.15, y = 2474.75, z = 49.69, heading = 34.82, model = 'u_m_y_prisoner_01'},
            animation = {dict = "timetable@ron@ig_3_couch", anim = "base"},
            camera = { x = 1761.6, y = 2480.29, z = 50.15, rotX = -1.83, rotY = 0.0, rotZ = -146.01, fov = 39.5 },
        },
    }
}