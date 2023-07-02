local zoneInRaid = {}
local zoneData = {}
local playerData = {}
local cooldownTime = 200
local time = 0

local function countTableValue(zone)
    local counts = {}

    for i, value in ipairs(zone) do
        if counts[value] then
            counts[value] = counts[value] + 1
        else
            counts[value] = 1
        end
    end
end

local function getMostJob(zone)
    countTableValue(zone)
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
    local biggestJob = getMostJob(zoneData[data.zone])
    local canRaid = #biggestJob == 1
    print(#biggestJob)
    data.isPaused = not canRaid
    data.biggestJob = biggestJob[1]
    for k,v in pairs(zoneData[data.zone]) do
        local xPlayer = ESX.GetPlayerFromId(k)
        xPlayer.triggerEvent('fusti_gangmap:client:updateStatus', data, canRaid)
    end
end

MySQL.ready(function ()
    for k,v in pairs(Config.Zones) do
        local response = MySQL.single.await('SELECT * FROM `gangmap` WHERE zone = ?', {k})
        if not response then
            local newZone = MySQL.insert.await('INSERT INTO `gangmap` (zone, progress, owner) VALUES (?, ?, ?)', {k, 0, k})
        end
        TriggerClientEvent('fusti_gangmap:setupZones', -1, response)
    end
end)

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
    if type == 'exit' then
        if playerData[id] then
            playerData[id] = nil
        end
    else
        
        -- local xPlayer = ESX.GetPlayerFromId(id)
        -- local job = xPlayer.getJob().name
        -- if playerData[id] then return end
        -- playerData[id] = job
        -- zoneData[zone] = playerData
        -- biggestJob = getMostJob(zoneData[zone])
    end
    print(json.encode(zoneData, {indent = true}))
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