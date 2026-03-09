fx_version 'cerulean'
game      'gta5'

author      'NJC'
description 'Awards XP and cash for play time and clean gameplay'
version     '1.0.0'

shared_scripts {
    'shared/config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}

dependencies {
    'xprp-core',
    'oxmysql',
}
