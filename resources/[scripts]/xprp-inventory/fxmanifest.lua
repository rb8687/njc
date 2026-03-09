fx_version 'cerulean'
game 'gta5'

name        'xprp-inventory'
description 'Item inventory system for NJC xprp.'
version     '1.0.0'
author      'NJC Development'

shared_scripts {
    'shared/items.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}

lua54 'yes'
