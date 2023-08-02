fx_version 'cerulean'
game {'rdr3', 'gta5'}
author 'Füsti'
version '1.0'
lua54 'yes'
description 'gangmap script using ox_lib'

client_scripts {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
}

shared_scripts {
    'shared/config.lua',
    '@ox_lib/init.lua',
    '@es_extended/imports.lua'
}

dependency {
    'blip_info' -- uncomment if you dont want to use it (Check Config.lua)
}