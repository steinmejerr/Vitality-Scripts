fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Steinmejer'
description 'Modern ESX jobcenter with interactive map'
version '1.0.0'

ui_page 'html/index.html'

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

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/gta_map.png',
    'html/gta_map_hd.png'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_target'
}
