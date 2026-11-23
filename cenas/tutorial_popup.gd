class_name TutorialPopup
extends CanvasLayer

signal fechado

@onready var container_janela: Control = $FundoEscuro/Centralizador/ContainerJanela
@onready var label_titulo: Label = $FundoEscuro/Centralizador/ContainerJanela/PlacaTitulo/LabelTitulo
@onready var texto_tutorial: RichTextLabel = $FundoEscuro/Centralizador/ContainerJanela/MolduraFundo/MargemInterna/VBoxConteudo/TextoTutorial
@onready var botao_fechar_x: TextureButton = $FundoEscuro/Centralizador/ContainerJanela/BotaoFecharX
@onready var botao_entendi: TextureButton = $FundoEscuro/Centralizador/ContainerJanela/MolduraFundo/MargemInterna/VBoxConteudo/CentralizadorBotao/BotaoEntendi

func _ready() -> void:
	botao_fechar_x.pressed.connect(fechar)
	botao_entendi.pressed.connect(fechar)
	hide()

func configurar(titulo: String, conteudo: String) -> void:
	label_titulo.text = titulo
	texto_tutorial.text = conteudo

func abrir() -> void:
	show()
	# Animação suave de entrada
	container_janela.pivot_offset = container_janela.size / 2.0
	container_janela.scale = Vector2(0.9, 0.9)
	container_janela.modulate.a = 0.0
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(container_janela, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(container_janela, "modulate:a", 1.0, 0.15)

func fechar() -> void:
	if not visible:
		return
	hide()
	fechado.emit()
