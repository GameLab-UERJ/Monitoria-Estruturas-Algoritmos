extends Node2D

@onready var tilemap: TileMapLayer = $TileMap
@onready var x_spinbox: SpinBox = $"UI/Fundo do Menu/HBoxContainer/Organizador Vertical/HBoxContainer/XSpinBox"
@onready var y_spinbox: SpinBox = $"UI/Fundo do Menu/HBoxContainer/Organizador Vertical/HBoxContainer/YSpinBox"
@onready var input_nome_salvar: LineEdit = $"UI/Fundo do Menu/HBoxContainer/Organizador Vertical/InputNomeSalvar"
@onready var input_nome_carregar: LineEdit = $"UI/Fundo do Menu/HBoxContainer/Organizador Vertical/InputNomeCarregar"

# Referências dos textos na UI
@onready var debug_label: Label = $"UI/Fundo do Menu/HBoxContainer/Organizador Vertical/DebugLabel"
@onready var terminal_label: Label = $"UI/Fundo do Menu/HBoxContainer/TerminalLabel"

var estado_celulas: Dictionary = {}

# Variáveis do Terminal
var historico_acoes: Array = []
const MAX_LINHAS_HISTORICO: int = 12 # Quantidade de linhas que o terminal vai mostrar

const ATALHOS_TILES = {
	KEY_Q: {"nome": "terra_vazia", "atlas": Vector2i(0, 1)},
	KEY_W: {"nome": "fruta_roxa", "atlas": Vector2i(0, 2)},
	KEY_E: {"nome": "fruta_laranja", "atlas": Vector2i(1, 2)},
	KEY_R: {"nome": "fruta_azul", "atlas": Vector2i(2, 2)},
	KEY_T: {"nome": "flor_laranja", "atlas": Vector2i(3, 2)},
	KEY_Y: {"nome": "flor_amarela", "atlas": Vector2i(4, 2)},
	KEY_U: {"nome": "flor_rosa", "atlas": Vector2i(0, 3)},
	KEY_I: {"nome": "flor_roxa", "atlas": Vector2i(1, 3)},
	KEY_O: {"nome": "flor_branca", "atlas": Vector2i(2, 3)},
	KEY_P: {"nome": "flor_vermelha", "atlas": Vector2i(3, 3)},
	KEY_A: {"nome": "flor_azul", "atlas": Vector2i(4, 3)},
	KEY_S: {"nome": "solo_infertil", "atlas": Vector2i(0, 4)}
}

# Variáveis das Camadas
var pos_cursor: Vector2i = Vector2i.ZERO
var cursor_layer: TileMapLayer
var objetos_layer: TileMapLayer 

func _ready():
	tilemap.clear()
	
	# 1. Cria a camada para as pedras/objetos
	objetos_layer = TileMapLayer.new()
	objetos_layer.tile_set = tilemap.tile_set
	tilemap.add_child(objetos_layer)
	
	# 2. Cria a camada do cursor (Adicionada por último para renderizar por cima)
	cursor_layer = TileMapLayer.new()
	cursor_layer.tile_set = tilemap.tile_set 
	tilemap.add_child(cursor_layer)
	
	x_spinbox.get_line_edit().focus_mode = Control.FOCUS_NONE
	y_spinbox.get_line_edit().focus_mode = Control.FOCUS_NONE
	input_nome_salvar.text_submitted.connect(func(t): get_viewport().gui_release_focus())
	input_nome_carregar.text_submitted.connect(func(t): get_viewport().gui_release_focus())
	
	atualizar_cursor_tela()
	registrar_acao("Editor iniciado. Aguardando comandos...")

# Atualiza apenas a posição do cursor no topo
func atualizar_cursor_tela():
	if debug_label:
		debug_label.text = "Cursor: " + str(pos_cursor)

# Adiciona ações ao histórico estilo terminal
func registrar_acao(texto_acao: String):
	historico_acoes.append(texto_acao)
	
	# Remove a mensagem mais velha se passar do limite
	if historico_acoes.size() > MAX_LINHAS_HISTORICO:
		historico_acoes.pop_front()
		
	if terminal_label:
		var texto_final = "--- Histórico ---\n"
		for acao in historico_acoes:
			texto_final += "> " + acao + "\n"
		terminal_label.text = texto_final

