extends Control

@onready var inv: Inv = preload("res://inventory/player_inventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var is_open = false

func _ready():
	update_slots()
	close()

func update_slots():
	for i in range(min(inv.items.size(), slots.size())):
		slots[i].update(inv.items[i])

func open():
	visible = true
	is_open = true

func close():
	visible = false
	is_open = false
