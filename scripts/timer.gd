extends Timer

func _on_timer_timeout() -> void:
	
	get_parent().processar_crescimento()
