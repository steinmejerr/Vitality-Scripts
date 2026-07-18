Config = Config or {}
-- Scens config (check scenes config and the docs to learn how scenes works)
Config.DefaultScene = "appartment" -- Default scene
Config.DefaultVehicle = `coquette4` -- Default vehicle to show if character doesn't own one
Config.DefaultPed = `mp_m_freemode_01` -- Default ped modelHash
Config.Scenes = {
    { -- GTA Interior
        value = "appartment", -- needs to match the scene key index
        label = "Appartment", -- used for multicharacter menu
        canUse = function() -- false it will hide this scene from player
            return true
        end
    },
    { -- GTA Interior
        value = "biker_club",
        label = "Biker Club",
        canUse = function()
            return true
        end
    },
    { -- GTA Interior
        value = "coke_lab",
        label = "Coke Lab",
        canUse = function()
            return true
        end
    },
    { -- GTA Exterior
        value = "hills",
        label = "Vinewood Hills",
        canUse = function()
            return true
        end
    },
    { -- Paid map by Gabz https://fivem.gabzv.com/
        value = "gabz_bennys",
        label = "Bennys Motorworks",
        canUse = function()
            return GetResourceState('cfx-gabz-bennys') == "started"
        end
    },
    { -- Paid map by Gabz https://fivem.gabzv.com/
        value = "gabz_prison",
        label = "Prison",
        canUse = function()
            return GetResourceState('cfx-gabz-prison') == "started"
        end
    },
    { -- Paid map by Gabz https://fivem.gabzv.com/
        value = "gabz_tuning",  
        label = "Tunershop", 
        canUse = function()
            return GetResourceState('cfx-gabz-tuners') == "started"
        end
    },
}