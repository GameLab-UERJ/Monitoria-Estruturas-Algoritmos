extends GridContainer

var tileset_resource = preload("res://Imagens/texturas-chao.tres")
var linhas_custom: int =4
var colunas_custom: int= 4
var tiles_permitidos = [
	Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), 
	Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), 
	Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 3) ]
func _ready() -> void:
	self.columns = colunas_custom
	
	var source_id = 0
	
	
	for i in range(linhas_custom * colunas_custom):
		var tile_aleatoria = randi_range(0, tiles_permitidos.size() - 1)
		var costomizacao = randf()
		var tile = tiles_permitidos[tile_aleatoria]
		var quadrado = TextureRect.new()			
		var atlas = AtlasTexture.new()
		atlas.atlas = tileset_resource.get_source(source_id).texture
			
		if costomizacao>=0.8:
			var tile_pos = tile
			var t_size = Vector2i(32, 32)
			atlas.region = Rect2(tile_pos*t_size, t_size)
		else:
			var tile_pos = Vector2i(0,0)
			var t_size = Vector2i(32, 32)
			atlas.region = Rect2(tile_pos*t_size, t_size)
														
		quadrado.texture = atlas
		quadrado.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		quadrado.custom_minimum_size = Vector2(128,128)
			
		quadrado.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		add_child(quadrado)
		
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
