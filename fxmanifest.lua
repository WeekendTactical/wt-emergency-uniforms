fx_version "cerulean"
game "gta5"

client_script {
  "client/main.lua",
}

shared_scripts { 
    'config.lua',
	  '@qb-core/import.lua',
}

ui_page "nui/index.html"

files {
  'nui/index.html',
  'nui/images/lossantosLogo.png',
  'nui/images/lossantospdBadge.png',
}

dependency 'qb-core'
