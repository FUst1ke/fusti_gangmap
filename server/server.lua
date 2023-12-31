local locale = Config.Locales
local ownerThread = false
local zoneInRaid = {}
local zoneData = {}
local started = {}
local cooldownTime = 3600
local time = 0

RegisterNetEvent('esx:playerLoaded', function(player)
    if not started[player] then
        MySQL.ready(function()
            for zone, data in pairs(Config.Zones) do
                local response = MySQL.single.await('SELECT * FROM `gangmap` WHERE zone = ?', {zone})
                if not response then
                    local newZone = MySQL.insert.await('INSERT INTO `gangmap` (zone, owner) VALUES (?, ?)', {zone, zone})
                end
                Wait(1000)
                TriggerClientEvent('fusti_gangmap:setupZones', player, response)
            end
        end)
        started[player] = true
    else
        return
    end
end)

AddEventHandler('playerDropped', function()
    started[source] = false
end)

local function getZoneData(zone, job)
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

local function getBiggestJob(zone)
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

local function updateStatus(data)
    local canRaid = biggestJob
    local zoneOwner = Config.Zones[data.zone].owner or data.owner
    data.isPaused = not canRaid
    data.biggestJob = biggestJob
    if data.biggestJob == zoneOwner and not ownerThread then
        ownerThread = true
    end
    for k,v in pairs(zoneData[data.zone]) do
        for _, i in pairs(v) do
            local xPlayer = ESX.GetPlayerFromId(i)
            xPlayer.triggerEvent('fusti_gangmap:client:updateStatus', data, canRaid)
        end
    end
end

local function setRaid(data)
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
                    local zoneOwner = Config.Zones[data.zone].owner or data.owner
                    local ownerJob = ESX.GetExtendedPlayers('job', zoneOwner)
                    for _,xPlayer in pairs(ownerJob) do
                        notify(xPlayer.source, locale['information'], locale['raid_defended'], 'success')
                        TriggerEvent('fusti_gangmap:server:stopRaid', data, false)
                    end
                    break
                end
            end
            Wait(sleep)
        end
    end)
end

lib.callback.register('fusti_gangmap:checkStatus', function(source, data, playerId)
    local zoneOwner = Config.Zones[data.zone].owner or data.owner
    local ownerJobCount = ESX.GetExtendedPlayers('job', zoneOwner)
    local currentTime = os.time()
    local canStart = (cooldownTime < currentTime - time)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local job = xPlayer.getJob().name

    if not Config.WhitelistedJobs[job] or zoneOwner == job then
        notify(source, locale['information'], locale['cant_do_this'], 'error')
        return false 
    end

    if not canStart then
        notify(source, locale['information'], locale['you_have_to_wait']:format(math.floor((cooldownTime - (currentTime - time)) / 60)), 'error')
        return false
    elseif zoneInRaid[data.zone] then 
        notify(source, locale['information'], locale['zone_already_in_raid'], 'error')
        return false
    elseif #ownerJobCount < data.minMember then 
        notify(source, locale['information'], locale['no_enough_member'], 'error')
        return false
    end

    return true 
end)

local function GiveReward(id, zone)
    local ZoneData = Config.Zones[zone]
    local Rewards = ZoneData.reward
    local inventory = exports.ox_inventory
    for item, amount in pairs(Rewards) do
        inventory:AddItem(id, item, amount)
    end
end

RegisterServerEvent('fusti_gangmap:server:stopRaid')
AddEventHandler('fusti_gangmap:server:stopRaid', function(data, success)
    if success then
        data.owner = data.biggestJob
        Config.Zones[data.zone].owner = data.biggestJob
        Config.Zones[data.zone].progress = 0
        Config.Zones[data.zone].isPaused = false
        local updatedZone = MySQL.update.await('UPDATE gangmap SET owner = ? WHERE zone = ?', {
            data.biggestJob, 
            data.zone
        })
        for _,i in pairs(zoneData[data.zone][data.biggestJob]) do
            GiveReward(i, data.zone)
        end
    end
    time = os.time()
    TriggerClientEvent('fusti_gangmap:client:stopRaid', -1, data, success)
    zoneInRaid[data.zone] = false
    setRaid(data)
end)

RegisterNetEvent('fusti_gangmap:server:startRaid')
AddEventHandler('fusti_gangmap:server:startRaid', function(data)
    zoneInRaid[data.zone] = true
    TriggerClientEvent('fusti_gangmap:client:startRaid', -1, data)
    notify(source, locale['information'], locale['raid_started'])

    local xPlayers = ESX.GetExtendedPlayers('job', data.owner)

    for _,xPlayer in pairs(xPlayers) do
        notify(xPlayer.source, locale['information'], locale['territory_under_raid'], 'inform')
    end

    setRaid(data)
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