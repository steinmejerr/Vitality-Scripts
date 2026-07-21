fx_version 'cerulean'
game 'gta5'

author 'Peak Scripts | KostaZ'
description 'Fishing script with a custom minigame, upgradable rods, bait and tackle systems, fishing nets, tournaments & more.'
version '1.2.2'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
this_is_a_map 'yes'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua'
}

server_scripts { 
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

client_scripts { 
    'client/*.lua',
}

ui_page 'web/dist/index.html'

files {
    'config/shared/*.lua',
    'config/client/*.lua',
    'locales/*.json',
    'modules/**/**.lua',
    'web/dist/index.html',
	'web/dist/**/*',
}

escrow_ignore {
    'install/**/*.lua',
    'bridge/**/*.lua',
    'config/**/*.lua',
    'modules/**/*.lua',
    'server/embed.lua',
    'stream/*.ydr',
}

data_file 'DLC_ITYP_REQUEST' 'stream/ep_fishing_net.ytyp'

dependency '/assetpacks'