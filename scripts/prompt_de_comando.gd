extends Control
@onready var editor = %EntradaComandos
@onready var historico = %TextEdit
@onready var game_manager = $"../../GameManager"
@onready var inventario = get_node("../../Player/Inventario")

const COMANDOS_VALIDOS = ["move_left", "move_right", "move_up", "move_down", "collect", "open", "close", "leave"]
const CONDICOES_VALIDAS = ["pode_plantar", "pode_colher"]
var actions = []

# Variável para rastrear o uso de loops na missão
var qtd_repeat_usados: int = 0

func _ready():
	editor.grab_focus()

func _on_button_pressed() -> void:
	var texto_completo = editor.text
	var linhas = texto_completo.split("\n")
	historico.text += "--- Processando Bloco ---\n"
	
	qtd_repeat_usados = 0 # Reseta a contagem ao rodar um novo bloco
	
	var erro = _parsear_linhas(linhas)
	if not erro:
		executar_acoes()
	editor.clear()

func _validar_comando(cmd: String):
	var regex_plant = RegEx.new()
	regex_plant.compile("^plant(?:\\((\\d+)\\))?$")
	var resultado_plant = regex_plant.search(cmd)
	
	if resultado_plant:
		var indice_str = resultado_plant.get_string(1)
		var indice = 1 
		if indice_str != "":
			indice = indice_str.to_int()
			
		if indice < 1 or indice > 10:
			return {"erro": "Índice de item inválido em plant(): " + str(indice)}
		return {"tipo": "plant", "indice": indice}
		
	if cmd in COMANDOS_VALIDOS:
		return cmd
	return null

func _parsear_linhas(linhas: Array) -> bool:
	var i = 0
	while i < linhas.size():
		var linha = linhas[i]
		var linha_limpa = linha.strip_edges()
		if linha_limpa.is_empty():
			i += 1
			continue
		var regex_repeat = RegEx.new()
		regex_repeat.compile("^repeat\\((\\d+)\\):$")
		var resultado_repeat = regex_repeat.search(linha_limpa)
		var regex_if = RegEx.new()
		regex_if.compile("^if\\s+(\\w+)\\s*:$")
		var resultado_if = regex_if.search(linha_limpa)
		
		if resultado_repeat:
			qtd_repeat_usados += 1 # Adiciona 1 à contagem de repeats
			var n = resultado_repeat.get_string(1).to_int()
			if n <= 0:
				historico.text += "ERRO: repeat() precisa de número maior que zero.\n"
				return true
			var cmds_bloco = []
			i += 1
			while i < linhas.size():
				var prox = linhas[i]
				if prox.length() > 0 and (prox[0] == "\t" or prox[0] == " "):
					var cmd = prox.strip_edges()
					if cmd.is_empty():
						i += 1
						continue
					var validado = _validar_comando(cmd)
					if validado == null:
						historico.text += "ERRO: Comando '" + cmd + "' inválido dentro de repeat()!\n"
						return true
					elif typeof(validado) == TYPE_DICTIONARY and validado.has("erro"):
						historico.text += "ERRO: " + validado.erro + "\n"
						return true
					else:
						cmds_bloco.append(validado)
						historico.text += "> Bloco: " + cmd + "\n"
					i += 1
				else:
					break
			if cmds_bloco.is_empty():
				historico.text += "ERRO: repeat() sem comandos dentro do bloco.\n"
				return true
			historico.text += "> Expandindo " + str(cmds_bloco.size()) + " comando(s) × " + str(n) + "\n"
			for _rep in range(n):
				for cmd in cmds_bloco:
					actions.append(cmd)
		elif resultado_if:
			var condicao = resultado_if.get_string(1)
			if not condicao in CONDICOES_VALIDAS:
				historico.text += "ERRO: Condição '" + condicao + "' inválida!\n"
				return true
			var cmds_bloco = []
			i += 1
			while i < linhas.size():
				var prox = linhas[i]
				if prox.length() > 0 and (prox[0] == "\t" or prox[0] == " "):
					var cmd = prox.strip_edges()
					if cmd.is_empty():
						i += 1
						continue
					var validado = _validar_comando(cmd)
					if validado == null:
						historico.text += "ERRO: Comando '" + cmd + "' inválido dentro de if!\n"
						return true
					elif typeof(validado) == TYPE_DICTIONARY and validado.has("erro"):
						historico.text += "ERRO: " + validado.erro + "\n"
						return true
					else:
						cmds_bloco.append(validado)
						historico.text += "> Bloco if: " + cmd + "\n"
					i += 1
				else:
					break
			if cmds_bloco.is_empty():
				historico.text += "ERRO: if sem comandos dentro do bloco.\n"
				return true
			historico.text += "> Condição registrada: if " + condicao + "\n"
			actions.append({"tipo": "if", "condicao": condicao, "comandos": cmds_bloco})
		else:
			var validado = _validar_comando(linha_limpa)
			if validado == null:
				historico.text += "ERRO: Comando '" + linha_limpa + "' inválido!\n"
				return true
			elif typeof(validado) == TYPE_DICTIONARY and validado.has("erro"):
				historico.text += "ERRO: " + validado.erro + "\n"
				return true
			else:
				actions.append(validado)
				if typeof(validado) == TYPE_STRING:
					historico.text += "> Adicionado: " + validado + "\n"
				else:
					historico.text += "> Adicionado: plant(" + str(validado.indice) + ")\n"
			i += 1
	return false

