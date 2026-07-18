-- This file will allow you to run custom code during scene creation

local props = {}

function CustomScene(scene) -- Triggered right before start spawning characters
    dbug("CustomScene(scene)", scene)
    local data = Scenes[scene] -- Access scene info and use it however u want
    -- print(json.encode(data, {indent = true}))
    DisplayHud(false) -- hide hud
    DisplayRadar(false) -- hide radar

end

function CustomCharacter(scene, ped, vehicle, slot) -- Triggered right after a scene ped is created
    dbug("RunCustom(scene, ped, vehicle, slot)", scene, ped, vehicle, slot)
    local data = Scenes[scene] -- Access scene info and use it however u want
    if data['characters'][slot] and data['characters'][slot]['prop'] then
        local info = data['characters'][slot]['prop']
        if not info['model'] or not IsModelValid(info['model']) then return end
        local coords = GetEntityCoords(ped)
        local offsets = info['offsets']
        lib.requestModel(info['model'], 30000)
        local obj = CreateObject(info['model'], coords.x, coords.y, coords.z, false, true, false)
        AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, info['bone']), offsets[1], offsets[2], offsets[3], offsets[4], offsets[5], offsets[6], true, true, false, true, 1, true)
        props[#props+1] = obj
    end
end

function CustomWipe()
    -- Multicharacter screen is being removed, delete everything here...
    dbug("CustomWipe()")
    if props and next(props) then
        for _, entity in pairs(props) do
            if entity and DoesEntityExist(entity) then
                SetEntityAsNoLongerNeeded(entity)
                DeleteEntity(entity)
            end
        end
    end
    props = {}
    DisplayHud(true) -- enable hud
    DisplayRadar(true) -- enable radar
end