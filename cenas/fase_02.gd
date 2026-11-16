extends FaseBase

var total_plantios = 0

func _ao_comando_sucesso(comando: String, _args: Array) -> void:
	if comando == "plantar":
		total_plantios += 1

func verificar_vitoria() -> bool:
	if total_plantios >= 3:
		return true 
		
	total_plantios = 0
	return false
