function RegisterCharacter(data)
    TriggerEvent('av_multicharacter:wipe')
    DoScreenFadeOut(10)
    Wait(500)
    Weather(false)
    if data and data['sex'] then
        data['sex'] = tonumber(data['sex'])
    end
    TriggerServerEvent('av_multicharacter:register',data)
    SetNuiFocus(false,false)
end