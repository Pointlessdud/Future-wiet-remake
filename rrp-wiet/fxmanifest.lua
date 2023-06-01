fx_version 'cerulean'
game 'gta5'

lua54 'yes'

description 'ESX Drugs'
version '2.0.0'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua',
	'client/main.lua',
	'client/weed.lua'
}

dependency 'es_extended'
