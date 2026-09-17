extends Node
class_name GerenciadorDeFases

# A variável 'static' mantém o valor guardado na memória mesmo quando a cena é recarregada!
static var missao_atual: int = 1

# Dicionário com os objetivos de cada fase. Edite os valores como preferir!
var missoes_config = {
	1: {"frutas": 1, "passos": 15, "texto": "Estágio 1: 4x4"},
	2: {"frutas": 1, "passos": 25, "texto": "Estágio 2"},
	3: {"frutas": 1, "passos": 35, "texto": "Estágio 3"},
	4: {"frutas": 1, "passos": 45, "texto": "Estágio 4"},
	5: {"frutas": 1, "passos": 50, "texto": "Estágio 5"},
	6: {"frutas": 1, "passos": 55, "texto": "Estágio 6"},
	7: {"frutas": 1, "passos": 65, "texto": "Estágio 7: 9x10"}
}

var fruit = 0
var passos = 0
var obj_fruta = 1
var obj_passos = 15
var obj_sim = false

@onready var objetivo_label = $"../CanvasLayer/PromptdeComando/Hud/Estagio e objetivo/ObjetivoLabel"
@onready var estagio_label = $"../CanvasLayer/PromptdeComando/Hud/Estagio e objetivo/EstágioLabel"
@onready var frutas_bar = $"../CanvasLayer/PromptdeComando/Hud/Plantas/FrutaBar"
@onready var passos_bar = $"../CanvasLayer/PromptdeComando/Hud/contador de passos/PassoBar"

func _ready():
	# Carrega as configurações de acordo com a missão atual que está salva na variável estática
	var config = missoes_config.get(missao_atual, missoes_config[1])
	obj_fruta = config["frutas"]
	obj_passos = config["passos"]
	
	estagio_label.text = config["texto"]
	objetivo_label.text = "Colete " + str(obj_fruta) + " plantas em menos de " + str(obj_passos) + " passos"
	
	frutas_bar.max_value = obj_fruta
	frutas_bar.value = 0
	passos_bar.max_value = obj_passos
	passos_bar.value = 0

func add_fruit():
	fruit += 1
	frutas_bar.value = fruit
	verificar_obj()

func add_passo():
	passos += 1
	passos_bar.value = passos
	if obj_sim:
		return
	if passos >= obj_passos and fruit < obj_fruta:
		objetivo_label.text = "Objetivo falhado"
		obj_sim = true

func verificar_obj():
	if obj_sim:
		return
	if fruit >= obj_fruta:
		if passos <= obj_passos:
			objetivo_label.text = "Objetivo concluído"
			obj_sim = true 
			await get_tree().create_timer(1.5).timeout
			avancar_missao()
		else:
			objetivo_label.text = "Objetivo falhado"
			obj_sim = true 

func avancar_missao():
	if missao_atual < 7:
		missao_atual += 1
		# Recarrega a cena inteira. O jogo vai reiniciar já sabendo que é a próxima missão!
		get_tree().reload_current_scene() 
	else:
		objetivo_label.text = "Você completou todas as missões!"
