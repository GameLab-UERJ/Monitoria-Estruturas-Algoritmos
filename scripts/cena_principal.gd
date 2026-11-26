class_name FaseBase
extends Node2D

const TAMANHO_TILE_ORIGINAL: int = 16
const ESCALA_TILE: int = 3
const TAMANHO_CELULA: int = TAMANHO_TILE_ORIGINAL * ESCALA_TILE
const CAMINHO_MENU: String = "res://cenas/menu_principal.tscn"

# ==========================================
# CONFIGURAÇÕES DA FASE (Ajustáveis no Inspetor)
# ==========================================
@export_category("Configurações do Terreno e Drone")
@export var colunas_terreno: int = 8
@export var linhas_terreno: int = 6
@export var usar_drone_agricultor: bool = false # Falso = Irrigador, Verdadeiro = Agricultor
@export var bateria_inicial: int = 100
@export var capacidade_agua: float = 10.0
@export var sementes_iniciais: Array[String] = []

# ==========================================
# REFERÊNCIAS DE NÓS
# ==========================================
@onready var camada_terreno: TileMapLayer = $CamadaTerreno
@onready var drone_visual: Node2D = $Drone
@onready var camera_2d: Camera2D = $Camera2D
@onready var hud: CanvasLayer = $HUD

# Editor de Código
@onready var janela_editor: Window = $JanelaEditor
@onready var code_edit: CodeEdit = $JanelaEditor/PainelPrincipal/VBoxEditor/Editor
@onready var botao_executar: Button = $JanelaEditor/PainelPrincipal/VBoxEditor/HBoxBotoes/BotaoExecutar
@onready var botao_pausar: Button = $JanelaEditor/PainelPrincipal/VBoxEditor/HBoxBotoes/BotaoPausar
@onready var botao_parar: Button = $JanelaEditor/PainelPrincipal/VBoxEditor/HBoxBotoes/BotaoParar
@onready var console_saida: TextEdit = $JanelaEditor/PainelPrincipal/VBoxEditor/ConsoleSaida
@onready var animated_sprite_drone: AnimatedSprite2D = $Drone/AnimatedSprite2D

# Nova Janela de Tutorial
@export_category("Tutorial e Progressão")
@export var exibir_tutorial_inicio: bool = false
@export var titulo_tutorial: String = "Tutorial da Fase"
@export_multiline var texto_tutorial: String = "Objetivo: ...\nComandos: ..."
@export var texto_objetivo_hub: String = "🎯 Missões Ativas:\n• 1. Concluir a fase"
@export var cena_proxima_fase: PackedScene

# Janela tutorial customizada
@onready var tutorial_popup: TutorialPopup = $TutorialPopup

var drone_logico: Drone
var interpretador: InterpretadorComandos
var terreno_logico: Terreno
var grade_overlay: GradeOverlay
var derrota_acionada: bool = false

func _ready() -> void:
	# 1. Inicializa Lógica Base
	terreno_logico = Terreno.new(colunas_terreno, linhas_terreno)
	if usar_drone_agricultor:
		drone_logico = DroneAgricultor.new(terreno_logico, 0, 0, 20.0)
	else:
		drone_logico = DroneIrrigador.new(terreno_logico, 0, 0, capacidade_agua)
	drone_logico.bateria_maxima = bateria_inicial
	drone_logico.bateria = bateria_inicial
	
	if drone_logico is DroneAgricultor:
		for especie in sementes_iniciais:
			drone_logico.inventario.adicionar(Cultura.new(especie, Cultura.Estagio.SEMENTE))
			
	# 2. Configurações Visuais
	camada_terreno.scale = Vector2(ESCALA_TILE, ESCALA_TILE)
	drone_visual.scale = Vector2(ESCALA_TILE, ESCALA_TILE)
	_posicionar_terreno_esquerda()
	_gerar_visual_terreno()
	_criar_grade_overlay()
	
	# 3. Configura Interfaces e Interpretador
	_configurar_editor_codigo()
	_posicionar_janela_editor_direita()
	get_viewport().size_changed.connect(_ao_redimensionar_tela)
	
	# 4. Configuração Inicial do HUD e Tutorial
	hud.definir_objetivo(texto_objetivo_hub)
	hud.atualizar_texto_velocidade(1.0)
	hud.atualizar_texto_grade(true)
	hud.atualizar_texto_editor(true)
	
	_configurar_janela_tutorial()
	atualizar_posicao_drone(true)

	# 5. Conexões de Sinais
	_conectar_sinais_hud()
	
	# Conecta a checagem de vitória e derrota ao interpretador
	interpretador.execucao_concluida.connect(_ao_concluir_execucao)
	interpretador.bateria_esgotada.connect(_on_derrota_bateria)

# ==========================================
# GESTÃO DE FASES, VITÓRIA E DERROTA
# ==========================================

