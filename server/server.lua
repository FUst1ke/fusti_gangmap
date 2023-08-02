local zoneInRaid = {}
local zoneData = {}
local cooldownTime = 200
local ownerThread = false
local time = 0

MySQL.ready(function()
    for k,v in pairs(Config.Zones) do
        local response = MySQL.single.await('SELECT * FROM `gangmap` WHERE zone = ?', {k})
        if not response then
            local newZone = MySQL.insert.await('INSERT INTO `gangmap` (zone, owner) VALUES (?, ?)', {k, k})
        end
        Wait(1000)
        TriggerClientEvent('fusti_gangmap:setupZones', -1, response)
    end
end)

local function notify(target, title, description, type, icon, position)
    TriggerClientEvent('ox_lib:notify', target, {
        title = title,
        description = description,
        type = type or 'inform',
        icon = icon or nil,
        position = position or 'top'
    })
end

function getZoneData(zone, job)
    if not zone then return end
    if not zoneData[zone] then
        zoneData[zone] = {}
    end
    if not job then
        return zoneData[zone]
    end
    if not zoneData[zone][job] then
        zoneData[zone][job] = {}
    end
    return zoneData[zone][job]
end

function getBiggestJob(zone)
    local counts = {}
    local min = 0
    local greatestJob = nil
    for job, value in pairs(zone) do
        counts[job] = #value
    end
    for job, value in pairs(counts) do
        if value > min then
            min = value
            greatestJob = job
        elseif value == min then
            return false
        end
    end
    return greatestJob
end

function updateStatus(data)
    local canRaid = biggestJob
    data.isPaused = not canRaid
    data.biggestJob = biggestJob
    if data.biggestJob == data.owner and not ownerThread then
        ownerThread = true
    end
    for k,v in pairs(zoneData[data.zone]) do
        for _, i in pairs(v) do
            local xPlayer = ESX.GetPlayerFromId(i)
            xPlayer.triggerEvent('fusti_gangmap:client:updateStatus', data, canRaid)
        end
    end
end

function setRaid(inRaid, data)
    local count = 0
    CreateThread(function()
        while zoneInRaid[data.zone] do
            local sleep = 0
            if data.progress < 100 and not data.isPaused then
                data.progress = data.progress + 1
                sleep = 1000
            elseif data.progress == 100 then
                TriggerEvent('fusti_gangmap:server:stopRaid', data, true)
                break
            end
            updateStatus(data)
            if ownerThread then
                if count < 10 then
                    count = count + 1
                    sleep = 1000
                else
                    ownerThread = false
                    local ownerJob = ESX.GetExtendedPlayers('job', data.owner)
                    for _,xPlayer in pairs(ownerJob) do
                        notify(xPlayer.source, 'Információ', 'Sikeresen visszaverted a raidet!', 'success')
                        TriggerEvent('fusti_gangmap:server:stopRaid', data, false)
                    end
                    break
                end
            end
            Wait(sleep)
        end
    end)
end

lib.callback.register('fusti_gangmap:checkStatus', function(source, data)
    local ownerJobCount = ESX.GetExtendedPlayers('job', data.owner)
    local currentTime = os.time()
    local canStart = (cooldownTime < currentTime - time)
    if #ownerJobCount < Config.Zones[data.zone].minMember then
        notify(source, 'Információ', 'Túl kevesen vannak a zóna foglalásához.', 'error')
        return true
    elseif zoneInRaid[data.zone] then 
        notify(source, 'Információ', 'Ez a zóna éppen foglaláshoz alatt áll.', 'error')
        return true
    elseif not canStart then 
        notify(source, 'Információ', 'A következő foglaláshoz várj '..math.floor((cooldownTime - (currentTime - time)) / 60).." óra "..math.fmod((cooldownTime - (currentTime - time)), 60).. ' percet.', 'error')
        return true
    else
        return false 
    end
end)

RegisterServerEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
    local xVictim = ESX.GetPlayerFromId(source)
    local xKiller = ESX.GetPlayerFromId(data.killerServerId)
    local killer = {name = xKiller.getName(), job = xKiller.getJob().label}
    local victim = {name = xVictim.getName(), job = xVictim.getJob().label}
    local zone = xVictim.getMeta('raidZone')
    TriggerEvent('fusti_gangmap:server:refreshPlayerList', zone, 'exit', source)
    notify(data.killerServerId, 'Információ', 'Megölted '..victim.name..' játékost ('..victim.job..').')
end)

RegisterNetEvent('fusti_gangmap:server:stopRaid')
AddEventHandler('fusti_gangmap:server:stopRaid', function(data, success)
    if success then
        data.owner = data.biggestJob
        local updatedZone = MySQL.update.await('UPDATE gangmap SET owner = ? WHERE zone = ?', {
            data.biggestJob, 
            data.zone
        })
    end
    time = os.time()
    zoneInRaid[data.zone] = false
    TriggerClientEvent('fusti_gangmap:client:stopRaid', -1, data)
    setRaid(false, data)
end)

RegisterNetEvent('fusti_gangmap:server:startRaid')
AddEventHandler('fusti_gangmap:server:startRaid', function(data)
    zoneInRaid[data.zone] = true
    TriggerClientEvent('fusti_gangmap:client:startRaid', -1, data)
    notify(source, 'Információ', 'Elindítottál egy raidet!')
    setRaid(true, data)
end)

RegisterNetEvent('fusti_gangmap:server:refreshPlayerList')
AddEventHandler('fusti_gangmap:server:refreshPlayerList', function(zone, type, id)
    local xPlayer = ESX.GetPlayerFromId(id)
    local job = xPlayer.getJob().name
    local currentID = getZoneData(zone, job)
    local inTable = ESX.Table.IndexOf(currentID, id)
    if type == 'exit' then
        if inTable > - 1 then
            zoneData[zone][job][inTable] = nil
            xPlayer.setMeta('raidZone', 'none')
            if #zoneData[zone][job] == 0 then
                zoneData[zone][job] = nil
            end
        end
    else
        xPlayer.setMeta('raidZone', zone)
        local newJob = zoneData[zone][job]
        newJob[#newJob + 1] = id
    end
    biggestJob = getBiggestJob(zoneData[zone])
end)

RegisterCommand('raidzone', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local zone = xPlayer.getMeta('raidZone')
    local data = zoneData[zone]
    print(json.encode(data, {indent = true}))
    --- ide majd a rablás startot!
end)