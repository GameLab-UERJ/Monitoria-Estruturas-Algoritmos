extends FaseBase

func verificar_vitoria() -> bool:
	var atingiu_objetivo = false
	
	# Percorre o mapa testando se existe algum quadrado 3x3 totalmente irrigado
	# Usamos -2 para não tentar ler fora dos limites do mapa
	for x in range(terreno_logico.colunas - 2):
		for y in range(terreno_logico.linhas - 2):
			if _checar_area_3x3(x, y):
				atingiu_objetivo = true
				break # Para de procurar assim que achar um quadrado vencedor
				
		if atingiu_objetivo:
			break
			
	return atingiu_objetivo

# Função auxiliar que testa um bloco específico de 3x3
func _checar_area_3x3(inicio_x: int, inicio_y: int) -> bool:
	for i in range(3):
		for j in range(3):
			var celula = terreno_logico.obter_celula(inicio_x + i, inicio_y + j)
			if celula == null or not celula.esta_irrigada():
				return false # Se achar um pedaço seco, cancela a verificação desta área
				
	return true # Se passar por todos os 9 quadrados e estiverem molhados, é vitória!
