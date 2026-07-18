function GetPlayerSlots()
    return lib.callback.await("av_multicharacter:getSlots", false)
end