func executar_acoes():
	historico.text += "--- Executando... ---\n"
	var mapa = get_node("../../TileMapLayer")
	var player = get_node("../../Player")
	
	# Passa a quantidade de repeats usados para o game manager antes de começar
	game_manager.registrar_uso_comandos(qtd_repeat_usados)
	
	for acao in actions:
		if acao is Dictionary and acao.get("tipo") == "if":
			var condicao_ok = false
			match acao.condicao:
				"pode_plantar":
					condicao_ok = mapa.pode_plantar(player.global_position)
				"pode_colher":
					condicao_ok = mapa.pode_colher(player.global_position)
			historico.text += "> if " + acao.condicao + " -> " + str(condicao_ok) + "\n"
			if condicao_ok:
				for cmd in acao.comandos:
					await _executar_um_comando(cmd, mapa, player)
			else:
				historico.text += "> Condição falsa, bloco ignorado.\n"
		else:
			await _executar_um_comando(acao, mapa, player)
			
	actions.clear()
	historico.text += "--- Concluído ---\n"
	
	# QUANDO TUDO ACABAR, CHAMA A VALIDAÇÃO DO GDD
	game_manager.validar_missao_fim_de_execucao()

# Função auxiliar para detetar a cor de forma universal
func obter_cor_da_planta(id_str: String) -> String:
	# O ID 9 é a flor vermelha, ID 3 é azul, ID 5 é amarela.
	if id_str == "vermelha" or id_str == "9" or id_str == "11": return "vermelha"
	if id_str == "azul" or id_str == "3" or id_str == "10": return "azul"
	if id_str == "amarela" or id_str == "5": return "amarela"
	return id_str

func _executar_um_comando(acao, mapa, player) -> void:
	var sucesso = false
	var erro_msg = ""

	# Lógica do PLANT
	if acao is Dictionary and acao.get("tipo") == "plant":
		var indice = acao.indice
		var slot = inventario.get_slot(indice)
		
		if slot == null or slot.quantidade <= 0:
			historico.text += "ERRO em plant(" + str(indice) + "): sem itens nesse slot!\n"
			game_manager.registrar_erro()
			return
			
		if mapa.pode_plantar(player.global_position):
			player.mover_por_comando("plant")
			await player.movement_finished
			
			sucesso = mapa.tentar_plantar(player.global_position, indice)
			if sucesso:
				slot.usar_item()
				var cor = obter_cor_da_planta(str(indice))
				game_manager.registrar_plantio(cor) # Avisa o juiz da cor correta
				historico.text += "> plant(" + str(indice) + ") realizado. Cor: " + cor + "\n"
		else:
			historico.text += "ERRO em plant(" + str(indice) + "): Precisa ser terra arada vazia!\n"
			game_manager.registrar_erro()
		return

	match acao:
		"move_left", "move_right", "move_up", "move_down":
			var pos_antes = player.global_position
			player.mover_por_comando(acao)
			await get_tree().create_timer(0.2).timeout
			if player.global_position.distance_to(pos_antes) > 1.0:
				sucesso = true
			else:
				erro_msg = "Movimento bloqueado!"
				game_manager.registrar_erro()
				
		# Lógica do COLLECT
		"collect":
			if mapa.pode_colher(player.global_position):
				# Lê a cor da flor antes de removê-la do mapa!
				var pos_grid = mapa.local_to_map(mapa.to_local(player.global_position))
				var celula = mapa.estado_celulas[pos_grid]
				var cor_da_flor = obter_cor_da_planta(str(celula.get("tipo_planta", "desconhecida")))
				
				player.mover_por_comando("collect")
				await player.movement_finished
				sucesso = mapa.tentar_colher(player.global_position)
				if sucesso:
					game_manager.registrar_coleta(cor_da_flor) # Avisa o juiz que flor foi recolhida
			else:
				erro_msg = "Nenhuma flor pronta para colher aqui!"
				game_manager.registrar_erro()
		"open":
			inventario.open()
			sucesso = true
		"close":
			inventario.close()
			sucesso = true
		"leave":
			historico.text += "> leave: voltando para a cena inicial...\n"
			get_tree().change_scene_to_file("res://scenes/control.tscn")
			return
			
	if sucesso:
		historico.text += "> " + acao + " realizado.\n"
	else:
		historico.text += "ERRO em " + acao + ": " + erro_msg + "\n"
