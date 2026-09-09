extends Button

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _on_button_pressed():
	var cena_do_jogo = load("res://scenes/map_editor.tscn").instantiate()
	var mapa = cena_do_jogo.get_node("TileMapLayer") 
	var l = int(%linhas.text)
	var c = int(%colunas.text)
	get_tree().root.add_child(cena_do_jogo)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = cena_do_jogo

func _on_pressed() -> void:
	_on_button_pressed()

func _on_colunas_text_changed(_new_text: String) -> void:
	pass 
