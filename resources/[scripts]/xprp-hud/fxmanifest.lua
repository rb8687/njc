fx_version 'cerulean'
game 'gta5'

name        'xprp-hud'
description 'Player HUD (health, armour, money, job) for NJC xprp.'
version     '1.0.0'
author      'NJC Development'

client_scripts {
    'client/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
}

lua54 'yes'
