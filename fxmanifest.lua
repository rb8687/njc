fx_version 'cerulean'
game 'gta5'

name        'NPC Criminal Factions'
description 'NPC criminal factions (cartels, mafias, gangs, MC gangs) that spawn every 45 minutes and wholesale-supply drugs to players and criminal factions.'
version     '1.0.0'
author      'njc'

shared_scripts {
    'shared/factions.lua',
}

client_scripts {
    'client/main.lua',
    'client/ui.lua',
}

server_scripts {
    'server/main.lua',
}

lua54 'yes'
