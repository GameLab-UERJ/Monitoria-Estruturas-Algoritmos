extends FaseBase

func verificar_vitoria() -> bool:
	var cols = terreno_logico.colunas
	var lins = terreno_logico.linhas

	# 1. Verifica 5 células irrigadas seguidas na horizontal
	for y in range(lins):
		var seguidas = 0
		for x in range(cols):
			var celula = terreno_logico.obter_celula(x, y)
			if celula != null and celula.esta_irrigada():
				seguidas += 1
				if seguidas >= 5:
					return true
			else:
				seguidas = 0

	# 2. Verifica 5 células irrigadas seguidas na vertical
	for x in range(cols):
		var seguidas = 0
		for y in range(lins):
			var celula = terreno_logico.obter_celula(x, y)
			if celula != null and celula.esta_irrigada():
				seguidas += 1
				if seguidas >= 5:
					return true
			else:
				seguidas = 0

	return false
