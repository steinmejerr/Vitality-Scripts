Config = Config or {}
Core = nil
Config.Framework = false

CreateThread(function()
    if Config.Framework then return end
    if GetResourceState("qbx_core") ~= "missing" then
        Config.Framework = "qbox"
        Config.Identifier = "license2"
        Core = true
        return
    end
    if GetResourceState("qb-core") ~= "missing" then
        Config.Framework = "qb"
        Core = exports['qb-core']:GetCoreObject()
        return
    end
    if GetResourceState("es_extended") ~= "missing" then
        Config.Framework = "esx"
        Core = exports['es_extended']:getSharedObject()
        return
    end
end)
