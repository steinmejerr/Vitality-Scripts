author 'Stausi'
description 'Stausi Clothing'
version '1.1.0'
package_id "5"

fx_version "adamant"
game "gta5"
lua54 "yes"

client_scripts {
    'client/utils.lua',
    'client/main.lua',
    'client/data.lua',
    'client/client.lua',
    'client/handlers.lua',
    'client/tattoo.lua',
    'client/cam.lua',
    'client/maskFixer.lua',
    'client/fixClothing.lua',
    'client/framework/**.*',
    'client/utils_open.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/main.lua',
    'server/tattoo.lua',
    'server/outfits.lua',
    'server/framework/**.*',
}

shared_scripts {
    "config.lua",
    "lang.lua",
    "shared/utils.lua",
    "shared/framework.lua",
    "shared/esx/utils.lua",
    '@st_libs/init.lua',
}

st_libs {
    'callback',
    'hook',
	"version-checker",
}

ui_page 'web/build/index.html'

files {
	'web/build/index.html',
	'web/build/**/*',
}

escrow_ignore {
    'config.lua',
    'lang.lua',
    'client/utils_open.lua',
}

dependencies {
    "st_libs",
    "/server:6231",
    "/onesync"
}

provide {
    'illenium-appearance',
    'esx_skin',
    'skinchanger',
}

dependency '/assetpacks'