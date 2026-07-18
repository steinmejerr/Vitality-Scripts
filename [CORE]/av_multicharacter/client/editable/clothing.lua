-- Applies the skin (clothes) to a specific ped
function SetSkin(ped,data)
    dbug("SetSkin(ped,data)", ped and DoesEntityExist(ped) or "false", data and json.encode(data) or "nil")
    if not data or not ped then return end
    local appearanceData = nil
    if type(data) == "string" then
        local success, decodedData = pcall(json.decode, data)
        if success and type(decodedData) == "table" then
            appearanceData = decodedData
        else
            dbug("Error: Failed to decode JSON data")
        end
    elseif type(data) == "table" then
        appearanceData = data
    else
        appearanceData = data
    end
    if Config.ClothingScript == "illenium-appearance" then
        dbug("illenium-appearance:setPedAppearance")
        return exports["illenium-appearance"]:setPedAppearance(ped, appearanceData)
    end
    if Config.ClothingScript == "tgiann-clothing" then
        dbug("tgiann-clothing:SetPedAppearance")
        return exports['tgiann-clothing']:SetPedAppearance(ped, appearanceData)
    end
    if Config.ClothingScript == "st_clothing" then
        dbug("st_clothing:SetPedAppearance")
        return exports['st_clothing']:setPedAppearance(appearanceData)
    end
    if Config.Framework == "qb" then
        dbug("qb-clothing:client:loadPlayerClothing")
        TriggerEvent('qb-clothing:client:loadPlayerClothing', appearanceData, ped)
        return true
    end
    if GetResourceState('skinchanger') == "started" then
        dbug("Skinchanger")
        ApplySkin(ped,appearanceData)
        return true
    end
    dbug("CustomSkin()")
    return CustomSkin(ped,GetEntityModel(ped))
end

-- We apply this variant to peds that doesn't have any clothes/skin, peds from unused slots for example
function CustomSkin(ped,model) -- ped: entity, model: hash
    if tonumber(model) == 1885233650 then -- Only apply clothing if the model is default mp freemode
        SetPedComponentVariation(ped, 8, 15, 0, 2) -- Tshirt
        SetPedComponentVariation(ped, 11, 1, 0, 2) -- torso parts
        SetPedComponentVariation(ped, 3, 0, 0, 0) -- Arms
        SetPedComponentVariation(ped, 4, 0, 0, 2) -- pants
        SetPedComponentVariation(ped, 6, 1, 0, 2) -- shoes
    end
end

