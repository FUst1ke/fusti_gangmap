local zoneInRaid = {}
local zoneData = {}
local cooldownTime = 200
local time = 0

local function setZoneData(zone, value, job)
    if not zoneData[zone] then
        zoneData[zone] = {}
    end
    if not job then
        zoneData[zone] = value
        return
    end
    zoneData[zone][job] = value
end

local function getZoneData(zone, job)
    if not job then
        return zoneData[zone]
    end
    return zoneData[zone][job] or {}
end

local function getBiggestJob(zone)
    local counts = {}
    for job, value in pairs(zone) do
        counts[job] = #value
    end
    local greatestJobs = {}
    local maxCount = 0

    for key, value in pairs(counts) do
        if value > maxCount then
            maxCount = value
            greatestJobs = {key}
        elseif value == maxCount then
            table.insert(greatestJobs, key)
        end
    end
    return greatestJobs
end

local function updateStatus(data)
    -- local biggestJob = getBiggestJob(zoneData[data.zone])
    local canRaid = #biggestJob == 1
    data.isPaused = not canRaid
    data.biggestJob = biggestJob[1]
    for k,v in pairs(zoneData[data.zone]) do
        local xPlayer = ESX.GetPlayerFromId(k)
        xPlayer.triggerEvent('fusti_gangmap:client:updateStatus', data, canRaid)
    end
end

-- AddEventHandler('onResourceStart', function(resourceName)
MySQL.ready(function ()
    for k,v in pairs(Config.Zones) do
        local response = MySQL.single.await('SELECT * FROM `gangmap` WHERE zone = ?', {k})
        if not response then
            local newZone = MySQL.insert.await('INSERT INTO `gangmap` (zone, progress, owner) VALUES (?, ?, ?)', {k, 0, k})
        end
        zoneData[k] = {}
        TriggerClientEvent('fusti_gangmap:setupZones', -1, response)
    end
end)
-- end)

RegisterNetEvent('fusti_gangmap:server:stopRaid')
AddEventHandler('fusti_gangmap:server:stopRaid', function(data)
    -- change zone data (owner = biggestJob etc.)
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
    local currentJobs = getZoneData(zone, job)
    local inTable = ESX.Table.IndexOf(currentJobs, id)
    if type == 'exit' and inTable > -1 then
        zoneData[zone][job][inTable] = nil
    else
        if inTable > -1 then return end
        if not currentJobs then
            currentJobs = {}
        end
        currentJobs[#currentJobs + 1] = id
        setZoneData(zone, currentJobs, job)
    end
    print(zoneData[zone][job][inTable]) -- nil
    local biggestJob = getBiggestJob(zoneData[zone])
    -- print(json.encode(biggestJob))
    -- print(json.encode(zoneData, {indent = true}))
end)

-- RegisterNetEvent('fusti_gangmap:server:updateStatus')
-- AddEventHandler('fusti_gangmap:server:updateStatus', function(zone, playerID)
--     local xPlayer = ESX.GetPlayerFromId(playerID)
--     local job = xPlayer.getJob().name
--     if playerData[playerID] then return end
--     playerData[playerID] = job
--     zoneData[zone] = playerData
--     biggestJob = getMostJob(zoneData[zone])
-- end)

lib.callback.register('fusti_gangmap:checkStatus', function(source, zone)
    local currentTime = os.time()
    local canStart = (cooldownTime < currentTime - time)
    if zoneInRaid[zone] then 
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Információ', 
            description = 'Ez a zóna éppen raid alatt áll.',
        })
        return true
    elseif not canStart then 
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Információ', 
            description = 'A következő raidhez várj '..math.floor((cooldownTime - (currentTime - time)) / 60).." óra "..math.fmod((cooldownTime - (currentTime - time)), 60).. ' percet.'
        }) 
        return true
    else
        return false 
    end
end)

function setRaid(inRaid, data)
    CreateThread(function()
        while zoneInRaid[data.zone] do
            local sleep = 0
            if data.progress < 100 and not data.isPaused then
                data.progress = data.progress + 1
                sleep = 1000
            elseif data.progress == 100 then
                TriggerEvent('fusti_gangmap:server:stopRaid', data)
                break
            end
            Wait(sleep)
            updateStatus(data)
            -- print(json.encode(data, {indent = true}))
        end
    end)
end


-- SERVER --

-- RegisterServerEvent('testambulance:sendData')
-- AddEventHandler('testambulance:sendData', function(location)
--     local xPlayers = ESX.GetExtendedPlayers('job', 'ambulance')
--     for _, xPlayer in pairs(xPlayers) do
--         xPlayer.triggerEvent('testambulance:receiveCall', location)
--     end
-- end)

-- CLIENT -- 

-- RegisterNetEvent('testambulance:receiveCall')
-- AddEventHandler('testambulance:receiveCall', function(location)
--     exports["npwd"]:createSystemNotification({
--         uniqId = "esxSurvey",
--         content = "Egy eszméletlen járókelőt jelentettek, elvállalod?",
--         secondaryTitle = "EMS",
--         keepOpen = true,
--         duration = 5000,
--         controls = true,
--         onConfirm = function()
--           SetNewWaypoint(location)
--         end
--     })
-- end)

-- RegisterCommand('testambulance', function()
--     local position = GetEntityCoords(cache.ped)
--     TriggerServerEvent('testambulance:sendData', position)
-- end)