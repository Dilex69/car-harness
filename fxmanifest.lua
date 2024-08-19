fx_version 'cerulean'
game 'gta5'

name 'Dilex'
description 'Savable Harness'

shared_script {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {   
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/main.lua',
    'client/target.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

lua54 'yes'