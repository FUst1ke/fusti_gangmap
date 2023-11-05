local locale = Config.Locales

local function IsJobWhiteListed(job)
    if Config.BlipInfo.OnlyForWhitelistedJobs then
        if not Config.WhitelistedJobs[job] then 
            return false 
        else
            return true
        end
    else
        return true
    end
end

local function setupBlip(blip, data, blipSprite)
    local zoneData = Config.Zones[data.zone]
    local ownerColour = Config.Zones[data.owner].blipData.colour
    local job = ESX.PlayerData.job.name
    --
    SetBlipDisplay(blip, 3)
    SetBlipRotation(blip, zoneData.rotation)
    SetBlipColour(blip, ownerColour)
    SetBlipAlpha(blip, data.alpha)
    SetBlipAsShortRange(blip, true)
    --
    SetBlipSprite(blipSprite, data.blipData.sprite)
    SetBlipColour(blipSprite, ownerColour)
    SetBlipScale(blipSprite, data.blipData.scale)
    SetBlipAsShortRange(blipSprite, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(data.label)
    EndTextCommandSetBlipName(blipSprite)
    --
    if Config.BlipInfo.Use then
        local haveAccess = IsJobWhiteListed(job)
        if not haveAccess then return end
        lib.requestStreamedTextureDict("jobs", false)
        exports['blip_info']:SetBlipInfoTitle(blipSprite, zoneData.label, false)
        exports['blip_info']:SetBlipInfoImage(blipSprite, "jobs", data.zone)
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

local function EnteredRaidZone(self)
    TriggerServerEvent('fusti_gangmap:server:refreshPlayerList', self.zone, 'enter', cache.serverId)
end

local function ExitedRaidZone(self)
    TriggerServerEvent('fusti_gangmap:server:refreshPlayerList', self.zone, 'exit', cache.serverId)
    Wait(1000)
    lib.hideTextUI()
end

local function InsideRaidZone(self)
    local zoneData = Config.Zones[self.zone]
    if IsControlJustReleased(0, Config.StartKey) then
        lib.callback('fusti_gangmap:checkStatus', false, function(canStart)
            if canStart then
                TriggerServerEvent('fusti_gangmap:server:startRaid', zoneData)
            end
        end, zoneData, cache.serverId)
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
AddEventHandler('fusti_gangmap:client:stopRaid', function(data, success)
    local blip = Config.Zones[data.zone].blip
    local blipSprite = Config.Zones[data.zone].blipSprite
    if success then
        SetBlipColour(blip, Config.Zones[data.biggestJob].blipData.colour or Config.DefaultColour)
        SetBlipColour(blipSprite, Config.Zones[data.biggestJob].blipData.colour or Config.DefaultColour)
    else
        SetBlipFlashes(blip, false)
    end
    Wait(1000)
    lib.hideTextUI()
end)

RegisterNetEvent('fusti_gangmap:client:updateStatus')
AddEventHandler('fusti_gangmap:client:updateStatus', function(data, canRaid) -- itt majd valami okosabbat légyszi
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
    if not zoneData or not data.zone then
        return print("[ERROR] RESTART THE SCRIPT AGAIN, ZONE NEEDS TO BE REGISTERED IN DATABASE")
    end
    local blip = AddBlipForArea(zoneData.coords, zoneData.size.x, zoneData.size.y)
    local blipSprite = AddBlipForCoord(zoneData.coords)
    Config.Zones[data.zone].blip = blip
    Config.Zones[data.zone].blipSprite = blipSprite
    Config.Zones[data.zone].owner = data.owner
    Config.Zones[data.zone].progress = 0
    Config.Zones[data.zone].isPaused = false
    Config.Zones[data.zone].zone = data.zone ---???
    setupBlip(Config.Zones[data.zone].blip, Config.Zones[data.zone], Config.Zones[data.zone].blipSprite)
    local zone = lib.zones.box({
        coords = zoneData.coords,
        size = zoneData.size,
        rotation = zoneData.rotation,
        debug = Config.Debug,
        onEnter = EnteredRaidZone,
        onExit = ExitedRaidZone,
        inside = InsideRaidZone,
        zone = data.zone
    })
end)