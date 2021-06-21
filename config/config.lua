config = {}

config.permissao = "policia.permissao" -- Permissão para avisar sobre os roubos
config.tempo = "10" -- Determine após quanto tempo o jogador pode roubar aquele local novamente

config.type= {
	['ammunation'] = {
		ptr = 3, -- Número de polícias necessários para iniciar o roubo
		tempoRoubo = 50, -- Tempo que demora para efetuar o roubo por completo
		chanceRoubo = 20, -- Determine quanto a chance de sucesso para efetuar o roubo. 

		item  = { -- Item que será dado
			['dinheirosujo'] = {min = 1000, max = 10000, div = 2}
		},

        cds = { -- Coordenadas dos locais que podem ser roubados
			{ id = 1, x = 23.89, y = -1106.02, z = 29.8, h = 157.74 },
        }
    },
	['lojinha'] = {
		ptr = 0, -- Número de polícias necessários para iniciar o roubo
		tempoRoubo = 50, -- Tempo que demora para efetuar o roubo por completo 
		chanceRoubo = 100, -- Determine quanto a chance de sucesso para efetuar o roubo. 

		item  = {  -- Item que será dado
			['dinheirosujo'] = {min = 1000, max = 10000, div = 2}
		},

        cds = { -- Coordenadas dos locais que podem ser roubados
			{ id = 55, x = 24.51, y = -1345.02, z = 29.5 , h = 268.07 },
        }
    },
}

return config