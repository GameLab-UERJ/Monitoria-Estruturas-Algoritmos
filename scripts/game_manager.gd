extends Node
var fruit = 0
var passos = 0
var obj_fruta = 4
var obj_passos = 10
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
	if passos >= obj_passos and fruit <= obj_fruta:
		objetivo_label.text = "Objetivo falhado"

func verificar_obj():
	if fruit >= obj_fruta:
		if passos <= obj_passos:
			objetivo_label.text = "Objetivo concluído"
		else:
			objetivo_label.text = "Objetivo falhado"
