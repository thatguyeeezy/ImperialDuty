fx_version 'cerulean'
game 'gta5'

name 'ImperialDuty'
description 'testing'
author 'Adams'
version '1.0.0'

shared_scripts {
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/main.lua'
}

server_export 'GetOnDutyUnits'
