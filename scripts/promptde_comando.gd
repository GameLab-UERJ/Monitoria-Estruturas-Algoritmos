extends Control

@onready var input    = $HBoxContainer/VBoxContainer/LineEdit
@onready var historico = $HBoxContainer/TextEdit

const COMANDOS_VALIDOS = ["move_left", "move_right", "move_up", "move_down", "plant", "collect"]

var actions: Array = []
var executando: bool = false

func _ready():
	input.text_submitted.connect(_on_input_submitted)
	input.grab_focus()

func _on_input_submitted(text: String):
	var comando = text.strip_edges()
	if not comando.is_empty():
		adicionar_comando(comando)
	input.clear()

func adicionar_comando(comando: String):
	var comando_limpo = comando.replace("()", "").strip_edges()
	if comando_limpo in COMANDOS_VALIDOS:
		actions.append(comando_limpo)
		historico.text += "+ Adicionado: " + comando_limpo + "\n"
	else:
		historico.text += "X ERRO: '" + comando_limpo + "' inválido!\n"

func _on_button_pressed() -> void:
	if executando:
		historico.text += "Já executando, aguarde...\n"
		return
	executar_acoes()

func executar_acoes():
	if actions.is_empty():
		historico.text += "Nenhum comando na fila.\n"
		return

	executando = true
	historico.text += "--- Executando %d ação(ões)... ---\n" % actions.size()

	# Pega o player (ajuste o caminho conforme sua cena)
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		historico.text += "X ERRO: Player não encontrado! Adicione ao grupo 'player'.\n"
		executando = false
		return

	for acao in actions:
		historico.text += "▶ %s\n" % acao

		var movimentos = ["move_left", "move_right", "move_up", "move_down"]
		if acao in movimentos:
			var ok = player.mover_por_comando(acao)
			if ok:
				# Aguarda o sinal de fim do movimento antes de continuar
				await player.movement_finished
			else:
				historico.text += "Movimento bloqueado.\n"
		# (plantar, coletar, etc. serão implementados depois)

	actions.clear()
	executando = false
	historico.text += "--- Concluído! ---\n"
