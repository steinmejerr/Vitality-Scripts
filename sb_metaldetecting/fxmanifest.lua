fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Steinmejer'
description 'Metal detecting for ESX Legacy'
version '1.0.0'

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
    'oxmysql'
}
