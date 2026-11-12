extends Node2D

@onready var animacao: AnimatedSprite2D = $AnimatedSprite2D

func aplicar_escala(escala: int) -> void:
	scale = Vector2(escala, escala)

func definir_velocidade(nova_vel: float) -> void:
	animacao.speed_scale = nova_vel

func animar_decolagem() -> void:
	# Se no futuro criar uma animação "decolar", ele toca. Se não, vai direto para o voo.
	if animacao.sprite_frames.has_animation("decolando"):
		animacao.play("decolando")
		await animacao.animation_finished
	animacao.play("Voar normal")

func animar_pouso() -> void:
	if animacao.sprite_frames.has_animation("pousando"):
		animacao.play("pousando")
		await animacao.animation_finished
	animacao.play("Voar normal") # Como não há animação "parado", ele fica a pairar

func animar_voando() -> void:
	# Atualizado para o nome exato que está no seu Godot
	if animacao.animation != "Voar normal":
		animacao.play("Voar normal")

func animar_batida(esta_voando: bool) -> void:
	if animacao.sprite_frames.has_animation("batendo"):
		animacao.play("batendo")
		await animacao.animation_finished
		
	animacao.play("Voar normal")

func mover_para(destino: Vector2, tempo: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", destino, tempo).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# ==========================================
# AÇÃO EXCLUSIVA DO DRONE IRRIGADOR
# ==========================================
func animar_irrigacao() -> void:
	# Atualizado para usar a sua animação "agua"
	if animacao.sprite_frames.has_animation("agua"):
		animacao.play("agua")
		await animacao.animation_finished
		
	animacao.play("Voar normal")
