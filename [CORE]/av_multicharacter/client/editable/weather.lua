function Weather(freeze,data)
    dbug("Weather(freeze?, data)", freeze, json.encode(data, {indent = true}))
    if freeze then
        if GetResourceState("av_weather") ~= "missing" then
            dbug("using av_weather...")
            TriggerEvent('av_weather:freeze', true, data and data['hour'] or 21, data and data['minutes'] or 30, data and data['weather'] or 'CLEAR', false, false, false)
            return
        end
        if GetResourceState('qb-weathersync') ~= "missing" then
            dbug("using qb-weathersync...")
            TriggerEvent('qb-weathersync:client:DisableSync')
            Wait(1000)
        end
        -- Add your own weather event/export here to freeze time:
        NetworkOverrideClockTime(data and data['hour'] or 21, data and data['minutes'] or 30, 0)
    else
        if GetResourceState("av_weather") ~= "missing" then
            dbug("using av_weather...")
            TriggerEvent('av_weather:freeze', false)
            return
        end
        if GetResourceState('qb-weathersync') ~= "missing" then
            dbug("using qb-weathersync...")
            TriggerEvent('qb-weathersync:client:EnableSync')
        end
        -- Add your own weather event/export to sync player time and weather:

    end
end