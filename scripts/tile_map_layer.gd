extends TileMapLayer
@export var linhas_custom: int
@export var colunas_custom: int
@onready var timer = get_parent().get_node("Timer")
@onready var camada_objetos = $CamadaObjetos
var estado_celulas = {}

func _ready() -> void:
	if timer:
		if not timer.timeout.is_connected(_on_timer_timeout):
			timer.timeout.connect(_on_timer_timeout)
	gerar_grid()
	centralizar_camera()

func centralizar_camera():
	var camera = $Camera2D
	var viewport_size = get_viewport().get_visible_rect().size
	var _grid_largura = colunas_custom * tile_set.tile_size.x * scale.x
	var grid_altura = linhas_custom * tile_set.tile_size.y * scale.y
	var grid_origem = global_position
	var canto_inf_esq = grid_origem + Vector2(0, grid_altura)
	camera.global_position = Vector2(
		canto_inf_esq.x + viewport_size.x / 2.0,
		canto_inf_esq.y - viewport_size.y / 2.0
	)
	camera.make_current()

func gerar_grid():
	for x in range(-1, colunas_custom + 1):
		for y in range(-1, linhas_custom + 1):
			var pos = Vector2i(x, y)
			
			# Bordas (Paredes invisíveis)
			if x == -1 or x == colunas_custom or y == -1 or y == linhas_custom:				
				set_cell(pos, 0, Vector2i(2, 4)) 
			
			# Área útil do mapa
			else:
				var sorteio = randf() # Sorteia um número de 0.0 a 1.0
				
				# 1. GERAÇÃO DE PEDRA (15% de chance)
				if sorteio < 0.15:
					# PRIMEIRO: Coloca a terra/grama no mapa base 
					set_cell(pos, 0, Vector2i(0, 0)) 
					
					# SEGUNDO: Coloca a pedra por cima, na nova Camada de Objetos
					camada_objetos.set_cell(pos, 1, Vector2i(0, 0)) 
					
					estado_celulas[pos] = {
						"terreno": "pedra",
						"ocupacao": "obstaculo",
						"tipo_planta": "nenhum",
						"estagio": "nenhum",
						"umidade": 0.0,
						"fertilidade": 0.0,
						"praga": false,
						"segundos": 0
					}
				
				# 2. GERAÇÃO DE BROTO (30% de chance)
				elif sorteio < 0.45:
					set_cell(pos, 0, Vector2i(2, 1))
					estado_celulas[pos] = {
						"terreno": "solo",
						"ocupacao": "planta",
						"tipo_planta": "milho", 
						"estagio": "broto",
						"umidade": 100.0,
						"fertilidade": 100.0,
						"praga": false,
						"segundos": 0
					}
					
				# 3. GERAÇÃO DE TERRA VAZIA (55% de chance)
				else:
					set_cell(pos, 0, Vector2i(0, 0))
					estado_celulas[pos] = {
						"terreno": "solo",
						"ocupacao": "vazio",
						"tipo_planta": "nenhum",
						"estagio": "nenhum",
						"umidade": 100.0,
						"fertilidade": 100.0,
						"praga": false,
						"segundos": 0
					}

func processar_crescimento():
	for pos in estado_celulas.keys():
		var celula = estado_celulas[pos]
		
		if celula.estagio == "broto":
			celula.segundos += 1
			if celula.segundos == 1:
				set_cell(pos, 0, Vector2i(3, 1))
			elif celula.segundos == 2:
				set_cell(pos, 0, Vector2i(4, 1))
			elif celula.segundos >= 3:
				var flor_final = Vector2i(randi_range(0, 4), randi_range(2, 3))
				set_cell(pos, 0, flor_final)
				celula.estagio = "flor" 
		else:
			pass

func _on_timer_timeout() -> void:
	processar_crescimento()

func tentar_plantar(player_pos: Vector2) -> bool:
	# Ajustado para usar a variável dinâmica "scale" em vez de 3.0 fixo
	var pos_grid = local_to_map(player_pos / scale)
	
	if not estado_celulas.has(pos_grid):
		return false
		
	var celula = estado_celulas[pos_grid]
	
	# Só pode plantar se for solo E estiver vazio
	if celula.terreno != "solo" or celula.ocupacao != "vazio":
		return false
		
	set_cell(pos_grid, 0, Vector2i(2, 1))
	# Atualiza todos os parâmetros da célula
	celula.ocupacao = "planta"
	celula.tipo_planta = "milho" 
	celula.estagio = "broto"
	celula.segundos = 0
	return true

func tentar_colher(player_pos: Vector2) -> bool:
	var pos_grid = local_to_map(player_pos / scale)
	
	if not estado_celulas.has(pos_grid):
		return false
	
	var celula = estado_celulas[pos_grid]
	
	if celula.estagio != "flor":
		return false
		
	set_cell(pos_grid, 0, Vector2i(0, 0))
	celula.ocupacao = "vazio"
	celula.tipo_planta = "nenhum"
	celula.estagio = "nenhum"
	celula.segundos = 0
	
	return true

func pode_plantar(player_pos: Vector2) -> bool:
	var pos_grid = local_to_map(player_pos / scale)
	if not estado_celulas.has(pos_grid):
		return false
		
	var celula = estado_celulas[pos_grid]
	return celula.terreno == "solo" and celula.ocupacao == "vazio"

func pode_colher(player_pos: Vector2) -> bool:
	var pos_grid = local_to_map(player_pos / scale)
	if not estado_celulas.has(pos_grid):
		return false
		
	var celula = estado_celulas[pos_grid]
	return celula.estagio == "flor"
