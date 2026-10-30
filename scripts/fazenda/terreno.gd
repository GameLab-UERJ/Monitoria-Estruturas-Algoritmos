class_name Terreno
extends RefCounted

var colunas: int
var linhas: int
var grid: Array[Array]

func _init(p_colunas: int, p_linhas: int) -> void:
	colunas = p_colunas
	linhas = p_linhas
	_gerar_terreno()

func _gerar_terreno() -> void:
	grid = []
	for x in range(colunas):
		var coluna: Array[Celula] = []
		for y in range(linhas):
			coluna.append(Celula.new())
		grid.append(coluna)

func is_valido(x: int, y: int) -> bool:
	return x >= 0 and x < colunas and y >= 0 and y < linhas

func obter_celula(x: int, y: int) -> Celula:
	if is_valido(x, y):
		return grid[x][y]
	push_error("Tentativa de acesso a célula fora dos limites: (%d, %d)" % [x, y])
	return null

func definir_obstaculo(x: int, y: int) -> void:
	var celula = obter_celula(x, y)
	if celula:
		celula.ocupacao = Celula.Ocupacao.OBSTACULO

func obter_vizinhos(x: int, y: int) -> Array[Celula]:
	var vizinhos: Array[Celula] = []
	var direcoes = [Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0)]
	
	for dir in direcoes:
		var nx = x + int(dir.x)
		var ny = y + int(dir.y)
		if is_valido(nx, ny):
			vizinhos.append(grid[nx][ny])
			
	return vizinhos