func _on_botao_gerar_pressed():
	var tamanho_x = int(x_spinbox.value)
	var tamanho_y = int(y_spinbox.value)
	
	tilemap.clear()
	objetos_layer.clear() 
	estado_celulas.clear()
	
	tilemap.colunas_custom = tamanho_x
	tilemap.linhas_custom = tamanho_y
	
	for x in range(tamanho_x):
		for y in range(tamanho_y):
			var coord = Vector2i(x, y)
			tilemap.set_cell(coord, 0, Vector2i(0,0))
			
			estado_celulas[str(x) + "," + str(y)] = {
				"tipo": "solo",
				"ocupacao": "vazio"
			}
	
	tilemap.centralizar_camera()
	
	pos_cursor = Vector2i(0, 0)
	desenhar_cursor()
	
	atualizar_cursor_tela()
	registrar_acao("Mapa " + str(tamanho_x) + "x" + str(tamanho_y) + " Gerado")

func _unhandled_input(event):
	if estado_celulas.is_empty():
		return
		
	var moveu = false
	var nova_pos = pos_cursor
	
	# --- CONTROLES DE MOVIMENTO ---
	if event.is_action_pressed("ui_right"):
		nova_pos.x += 1
		moveu = true
	elif event.is_action_pressed("ui_left"):
		nova_pos.x -= 1
		moveu = true
	elif event.is_action_pressed("ui_down"):
		nova_pos.y += 1
		moveu = true
	elif event.is_action_pressed("ui_up"):
		nova_pos.y -= 1
		moveu = true
		
	if moveu:
		nova_pos.x = clamp(nova_pos.x, 0, int(x_spinbox.value) - 1)
		nova_pos.y = clamp(nova_pos.y, 0, int(y_spinbox.value) - 1)
		
		if nova_pos != pos_cursor:
			pos_cursor = nova_pos
			desenhar_cursor()
			atualizar_cursor_tela() # Atualiza SÓ o cursor quando andamos
			
	# --- CONTROLE DE AÇÃO (ENTER) ---
	if event.is_action_pressed("ui_accept"):
		alternar_pedra()
	
	# --- ATALHOS DO TECLADO PARA PLANTAS E SOLOS ---
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if ATALHOS_TILES.has(event.keycode):
			desenhar_tile_atalho(ATALHOS_TILES[event.keycode])

func desenhar_cursor():
	cursor_layer.clear()
	cursor_layer.set_cell(pos_cursor, 0, Vector2i(1, 1))

func alternar_pedra():
	var chave = str(pos_cursor.x) + "," + str(pos_cursor.y)
	
	if estado_celulas[chave]["tipo"] == "pedra":
		objetos_layer.erase_cell(pos_cursor)
		
		estado_celulas[chave]["tipo"] = "solo"
		estado_celulas[chave]["ocupacao"] = "vazio"
		
		registrar_acao("Pedra removida: " + str(pos_cursor))
		print("Pedra REMOVIDA da coordenada: ", pos_cursor)
		
	else:
		objetos_layer.set_cell(pos_cursor, 1, Vector2i(0, 0))
		
		estado_celulas[chave]["tipo"] = "pedra"
		estado_celulas[chave]["ocupacao"] = "obstaculo"
		
		registrar_acao("Pedra colocada: " + str(pos_cursor))
		print("Pedra COLOCADA na coordenada: ", pos_cursor)
		
func salvar_mapa():
	var nome_digitado = input_nome_salvar.text.strip_edges()
	
	if nome_digitado == "":
		nome_digitado = "mapa_padrao"
		
	var caminho = "res://missions//" + nome_digitado + ".json"
	
	var dados_do_mapa = {
		"tamanho_x": tilemap.colunas_custom,
		"tamanho_y": tilemap.linhas_custom,
		"celulas": estado_celulas
	}
	
	var arquivo = FileAccess.open(caminho, FileAccess.WRITE)
	var texto_json = JSON.stringify(dados_do_mapa, "\t")
	arquivo.store_string(texto_json)
	arquivo.close()
	
	registrar_acao("Salvo: " + nome_digitado + ".json")
	print("Mapa salvo com sucesso em: ", caminho)
	
	get_viewport().gui_release_focus()
	
