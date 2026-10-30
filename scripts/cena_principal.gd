extends Node2D

const TAMANHO_TILE_ORIGINAL: int = 16
const ESCALA_TILE: int = 3
const TAMANHO_CELULA: int = TAMANHO_TILE_ORIGINAL * ESCALA_TILE

# --- configuração da fase
@export var colunas_terreno: int = 8
@export var linhas_terreno: int = 6
@export var usar_drone_agricultor: bool = false # Checkbox: Falso = Irrigador, Verdadeiro = Agricultor
@export var bateria_inicial: int = 100
@export var capacidade_agua: float = 10.0
# -----------------------------------------------------------

@onready var camada_terreno: TileMapLayer = $CamadaTerreno
@onready var drone_visual: Node2D = $Drone
@onready var camera_2d: Camera2D = $Camera2D
@onready var janela_editor: Window = $JanelaEditor
@onready var code_edit: CodeEdit = $JanelaEditor/PainelPrincipal/VBoxEditor/Editor
@onready var botao_executar: Button = $JanelaEditor/PainelPrincipal/VBoxEditor/HBoxBotoes/BotaoExecutar
@onready var botao_pausar: Button = $JanelaEditor/PainelPrincipal/VBoxEditor/HBoxBotoes/BotaoPausar
@onready var botao_parar: Button = $JanelaEditor/PainelPrincipal/VBoxEditor/HBoxBotoes/BotaoParar

@onready var console_saida: TextEdit = $JanelaEditor/PainelPrincipal/VBoxEditor/ConsoleSaida
@onready var animated_sprite_drone: AnimatedSprite2D = $Drone/AnimatedSprite2D
@onready var hud: CanvasLayer = $HUD

var drone_logico: Drone
var interpretador: InterpretadorComandos
var terreno_logico: Terreno
var grade_overlay: GradeOverlay

func _ready() -> void:
	terreno_logico = Terreno.new(colunas_terreno, linhas_terreno)
	
	if usar_drone_agricultor:
		drone_logico = DroneAgricultor.new(terreno_logico, 0, 0, 20.0)
	else:
		drone_logico = DroneIrrigador.new(terreno_logico, 0, 0, capacidade_agua)
		
	drone_logico.bateria = bateria_inicial
	
	camada_terreno.scale = Vector2(ESCALA_TILE, ESCALA_TILE)
	drone_visual.scale = Vector2(ESCALA_TILE, ESCALA_TILE)
	
	_posicionar_terreno_esquerda()
	_gerar_visual_terreno()
	atualizar_posicao_drone()
	_criar_grade_overlay()
	_configurar_editor_codigo()
	_posicionar_janela_editor_direita()
	get_viewport().size_changed.connect(_ao_redimensionar_tela)
	
	# Configura os textos iniciais do HUD
	hud.definir_objetivo("🎯 Missões Ativas:\n• 1. Decolar\n• 2. Pousar o drone")
	hud.atualizar_texto_velocidade(1.0)
	hud.atualizar_texto_grade(true)
	hud.atualizar_texto_editor(true)
	atualizar_posicao_drone()

	# Conecta os cliques do jogador à lógica do cenário
	hud.velocidade_clicada.connect(_alternar_velocidade)
	hud.grade_clicada.connect(_alternar_grade)
	hud.editor_clicado.connect(_alternar_janela_editor)
	
	if botao_pausar:
		botao_pausar.pressed.connect(_on_botao_pausar_pressed)
	if botao_parar:
		botao_parar.pressed.connect(_on_botao_parar_pressed)

func _on_botao_velocidade_pressed() -> void:
	if interpretador:
		var nova_vel = interpretador.alternar_velocidade()
		drone_visual.definir_velocidade(nova_vel) # Chama a função do script do Drone

func _on_botao_pausar_pressed() -> void:
	if interpretador:
		interpretador.pausar_execucao()
		botao_pausar.text = " ▶️ Retomar " if interpretador.pausado else " ⏸️ Pausar "

func _on_botao_parar_pressed() -> void:
	if interpretador:
		interpretador.parar_execucao()
		botao_pausar.text = " ⏸️ Pausar " # Reseta o botão de pausa
				
func _posicionar_terreno_esquerda() -> void:
	camada_terreno.position = Vector2(40, 120)
	camera_2d.zoom = Vector2(1.0, 1.0)

func _criar_grade_overlay() -> void:
	grade_overlay = GradeOverlay.new()
	grade_overlay.name = "GradeVisual"
	grade_overlay.configurar(terreno_logico.colunas, terreno_logico.linhas, TAMANHO_TILE_ORIGINAL)
	camada_terreno.add_child(grade_overlay)

