fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Steinmejer'
description 'ESX Legacy adminmenu med ox_lib'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua',
    'locales/*.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'ox_lib',
    'es_extended'
}
