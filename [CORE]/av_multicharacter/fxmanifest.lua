fx_version 'cerulean'
author 'AV Scripts'
version '2.0.0'
lua54 'yes'
games {
    'gta5'
}

ui_page 'ui/dist/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'config/*.lua'
}

client_scripts {
    'client/**/*',
    'scenes/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/**/*'
}

files {
    'ui/dist/index.html',
    'ui/dist/**/*',
}

escrow_ignore {
    'config/*.lua',
    'scenes/*.lua',
    'client/editable/*.lua',
    'server/editable/*.lua',
}

dependencies {
    "ox_lib",
}
dependency '/assetpacks'