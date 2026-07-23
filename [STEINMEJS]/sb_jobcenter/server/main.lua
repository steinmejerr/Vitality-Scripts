local ESX = exports['es_extended']:getSharedObject()

local JobsById = {}
for i = 1, #Config.Jobs do
    JobsById[Config.Jobs[i].id] = Config.Jobs[i]
end

RegisterNetEvent('sb_jobcenter:selectJob', function(jobId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local selected = JobsById[jobId]

    if not xPlayer or not selected then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local center = vector3(Config.JobCenter.ped.coords.x, Config.JobCenter.ped.coords.y, Config.JobCenter.ped.coords.z)

    if #(coords - center) > 10.0 then
        print(('[sb_jobcenter] %s forsøgte at vælge job for langt fra jobcenteret.'):format(src))
        return
    end

    if not ESX.DoesJobExist(selected.job, selected.grade) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Jobcenter',
            description = ('Jobbet "%s" findes ikke i databasen.'):format(selected.job),
            type = 'error'
        })
        return
    end

    xPlayer.setJob(selected.job, selected.grade)
    TriggerClientEvent('sb_jobcenter:jobSelected', src, selected.job, selected.label)
end)
