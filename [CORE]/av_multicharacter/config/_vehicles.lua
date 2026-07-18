Config = Config or {}
Config.BlacklistedCategories = { -- Any vehicle from these categories won't be usable in scenes
    ["10"] = true,
    ["14"] = true,
    ["15"] = true,
    ["16"] = true,
    ["19"] = true,
}
Config.BlacklistedVehicles = {
    -- Prevent specific vehicles from being spawned in character selection
    [`pounder`] = true,
    [`pounder2`] = true,
    [`terbyte`] = true,
    [`pbus`] = true,
    [`riot`] = true,
    [`rubble`] = true,
    [`flatbed`] = true,
}