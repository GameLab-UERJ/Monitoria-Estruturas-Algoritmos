class_name GradeOverlay
extends Node2D

var colunas: int = 0
var linhas: int = 0
var tamanho_tile: float = 16.0
var mostrar_grade: bool = true

func configurar(p_colunas: int, p_linhas: int, p_tamanho_tile: float) -> void:
	colunas = p_colunas
	linhas = p_linhas
	tamanho_tile = p_tamanho_tile
	queue_redraw()

func _draw() -> void:
	if not mostrar_grade:
		return
		
	var cor_linha = Color(1.0, 1.0, 1.0, 0.4) # Branco semitransparente
	var largura_total = colunas * tamanho_tile
	var altura_total = linhas * tamanho_tile
	
	# Desenha linhas verticais do grid exatamente no tamanho do terreno
	for x in range(colunas + 1):
		var px = x * tamanho_tile
		draw_line(Vector2(px, 0), Vector2(px, altura_total), cor_linha, 1.0)
		
	# Desenha linhas horizontais do grid exatamente no tamanho do terreno
	for y in range(linhas + 1):
		var py = y * tamanho_tile
		draw_line(Vector2(0, py), Vector2(largura_total, py), cor_linha, 1.0)

func alternar_visibilidade() -> void:
	mostrar_grade = not mostrar_grade
	queue_redraw()
