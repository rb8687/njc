fx_version 'cerulean'
game 'gta5'

name        'xprp-factions'
description 'Faction system for NJC xprp – state factions and gangs.'
version     '1.0.0'
author      'NJC Development'

shared_scripts {
    'shared/factions.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}

dependencies {
    'oxmysql',
    'xprp-core',
}

lua54 'yes'
