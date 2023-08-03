Config = {}
Config.Debug = true
Config.StartKey = 344 -- https://docs.fivem.net/docs/game-references/controls/
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
    ['no_weapon_in_hand'] = 'You dont have a weapon on you!',
    ['information'] = 'Information',
    ['raid_defended'] = 'You have successfully defended your zone!',
    ['no_enough_member'] = 'There are not enough players to start the raid.',
    ['zone_already_in_raid'] = 'The zone is already under raid.',
    ['you_have_to_wait'] = 'You have to wait %s hour and %s minute.',
    ['you_killed'] = 'You have killed player %s (%s).',
    ['raid_started'] = 'You have started a raid!',
    ['cant_do_this'] = 'You can not do this at the moment!',
    -- blip info
    ['owner'] = 'Owner:',
    ['minMember'] = 'Minimum member to attack:',
    ['rewards'] = 'Rewards:',
    ['suggestion'] = 'When entering the zone, use the /raid command to start the raid!'
}

Config.WhitelistedJobs = {
    ['police'] = true,
    ['ambulance'] = true,
    ['unemployed'] = true
}

Config.Zones = {
    ["police"] = {
        label = 'POLICE ZONE',
        coords = vec3(-993.8083, -3153.3833, 13.9444),
        size = vec3(56.0, 57.0, 15.0),
        alpha = 70.0,
        rotation = 340.0,
        minMember = 0,

        reward = {
            ['money'] = 3500,
            ['bread'] = 5,
            ['water'] = 3
        },

        blipData = {
            colour = 38, --https://docs.fivem.net/docs/game-references/blips/#blip-colors
            sprite = 310,
            scale = 1.0
        }
    },
    ["ambulance"] = {
        label = 'AMBULANCE ZONE',
        coords = vec3(-1057.7834, -3309.5071, 13.9445),
        size = vec3(56.0, 57.0, 15.0),
        alpha = 70.0,
        rotation = 340.0,
        minMember = 0,

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