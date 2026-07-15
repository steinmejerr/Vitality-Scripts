Config = {}

Config.Debug = false
Config.UpdateInterval = 350
Config.SyncInterval = 1000
Config.MaxVisibleWeapons = 3
Config.HideWhileInVehicle = false
Config.RemoveOnDeath = true

Config.UseOxInventory = true

Config.DefaultBone = 24818

Config.Weapons = {
    -- Rifler
    [`WEAPON_ASSAULTRIFLE`] = {
        model = `w_ar_assaultrifle`,
        bone = 24818,
        position = vec3(-0.10, -0.17, 0.02),
        rotation = vec3(0.0, 165.0, 0.0)
    },
    [`WEAPON_ASSAULTRIFLE_MK2`] = {
        model = `w_ar_assaultrifle`,
        bone = 24818,
        position = vec3(-0.10, -0.17, 0.02),
        rotation = vec3(0.0, 165.0, 0.0)
    },
    [`WEAPON_CARBINERIFLE`] = {
        model = `w_ar_carbinerifle`,
        bone = 24818,
        position = vec3(-0.10, -0.17, 0.02),
        rotation = vec3(0.0, 165.0, 0.0)
    },
    [`WEAPON_CARBINERIFLE_MK2`] = {
        model = `w_ar_carbineriflemk2`,
        bone = 24818,
        position = vec3(-0.10, -0.17, 0.02),
        rotation = vec3(0.0, 165.0, 0.0)
    },
    [`WEAPON_SPECIALCARBINE`] = {
        model = `w_ar_specialcarbine`,
        bone = 24818,
        position = vec3(-0.10, -0.17, 0.02),
        rotation = vec3(0.0, 165.0, 0.0)
    },
    [`WEAPON_BULLPUPRIFLE`] = {
        model = `w_ar_bullpuprifle`,
        bone = 24818,
        position = vec3(-0.10, -0.17, 0.02),
        rotation = vec3(0.0, 165.0, 0.0)
    },
    [`WEAPON_COMPACTRIFLE`] = {
        model = `w_ar_assaultrifle_smg`,
        bone = 24818,
        position = vec3(-0.10, -0.17, 0.02),
        rotation = vec3(0.0, 165.0, 0.0)
    },

    -- Shotguns
    [`WEAPON_PUMPSHOTGUN`] = {
        model = `w_sg_pumpshotgun`,
        bone = 24818,
        position = vec3(0.08, -0.18, 0.04),
        rotation = vec3(0.0, 165.0, 180.0)
    },
    [`WEAPON_PUMPSHOTGUN_MK2`] = {
        model = `w_sg_pumpshotgunmk2`,
        bone = 24818,
        position = vec3(0.08, -0.18, 0.04),
        rotation = vec3(0.0, 165.0, 180.0)
    },
    [`WEAPON_SAWNOFFSHOTGUN`] = {
        model = `w_sg_sawnoff`,
        bone = 24818,
        position = vec3(0.08, -0.18, 0.04),
        rotation = vec3(0.0, 165.0, 180.0)
    },
    [`WEAPON_BULLPUPSHOTGUN`] = {
        model = `w_sg_bullpupshotgun`,
        bone = 24818,
        position = vec3(0.08, -0.18, 0.04),
        rotation = vec3(0.0, 165.0, 180.0)
    },
    [`WEAPON_ASSAULTSHOTGUN`] = {
        model = `w_sg_assaultshotgun`,
        bone = 24818,
        position = vec3(0.08, -0.18, 0.04),
        rotation = vec3(0.0, 165.0, 180.0)
    },
    [`WEAPON_HEAVYSHOTGUN`] = {
        model = `w_sg_heavyshotgun`,
        bone = 24818,
        position = vec3(0.08, -0.18, 0.04),
        rotation = vec3(0.0, 165.0, 180.0)
    },

    -- Melee
    [`WEAPON_BAT`] = {
        model = `w_me_bat`,
        bone = 24818,
        position = vec3(0.18, -0.15, -0.03),
        rotation = vec3(0.0, 90.0, 0.0)
    },
    [`WEAPON_CROWBAR`] = {
        model = `w_me_crowbar`,
        bone = 24818,
        position = vec3(0.18, -0.15, -0.03),
        rotation = vec3(0.0, 90.0, 0.0)
    },
    [`WEAPON_GOLFCLUB`] = {
        model = `w_me_gclub`,
        bone = 24818,
        position = vec3(0.18, -0.15, -0.03),
        rotation = vec3(0.0, 90.0, 0.0)
    },
    [`WEAPON_POOLCUE`] = {
        model = `w_me_poolcue`,
        bone = 24818,
        position = vec3(0.18, -0.15, -0.03),
        rotation = vec3(0.0, 90.0, 0.0)
    }
}
