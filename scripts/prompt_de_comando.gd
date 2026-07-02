extends Control
@onready var editor = %EntradaComandos
@onready var historico = %TextEdit
@onready var game_manager = $"../../GameManager"

const COMANDOS_VALIDOS = ["move_left", "move_right", "move_up", "move_down", "plant", "collect"]
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
					if cmd in COMANDOS_VALIDOS:
						cmds_bloco.append(cmd)
						historico.text += "> Bloco: " + cmd + "\n"
					else:
						historico.text += "ERRO: Comando '" + cmd + "' inválido dentro de repeat()!\n"
						return true
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
					if cmd in COMANDOS_VALIDOS:
						cmds_bloco.append(cmd)
						historico.text += "> Bloco if: " + cmd + "\n"
					else:
						historico.text += "ERRO: Comando '" + cmd + "' inválido dentro de if!\n"
						return true
					i += 1
				else:
					break
			if cmds_bloco.is_empty():
				historico.text += "ERRO: if sem comandos dentro do bloco.\n"
				return true
			historico.text += "> Condição registrada: if " + condicao + "\n"
			actions.append({"tipo": "if", "condicao": condicao, "comandos": cmds_bloco})

		else:
			if linha_limpa in COMANDOS_VALIDOS:
				actions.append(linha_limpa)
				historico.text += "> Adicionado: " + linha_limpa + "\n"
			else:
				historico.text += "ERRO: Comando '" + linha_limpa + "' inválido!\n"
				return true
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

func _executar_um_comando(acao: String, mapa, player) -> void:
	var sucesso = false
	var erro_msg = ""
	match acao:
		"move_left", "move_right", "move_up", "move_down":
			var pos_antes = player.position
			player.mover_por_comando(acao)
			await get_tree().create_timer(0.2).timeout
			if player.position.distance_to(pos_antes) > 1.0:
				sucesso = true
			else:
				erro_msg = "Movimento bloqueado!"
		"plant":
			player.mover_por_comando("plant")
			await player.movement_finished
			sucesso = mapa.tentar_plantar(player.position)
			if not sucesso:
				erro_msg = "Solo inválido!"
		"collect":
			player.mover_por_comando("collect")
			await player.movement_finished
			sucesso = mapa.tentar_colher(player.position)
			if sucesso:
				game_manager.add_fruit()
			else:
				erro_msg = "Nada para colher!"

	if sucesso:
		historico.text += "> " + acao + " realizado.\n"
	else:
		historico.text += "ERRO em " + acao + ": " + erro_msg + "\n"
