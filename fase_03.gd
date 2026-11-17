extends FaseBase

func verificar_vitoria() -> bool:
	# Pega o texto do editor da cena base
	var codigo_aluno = code_edit.text.to_lower()
	
	# 1. Verifica uso de IF e acha onde está o ELSE
	var usou_if = ("if " in codigo_aluno) or ("if(" in codigo_aluno)
	var indice_else = codigo_aluno.find("else")
	var usou_else = (indice_else != -1)
	
	# 2. Verifica se usou pousar() depois do else
	var usou_pousar_no_else = false
	if usou_else:
		# Recorta o código pegando só a parte do "else" para baixo
		var bloco_else = codigo_aluno.substr(indice_else)
		if "pousar()" in bloco_else:
			usou_pousar_no_else = true
			
	# Se faltar qualquer uma das regras de texto, não deixa vencer
	if not (usou_if and usou_else and usou_pousar_no_else):
		print("Dica: Use 'if', 'else' e coloque 'pousar()' dentro do bloco else!")
		return false
		
	# 3. Conta as células irrigadas
	var celulas_irrigadas = 0
	
	for x in range(terreno_logico.colunas):
		for y in range(terreno_logico.linhas):
			var celula = terreno_logico.obter_celula(x, y)
			if celula != null and celula.esta_irrigada():
				celulas_irrigadas += 1
				
	# 4. Checa se atingiu a meta de 2 irrigações
	if celulas_irrigadas >= 2:
		return true 
		
	return false
