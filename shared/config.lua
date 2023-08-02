Config = {}
Config.DefaultColour = 5
Config.BlipInfo = {
    Use = true,
    OnlyForWhitelistedJobs = true
}

Config.Locales = {
    progress = {
        ['zone'] = 'Zone: %s',
        ['owner'] = 'Owner: %s',
        ['progress'] = 'Progress: %s',
        ['contested'] = 'Contested'
    },
    -- general
    ['no_weapon_in_hand'] = 'Nincs nálad fegyver!',
    ['information'] = 'Information',
    ['raid_defended'] = 'You have successfully defended your zone!',
    ['no_enough_member'] = 'There are not enough players to start the raid.',
    ['zone_already_in_raid'] = 'The zone is already under raid.',
    ['you_have_to_wait'] = 'You have to wait %s hour and %s minute.',
    ['you_killed'] = 'You have killed player %s (%s).',
    -- blip info
    ['owner'] = 'Owner:',
    ['minMember'] = 'Minimum member to attack:',
    ['rewards'] = 'Rewards:',
    ['suggestion'] = 'When entering the zone, use the /raid command to start the raid!'
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