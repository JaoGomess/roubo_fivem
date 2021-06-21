fx_version 'adamant'
game 'gta5'

author 'Tikuida'

client_script{
    '@vrp/lib/utils.lua',
    'config/config.lua',
    'client/*.lua'
}

server_script {
    '@vrp/lib/utils.lua',
    'config/config.lua',
	'server.lua'
}