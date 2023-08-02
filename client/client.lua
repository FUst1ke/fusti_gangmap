local haveAccess = false

local function setupBlip(blip, data, blipSprite)
    local zoneData = Config.Zones[data.zone]
    local locale = Config.Locales
    SetBlipRotation(blip, zoneData.rotation)
    SetBlipColour(blip, zoneData.blipData.colour)
    SetBlipAlpha(blip, zoneData.alpha)
    SetBlipAsShortRange(blip, true)
    --
    SetBlipSprite(blipSprite, zoneData.blipData.sprite)
    SetBlipColour(blipSprite, zoneData.blipData.colour)
    SetBlipScale(blipSprite, zoneData.blipData.scale)
    SetBlipAsShortRange(blipSprite, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(zoneData.label)
    EndTextCommandSetBlipName(blipSprite)
    --
    if Config.BlipInfo.OnlyForWhitelistedJobs then
        local job = ESX.PlayerData.job.name
        if not Config.WhitelistedJobs[job] then 
            haveAccess = false 
        else
            haveAccess = true
        end
    else
        haveAccess = true
    end
    --
    if Config.BlipInfo.Use then
        if haveAccess then
            lib.requestStreamedTextureDict("jobs", false)
            exports['blip_info']:SetBlipInfoTitle(blipSprite, zoneData.label, false)
            exports['blip_info']:SetBlipInfoImage(blipSprite, "jobs", data.zone)
            print("DATA OWNER", Config.Zones[data.owner].label)
            exports['blip_info']:AddBlipInfoText(blipSprite, locale['owner'], tostring(Config.Zones[data.owner].label))
            exports['blip_info']:AddBlipInfoName(blipSprite, locale['minMember'], tostring(zoneData.minMember))
            exports['blip_info']:AddBlipInfoText(blipSprite, locale['rewards'], "")
            
            for item, data in pairs(exports.ox_inventory:Items()) do
                for k,v in pairs(zoneData.reward) do
                    if k == item then
                        exports['blip_info']:AddBlipInfoText(blipSprite, data.label, v.."x")
                    end
                end
            end

            exports['blip_info']:AddBlipInfoHeader(blipSprite, "")
            exports['blip_info']:AddBlipInfoText(blipSprite, locale['suggestion'])
        end
    end
end

local function EnteredRaidZone(self)
    local id = GetPlayerServerId(PlayerId())
    local job = ESX.PlayerData.job.name
    local zoneData = self.zoneData
    local progressData = self.progressData
    local locale = Config.Locales
    TriggerServerEvent('fusti_gangmap:server:refreshPlayerList', progressData.zone, 'enter', id)
    if progressData.owner == job then return end
end

local function ExitedRaidZone(self)
    local id = GetPlayerServerId(PlayerId())
    local zoneData = self.zoneData
    local progressData = self.progressData
    local locale = Config.Locales
    progressData.blip = self.blip
    TriggerServerEvent('fusti_gangmap:server:refreshPlayerList', progressData.zone, 'exit', id)
    Wait(1000)
    lib.hideTextUI()
end

local function InsideRaidZone(self)
    local job = ESX.PlayerData.job.name
    local zoneData = self.zoneData
    local progressData = self.progressData
    local locale = Config.Locales
    if not Config.WhitelistedJobs[job] then return end
    if progressData.owner == job then return end
    if IsControlJustReleased(0, Config.StartKey) then
        if not IsPedArmed(cache.ped, 4) then lib.notify({title = 'Információ', description = locale['no_weapon_in_hand'], type = 'error'}) return end
        lib.callback('fusti_gangmap:checkStatus', false, function(started)
            if not started then
                progressData.blip = self.blip
                progressData.progress = 0
                progressData.isPaused = false
                TriggerServerEvent('fusti_gangmap:server:startRaid', progressData)
            end
        end, progressData)
    end
end

RegisterNetEvent('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

RegisterNetEvent('fusti_gangmap:client:startRaid')
AddEventHandler('fusti_gangmap:client:startRaid', function(data)
    local blip = Config.Zones[data.zone].blip
    SetBlipFlashes(blip, true)
    SetBlipFlashInterval(blip, 800)
end)

RegisterNetEvent('fusti_gangmap:client:stopRaid')
AddEventHandler('fusti_gangmap:client:stopRaid', function(data)
    local blip = Config.Zones[data.zone].blip
    SetBlipFlashes(blip, false)
    SetBlipColour(blip, Config.Zones[data.biggestJob].blipData.colour or Config.DefaultColour)
    Wait(1000)
    lib.hideTextUI()
end)

RegisterNetEvent('fusti_gangmap:client:updateStatus')
AddEventHandler('fusti_gangmap:client:updateStatus', function(data, canRaid)
    local locale = Config.Locales.progress
    local job = ESX.PlayerData.job.name
    if not canRaid then 
        lib.showTextUI(locale['zone']:format(Config.Zones[data.zone].label)..'  \n '..locale['owner']:format(Config.Zones[data.owner].label)..'  \n '..locale['progress']:format(locale['contested']))
        return
    end
    if job == data.biggestJob or job == data.owner then
        lib.showTextUI(locale['zone']:format(Config.Zones[data.zone].label)..'  \n '..locale['owner']:format(Config.Zones[data.owner].label)..'  \n '..locale['progress']:format(data.progress)..'%')
    end
end)

RegisterNetEvent('fusti_gangmap:setupZones')
AddEventHandler('fusti_gangmap:setupZones', function(data)
    local zoneData = Config.Zones[data.zone]
    if not zoneData then
        return print("[ERROR] RESTART THE SCRIPT AGAIN, ZONE NEEDS TO BE REGISTERED IN DATABASE")
    end
    local blip = AddBlipForArea(zoneData.coords, zoneData.size.x, zoneData.size.y)
    local blipSprite = AddBlipForCoord(zoneData.coords)
    Config.Zones[data.zone].blip = blip
    setupBlip(blip, data, blipSprite)
    local zone = lib.zones.box({
        coords = zoneData.coords,
        size = zoneData.size,
        rotation = zoneData.rotation,
        debug = false,
        onEnter = EnteredRaidZone,
        onExit = ExitedRaidZone,
        inside = InsideRaidZone,
        zoneData = zoneData,
        progressData = data
    })
end)