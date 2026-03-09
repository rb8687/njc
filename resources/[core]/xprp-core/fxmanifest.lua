fx_version 'cerulean'
game 'gta5'

name        'xprp-core'
description 'Core framework for NJC xprp – handles players, characters, and events.'
version     '1.0.0'
author      'NJC Development'

shared_scripts {
    'shared/config.lua',
    'shared/utils.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/players.lua',
    'server/characters.lua',
}

client_scripts {
    'client/main.lua',
    'client/characters.lua',
}

lua54 'yes'
