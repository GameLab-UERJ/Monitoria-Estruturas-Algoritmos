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

func get_slot(indice: int) -> Panel:
	var grid = $NinePatchRect/GridContainer
	if indice < 1 or indice > grid.get_child_count():
		return null
	return grid.get_child(indice - 1)

func open():
	visible = true
	is_open = true

func close():
	visible = false
	is_open = false
