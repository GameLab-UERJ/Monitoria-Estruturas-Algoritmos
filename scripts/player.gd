extends CharacterBody2D

@onready var ray = $RayCast2D
var tile_size = 32
var grid_position: Vector2
var is_moving: bool = false

var inputs = {
	"ui_right": Vector2.RIGHT,
	"ui_left": Vector2.LEFT,
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN
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

func move2(dir):
	ray.target_position = inputs[dir] * tile_size * 2
	ray.force_raycast_update()
	if !ray.is_colliding():
		grid_position += inputs[dir] * 2
		var target = grid_position * tile_size + Vector2.ONE * tile_size / 2
		var tween = create_tween()
		tween.tween_property(self, "position", target, 0.15)
		tween.tween_callback(func(): is_moving = false)
		is_moving = true
