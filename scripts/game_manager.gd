extends Node
var fruit = 0
var passos = 0
@export var obj_fruta : int
@export var obj_passos : int
@export_file("*.tscn") var proxima_cena: String
var obj_sim = false
@onready var fruit_label = $FruitLabel
@onready var passos_label = $PassosLabel
@onready var objetivo_label = $ObjetivoLabel

func _ready():
	
	objetivo_label.text = "Colete " + str(obj_fruta) + " plantas em menos de " + str(obj_passos) + " passos"
	 
func add_fruit():
	fruit += 1
	fruit_label.text = "Você colheu " + str(fruit) + " plantas " 
	verificar_obj()

func add_passo():
	passos += 1
	passos_label.text = "Passos: " + str(passos)
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
