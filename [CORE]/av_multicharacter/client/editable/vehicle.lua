function ApplyTuning(vehicle, mods)
    if Config.Framework == "qb" then
        Core.Functions.SetVehicleProperties(vehicle, mods)
    elseif Config.Framework == "esx" then
        Core.Game.SetVehicleProperties(vehicle, mods)
    else
        lib.setVehicleProperties(vehicle, mods)
    end
end