## MÉTODO VIRTUAL: Deve ser sobrescrito nos scripts específicos de cada fase
func verificar_vitoria() -> bool:
	# Exemplo: return drone_logico.posicao == Vector2i(4, 0)
	return false

## Verifica se a condição de derrota foi atingida (bateria zerada)
func verificar_derrota() -> bool:
	return drone_logico != null and drone_logico.bateria <= 0

## Chamado sempre que o interpretador termina de rodar o código do aluno
func _ao_concluir_execucao() -> void:
	atualizar_telemetria_geral()
	
	if derrota_acionada or verificar_derrota():
		if not derrota_acionada:
			_on_derrota_bateria()
		return
		
	if interpretador.erro_detectado:
		print("Execução interrompida por erro.")
		return
		
	if verificar_vitoria():
		print("Objetivo Concluído!")
		_transicao_proxima_fase()
	else:
		print("Objetivo não atingido.")

func _on_derrota_bateria() -> void:
	if derrota_acionada:
		return
	derrota_acionada = true
	
	atualizar_telemetria_geral()
	botao_executar.disabled = true
	print("DERROTA: A bateria do drone acabou!")
	
	var popup_derrota = ConfirmationDialog.new()
	popup_derrota.title = "Bateria Esgotada!"
	popup_derrota.dialog_text = "A bateria do drone acabou antes de concluir a missão.\nDeseja tentar novamente?"
	popup_derrota.ok_button_text = "Tentar Novamente"
	popup_derrota.cancel_button_text = "Voltar ao Menu"
	popup_derrota.confirmed.connect(_reiniciar_fase)
	popup_derrota.canceled.connect(_ao_clicar_menu)
	add_child(popup_derrota)
	popup_derrota.popup_centered()

func _reiniciar_fase() -> void:
	get_tree().paused = false
	janela_editor.visible = false
	if not scene_file_path.is_empty():
		EasyTransition.transition_to(scene_file_path, 0.8, EasyTransition.TransitionAnim.FADE, Color.CORAL)
	else:
		get_tree().reload_current_scene()

func _transicao_proxima_fase() -> void:
	if cena_proxima_fase:
		EasyTransition.transition_to(cena_proxima_fase.resource_path, 1.0, EasyTransition.TransitionAnim.FADE, Color.CORAL)
	else:
		print("Fim de Jogo ou Cena não configurada!") # Pode carregar a cena de Créditos aqui

## Volta para o menu principal ao clicar no botão do HUD.
func _ao_clicar_menu() -> void:
	get_tree().paused = false # Garante que o menu não nasça pausado, caso você use pausa
	janela_editor.visible = false
	EasyTransition.transition_to(CAMINHO_MENU, 1.0, EasyTransition.TransitionAnim.FADE, Color.CORAL)

# ==========================================
# JANELA DE TUTORIAL
# ==========================================
func _configurar_janela_tutorial() -> void:
	if not tutorial_popup:
		return
		
	tutorial_popup.configurar(titulo_tutorial, texto_tutorial)
	
	if not tutorial_popup.fechado.is_connected(_on_tutorial_fechado):
		tutorial_popup.fechado.connect(_on_tutorial_fechado)
	
	if exibir_tutorial_inicio:
		tutorial_popup.abrir()
		hud.atualizar_texto_tutorial(true)
	else:
		tutorial_popup.hide()
		hud.atualizar_texto_tutorial(false)

func _on_tutorial_fechado() -> void:
	hud.atualizar_texto_tutorial(false)

func _alternar_janela_tutorial() -> void:
	if not tutorial_popup:
		return
		
	if tutorial_popup.visible:
		tutorial_popup.fechar()
	else:
		tutorial_popup.abrir()
		hud.atualizar_texto_tutorial(true)
		
# ==========================================
# CONTROLES DA INTERFACE E EDITOR
# ==========================================
func _conectar_sinais_hud() -> void:
	hud.velocidade_clicada.connect(_alternar_velocidade)
	hud.grade_clicada.connect(_alternar_grade)
	hud.editor_clicado.connect(_alternar_janela_editor)
	hud.menu_clicado.connect(_ao_clicar_menu)
	
	if hud.has_signal("tutorial_clicado"):
		hud.tutorial_clicado.connect(_alternar_janela_tutorial)
	
	if botao_pausar:
		botao_pausar.pressed.connect(_on_botao_pausar_pressed)
	if botao_parar:
		botao_parar.pressed.connect(_on_botao_parar_pressed)

func _on_botao_pausar_pressed() -> void:
	if interpretador:
		interpretador.pausar_execucao()
		botao_pausar.text = " ▶️ Retomar " if interpretador.pausado else " ⏸️ Pausar "

func _on_botao_parar_pressed() -> void:
	if interpretador:
		interpretador.parar_execucao()
		botao_pausar.text = " ⏸️ Pausar "

func _alternar_velocidade() -> void:
	if interpretador:
		var nova_vel = interpretador.alternar_velocidade()
		hud.atualizar_texto_velocidade(nova_vel)
		drone_visual.definir_velocidade(nova_vel)

