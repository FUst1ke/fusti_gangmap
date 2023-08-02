Config = {}
Config.DefaultColour = 5
Config.BlipInfo = {
    Use = true,
    OnlyForWhitelistedJobs = true
}

Config.Locales = {
    ['zone'] = 'Zóna: %s',
    ['owner'] = 'Tulajdonos: %s',
    ['progress'] = 'Állapot: %s',
    ['no_weapon_in_hand'] = 'Nincs nálad fegyver!'
}

Config.WhitelistedJobs = {
    ['police'] = true,
    ['ambulance'] = true,
    ['ballas'] = true
}

Config.Zones = {
    ["grove"] = {
        label = 'Grove Street Families',
        coords = vec3(-993.8083, -3153.3833, 13.9444),
        size = vec3(56.0, 57.0, 15.0),
        alpha = 70.0,
        rotation = 340.0,
        minMember = 1,

        reward = {
            ['money'] = 3500,
            ['bread'] = 5,
            ['water'] = 3
        },

        blipData = {
            colour = 6, --https://docs.fivem.net/docs/game-references/blips/#blip-colors
            sprite = 310,
            scale = 1.0
        }
    }
}