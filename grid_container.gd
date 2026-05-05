extends GridContainer

var tileset_resource = preload("res://Imagens/texturas-chao.tres")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var colunas = 4
	var linhas = 4
	self.columns = colunas
	var source_id = 0
	for i in range(colunas):
		for j in range(linhas):
			var quadrado = TextureRect.new()
			
			var atlas = AtlasTexture.new()
			atlas.atlas = tileset_resource.get_source(source_id).texture
			
			if j%2 ==0:
				var tile_pos = Vector2i(2, 1)
				var t_size = tileset_resource.tile_size
				atlas.region = Rect2(tile_pos*t_size, t_size)
			else:
				var tile_pos = Vector2i(2, 2)				
				var t_size = tileset_resource.tile_size
				atlas.region = Rect2(tile_pos*t_size, t_size)
														
			quadrado.texture = atlas
			quadrado.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			quadrado.custom_minimum_size = Vector2(128,128)
			
			quadrado.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			add_child(quadrado)
		
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
