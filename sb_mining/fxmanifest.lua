fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Steinmejer'
description 'ESX mining job with NUI, missions, levels and multiplayer support'
version '1.0.5'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_target',
    'ox_inventory',
    'oxmysql'
}
