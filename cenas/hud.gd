extends CanvasLayer # Ou Control, dependendo do tipo do seu nó base do HUD

# Sinais para avisar o CenarioPrincipal que o jogador interagiu com a interface
signal velocidade_clicada
signal grade_clicada
signal editor_clicado

# Referências de texto (Labels)
@onready var label_bateria: Label = $MargemTopo/PainelTopo/HBoxInformacoes/BoxTelemetria/LabelBateria
@onready var label_posicao: Label = $MargemTopo/PainelTopo/HBoxInformacoes/BoxTelemetria/LabelPosicao
@onready var label_agua: Label = $MargemTopo/PainelTopo/HBoxInformacoes/BoxTelemetria/LabelAgua
@onready var label_objetivos: Label = $MargemTopo/PainelTopo/HBoxInformacoes/BoxObjetivos/LabelTextoObjetivo

# Referências de botões
@onready var botao_grade: Button = $MargemTopo/PainelTopo/HBoxInformacoes/BoxAcoes/BotaoGrade
@onready var botao_abrir_editor: Button = $MargemTopo/PainelTopo/HBoxInformacoes/BoxAcoes/BotaoAbrirEditor
@onready var botao_velocidade: Button = $MargemTopo/PainelTopo/HBoxInformacoes/BoxAcoes/BotaoVelocidade

func _ready() -> void:
	# Conecta os botões internamente para emitir os sinais para fora
	botao_velocidade.pressed.connect(func(): velocidade_clicada.emit())
	botao_grade.pressed.connect(func(): grade_clicada.emit())
	botao_abrir_editor.pressed.connect(func(): editor_clicado.emit())

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
