Config = {}

-- TODO: JOB NOTIFY WHEN IN ZONE IN RAID
-- hát meg amúgy még nagyon sok minden van :)


Config.Locales = {
    ['zone'] = 'Zóna: %s',
    ['owner'] = 'Tulajdonos: %s',
    ['progress'] = 'Állapot: %s',
    ['no_weapon_in_hand'] = 'Nincs nálad fegyver!'
}

Config.Zones = {
    ["ambulance"] = {
        coords = vec3(107.0143, -1942.6709, 20.8037),
        size = vec3(56.0, 57.0, 15.0),
        rotation = 340.0,
        alpha = 100.0
    }
}

Config.JobColours = { -- https://docs.fivem.net/docs/game-references/blips/#blip-colors
    ['police'] = 3,
    ['ambulance'] = 6
}