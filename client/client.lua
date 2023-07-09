local function setupBlip(blip, data)
    local zoneData = Config.Zones[data.zone]
    SetBlipRotation(blip, zoneData.rotation)
    SetBlipColour(blip, Config.JobColours[data.owner])
    SetBlipAlpha(blip, zoneData.alpha)
    SetBlipAsShortRange(blip, true)
end

local function EnteredRaidZone(self)
    local id = GetPlayerServerId(PlayerId())
    local job = ESX.PlayerData.job.name
    local zoneData = self.zoneData
    local progressData = self.progressData
    local locale = Config.Locales
    TriggerServerEvent('fusti_gangmap:server:refreshPlayerList', progressData.zone, 'enter', id)
    if progressData.owner == job then return end
    -- lib.showTextUI('[E] - Foglalás indítása')
end

local function ExitedRaidZone(self)
    local id = GetPlayerServerId(PlayerId())
    local zoneData = self.zoneData
    local progressData = self.progressData
    local locale = Config.Locales
    progressData.blip = self.blip
    lib.hideTextUI()
    TriggerServerEvent('fusti_gangmap:server:refreshPlayerList', progressData.zone, 'exit', id)
end

local function InsideRaidZone(self)
    local job = ESX.PlayerData.job.name
    local zoneData = self.zoneData
    local progressData = self.progressData
    local locale = Config.Locales
    if progressData.owner == job then return end
    if IsControlJustReleased(0, 38) then
        if not IsPedArmed(cache.ped, 4) then lib.notify({title = 'Információ', description = locale['no_weapon_in_hand'], type = 'error'}) return end
        lib.callback('fusti_gangmap:checkStatus', false, function(started)
            if not started then
                progressData.blip = self.blip
                progressData.progress = 0
                progressData.isPaused = false
                TriggerServerEvent('fusti_gangmap:server:startRaid', progressData)
            end
        end, progressData.zone)
    end
end

RegisterNetEvent('fusti_gangmap:client:startRaid')
AddEventHandler('fusti_gangmap:client:startRaid', function(data)
    SetBlipFlashes(data.blip, true)
    SetBlipFlashInterval(data.blip, 800)
end)

RegisterNetEvent('fusti_gangmap:client:stopRaid')
AddEventHandler('fusti_gangmap:client:stopRaid', function(data)
    SetBlipFlashes(data.blip, false)
    SetBlipColour(data.blip, Config.JobColours[data.biggestJob] or Config.DefaultColour)
    lib.hideTextUI()
end)

RegisterNetEvent('fusti_gangmap:client:updateStatus')
AddEventHandler('fusti_gangmap:client:updateStatus', function(data, canRaid)
    local locale = Config.Locales
    local job = ESX.PlayerData.job.name
    if not canRaid then 
        lib.showTextUI(locale['zone']:format(data.zone)..'  \n '..locale['owner']:format(data.owner)..'  \n '..locale['progress']:format('Contested'))
        return
    end
    if job == data.biggestJob and job ~= data.owner then
        lib.showTextUI(locale['zone']:format(data.zone)..'  \n '..locale['owner']:format(data.owner)..'  \n '..locale['progress']:format(data.progress)..'%')
    end
end)

RegisterNetEvent('fusti_gangmap:setupZones')
AddEventHandler('fusti_gangmap:setupZones', function(data)
    local zoneData = Config.Zones[data.zone]
    local blip = AddBlipForArea(zoneData.coords, zoneData.size.x, zoneData.size.y)
    setupBlip(blip, data)
    local zone = lib.zones.box({
        coords = zoneData.coords,
        size = zoneData.size,
        rotation = zoneData.rotation,
        debug = true,
        onEnter = EnteredRaidZone,
        onExit = ExitedRaidZone,
        inside = InsideRaidZone,
        zoneData = zoneData,
        progressData = data,
        blip = blip
    })
end)