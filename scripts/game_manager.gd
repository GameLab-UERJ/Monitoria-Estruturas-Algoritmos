extends Node
var fruit = 0
var passos = 0
@onready var fruit_label = $FruitLabel
@onready var passos_label = $PassosLabel

func add_fruit():
	fruit += 1
	print(fruit)
	fruit_label.text = "Você colheu " + str(fruit) + " plantas " 

func add_passo():
	passos += 1
	passos_label.text = "Passos: " + str(passos)
