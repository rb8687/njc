fx_version 'cerulean'
game      'gta5'

author      'NJC'
description 'xprp core framework – accounts, characters, player management'
version     '1.0.0'

shared_scripts {
    'shared/config.lua',
    'shared/utils.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/players.lua',
}

client_scripts {
    'client/main.lua',
}

dependencies {
    'oxmysql',
}
