RegisterCommand(Config.SettingsCommand, function()
    local myVehicles = {}
    local vehicles = lib.callback.await('av_multicharacter:getVehicleList', false)
    local settings = lib.callback.await('av_multicharacter:getSettings', false)
    local scenes = {}
    if vehicles and next(vehicles) then
        for k, v in pairs(vehicles) do
            local label = v['vehicle']
            if tonumber(label) then
                label = GetLabelText(GetDisplayNameFromVehicleModel(tonumber(label)))
            end
            myVehicles[#myVehicles+1] = {
                label = label,
                value = v['plate']
            }
        end
    end
    if Config.Scenes and next(Config.Scenes) then
        for _, v in pairs(Config.Scenes) do
            if v and v['canUse']() then
                scenes[#scenes+1] = {
                    value = v['value'],
                    label = v['label']
                }
            end
        end
    end
    local input = lib.inputDialog(Lang['menu_title'], {
        { type = 'select', label = Lang['my_vehicles'], options = myVehicles, default = settings['vehicle'], clearable = false},
        { type = 'select', label = Lang['scenes'], options = scenes, required = true, default = settings['scene'], clearable = false},
    })
    if not input then return end
    TriggerServerEvent("av_multicharacter:saveSettings", {vehicle = input[1], scene = input[2]})
end)