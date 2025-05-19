fx_version   'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'
author       'oliann97'
name         'multicharacter'
version      '1.0.0'


shared_scripts {
	'@ox_lib/init.lua',
  '@qbx_core/modules/lib.lua',
  '@es_extended/imports.lua',
  'shared/config.lua'
}

client_scripts {
	'client/main.lua',
  'bridge/appearance/client.lua',
  'bridge/core/esx/client.lua',
  'bridge/core/qbx/client.lua',
  'bridge/core/qb/client.lua',
  '@qbx_core/modules/playerdata.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
  'bridge/core/esx/server.lua',
  'bridge/core/qbx/server.lua',
  'bridge/core/qb/server.lua',
  'bridge/appearance/server.lua',
  'bridge/inventory/server.lua'
}

ui_page 'web/build/index.html'

files {
  'web/build/index.html',
  'web/build/**/*',
}
provides { 'esx_multicharacter' }