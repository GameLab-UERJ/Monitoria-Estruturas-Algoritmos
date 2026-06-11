extends Control

@onready var editor = $HBoxContainer/VBoxContainer/EntradaComandos 
@onready var historico = $HBoxContainer/TextEdit            

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
	var player = $"../../Player"
	var mapa = $"../../TileMapLayer"
	
	for acao in actions:
		match acao:
			"move_left", "move_right", "move_up", "move_down":
			   
				player.mover_por_comando(acao)
				
				await player.movement_finished
				
			"plant":
				mapa.plantar_na_posicao(player.position)
				player.mover_por_comando("plant")
				await player.movement_finished # Pequeno delay visual
				
			"collect":
				mapa.colher_na_posicao(player.position)
				player.mover_por_comando("collect")
				await player.movement_finished
		
	actions.clear()
	historico.text += "--- Concluído ---\n"
