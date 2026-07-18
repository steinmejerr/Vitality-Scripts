-- Removes loadingscreen, set screen to black and start loading all characters data...
CreateThread(function()
    while true do
        if NetworkIsSessionStarted() then
            while not IsScreenFadedOut() do
                DoScreenFadeOut(10)
                Wait(0)
            end
            while not Config.Framework and not Core do Wait(10) end
            SetupFramework() -- for esx
            init()
            return
        end
        Wait(0)
    end
end)
