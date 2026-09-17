extends Button

# Carrega o script do GameManager diretamente pelo caminho
const GameManagerScript = preload("res://scripts/game_manager.gd")

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _on_button_pressed():
	# Reseta o progresso para a Missão 1 usando o script carregado
	GameManagerScript.missao_atual = 1
	
	var cena_do_jogo = load("res://scenes/cena_inicial_do_jogo.tscn").instantiate()
	get_tree().root.add_child(cena_do_jogo)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = cena_do_jogo

func _on_pressed() -> void:
	_on_button_pressed()

func _on_colunas_text_changed(_new_text: String) -> void:
	pass
