extends Node
var fruit = 0
var passos = 0
@export var obj_fruta : int
@export var obj_passos : int
@export_file("*.tscn") var proxima_cena: String
@export var estagio_texto: String = "Estágio Z: XxY"  
var obj_sim = false
@onready var objetivo_label = $"../CanvasLayer/PromptdeComando/Hud/Estagio e objetivo/ObjetivoLabel"
@onready var estagio_label = $"../CanvasLayer/PromptdeComando/Hud/Estagio e objetivo/EstágioLabel"
@onready var frutas_bar = $"../CanvasLayer/PromptdeComando/Hud/Plantas/FrutaBar"
@onready var passos_bar = $"../CanvasLayer/PromptdeComando/Hud/contador de passos/PassoBar"

func _ready():
	estagio_label.text = estagio_texto
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
	if passos >= obj_passos and fruit <= obj_fruta:
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
			get_tree().change_scene_to_file(proxima_cena) 
		else:
			objetivo_label.text = "Objetivo falhado"
			obj_sim = true 
