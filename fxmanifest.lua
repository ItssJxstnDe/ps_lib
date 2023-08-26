fx_version 'cerulean'
version '1.9.3'
game 'gta5'
author 'PrimeState'
lua54 'yes'
shared_scripts {
    'ps.lua'
}

client_scripts {
    'client/*.lua',
    'client/client_*.lua',
    'common/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
    'server/server_*.lua',
    'common/*.lua',
}

ui_page 'html/index.html'


dependencies {
    'oxmysql'
}

files {
    'import.lua',
    'html/index.html',
    'html/js/*.js',
    'html/css/*.css',
    'html/bag.png'
}
export 'headbag'
