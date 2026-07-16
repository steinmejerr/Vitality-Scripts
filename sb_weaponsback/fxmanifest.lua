fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Steinmejer'
description 'Shows large weapons on players backs or front'
version '1.2.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'ox_lib'
}

optional_dependencies {
    'ox_inventory',
    'es_extended'
}
