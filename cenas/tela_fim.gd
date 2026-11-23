extends Control

func _on_button_pressed() -> void:
	# Substitua o caminho abaixo pelo caminho exato do seu menu principal
	EasyTransition.transition_to("res://cenas/menu_principal.tscn",1.0,EasyTransition.TransitionAnim.FADE,Color.CORAL)
	
