extends GridContainer


@export var linhas_custom: int 
@export var colunas_custom: int
var script_do_bloco = preload("res://scripts/texture_rect.gd")
func _ready() -> void:
	gera_grid(linhas_custom,colunas_custom)
		
func gera_grid(linhas,colunas):
	
	self.columns = colunas_custom
	print("DEBUG: Vou desenhar ",linhas_custom * colunas_custom , " blocos na tela.")
	for i in range(linhas_custom * colunas_custom):
		var quadrado = script_do_bloco.new()
		quadrado.gera_bloco()
		
		add_child(quadrado)

func _on_timer_timeout() -> void:

	
	for quadrado in get_children():
		if quadrado.has_method("_on_timer_timeout"):
			quadrado._on_timer_timeout()
func _process(delta: float) -> void:
	pass
