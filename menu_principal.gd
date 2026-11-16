extends Control

# Referências aos botões principais (adaptado aos seus nomes exatos)
@onready var btn_iniciar = $VBoxContainer/BtnIniciar
@onready var btn_escolher_fase = $VBoxContainer/BtnEscolherFase
@onready var btn_creditos = $VBoxContainer/BtncCreditos # Nome exato da sua árvore
@onready var btn_sair = $VBoxContainer/BtnSair

# Referência ao VBoxContainer secundário que serve de lista
@onready var lista_de_fases = $VBoxContainer/VBoxContainer # Nome exato da sua árvore

# Assumindo que criou os botões das fases dentro do VBoxContainer secundário
@onready var btn_fase_1 = $VBoxContainer/VBoxContainer/BtnFase1
@onready var btn_fase_2 = $VBoxContainer/VBoxContainer/BtnFase2
@onready var btn_fase_3 = $VBoxContainer/VBoxContainer/BtnFase3

# O caminho padrão passa a ser a sua Fase_01 na pasta cenas
var caminho_fase_selecionada = "res://cenas/Fase_01.tscn"

func _ready():
	# Esconde a lista ao iniciar
	lista_de_fases.hide()

	# Liga os botões principais
	btn_iniciar.pressed.connect(_on_iniciar_pressed)
	btn_escolher_fase.pressed.connect(_on_escolher_fase_pressed)
	btn_creditos.pressed.connect(_on_creditos_pressed)
	btn_sair.pressed.connect(_on_sair_pressed)
	
	# Liga os botões da lista aos caminhos exatos dos seus ficheiros
	btn_fase_1.pressed.connect(func(): _selecionar_fase("res://cenas/Fase_01.tscn", "Fase 1"))
	btn_fase_2.pressed.connect(func(): _selecionar_fase("res://cenas/Fase_02.tscn", "Fase 2"))
	btn_fase_3.pressed.connect(func(): _selecionar_fase("res://cenas/Fase_3.tscn", "Fase 3"))

func _on_escolher_fase_pressed():
	lista_de_fases.visible = !lista_de_fases.visible

func _selecionar_fase(caminho: String, nome_fase: String):
	caminho_fase_selecionada = caminho
	lista_de_fases.hide()
	btn_iniciar.text = "Iniciar " + nome_fase

func _on_iniciar_pressed():
	get_tree().change_scene_to_file(caminho_fase_selecionada)

func _on_creditos_pressed():
	# Se ainda não criou a cena de créditos, crie-a na pasta 'cenas'
	get_tree().change_scene_to_file("res://cenas/creditos.tscn")

func _on_sair_pressed():
	get_tree().quit()