func _posicionar_janela_editor_direita() -> void:
	janela_editor.title = "Terminal de Controle do Drone"
	janela_editor.size = Vector2i(520, 500)
	
	var tamanho_viewport = get_viewport_rect().size
	var largura_editor = janela_editor.size.x
	var posicao_x = int(tamanho_viewport.x) - largura_editor - 40
	var posicao_y = 120
	
	janela_editor.position = Vector2i(max(posicao_x, 450), posicao_y)
	janela_editor.visible = true
	
	if not janela_editor.close_requested.is_connected(_on_editor_close_requested):
		janela_editor.close_requested.connect(_on_editor_close_requested)

func _ao_redimensionar_tela() -> void:
	_posicionar_janela_editor_direita()

func _on_editor_close_requested() -> void:
	janela_editor.hide()

func grid_para_mundo(coord: Vector2i) -> Vector2:
	var pixel_x = coord.x * TAMANHO_CELULA + (TAMANHO_CELULA / 2.0)
	var pixel_y = (terreno_logico.linhas - 1 - coord.y) * TAMANHO_CELULA + (TAMANHO_CELULA / 2.0)
	return camada_terreno.position + Vector2(pixel_x, pixel_y)
	
func _gerar_visual_terreno() -> void:
	camada_terreno.clear()
	var celulas_para_pintar: Array[Vector2i] = []
	for x in range(terreno_logico.colunas):
		for y in range(terreno_logico.linhas):
			var tile_pos = Vector2i(x, terreno_logico.linhas - 1 - y)
			celulas_para_pintar.append(tile_pos)
			
	if camada_terreno.tile_set:
		camada_terreno.set_cells_terrain_connect(celulas_para_pintar, 0, 0)

func _configurar_editor_codigo() -> void:
	code_edit.text = "# Programa básico do Drone\ndecolar()\nmover_direita()\nmover_direita()\nmover_cima()\npousar()"
	# Define uma cor amarela/dourada suave com transparência (Alpha = 0.35) para a linha em execução
	code_edit.add_theme_color_override("executing_line_color", Color(1.0, 0.85, 0.2, 0.35))
	
	interpretador = InterpretadorComandos.new(drone_logico, self, code_edit, console_saida)
	
	if not botao_executar.pressed.is_connected(_ao_clicar_executar):
		botao_executar.pressed.connect(_ao_clicar_executar)
		

func _ao_clicar_executar() -> void:
	botao_executar.disabled = true # Desativa o botão enquanto roda
	await interpretador.executar_codigo(code_edit.text)
	botao_executar.disabled = false

## Atualiza a posição e delega a animação para o nó do Drone
func atualizar_posicao_drone() -> void:
	var destino = grid_para_mundo(drone_logico.posicao)
	
	# Verifica o estado para decidir qual animação base manter
	var esta_voando = (drone_logico.estado_voo == Drone.EstadoVoo.EM_VOO)
	if esta_voando:
		drone_visual.animar_voando()
	else:
		drone_visual.animar_pouso() # Ou apenas forçar o quadro parado
		
	# Move passando a responsabilidade do Tween para o próprio Drone
	drone_visual.mover_para(destino, 0.25)
	
	atualizar_telemetria_geral()

## Atualiza a célula no TileMapLayer caso ela tenha sido irrigada
func atualizar_visual_terreno_irrigado(coord: Vector2i) -> void:
	var celula: Celula = terreno_logico.obter_celula(coord.x, coord.y)
	if celula == null:
		return
		
	if celula.esta_irrigada():
		# Converte para a coordenada visual do TileMap
		var tile_pos = Vector2i(coord.x, terreno_logico.linhas - 1 - coord.y)
		var source_id: int = 0 # ID da fonte do seu tileset (geralmente 0)
		# A terra molhada no atlas está na coordenada (3,12) (olhando no painel do TileSet)
		var atlas_coords_molhado: Vector2i = Vector2i(3, 12) # cuidado na hora de alterar
		# Altera diretamente o tile na camada visual
		camada_terreno.set_cell(tile_pos, source_id, atlas_coords_molhado)

func atualizar_telemetria_geral() -> void:
	if drone_logico:
		var agua = drone_logico.agua_atual if "agua_atual" in drone_logico else 0.0
		var max_agua = drone_logico.capacidade_agua if "capacidade_agua" in drone_logico else 0.0
		hud.atualizar_telemetria(drone_logico.bateria, agua, max_agua, drone_logico.posicao)

func _alternar_velocidade() -> void:
	if interpretador:
		var nova_vel = interpretador.alternar_velocidade()
		hud.atualizar_texto_velocidade(nova_vel)
		if animated_sprite_drone:
			animated_sprite_drone.speed_scale = nova_vel

func _alternar_grade() -> void:
	if grade_overlay:
		grade_overlay.alternar_visibilidade()
		hud.atualizar_texto_grade(grade_overlay.mostrar_grade)

func _alternar_janela_editor() -> void:
	if janela_editor:
		janela_editor.visible = not janela_editor.visible
		hud.atualizar_texto_editor(janela_editor.visible)
