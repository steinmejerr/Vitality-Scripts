Config = {}

Config.Debug = false
Config.UpdateInterval = 350
Config.SyncInterval = 1000
Config.MaxVisibleWeapons = 3
Config.HideWhileInVehicle = false
Config.RemoveOnDeath = true

Config.UseOxInventory = true

-- Menu til valg af våbenplacering.
Config.Menu = {
    command = 'weaponplacement',
    key = 'F7',
    title = 'Våbenplacering'
}


Config.DefaultBone = 24818

Config.Placements = {
    rifle = {
        back = {
            bone = 24818,
            position = vec3(-0.10, -0.17, 0.02),
            rotation = vec3(0.0, 165.0, 0.0)
        },
        front = {
            bone = 24818,
            position = vec3(0.10, 0.18, 0.05),
            rotation = vec3(0.0, 15.0, 180.0)
        }
    },
    shotgun = {
        back = {
            bone = 24818,
            position = vec3(0.08, -0.18, 0.04),
            rotation = vec3(0.0, 165.0, 180.0)
        },
        front = {
            bone = 24818,
            position = vec3(-0.08, 0.18, 0.06),
            rotation = vec3(0.0, 15.0, 0.0)
        }
    },
    melee = {
        back = {
            bone = 24818,
            position = vec3(0.02, -0.16, -0.12),
            rotation = vec3(0.0, 90.0, 0.0)
        },
        front = {
            bone = 24818,
            position = vec3(0.17, 0.16, -0.02),
            rotation = vec3(0.0, 90.0, 180.0)
        }
    }
}


Config.WeaponPlacements = {
    [`WEAPON_BAT`] = {
        back = {
            bone = 24818,
            position = vec3(0.02, -0.16, -0.12),
            rotation = vec3(0.0, 90.0, 0.0)
        },
        front = {
            bone = 24818,
            position = vec3(0.14, 0.14, -0.02),
            rotation = vec3(8.0, 28.0, 188.0)
        }
    },
    [`WEAPON_CROWBAR`] = {
        back = {
            bone = 24818,
            position = vec3(0.02, -0.16, -0.12),
            rotation = vec3(0.0, 90.0, 0.0)
        }
    },
    [`WEAPON_GOLFCLUB`] = {
        back = {
            bone = 24818,
            position = vec3(0.02, -0.16, -0.12),
            rotation = vec3(0.0, 90.0, 0.0)
        }
    },
    [`WEAPON_POOLCUE`] = {
        back = {
            bone = 24818,
            position = vec3(0.02, -0.16, -0.12),
            rotation = vec3(0.0, 90.0, 0.0)
        }
    }
}

Config.Weapons = {
    -- Rifler
    [`WEAPON_ASSAULTRIFLE`] = {
        label = 'Assault Rifle',
        model = `w_ar_assaultrifle`,
        category = 'rifle',
        placement = 'back'
    },
    [`WEAPON_ASSAULTRIFLE_MK2`] = {
        label = 'Assault Rifle Mk II',
        model = `w_ar_assaultrifle`,
        category = 'rifle',
        placement = 'back'
    },
    [`WEAPON_CARBINERIFLE`] = {
        label = 'Carbine Rifle',
        model = `w_ar_carbinerifle`,
        category = 'rifle',
        placement = 'back'
    },
    [`WEAPON_CARBINERIFLE_MK2`] = {
        label = 'Carbine Rifle Mk II',
        model = `w_ar_carbineriflemk2`,
        category = 'rifle',
        placement = 'back'
    },
    [`WEAPON_SPECIALCARBINE`] = {
        label = 'Special Carbine',
        model = `w_ar_specialcarbine`,
        category = 'rifle',
        placement = 'back'
    },
    [`WEAPON_BULLPUPRIFLE`] = {
        label = 'Bullpup Rifle',
        model = `w_ar_bullpuprifle`,
        category = 'rifle',
        placement = 'back'
    },
    [`WEAPON_COMPACTRIFLE`] = {
        label = 'Compact Rifle',
        model = `w_ar_assaultrifle_smg`,
        category = 'rifle',
        placement = 'back'
    },

    -- Shotguns
    [`WEAPON_PUMPSHOTGUN`] = {
        label = 'Pump Shotgun',
        model = `w_sg_pumpshotgun`,
        category = 'shotgun',
        placement = 'back'
    },
    [`WEAPON_PUMPSHOTGUN_MK2`] = {
        label = 'Pump Shotgun Mk II',
        model = `w_sg_pumpshotgunmk2`,
        category = 'shotgun',
        placement = 'back'
    },
    [`WEAPON_SAWNOFFSHOTGUN`] = {
        label = 'Sawed-Off Shotgun',
        model = `w_sg_sawnoff`,
        category = 'shotgun',
        placement = 'back'
    },
    [`WEAPON_BULLPUPSHOTGUN`] = {
        label = 'Bullpup Shotgun',
        model = `w_sg_bullpupshotgun`,
        category = 'shotgun',
        placement = 'back'
    },
    [`WEAPON_ASSAULTSHOTGUN`] = {
        label = 'Assault Shotgun',
        model = `w_sg_assaultshotgun`,
        category = 'shotgun',
        placement = 'back'
    },
    [`WEAPON_HEAVYSHOTGUN`] = {
        label = 'Heavy Shotgun',
        model = `w_sg_heavyshotgun`,
        category = 'shotgun',
        placement = 'back'
    },

    -- Melee
    [`WEAPON_BAT`] = {
        label = 'Bat',
        model = `w_me_bat`,
        category = 'melee',
        placement = 'back'
    },
    [`WEAPON_CROWBAR`] = {
        label = 'Crowbar',
        model = `w_me_crowbar`,
        category = 'melee',
        placement = 'back'
    },
    [`WEAPON_GOLFCLUB`] = {
        label = 'Golf Club',
        model = `w_me_gclub`,
        category = 'melee',
        placement = 'back'
    },
    [`WEAPON_POOLCUE`] = {
        label = 'Pool Cue',
        model = `w_me_poolcue`,
        category = 'melee',
        placement = 'back'
    }
}
