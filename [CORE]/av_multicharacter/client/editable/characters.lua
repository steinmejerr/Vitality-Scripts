charactersList = {}

function FetchCharacters() -- Retrieve player characters
    dbug("getData()")
    local characters = lib.callback.await('av_multicharacter:getData', false)
    local max = Config.Slots and Config.Slots['max'] or 5
--    print(json.encode(characters, { indent = true}))
    for i=1, max do
        if characters and next(characters) then
            local found = false
            for _, character in pairs(characters) do
                local slot = tonumber(character['slot'])
                if slot == i then
                    charactersList[i] = {
                        slot = slot,
                        citizenid = character['identifier'],
                        firstname = character['firstname'],
                        lastname = character['lastname'],
                        job = character['job'],
                        isNew = false
                    }
                    charactersList[i]['clothes'] = lib.callback.await('av_multicharacter:getSkin', false, character['identifier'])
                    if character['vehicle'] then
                        charactersList[i]['vehicle'] = lib.callback.await('av_multicharacter:getVehicle', false, character['identifier'], character['vehicle'])
                    end
                    found = true
                    break
                end
            end
            if not found then
                charactersList[i] = {
                    clothes = false,
                    isNew = true,
                    slot = i
                }
            end
        else
            charactersList[i] = {
                clothes = false,
                isNew = true,
                slot = i
            }
        end
    end
end