func carregar_mapa():
	var nome_digitado = input_nome_carregar.text.strip_edges()
	
	if nome_digitado == "":
		registrar_acao("Erro: Digite o nome para carregar!")
		get_viewport().gui_release_focus()
		return
		
	var caminho = "res://missions//" + nome_digitado + ".json"
	
	if not FileAccess.file_exists(caminho):
		registrar_acao("Erro: Arquivo não encontrado!")
		get_viewport().gui_release_focus()
		return
		
	var arquivo = FileAccess.open(caminho, FileAccess.READ)
	var texto_json = arquivo.get_as_text()
	arquivo.close()
	
	var dados_do_mapa = JSON.parse_string(texto_json)
	
	tilemap.clear()
	objetos_layer.clear()
	
	var tamanho_x = dados_do_mapa["tamanho_x"]
	var tamanho_y = dados_do_mapa["tamanho_y"]
	tilemap.colunas_custom = tamanho_x
	tilemap.linhas_custom = tamanho_y
	x_spinbox.value = tamanho_x
	y_spinbox.value = tamanho_y
	
	estado_celulas = dados_do_mapa["celulas"]
	
	for x in range(tamanho_x):
		for y in range(tamanho_y):
			var coord = Vector2i(x, y)
			var chave = str(x) + "," + str(y)
			var celula = estado_celulas[chave]
			var tipo = celula["tipo"]
			
			tilemap.set_cell(coord, 0, Vector2i(0,0))
			
			match tipo:
				"pedra":
					objetos_layer.set_cell(coord, 1, Vector2i(0, 0)) 
				"terra_vazia":
					objetos_layer.set_cell(coord, 0, Vector2i(0, 1)) 
				"fruta_roxa":
					objetos_layer.set_cell(coord, 0, Vector2i(0, 2))
				"fruta_laranja":
					objetos_layer.set_cell(coord, 0, Vector2i(1, 2))
				"fruta_azul":
					objetos_layer.set_cell(coord, 0, Vector2i(2, 2))
				"flor_laranja":
					objetos_layer.set_cell(coord, 0, Vector2i(3, 2))
				"flor_amarela":
					objetos_layer.set_cell(coord, 0, Vector2i(4, 2))
				"flor_rosa":
					objetos_layer.set_cell(coord, 0, Vector2i(0, 3))
				"flor_roxa":
					objetos_layer.set_cell(coord, 0, Vector2i(1, 3))
				"flor_branca":
					objetos_layer.set_cell(coord, 0, Vector2i(2, 3))
				"flor_vermelha":
					objetos_layer.set_cell(coord, 0, Vector2i(3, 3))
				"flor_azul":
					objetos_layer.set_cell(coord, 0, Vector2i(4, 3))
				"solo_infertil":
					objetos_layer.set_cell(coord, 0, Vector2i(0, 4))
				
	tilemap.centralizar_camera()
	pos_cursor = Vector2i(0, 0)
	desenhar_cursor()
	atualizar_cursor_tela()
	
	registrar_acao("Carregado: " + nome_digitado + ".json")
	print("Mapa carregado com sucesso de: ", caminho)
	
	get_viewport().gui_release_focus()
	
func desenhar_tile_atalho(dados_tile: Dictionary):
	var chave = str(pos_cursor.x) + "," + str(pos_cursor.y)
	
	objetos_layer.set_cell(pos_cursor, 0, dados_tile["atlas"])
	
	estado_celulas[chave]["tipo"] = dados_tile["nome"]
	estado_celulas[chave]["ocupacao"] = "planta_ou_modificador"
	
	registrar_acao(dados_tile["nome"] + " -> " + str(pos_cursor))
	print("Desenhado: ", dados_tile["nome"], " na coordenada: ", pos_cursor)
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_viewport().gui_release_focus()
