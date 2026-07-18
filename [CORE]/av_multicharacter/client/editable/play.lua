function Play(slot)
    local character = charactersList[slot]
    if character then
        TriggerEvent('av_multicharacter:wipe')
        SetNuiFocus(false,false)
        DoScreenFadeOut(10)
        Wait(500)
        Weather(false)
        FreezeEntityPosition(cache.ped,false)
        TriggerServerEvent('av_multicharacter:play',character)
    else
        warn("Character in slot "..slot.." doesn't exist?")
    end
end