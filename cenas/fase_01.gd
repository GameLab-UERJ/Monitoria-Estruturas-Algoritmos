extends FaseBase

# Sobrescreve o método virtual da FaseBase
func verificar_vitoria() -> bool:
	var total_irrigadas = 0
	
	# Percorre todas as colunas e linhas do grid do terreno
	for x in range(terreno_logico.colunas):
		for y in range(terreno_logico.linhas):
			# Obtém a célula na posição (x, y)
			var celula = terreno_logico.obter_celula(x, y)
			
			# Checa se a célula existe e se a umidade atingiu o limite de irrigação
			if celula != null and celula.esta_irrigada():
				total_irrigadas += 1
				
	# Verifica se a condição da fase (4 células irrigadas) foi atingida
	if total_irrigadas >= 4:
		return true
		
	return false
