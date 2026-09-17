extends Button

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _on_button_pressed():
	var cena_do_jogo = load("res://scenes/map_editor.tscn").instantiate()
	get_tree().root.add_child(cena_do_jogo)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = cena_do_jogo

func _on_pressed() -> void:
	_on_button_pressed()
