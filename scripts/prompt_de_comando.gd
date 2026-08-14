extends Control
@onready var editor = %EntradaComandos
@onready var historico = %TextEdit
@onready var game_manager = $"../../GameManager"
@onready var inventario = get_node("../../Player/Inventario")

const COMANDOS_VALIDOS = ["move_left", "move_right", "move_up", "move_down", "collect", "open", "close"]
const CONDICOES_VALIDAS = ["pode_plantar", "pode_colher"]
var actions = []

func _ready():
	editor.grab_focus()

func _on_button_pressed() -> void:
	var texto_completo = editor.text
	var linhas = texto_completo.split("\n")
	historico.text += "--- Processando Bloco ---\n"
	var erro = _parsear_linhas(linhas)
	if not erro:
		executar_acoes()
	editor.clear()

func _validar_comando(cmd: String):
	var regex_plant = RegEx.new()
	regex_plant.compile("^plant\\((\\d+)\\)$")
	var resultado_plant = regex_plant.search(cmd)
	if resultado_plant:
		var indice = resultado_plant.get_string(1).to_int()
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
	for acao in actions:
		if acao is Dictionary and acao.get("tipo") == "if":
			var condicao_ok = false
			match acao.condicao:
				"pode_plantar":
					condicao_ok = mapa.pode_plantar(player.position)
				"pode_colher":
					condicao_ok = mapa.pode_colher(player.position)
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

func _executar_um_comando(acao, mapa, player) -> void:
	var sucesso = false
	var erro_msg = ""

	if acao is Dictionary and acao.get("tipo") == "plant":
		var indice = acao.indice
		var slot = inventario.get_slot(indice)
		
		if slot == null or slot.quantidade <= 0:
			historico.text += "ERRO em plant(" + str(indice) + "): sem itens nesse slot!\n"
			return
			
		
		
		player.mover_por_comando("plant")
		await player.movement_finished
		
		# Agora passamos a posição e o NOME da semente!
		sucesso = mapa.tentar_plantar(player.position, indice)
		
		if sucesso:
			slot.usar_item()
			historico.text += "> plant(" + str(indice) + ") realizado.\n"
		else:
			historico.text += "ERRO em plant(" + str(indice) + "): Solo inválido!\n"
		return

	match acao:
		"move_left", "move_right", "move_up", "move_down":
			var pos_antes = player.position
			player.mover_por_comando(acao)
			await get_tree().create_timer(0.2).timeout
			if player.position.distance_to(pos_antes) > 1.0:
				sucesso = true
			else:
				erro_msg = "Movimento bloqueado!"
		"collect":
			player.mover_por_comando("collect")
			await player.movement_finished
			sucesso = mapa.tentar_colher(player.position)
			if sucesso:
				game_manager.add_fruit()
			else:
				erro_msg = "Nada para colher!"
		"open":
			inventario.open()
			sucesso = true
		"close":
			inventario.close()
			sucesso = true
	if sucesso:
		historico.text += "> " + acao + " realizado.\n"
	else:
		historico.text += "ERRO em " + acao + ": " + erro_msg + "\n"
