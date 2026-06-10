
extends TileMapLayer

@export var linhas_custom: int = 4
@export var colunas_custom: int = 4


@onready var timer = get_parent().get_node("Timer")

var dados_plantas = {} 

func _ready() -> void:
   
   
	self.scale = Vector2(3, 3)
	
	if timer:
		if not timer.timeout.is_connected(_on_timer_timeout):
			timer.timeout.connect(_on_timer_timeout)
			
	gerar_grid()

func gerar_grid():
	
	for x in range(colunas_custom):
		for y in range(linhas_custom):
			var pos = Vector2i(x, y)
			
			
			if randf() >= 0.7:
				
				set_cell(pos, 0, Vector2i(2, 1)) 
				dados_plantas[pos] = {"status": "broto", "segundos": 0}
				
			else:
				
				set_cell(pos, 0, Vector2i(0, 0)) 
				dados_plantas[pos] = {"status": "terra", "segundos": 0}
				

func processar_crescimento():
	
	
	for pos in dados_plantas.keys():
		var planta = dados_plantas[pos]
		
		
		if planta.status == "broto":
			
			
			planta.segundos += 1
			
			if planta.segundos == 1:
				set_cell(pos, 0, Vector2i(3, 1))
			elif planta.segundos == 2:
				set_cell(pos, 0, Vector2i(4, 1))
			elif planta.segundos >= 3:
				var flor_final = Vector2i(randi_range(0, 4), randi_range(2, 3))
				set_cell(pos, 0, flor_final)
				planta.status = "flor"
		else:
			
			pass


func _on_timer_timeout() -> void:
   
	
	processar_crescimento() 
func plantar_na_posicao(player_pos: Vector2):
	# O /3.0 é crucial por causa do seu scale(3,3)
	var pos_grid = local_to_map(player_pos / 3.0) 
	
	if dados_plantas.has(pos_grid) and dados_plantas[pos_grid].status == "terra":
		set_cell(pos_grid, 0, Vector2i(2, 1)) # ID do broto
		dados_plantas[pos_grid] = {"status": "broto", "segundos": 0}

func colher_na_posicao(player_pos: Vector2):
	var pos_grid = local_to_map(player_pos / 3.0)
	
	if dados_plantas.has(pos_grid) and dados_plantas[pos_grid].status == "flor":
		set_cell(pos_grid, 0, Vector2i(0, 0)) # Volta para terra
		dados_plantas[pos_grid] = {"status": "terra", "segundos": 0}
