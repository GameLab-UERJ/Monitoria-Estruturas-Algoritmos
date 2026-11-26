extends Control

const SOM_CLIQUE: AudioStream = preload("res://assets/sounds/emilianodleon-select-button-ui-395763.mp3")

# Referências aos botões principais (adaptado aos seus nomes exatos)
@onready var btn_iniciar: Button = $MarginContainer/VBoxContainer/BtnIniciar
@onready var btn_escolher_fase: Button = $MarginContainer/VBoxContainer/BtnEscolherFase
@onready var btn_creditos: Button = $MarginContainer/VBoxContainer/BtncCreditos
@onready var btn_sair: Button = $MarginContainer/VBoxContainer/BtnSair

# Referência ao VBoxContainer secundário que serve de lista
@onready var lista_de_fases: VBoxContainer = $MarginContainer/VBoxContainer/VBoxContainer

# Assumindo que criou os botões das fases dentro do VBoxContainer secundário
@onready var btn_fase_0: Button = $MarginContainer/VBoxContainer/VBoxContainer/BtnFase0
@onready var btn_fase_1: Button = $MarginContainer/VBoxContainer/VBoxContainer/BtnFase1
@onready var btn_fase_2: Button = $MarginContainer/VBoxContainer/VBoxContainer/BtnFase2
@onready var btn_fase_3: Button = $MarginContainer/VBoxContainer/VBoxContainer/BtnFase3
@onready var btn_fase_4: Button = $MarginContainer/VBoxContainer/VBoxContainer/BtnFase4
@onready var intro_layer: CanvasLayer = $IntroLayer
@onready var black_screen: ColorRect = $IntroLayer/BlackScreen
@onready var developer_logo: TextureRect = $IntroLayer/DeveloperLogo
@onready var game_title: TextureRect = $GameTitle
@onready var menu_buttons: Array = [
		btn_iniciar,
		btn_escolher_fase,
		btn_creditos,
		btn_sair
	]

# O caminho padrão passa a ser a sua Fase_01 na pasta cenas
var caminho_fase_selecionada = "res://cenas/Fase_01.tscn"

# Player de áudio criado por código para o som de clique
var som_clique: AudioStreamPlayer

# Evita cliques repetidos enquanto o som toca e a cena está para trocar
var trocando_de_cena: bool = false

func _ready():
	
	# Cria o player do som de clique
	som_clique = AudioStreamPlayer.new()
	som_clique.stream = SOM_CLIQUE
	add_child(som_clique)

	# Esconde a lista ao iniciar
	lista_de_fases.hide()

	# Liga os botões principais
	btn_iniciar.pressed.connect(_on_iniciar_pressed)
	btn_escolher_fase.pressed.connect(_on_escolher_fase_pressed)
	btn_creditos.pressed.connect(_on_creditos_pressed)
	btn_sair.pressed.connect(_on_sair_pressed)
	
	# Liga os botões da lista aos caminhos exatos dos seus ficheiros
	btn_fase_0.pressed.connect(func(): _selecionar_fase("res://cenas/Fase_00.tscn", "Tutorial"))
	btn_fase_1.pressed.connect(func(): _selecionar_fase("res://cenas/Fase_01.tscn", "Fase 1"))
	btn_fase_2.pressed.connect(func(): _selecionar_fase("res://cenas/Fase_02.tscn", "Fase 2"))
	btn_fase_3.pressed.connect(func(): _selecionar_fase("res://cenas/Fase_03.tscn", "Fase 3"))
	btn_fase_4.pressed.connect(func(): _selecionar_fase("res://cenas/Fase_04.tscn", "Fase 4"))
	_setup_intro()
	await _play_intro()


## Toca o som de clique sem esperar (para botões que só alteram a interface).
func _tocar_clique() -> void:
	som_clique.play()

## Toca o som de clique e espera terminar (para botões que trocam de cena ou fecham o jogo).
## Retorna false se já houver uma troca de cena em andamento.
func _tocar_clique_e_aguardar() -> bool:
	if trocando_de_cena:
		return false
	trocando_de_cena = true
	som_clique.play()
	await som_clique.finished
	return true

func _on_escolher_fase_pressed():
	_tocar_clique()
	lista_de_fases.visible = !lista_de_fases.visible

func _selecionar_fase(caminho: String, nome_fase: String):
	_tocar_clique()
	caminho_fase_selecionada = caminho
	lista_de_fases.hide()
	btn_iniciar.text = "Iniciar " + nome_fase

func _on_iniciar_pressed():
	if await _tocar_clique_e_aguardar():
		EasyTransition.transition_to(caminho_fase_selecionada,1.0,EasyTransition.TransitionAnim.FADE,Color.CORAL)

func _on_creditos_pressed():
	# Se ainda não criou a cena de créditos, crie-a na pasta 'cenas'
	if await _tocar_clique_e_aguardar():
		EasyTransition.transition_to("res://cenas/creditos.tscn",1.0,EasyTransition.TransitionAnim.FADE,Color.CORAL)

func _on_sair_pressed():
	get_tree().quit()

#region intro
func _setup_intro() -> void:
	
	intro_layer.visible = true

	black_screen.modulate.a = 1.0
	developer_logo.modulate.a = 0.0

	game_title.modulate.a = 0.0

	for button in menu_buttons:
		button.modulate.a = 0.0


func _play_intro() -> void:
	# ==========================================
	# LOGO DOS DESENVOLVEDORES - FADE IN
	# ==========================================

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		developer_logo,
		"modulate:a",
		1.0,
		1.0
	)

	await tween.finished


	# ==========================================
	# SEGURA A LOGO
	# ==========================================

	await get_tree().create_timer(1.2).timeout


	# ==========================================
	# LOGO DOS DESENVOLVEDORES - FADE OUT
	# ==========================================

	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		developer_logo,
		"modulate:a",
		0.0,
		1.0
	)

	await tween.finished


	# ==========================================
	# REVELA O MENU
	# ==========================================

	await _show_main_menu()
	
func _show_main_menu() -> void:
	# Remove a tela preta.
	var tween := create_tween()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		black_screen,
		"modulate:a",
		0.0,
		0.8
	)

	await tween.finished

	intro_layer.visible = false

	await _animate_menu()


func _animate_menu() -> void:
	var title_tween := create_tween()

	title_tween.set_parallel(true)
	title_tween.set_trans(Tween.TRANS_BACK)
	title_tween.set_ease(Tween.EASE_OUT)

	title_tween.tween_property(
		game_title,
		"modulate:a",
		1.0,
		0.8
	)
	
	await get_tree().create_timer(1).timeout
	
	title_tween = create_tween()

	title_tween.set_parallel(true)
	title_tween.set_trans(Tween.TRANS_BACK)
	title_tween.set_ease(Tween.EASE_OUT)
	title_tween.tween_property(
		game_title,
		"scale",
		Vector2.ONE*0.5,
		0.8
	)

	title_tween.parallel().tween_property(
		game_title,
		"position",
		Vector2(500,140),
		0.8
	)

	await title_tween.finished

	await get_tree().create_timer(0.15).timeout
	
	await _animate_buttons()


func _animate_buttons() -> void:
	for button in menu_buttons:
		var tween := create_tween()

		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)

		tween.tween_property(
			button,
			"modulate:a",
			1.0,
			0.35
		)

		await tween.finished
		await get_tree().create_timer(0.08).timeout
	#animation_finished = true
	for button in menu_buttons:
		button.mouse_filter = Control.MOUSE_FILTER_STOP

#endregion
