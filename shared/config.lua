Config = {}
Config.Debug = false
Config.StartKey = 344 -- https://docs.fivem.net/docs/game-references/controls/
Config.DefaultColour = 5
Config.BlipInfo = { -- https://github.com/glitchdetector/fivem-blip-info
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
    ['information'] = 'Information',
    ['raid_defended'] = 'You have successfully defended your zone!',
    ['no_enough_member'] = 'There are not enough players to start the raid.',
    ['zone_already_in_raid'] = 'The zone is already under raid.',
    ['you_have_to_wait'] = 'You have to wait %s minute(s).',
    ['you_killed'] = 'You have killed player %s (%s).',
    ['raid_started'] = 'You have started a raid!',
    ['territory_under_raid'] = 'A gang is attacking your territory!',
    ['cant_do_this'] = 'You can not do this at the moment!',
    -- blip info
    ['owner'] = 'Owner:',
    ['minMember'] = 'Minimum member to attack:',
    ['rewards'] = 'Rewards:',
    ['suggestion'] = 'When entering the zone, use the specific key to start the raid!'
}

Config.WhitelistedJobs = {
    ['police'] = true,
    ['ambulance'] = true,
    ['unemployed'] = true
}

Config.Zones = {
    ["grove"] = {
        label = 'Grove Street Families',
        coords = vec3(23.0, -1869.0, 41.0),
        size = vec3(359.0, 94.0, 46.0),
        rotation = 137,
        alpha = 60,
        minMember = 0,

        reward = {
            ['money'] = 3500,
            ['bread'] = 5,
            ['water'] = 3
        },

        blipData = {
            colour = 2, --https://docs.fivem.net/docs/game-references/blips/#blip-colors
            sprite = 310,
            scale = 1.0
        }
    },
    ["ballas"] = {
        label = 'Ballas',
        coords = vec3(-112.0, -1531.0, 36.0),
        size = vec3(204.0, 429.0, 54.0),
        rotation = 320,
        alpha = 60,
        minMember = 0,

        reward = {
            ['money'] = 3500,
            ['bread'] = 5,
            ['water'] = 3
        },

        blipData = {
            colour = 27, --https://docs.fivem.net/docs/game-references/blips/#blip-colors
            sprite = 310,
            scale = 1.0
        }
    },
    ["vagos"] = {
        label = 'Vagos Family',
        coords = vec3(351.0, -2063.0, 30.0),
        size = vec3(154.0, 154.0, 25),
        rotation = 315,
        alpha = 60,
        minMember = 0,

        reward = {
            ['money'] = 3500,
            ['bread'] = 5,
            ['water'] = 3
        },

        blipData = {
            colour = 46, --https://docs.fivem.net/docs/game-references/blips/#blip-colors
            sprite = 310,
            scale = 1.0
        }
    },
    ["crips"] = {
        label = 'Crips',
        coords = vec3(1256.0, -1672.0, 47.0),
        size = vec3(214.0, 199.0, 44.0),
        rotation = 15,
        alpha = 60,
        minMember = 0,

        reward = {
            ['money'] = 3500,
            ['bread'] = 5,
            ['water'] = 3
        },

        blipData = {
            colour = 18, --https://docs.fivem.net/docs/game-references/blips/#blip-colors
            sprite = 310,
            scale = 1.0
        }
    },
    ["lostmc"] = {
        label = 'Lost MC',
        coords = vec3(998.5, -123.0, 85.0),
        size = vec3(84.0, 115, 20.0),
        rotation = 57,
        alpha = 80,
        minMember = 0,

        reward = {
            ['money'] = 3500,
            ['bread'] = 5,
            ['water'] = 3
        },

        blipData = {
            colour = 10, --https://docs.fivem.net/docs/game-references/blips/#blip-colors
            sprite = 310,
            scale = 1.0
        }
    }
}