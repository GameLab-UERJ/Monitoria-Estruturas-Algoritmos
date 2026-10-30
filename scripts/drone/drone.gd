class_name Drone
extends RefCounted

enum EstadoVoo { POUSADO, EM_VOO }

var posicao: Vector2i
var estado_voo: EstadoVoo
var bateria: int
var bateria_maxima: int
var terreno: Terreno

func _init(p_terreno: Terreno, x: int = 0, y: int = 0, p_bateria_maxima: int = 100) -> void:
	terreno = p_terreno
	posicao = Vector2i(x, y)
	bateria_maxima = p_bateria_maxima
	bateria = bateria_maxima
	estado_voo = EstadoVoo.POUSADO

## Coloca o drone no ar, permitindo a movimentação.
func decolar() -> bool:
	if estado_voo == EstadoVoo.EM_VOO:
		return false # Já está no ar
	if not _gastar_bateria(1):
		return false # Sem energia para decolagem
		
	estado_voo = EstadoVoo.EM_VOO
	return true

## Retorna o drone ao solo com segurança.
func pousar() -> bool:
	if estado_voo == EstadoVoo.POUSADO:
		return false # Já está pousado
	if not _gastar_bateria(1):
		return false
		
	estado_voo = EstadoVoo.POUSADO
	return true

## Move 1 célula para cima (Y decrementa no grid 2D do Godot).
func mover_cima() -> bool:
	return _tentar_mover(Vector2i(0, 1))

## Move 1 célula para baixo (Y incrementa no grid 2D do Godot).
func mover_baixo() -> bool:
	return _tentar_mover(Vector2i(0, -1))

## Move 1 célula para a esquerda (X decrementa).
func mover_esquerda() -> bool:
	return _tentar_mover(Vector2i(-1, 0))

## Move 1 célula para a direita (X incrementa).
func mover_direita() -> bool:
	return _tentar_mover(Vector2i(1, 0))

## Centraliza a validação de movimento, bateria e limites do terreno.
func _tentar_mover(deslocamento: Vector2i) -> bool:
	if estado_voo != EstadoVoo.EM_VOO:
		return false # Drone não pode se mover pousado
		
	if not _gastar_bateria(1):
		return false # Sem bateria suficiente
		
	var nova_pos = posicao + deslocamento
	if terreno.is_valido(nova_pos.x, nova_pos.y):
		posicao = nova_pos
		return true
		
	return false # Bateu nos limites do mapa

## Deduz energia da bateria caso haja quantidade disponível.
func _gastar_bateria(quantidade: int) -> bool:
	if bateria >= quantidade:
		bateria -= quantidade
		return true
	return false

## Retorna a célula sobre a qual o drone está pareando.
func _obter_celula_abaixo() -> Celula:
	return terreno.obter_celula(posicao.x, posicao.y)
