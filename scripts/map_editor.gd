extends Node2D

@onready var tilemap: TileMap = $TileMap
@onready var x_spinbox: SpinBox = $"UI/Fundo do Menu/Organizador Vertical/HBoxContainer/XSpinBox"
@onready var y_spinbox: SpinBox = $"UI/Fundo do Menu/Organizador Vertical/HBoxContainer/YSpinBox"

# Configurações do pincel atual
var id_bloco_selecionado: int = 0 # 0 = Terra, 1 = Pedra, etc.
var layer_atual: int = 0

# Dicionário principal que armazena os dados lógicos
var estado_celulas: Dictionary = {}

func _ready():
	# Inicializa um mapa padrão (ex: 5x5)
	gerar_grid_vazio(5, 5)

func gerar_grid_vazio(tamanho_x: int, tamanho_y: int):
	tilemap.clear()
	estado_celulas.clear()
	
	for x in range(tamanho_x):
		for y in range(tamanho_y):
			var coord = Vector2i(x, y)
			# Define bloco padrão visualmente (ex: Terra, source_id = 0)
			tilemap.set_cell(0, coord, 0, Vector2i(0,0))
			
			# Adiciona ao dicionário lógico
			estado_celulas[str(x) + "," + str(y)] = {
				"tipo": "terra",
				"ocupacao": null,
				"estagio_desenvolvimento": 0
			}

func _unhandled_input(event):
	# Verifica se o clique ou o arrasto do botão esquerdo está acontecendo
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		
		# 1. Pega a posição do mouse na tela em pixels (ex: x: 325, y: 150)
		var posicao_pixel = get_global_mouse_position()
		
		# 2. Converte os pixels para a coordenada exata da grade (ex: x: 5, y: 2)
		var coordenada_grade = tilemap.local_to_map(posicao_pixel)
		
		# 3. Manda pintar e atualizar o dicionário nessa coordenada
		pintar_celula(coordenada_grade)

func pintar_celula(coord: Vector2i):
	# Converte a coordenada para String para usar como chave no JSON
	var chave_string = str(coord.x) + "," + str(coord.y)
	
	# Atualiza o dicionário lógico
	estado_celulas[chave_string] = {
		"tipo": "terra" if id_bloco_selecionado == 0 else "pedra",
		"ocupacao": null
	}

func salvar_mapa():
	# 1. Abre um arquivo em modo de ESCRITA
	var arquivo = FileAccess.open("res://scenes/meu_mapa.json", FileAccess.WRITE)
	
	# 2. Transforma o dicionário Godot em um texto formatado em JSON
	var texto_json = JSON.stringify(estado_celulas, "\t")
	
	# 3. Escreve o texto no arquivo e fecha
	arquivo.store_string(texto_json)
	arquivo.close()

func coord_dentro_dos_limites(coord: Vector2i) -> bool:
	# Impede que o jogador pinte fora do tamanho definido no SpinBox
	return coord.x >= 0 and coord.x < x_spinbox.value and coord.y >= 0 and coord.y < y_spinbox.value




func _on_item_list_item_selected(index: int):
	# Se clicar em "Terra" (1º item), o index será 0
	# Se clicar em "Pedra" (2º item), o index será 1
	id_bloco_selecionado = index
	print("Pincel alterado para o ID: ", index)