func _alternar_grade() -> void:
	if grade_overlay:
		grade_overlay.alternar_visibilidade()
		hud.atualizar_texto_grade(grade_overlay.mostrar_grade)

func _alternar_janela_editor() -> void:
	if janela_editor:
		janela_editor.visible = not janela_editor.visible
		hud.atualizar_texto_editor(janela_editor.visible)

func _posicionar_janela_editor_direita() -> void:
	janela_editor.title = "Terminal de Controle do Drone"
	janela_editor.size = Vector2i(520, 500)
	var tamanho_viewport = get_viewport_rect().size
	var largura_editor = janela_editor.size.x
	var posicao_x = int(tamanho_viewport.x) - largura_editor - 40
	janela_editor.position = Vector2i(max(posicao_x, 450), 120)
	janela_editor.visible = true
	
	if not janela_editor.close_requested.is_connected(_on_editor_close_requested):
		janela_editor.close_requested.connect(_on_editor_close_requested)

func _on_editor_close_requested() -> void:
	janela_editor.hide()
	hud.atualizar_texto_editor(false) # Sincroniza o HUD

func _ao_redimensionar_tela() -> void:
	_posicionar_janela_editor_direita()

func _configurar_editor_codigo() -> void:
	code_edit.text = "# Programa básico do Drone\ndecolar()\n\n\npousar()"
	code_edit.add_theme_color_override("executing_line_color", Color(1.0, 0.85, 0.2, 0.35))
	interpretador = InterpretadorComandos.new(drone_logico, self, code_edit, console_saida)
	if not botao_executar.pressed.is_connected(_ao_clicar_executar):
		botao_executar.pressed.connect(_ao_clicar_executar)
	interpretador.comando_sucesso.connect(_ao_comando_sucesso)

func _ao_clicar_executar() -> void:
	if derrota_acionada:
		return
	botao_executar.disabled = true
	await interpretador.executar_codigo(code_edit.text)
	if not derrota_acionada:
		botao_executar.disabled = false

# ==========================================
# LÓGICA DE TERRENO E MOVIMENTO
# ==========================================
func _posicionar_terreno_esquerda() -> void:
	camada_terreno.position = Vector2(40, 120)
	camera_2d.zoom = Vector2(1.0, 1.0)

func _criar_grade_overlay() -> void:
	grade_overlay = GradeOverlay.new()
	grade_overlay.name = "GradeVisual"
	grade_overlay.configurar(terreno_logico.colunas, terreno_logico.linhas, TAMANHO_TILE_ORIGINAL)
	camada_terreno.add_child(grade_overlay)

func grid_para_mundo(coord: Vector2i) -> Vector2:
	var pixel_x = coord.x * TAMANHO_CELULA + (TAMANHO_CELULA / 2.0)
	var pixel_y = (terreno_logico.linhas - 1 - coord.y) * TAMANHO_CELULA + (TAMANHO_CELULA / 2.0)
	return camada_terreno.position + Vector2(pixel_x, pixel_y)
	
func _gerar_visual_terreno() -> void:
	camada_terreno.clear()
	var celulas_para_pintar: Array[Vector2i] = []
	for x in range(terreno_logico.colunas):
		for y in range(terreno_logico.linhas):
			celulas_para_pintar.append(Vector2i(x, terreno_logico.linhas - 1 - y))
			
	if camada_terreno.tile_set:
		camada_terreno.set_cells_terrain_connect(celulas_para_pintar, 0, 0)

func atualizar_posicao_drone(instantaneo: bool = false) -> void:
	var destino = grid_para_mundo(drone_logico.posicao)
	var esta_voando = (drone_logico.estado_voo == Drone.EstadoVoo.EM_VOO)
	
	if esta_voando:
		drone_visual.animar_voando()
	else:
		drone_visual.animar_parado()
		
	# Condição para evitar o efeito de queda no início do jogo
	if instantaneo:
		drone_visual.position = destino
	else:
		drone_visual.mover_para(destino, 0.25)
		
	atualizar_telemetria_geral()

func atualizar_visual_terreno_irrigado(coord: Vector2i) -> void:
	var celula: Celula = terreno_logico.obter_celula(coord.x, coord.y)
	if celula and celula.esta_irrigada():
		var tile_pos = Vector2i(coord.x, terreno_logico.linhas - 1 - coord.y)
		camada_terreno.set_cell(tile_pos, 0, Vector2i(3, 12))

func atualizar_telemetria_geral() -> void:
	if drone_logico:
		var agua = drone_logico.agua_atual if "agua_atual" in drone_logico else 0.0
		var max_agua = drone_logico.capacidade_agua if "capacidade_agua" in drone_logico else 0.0
		hud.atualizar_telemetria(drone_logico.bateria, agua, max_agua, drone_logico.posicao)

func _ao_comando_sucesso(comando: String, args: Array) -> void:
	pass
