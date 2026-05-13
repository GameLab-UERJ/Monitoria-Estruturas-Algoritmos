extends Node

var fruit = 0

@onready var fruit_label = $FruitLabel

func add_fruit():
	fruit += 1
	print(fruit)
	fruit_label.text = "Você colheu " + str(fruit) + " frutas " 
