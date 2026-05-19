extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed():
	var cena_do_jogo = load("res://cenas/cena_inical_do_jogo.tscn").instantiate()
	
	var l = int(%linhas.text)
	var c = int(%colunas.text)
	
	
	
	cena_do_jogo.linhas_custom = l if l > 0 else 4
	cena_do_jogo.colunas_custom = c if c > 0 else 4
	
	 
	get_tree().root.add_child(cena_do_jogo)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = cena_do_jogo

	
	

func _on_pressed() -> void:
	_on_button_pressed()


func _on_colunas_text_changed(new_text: String) -> void:
	pass # Replace with function body.
