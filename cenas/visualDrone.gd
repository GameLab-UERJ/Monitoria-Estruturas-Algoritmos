extends Node2D

@onready var animacao: AnimatedSprite2D = $AnimatedSprite2D
@onready var som_drone: AudioStreamPlayer2D = $AudioStreamPlayer2D

func aplicar_escala(escala: int) -> void:
	scale = Vector2(escala, escala)

func definir_velocidade(nova_vel: float) -> void:
	animacao.speed_scale = nova_vel

func animar_decolagem() -> void:
	# O som começa junto com a decolagem
	if not som_drone.playing:
		som_drone.play()
	
	if animacao.sprite_frames.has_animation("decolando"):
		animacao.play("decolando")
		await animacao.animation_finished
	animacao.play("voando")

func animar_pouso() -> void:
	if animacao.sprite_frames.has_animation("pousando"):
		animacao.play("pousando")
		await animacao.animation_finished
	
	# O som para só depois que a animação de pouso termina
	som_drone.stop()
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
