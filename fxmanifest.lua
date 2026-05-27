fx_version 'cerulean'
game 'gta5'

name 'az-jobcenter'
author 'MadebyAzure'
description 'GTA-style Job Center NUI – updates job via MySQL'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}

shared_script 'config.lua'

client_script 'client.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}
