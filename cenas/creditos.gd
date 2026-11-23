extends Control

const CAMINHO_MENU: String = "res://cenas/menu_principal.tscn"
const SOM_CLIQUE: AudioStream = preload("res://assets/sounds/emilianodleon-select-button-ui-395763.mp3")

# Tempo (em segundos) que o clique toca antes de voltar ao menu
const TEMPO_ESPERA_CLIQUE: float = 0.25

@onready var btn_voltar: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BtnVoltar

# Player de áudio criado por código para o som de clique
var som_clique: AudioStreamPlayer

# Evita cliques repetidos enquanto a cena está para trocar
var voltando_ao_menu: bool = false

func _ready() -> void:
	# Cria o player do som de clique
	som_clique = AudioStreamPlayer.new()
	som_clique.stream = SOM_CLIQUE
	add_child(som_clique)

	btn_voltar.pressed.connect(_ao_apertar_voltar)
	btn_voltar.grab_focus() # Permite confirmar com teclado/controle

func _ao_apertar_voltar() -> void:
	if voltando_ao_menu:
		return
	voltando_ao_menu = true
	som_clique.play()
	await get_tree().create_timer(TEMPO_ESPERA_CLIQUE).timeout
	EasyTransition.transition_to(CAMINHO_MENU,1.0,EasyTransition.TransitionAnim.FADE,Color.CORAL)
