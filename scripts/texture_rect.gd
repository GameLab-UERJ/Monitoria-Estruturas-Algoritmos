extends TextureRect
var tileset_resource = preload("res://Imagens/tileset.png")

var tamanho_tile = 32

var eh_planta = false
var segundos = 0
var escala_visual = 3
func _ready() -> void:
	pass
	


func gera_bloco():
	var costumizacao = randf()
	var atlas = AtlasTexture.new()
	
	if costumizacao >= 0.7:	 
		eh_planta = true
		atlas.atlas = tileset_resource
		atlas.region = Rect2(2*tamanho_tile,1*tamanho_tile,tamanho_tile,tamanho_tile)
		
		
	else:	
		
		atlas.atlas = tileset_resource
		atlas.region = Rect2(0*tamanho_tile,0*tamanho_tile,tamanho_tile,tamanho_tile)
	
		
	self.texture = atlas
	var tamanho_final = tamanho_tile * escala_visual
	self.custom_minimum_size = Vector2(tamanho_final, tamanho_final)
	self.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	self.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	

	
		
func _on_timer_timeout() -> void:
	
	if not eh_planta:
		return
	segundos += 1
	
	var atlas = AtlasTexture.new()
	atlas.atlas = tileset_resource
	
	if segundos == 1:
		eh_planta = true
		atlas.atlas = tileset_resource
		atlas.region = Rect2(3*tamanho_tile,1*tamanho_tile,tamanho_tile,tamanho_tile)
		self.texture = atlas
	elif segundos == 2:
		
		atlas.atlas = tileset_resource
		atlas.region = Rect2(4*tamanho_tile,1*tamanho_tile,tamanho_tile,tamanho_tile)
		self.texture = atlas

	elif segundos ==3:
		
		atlas.atlas = tileset_resource
		var posi_linha = randi_range(2,3)
		var posi_coluna = randi_range(0,4)
		atlas.region = Rect2(posi_coluna*tamanho_tile,posi_linha*tamanho_tile,tamanho_tile,tamanho_tile)
		self.texture = atlas
		 
