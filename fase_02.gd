extends FaseBase

func verificar_vitoria() -> bool:
	# Ignora a lógica do solo e conta diretamente quantos milhos visuais estão na tela
	if $CamadaObjetos.get_child_count() >= 3:
		return true
		
	return false
