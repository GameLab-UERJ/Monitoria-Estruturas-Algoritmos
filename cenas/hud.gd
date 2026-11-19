extends CanvasLayer # Ou Control, dependendo do tipo do seu nó base do HUD

# Sinais para avisar o CenarioPrincipal que o jogador interagiu com a interface
signal velocidade_clicada
signal grade_clicada
signal editor_clicado
signal menu_clicado

const SOM_CLIQUE: AudioStream = preload("res://assets/sounds/emilianodleon-select-button-ui-395763.mp3")

# Tempo (em segundos) que o clique toca antes de voltar ao menu
const TEMPO_ESPERA_CLIQUE: float = 0.25

# Referências de texto (Labels)
@onready var label_bateria: Label = $MargemTopo/PainelTopo/HBoxInformacoes/BoxTelemetria/LabelBateria
@onready var label_posicao: Label = $MargemTopo/PainelTopo/HBoxInformacoes/BoxTelemetria/LabelPosicao
@onready var label_agua: Label = $MargemTopo/PainelTopo/HBoxInformacoes/BoxTelemetria/LabelAgua
@onready var label_objetivos: Label = $MargemTopo/PainelTopo/HBoxInformacoes/BoxObjetivos/LabelTextoObjetivo

# Referências de botões
@onready var botao_grade: Button = $MargemTopo/PainelTopo/HBoxInformacoes/BoxAcoes/BotaoGrade
@onready var botao_abrir_editor: Button = $MargemTopo/PainelTopo/HBoxInformacoes/BoxAcoes/BotaoAbrirEditor
@onready var botao_velocidade: Button = $MargemTopo/PainelTopo/HBoxInformacoes/BoxAcoes/BotaoVelocidade
@onready var botao_menu: Button = $MargemTopo/PainelTopo/HBoxInformacoes/BoxAcoes/BotaoMenu

# Player de áudio criado por código para o som de clique
var som_clique: AudioStreamPlayer

# Evita cliques repetidos enquanto a cena está para trocar
var voltando_ao_menu: bool = false

func _ready() -> void:
	# Cria o player do som de clique
	som_clique = AudioStreamPlayer.new()
	som_clique.stream = SOM_CLIQUE
	add_child(som_clique)

	# Conecta os botões internamente para emitir os sinais para fora
	botao_velocidade.pressed.connect(func(): _tocar_clique(); velocidade_clicada.emit())
	botao_grade.pressed.connect(func(): _tocar_clique(); grade_clicada.emit())
	botao_abrir_editor.pressed.connect(func(): _tocar_clique(); editor_clicado.emit())
	botao_menu.pressed.connect(_ao_apertar_menu)

## Toca o som de clique.
func _tocar_clique() -> void:
	som_clique.play()

## Toca o clique e espera um instante antes de avisar o cenário, que troca de cena.
func _ao_apertar_menu() -> void:
	if voltando_ao_menu:
		return
	voltando_ao_menu = true
	_tocar_clique()
	await get_tree().create_timer(TEMPO_ESPERA_CLIQUE).timeout
	menu_clicado.emit()

# --- MÉTODOS PÚBLICOS PARA O CENÁRIO CHAMAR ---

func definir_objetivo(texto: String) -> void:
	label_objetivos.text = texto

func atualizar_telemetria(bateria: int, agua: float, capacidade_agua: float, pos: Vector2i) -> void:
	label_bateria.text = " 🔋 %d%% " % bateria
	label_posicao.text = " 📍 (%d, %d) " % [pos.x, pos.y]
	label_agua.text = " 💧 Água: %d/%d " % [agua, capacidade_agua]

func atualizar_texto_velocidade(vel: float) -> void:
	botao_velocidade.text = " ⏩ %.1fx " % vel

func atualizar_texto_grade(esta_visivel: bool) -> void:
	botao_grade.text = "🪟 Ocultar Grade" if esta_visivel else "🪟 Mostrar Grade"

func atualizar_texto_editor(esta_visivel: bool) -> void:
	botao_abrir_editor.text = "💻 Ocultar Editor" if esta_visivel else "💻 Abrir Editor"
