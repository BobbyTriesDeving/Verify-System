fx_version 'cerulean'
game 'gta5'

author 'BobbyTriesDeving'
description 'Verify System to keep nerds out of the server'
version '1.0.0'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'sconfig.lua',
    'server.lua'
}

client_scripts {
    '@ox_lib/init.lua',
    'c.lua'
}

lua54 'yes'
