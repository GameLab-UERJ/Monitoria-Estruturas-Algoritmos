extends FaseBase

#Código da fase 2
# Sobrescreve o método virtual da FaseBase
func verificar_vitoria() -> bool:
	# O drone irrigador chegou no fim do mapa?
	if drone_logico.posicao == Vector2i(4, 0):
		# Checar as condições da fase
		return true 
	return false
