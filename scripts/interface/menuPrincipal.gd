extends Control

func _on_btn_iniciar_pressed() -> void:
	# Carrega o nível 1 por padrão através do Autoload global
	#GerenciadorCenas.mudar_para_cena("res://telas/nivel_jogo/JogoPrincipal.tscn")
	pass

func _on_btn_editor_pressed() -> void:
	#GerenciadorCenas.mudar_para_cena("res://telas/editor_mapas/EditorMapas.tscn")
	pass

func _on_btn_sair_pressed() -> void:
	get_tree().quit()
