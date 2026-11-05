extends CharacterBody2D

@onready var ray = $RayCast2D
@onready var animacao: AnimatedSprite2D = $AnimatedSprite2D
@onready var mapa = $"../TileMapLayer"
@onready var game_manager = %GameManager
@export var inv: Resource

var tile_size: int
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
	grid_position = ((position - Vector2.ONE * tile_size / 2) / tile_size).round()
	position = grid_position * tile_size + Vector2.ONE * tile_size / 2
	animar_voando() # Garante que já inicie voando

# ==========================================
# FUNÇÕES DE ANIMAÇÃO DO SEU NOVO MODELO
# ==========================================

func aplicar_escala(escala: int) -> void:
	scale = Vector2(escala, escala)

func definir_velocidade(nova_vel: float) -> void:
	animacao.speed_scale = nova_vel

func animar_decolagem() -> void:
	if animacao.sprite_frames.has_animation("decolando"):
		animacao.play("decolando")
		await animacao.animation_finished
	animacao.play("voando")

func animar_pouso() -> void:
	if animacao.sprite_frames.has_animation("pousando"):
		animacao.play("pousando")
		await animacao.animation_finished
	animacao.play("parado")

func animar_voando() -> void:
	if animacao.animation != "voando":
		animacao.play("voando")

func animar_batida(esta_voando: bool) -> void:
	if animacao.sprite_frames.has_animation("batendo"):
		animacao.play("batendo")
		await animacao.animation_finished
	animacao.play("voando" if esta_voando else "parado")

func mover_para(destino: Vector2, tempo: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", destino, tempo).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Ao terminar o movimento do Tween, avisa o terminal que o drone parou
	tween.tween_callback(func():
		is_moving = false
		movement_finished.emit()
	)

# ==========================================
# INTEGRAÇÃO COM A GRADE (GRID) E COMANDOS
# ==========================================

func _unhandled_input(event):
	if is_moving:
		return
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			move2(dir)

func move2(dir: String):
	var tamanho_base = mapa.tile_set.tile_size.x
	
	ray.target_position = inputs[dir] * tamanho_base
	ray.force_raycast_update()
	
	if !ray.is_colliding():
		is_moving = true
		animar_voando() # Mantém a animação de voo
		
		grid_position += inputs[dir]
		var target = grid_position * tile_size + Vector2.ONE * tile_size / 2
		
		game_manager.add_passo()
		
		# Chamamos a função mover_para do seu modelo!
		mover_para(target, 0.15) 
	else:
		# Se bater numa pedra, toca a animação de batida e encerra o movimento
		animar_batida(true)
		movement_finished.emit()

func mover_por_comando(comando: String) -> bool:
	if is_moving:
		return false
		
	# Se for um comando de movimento do terminal
	if comando in command_to_input:
		move2(command_to_input[comando])
		return true
		
	# Exemplo de integração do modelo para ações como plantar
	if comando in ["plant", "collect"]:
		is_moving = true
		animar_pouso()
		await animacao.animation_finished
		# (Opcional: Colocar animação de soltar semente aqui)
		animar_decolagem()
		is_moving = false
		movement_finished.emit()
		return true
		
	return false
