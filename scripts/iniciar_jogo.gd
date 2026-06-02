extends Button



func _ready() -> void:
    pass



func _process(delta: float) -> void:
    pass


func _on_button_pressed():
    var cena_do_jogo = load("res://cenas/cena_inical_do_jogo.tscn").instantiate()
    
   
    var mapa = cena_do_jogo.get_node("TileMapLayer") 
    
    var l = int(%linhas.text)
    var c = int(%colunas.text)
    
    mapa.linhas_custom = l if l > 0 else 4
    mapa.colunas_custom = c if c > 0 else 4
    
    get_tree().root.add_child(cena_do_jogo)
    get_tree().current_scene.queue_free()
    get_tree().current_scene = cena_do_jogo

    
    

func _on_pressed() -> void:
    _on_button_pressed()


func _on_colunas_text_changed(new_text: String) -> void:
    pass 
