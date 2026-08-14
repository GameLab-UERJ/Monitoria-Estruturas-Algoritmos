extends Panel

@export var quantidade_inicial: int = 10

var quantidade: int

@onready var item_visual: TextureRect = $CenterContainer/Panel/itemdisplay
@onready var quantidade_label = $CenterContainer/Panel/Label

func _ready():
	quantidade = quantidade_inicial
	quantidade_label.text = str(quantidade)

func update(item: InvItem):
	if !item:
		item_visual.visible = false
	else:
		item_visual.visible = true
		item_visual.texture = item.texture

func usar_item():
	if quantidade <= 0:
		return

	quantidade -= 1
	quantidade_label.text = str(quantidade)

	if quantidade <= 0:
		# opcional: o que fazer quando o slot esvazia
		pass