-- Used for ESX default skinchanger only
function ApplySkin(ped,clothes)
    if not ped or not clothes then return end
    local face_weight = (clothes['face_md_weight'] / 100) + 0.0
    local skin_weight = (clothes['skin_md_weight'] / 100) + 0.0
    SetPedHeadBlendData(ped, clothes['mom'], clothes['dad'], 0, clothes['mom'], clothes['dad'], 0, face_weight, skin_weight, 0.0, false)
    SetPedFaceFeature(ped, 0, (clothes['nose_1'] / 10) + 0.0) -- Nose Width
    SetPedFaceFeature(ped, 1, (clothes['nose_2'] / 10) + 0.0) -- Nose Peak Height
    SetPedFaceFeature(ped, 2, (clothes['nose_3'] / 10) + 0.0) -- Nose Peak Length
    SetPedFaceFeature(ped, 3, (clothes['nose_4'] / 10) + 0.0) -- Nose Bone Height
    SetPedFaceFeature(ped, 4, (clothes['nose_5'] / 10) + 0.0) -- Nose Peak Lowering
    SetPedFaceFeature(ped, 5, (clothes['nose_6'] / 10) + 0.0) -- Nose Bone Twist
    SetPedFaceFeature(ped, 6, (clothes['eyebrows_5'] / 10) + 0.0) -- Eyebrow height
    SetPedFaceFeature(ped, 7, (clothes['eyebrows_6'] / 10) + 0.0) -- Eyebrow depth
    SetPedFaceFeature(ped, 8, (clothes['cheeks_1'] / 10) + 0.0) -- Cheekbones Height
    SetPedFaceFeature(ped, 9, (clothes['cheeks_2'] / 10) + 0.0) -- Cheekbones Width
    SetPedFaceFeature(ped, 10, (clothes['cheeks_3'] / 10) + 0.0) -- Cheeks Width
    SetPedFaceFeature(ped, 11, (clothes['eye_squint'] / 10) + 0.0) -- Eyes squint
    SetPedFaceFeature(ped, 12, (clothes['lip_thickness'] / 10) + 0.0) -- Lip Fullness
    SetPedFaceFeature(ped, 13, (clothes['jaw_1'] / 10) + 0.0) -- Jaw Bone Width
    SetPedFaceFeature(ped, 14, (clothes['jaw_2'] / 10) + 0.0) -- Jaw Bone Length
    SetPedFaceFeature(ped, 15, (clothes['chin_1'] / 10) + 0.0) -- Chin Height
    SetPedFaceFeature(ped, 16, (clothes['chin_2'] / 10) + 0.0) -- Chin Length
    SetPedFaceFeature(ped, 17, (clothes['chin_3'] / 10) + 0.0) -- Chin Width
    SetPedFaceFeature(ped, 18, (clothes['chin_4'] / 10) + 0.0) -- Chin Hole Size
    SetPedFaceFeature(ped, 19, (clothes['neck_thickness'] / 10) + 0.0) -- Neck Thickness
    SetPedHairColor(ped, clothes['hair_color_1'], clothes['hair_color_2']) -- Hair Color
    SetPedHeadOverlay(ped, 3, clothes['age_1'], (clothes['age_2'] / 10) + 0.0) -- Age + opacity
    SetPedHeadOverlay(ped, 0, clothes['blemishes_1'], (clothes['blemishes_2'] / 10) + 0.0) -- Blemishes + opacity
    SetPedHeadOverlay(ped, 1, clothes['beard_1'], (clothes['beard_2'] / 10) + 0.0) -- Beard + opacity
    SetPedEyeColor(ped, clothes['eye_color']) -- Eyes color
    SetPedHeadOverlay(ped, 2, clothes['eyebrows_1'], (clothes['eyebrows_2'] / 10) + 0.0) -- Eyebrows + opacity
    SetPedHeadOverlay(ped, 4, clothes['makeup_1'], (clothes['makeup_2'] / 10) + 0.0) -- Makeup + opacity
    SetPedHeadOverlay(ped, 8, clothes['lipstick_1'], (clothes['lipstick_2'] / 10) + 0.0) -- Lipstick + opacity
    SetPedComponentVariation(ped, 2, clothes['hair_1'], clothes['hair_2'], 2) -- Hair
    SetPedHeadOverlayColor(ped, 1, 1, clothes['beard_3'], clothes['beard_4']) -- Beard Color
    SetPedHeadOverlayColor(ped, 2, 1, clothes['eyebrows_3'], clothes['eyebrows_4']) -- Eyebrows Color
    SetPedHeadOverlayColor(ped, 4, 2, clothes['makeup_3'], clothes['makeup_4']) -- Makeup Color
    SetPedHeadOverlayColor(ped, 8, 1, clothes['lipstick_3'], clothes['lipstick_4']) -- Lipstick Color
    SetPedHeadOverlay(ped, 5, clothes['blush_1'], (clothes['blush_2'] / 10) + 0.0) -- Blush + opacity
    SetPedHeadOverlayColor(ped, 5, 2, clothes['blush_3']) -- Blush Color
    SetPedHeadOverlay(ped, 6, clothes['complexion_1'], (clothes['complexion_2'] / 10) + 0.0) -- Complexion + opacity
    SetPedHeadOverlay(ped, 7, clothes['sun_1'], (clothes['sun_2'] / 10) + 0.0) -- Sun Damage + opacity
    SetPedHeadOverlay(ped, 9, clothes['moles_1'], (clothes['moles_2'] / 10) + 0.0) -- Moles/Freckles + opacity
    SetPedHeadOverlay(ped, 10, clothes['chest_1'], (clothes['chest_2'] / 10) + 0.0) -- Chest Hair + opacity
    SetPedHeadOverlayColor(ped, 10, 1, clothes['chest_3']) -- Torso Color
    if clothes['bodyb_1'] == -1 then
        SetPedHeadOverlay(ped, 11, 255, (clothes['bodyb_2'] / 10) + 0.0) -- Body Blemishes + opacity
    else
        SetPedHeadOverlay(ped, 11, clothes['bodyb_1'], (clothes['bodyb_2'] / 10) + 0.0)
    end
    if clothes['bodyb_3'] == -1 then
        SetPedHeadOverlay(ped, 12, 255, (clothes['bodyb_4'] / 10) + 0.0)
    else
        SetPedHeadOverlay(ped, 12, clothes['bodyb_3'], (clothes['bodyb_4'] / 10) + 0.0) -- Blemishes 'added body effect' + opacity
    end
    if clothes['ears_1'] == -1 then
        ClearPedProp(ped, 2)
    else
        SetPedPropIndex(ped, 2, clothes['ears_1'], clothes['ears_2'], 2) -- Ears Accessories
    end
    SetPedComponentVariation(ped, 8, clothes['tshirt_1'], clothes['tshirt_2'], 2) -- Tshirt
    SetPedComponentVariation(ped, 11, clothes['torso_1'], clothes['torso_2'], 2) -- torso parts
    SetPedComponentVariation(ped, 3, clothes['arms'], clothes['arms_2'], 2) -- Arms
    SetPedComponentVariation(ped, 10, clothes['decals_1'], clothes['decals_2'], 2) -- decals
    SetPedComponentVariation(ped, 4, clothes['pants_1'], clothes['pants_2'], 2) -- pants
    SetPedComponentVariation(ped, 6, clothes['shoes_1'], clothes['shoes_2'], 2) -- shoes
    SetPedComponentVariation(ped, 1, clothes['mask_1'], clothes['mask_2'], 2) -- mask
    SetPedComponentVariation(ped, 9, clothes['bproof_1'], clothes['bproof_2'], 2) -- bulletproof
    SetPedComponentVariation(ped, 7, clothes['chain_1'], clothes['chain_2'], 2) -- chain
    SetPedComponentVariation(ped, 5, clothes['bags_1'], clothes['bags_2'], 2) -- Bag
    if clothes['helmet_1'] == -1 then
        ClearPedProp(ped, 0)
    else
        SetPedPropIndex(ped, 0, clothes['helmet_1'], clothes['helmet_2'], 2) -- Helmet
    end
    if clothes['glasses_1'] == -1 then
        ClearPedProp(ped, 1)
    else
        SetPedPropIndex(ped, 1, clothes['glasses_1'], clothes['glasses_2'], 2) -- Glasses
    end
    if clothes['watches_1'] == -1 then
        ClearPedProp(ped, 6)
    else
        SetPedPropIndex(ped, 6, clothes['watches_1'], clothes['watches_2'], 2) -- Watches
    end
    if clothes['bracelets_1'] == -1 then
        ClearPedProp(ped, 7)
    else
        SetPedPropIndex(ped, 7, clothes['bracelets_1'], clothes['bracelets_2'], 2) -- Bracelets
    end
end