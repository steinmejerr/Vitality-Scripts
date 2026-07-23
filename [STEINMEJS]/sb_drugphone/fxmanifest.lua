fx_version 'cerulean'
game 'gta5'

name 'sb_drugphone'
author 'Steinmejer'
description 'Drug phone dealing system for ESX Legacy, ox_inventory, ox_lib and ox_target'
version '1.0.0'

lua54 'yes'

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
    'ox_inventory',
    'ox_target'
}
