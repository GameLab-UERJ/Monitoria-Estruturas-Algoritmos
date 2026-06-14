extends CharacterBody2D
@onready var ray = $RayCast2D
@onready var sprite = $AnimatedSprite2D
@onready var mapa = $"../TileMapLayer"
@onready var game_manager = %GameManager

var tile_size: int
var passo: int
var grid_position: Vector2
var is_moving: bool = false
signal movement_finished

var inputs = {
    "ui_right": Vector2.RIGHT,
    "ui_left":  Vector2.LEFT,
    "ui_up":    Vector2.UP,
    "ui_down":  Vector2.DOWN
}
var command_to_input = {
    "move_right": "ui_right",
    "move_left":  "ui_left",
    "move_up":    "ui_up",
    "move_down":  "ui_down"
}

func _ready():
    tile_size = mapa.tile_set.tile_size.x * int(mapa.scale.x)
    var tamanho_medio = (mapa.linhas_custom + mapa.colunas_custom) / 2
    passo = max(1, tamanho_medio / 4)
    grid_position = ((position - Vector2.ONE * tile_size / 2) / tile_size).round()
    position = grid_position * tile_size + Vector2.ONE * tile_size / 2

func _unhandled_input(event):
    if is_moving:
        return
    for dir in inputs.keys():
        if event.is_action_pressed(dir):
            move2(dir)

func move2(dir: String):
    var tile_size_raw = mapa.tile_set.tile_size.x
    ray.target_position = inputs[dir] * tile_size_raw * passo
    ray.force_raycast_update()
    if !ray.is_colliding():
        grid_position += inputs[dir] * passo
        var target = grid_position * tile_size + Vector2.ONE * tile_size / 2
        var tween = create_tween()
        tween.tween_property(self, "position", target, 0.15)
        tween.tween_callback(func():
            is_moving = false
            movement_finished.emit()
        )
        is_moving = true
        game_manager.add_passo()
    else:
        movement_finished.emit()

func mover_por_comando(comando: String) -> bool:
    if is_moving:
        return false
    if comando in command_to_input:
        move2(command_to_input[comando])
        return true
    if comando in ["plant", "collect"]:
        await animar_interacao()
        movement_finished.emit()
        return true
    return false
    
func animar_interacao():
    sprite.play("interact")
    await sprite.animation_finished
    sprite.play("idle")
