-- This file is named delete.lua because here's the Delete Character function NOT bc u have to delete it :facepalm
function DeleteCharacter(slot)
    local character = charactersList[slot]
    if character then
        TriggerEvent('av_multicharacter:wipe')
        SetNuiFocus(false,false)
        DoScreenFadeOut(10)
        Wait(500)
        Weather(false)
        TriggerServerEvent('av_multicharacter:delete',character)
    else
        print("^2[ERROR] Character doesn't exist?")
    end
end

function GetDeletePermission()
    return lib.callback.await('av_multicharacter:canDelete', false)
end