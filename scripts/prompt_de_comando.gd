extends Control

@onready var editor = $HBoxContainer/VBoxContainer/EntradaComandos
@onready var historico = $HBoxContainer/TextEdit
@onready var game_manager = %GameManager

const COMANDOS_VALIDOS = ["move_left", "move_right", "move_up", "move_down", "plant", "collect"]
var actions = []

func _ready():
	
	editor.grab_focus()


func _on_button_pressed() -> void:
	var texto_completo = editor.text
	var linhas = texto_completo.split("\n")
	historico.text += "--- Processando Bloco ---\n"

	for linha in linhas:
		var comando = linha.strip_edges()
		if not comando.is_empty():
			if comando in COMANDOS_VALIDOS:
				actions.append(comando)
				historico.text += "> Adicionado: " + comando + "\n"
			else:
				historico.text += "ERRO: Comando '" + comando + "' inválido!\n"
	
	
	editor.clear()
	
	
	executar_acoes()

func executar_acoes():
	historico.text += "--- Executando... ---\n"
	var mapa = get_node("../../TileMapLayer")
	var player = get_node("../../Player")
	
	for acao in actions:
		var sucesso = false
		var erro_msg = ""
		
		match acao:
			"move_left", "move_right", "move_up", "move_down":
				# 1. Pega a posição exata de agora
				var pos_antes = player.position
				
			   
				player.mover_por_comando(acao)
				
				
				await get_tree().create_timer(0.2).timeout
				
				
				if player.position.distance_to(pos_antes) > 1.0:
					sucesso = true
				else:
					sucesso = false
					erro_msg = "Movimento bloqueado!"
			
			"plant":
				sucesso = mapa.tentar_plantar(player.position)
				if not sucesso: erro_msg = "Solo inválido!"
				await get_tree().create_timer(0.2).timeout
			
			"collect":
				sucesso = mapa.tentar_colher(player.position)
				if not sucesso: erro_msg = "Nada para colher!"
				await get_tree().create_timer(0.2).timeout

		
		if sucesso:
			historico.text += "> " + acao + " realizado.\n"
		else:
			historico.text += "ERRO em " + acao + ": " + erro_msg + "\n"
			
	actions.clear()
	historico.text += "--- Concluído ---\n"
