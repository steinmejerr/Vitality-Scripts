fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Steinmejer'
description 'Shows large weapons on players backs'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

optional_dependencies {
    'ox_inventory',
    'es_extended'
}
