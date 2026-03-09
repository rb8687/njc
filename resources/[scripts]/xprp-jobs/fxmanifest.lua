fx_version 'cerulean'
game 'gta5'

name        'xprp-jobs'
description 'Job system for NJC xprp – manages player jobs and duty state.'
version     '1.0.0'
author      'NJC Development'

shared_scripts {
    'shared/jobs.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}

lua54 'yes'
