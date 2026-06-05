extends CharacterBody2D

@onready var ray = $RayCast2D
var tile_size = 32
var grid_position: Vector2
var is_moving: bool = false

signal movement_finished  # sinal para avisar que terminou

var inputs = {
	"ui_right":  Vector2.RIGHT,
	"ui_left":   Vector2.LEFT,
	"ui_up":     Vector2.UP,
	"ui_down":   Vector2.DOWN
}

# Mapeamento de comando de texto para action name
var command_to_input = {
	"move_right": "ui_right",
	"move_left":  "ui_left",
	"move_up":    "ui_up",
	"move_down":  "ui_down"
}

func _ready():
	grid_position = ((position - Vector2.ONE * tile_size / 2) / tile_size).round()
	position = grid_position * tile_size + Vector2.ONE * tile_size / 2

func _unhandled_input(event):
	if is_moving:
		return
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			move2(dir)

func move2(dir: String):
	ray.target_position = inputs[dir] * tile_size * 2
	ray.force_raycast_update()
	if !ray.is_colliding():
		grid_position += inputs[dir] * 2
		var target = grid_position * tile_size + Vector2.ONE * tile_size / 2
		var tween = create_tween()
		tween.tween_property(self, "position", target, 0.15)
		tween.tween_callback(func():
			is_moving = false
			movement_finished.emit()  # avisa que terminou
		)
		is_moving = true
	else:
		# Colisão e emite o sinal mesmo assim para não travar a fila
		movement_finished.emit()

# Chamado pelo prompt de comando passando string como "move_left"
func mover_por_comando(comando: String) -> bool:
	if is_moving:
		return false
	if comando in command_to_input:
		move2(command_to_input[comando])
		return true
	return false
