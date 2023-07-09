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
        zoneData[k] = {}
        TriggerClientEvent('fusti_gangmap:setupZones', -1, response)
    end
end)

function getZoneData(zone, job)
    if not zone then return end
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
            greatestJob = job
        elseif value == min then
            return false
        end
    end
    return greatestJob
end

function updateDataBase(data)
    local updatedZone = MySQL.update.await('UPDATE gangmap SET owner = ? WHERE zone = ?', {data.biggestJob, data.zone})
end

function updateStatus(data)
    local canRaid = biggestJob
    data.isPaused = not canRaid
    data.biggestJob = biggestJob
    if data.biggestJob == data.owner and not ownerThread then
        ownerThread = true
        startOwnerThread(data)
    end
    for k,v in pairs(zoneData[data.zone]) do
        for _, i in pairs(v) do
            local xPlayer = ESX.GetPlayerFromId(i)
            xPlayer.triggerEvent('fusti_gangmap:client:updateStatus', data, canRaid)
        end
    end
end

function setRaid(inRaid, data)
    CreateThread(function()
        while zoneInRaid[data.zone] do
            local sleep = 0
            if data.progress < 100 and not data.isPaused then
                data.progress = data.progress + 1
                sleep = 100
            elseif data.progress == 100 then
                TriggerEvent('fusti_gangmap:server:stopRaid', data, true)
                updateDataBase(data)
                break
            end
            Wait(sleep)
            updateStatus(data)
        end
    end)
end

function startOwnerThread(data)
    local count = 0
    local sleep = 0
    CreateThread(function()
        while ownerThread do
            if count < 10 then
                count = count + 1
                sleep = 1000
            else
                ownerThread = false
                local ownerJob = ESX.GetExtendedPlayers('job', data.owner)
                for _,xPlayer in pairs(ownerJob) do
                    xPlayer.triggerEvent('ox_lib:notify', {title = 'Információ', description = 'Sikeresen visszaverted a raidet!', type = 'success'})
                    TriggerEvent('fusti_gangmap:server:stopRaid', data, false)
                end
                break
            end
            Wait(sleep)
        end
    end)
end

lib.callback.register('fusti_gangmap:checkStatus', function(source, zone)
    local currentTime = os.time()
    local canStart = (cooldownTime < currentTime - time)
    if zoneInRaid[zone] then 
        TriggerClientEvent('ox_lib:notify', source, {title = 'Információ', description = 'Ez a zóna éppen raid alatt áll.',})
        return true
    elseif not canStart then 
        TriggerClientEvent('ox_lib:notify', source, {title = 'Információ', description = 'A következő raidhez várj '..math.floor((cooldownTime - (currentTime - time)) / 60).." óra "..math.fmod((cooldownTime - (currentTime - time)), 60).. ' percet.'}) 
        return true
    else
        return false 
    end
end)

RegisterServerEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local job = xPlayer.getJob().name
    local zone = xPlayer.getMeta('raidZone')
    TriggerEvent('fusti_gangmap:server:refreshPlayerList', zone, 'exit', source)
end)

RegisterNetEvent('fusti_gangmap:server:stopRaid')
AddEventHandler('fusti_gangmap:server:stopRaid', function(data, success)
    time = os.time()
    zoneInRaid[data.zone] = false
    TriggerClientEvent('fusti_gangmap:client:stopRaid', -1, data)
    setRaid(false, data)
end)

RegisterNetEvent('fusti_gangmap:server:startRaid')
AddEventHandler('fusti_gangmap:server:startRaid', function(data)
    zoneInRaid[data.zone] = true
    TriggerClientEvent('fusti_gangmap:client:startRaid', -1, data)
    TriggerClientEvent('ox_lib:notify', source, {title = 'Információ',  description = 'Elindítottál egy raidet!'})
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
    print(json.encode(zoneData[zone], {indent = true}))
end)