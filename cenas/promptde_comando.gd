extends Control

@onready var input = $HBoxContainer/VBoxContainer/LineEdit
@onready var historico = $HBoxContainer/TextEdit
# Lista de comandos que o jogo entende
const COMANDOS_VALIDOS = ["mover_esq", "mover_dir", "acima", "abaixo", "plantar", "coletar"]
var actions = []

func _ready():
    input.text_submitted.connect(_on_input_submitted)
    input.grab_focus()

func _on_input_submitted(text: String):
    var comando = text.strip_edges()
    
    # Agora todo comando digitado é enviado para a validação/fila
    if not comando.is_empty():
        adicionar_comando(comando)
        
    input.clear()

# Nova função para organizar a adição
func adicionar_comando(comando: String):
   
    var comando_limpo = comando.replace("()", "").strip_edges()
    
    if comando_limpo in COMANDOS_VALIDOS:
        actions.append(comando_limpo)
        historico.text += "Comando adicionado: " + comando_limpo + "\n"
    else:
        historico.text += "ERRO: Comando '" + comando_limpo + "' inválido!\n"

# Função chamada pelo Botão "Executar"
func _on_button_pressed() -> void:
    executar_acoes()

func executar_acoes():
    historico.text += "--- Executando... ---\n"
    for acao in actions:
        print("Executando: ", acao)
        # Aqui você chamará as funções de movimento do seu player/mapa
    
    actions.clear()
