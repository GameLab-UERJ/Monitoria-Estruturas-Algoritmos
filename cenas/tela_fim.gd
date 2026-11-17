extends Control

func _on_button_pressed() -> void:
	# Substitua o caminho abaixo pelo caminho exato do seu menu principal
	get_tree().change_scene_to_file("res://cenas/menu_principal.tscn")
