fx_version 'cerulean'
game 'gta5'

name 'Az-JobCenter'
author 'Azure(TheStoicBear)'
description 'GTA-style Job Center NUI – updates job via MySQL'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/img/*.png',
    'html/img/*.jpg',
}

shared_script 'config.lua'

client_script 'client.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}
