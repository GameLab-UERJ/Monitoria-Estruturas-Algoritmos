
extends TileMapLayer

@export var linhas_custom: int = 4
@export var colunas_custom: int = 4

var dados_plantas = {} 

func _ready() -> void:
    self.scale = Vector2(3, 3)
    
  
    var timer_node = get_node_or_null("Timer")
    
    if timer_node:
        
        if not timer_node.timeout.is_connected(_on_timer_timeout):
            timer_node.timeout.connect(_on_timer_timeout)
            
    else:
       pass
        
    gerar_grid()

func gerar_grid():
    print("Gerando grid de ", colunas_custom, "x", linhas_custom)
    for x in range(colunas_custom):
        for y in range(linhas_custom):
            var pos = Vector2i(x, y)
            
            
            if randf() >= 0.7:
                
                set_cell(pos, 0, Vector2i(2, 1)) 
                dados_plantas[pos] = {"status": "broto", "segundos": 0}
                print("Desenhando BROTO em: ", pos)
            else:
                
                set_cell(pos, 0, Vector2i(0, 0)) 
                dados_plantas[pos] = {"status": "terra", "segundos": 0}
                print("Desenhando TERRA em: ", pos)

func processar_crescimento():
    
    
    for pos in dados_plantas.keys():
        var planta = dados_plantas[pos]
        
        
        if planta.status == "broto":
            
            
            planta.segundos += 1
            
            if planta.segundos == 1:
                set_cell(pos, 0, Vector2i(3, 1))
            elif planta.segundos == 2:
                set_cell(pos, 0, Vector2i(4, 1))
            elif planta.segundos >= 3:
                var flor_final = Vector2i(randi_range(0, 4), randi_range(2, 3))
                set_cell(pos, 0, flor_final)
                planta.status = "flor"
        else:
            
            pass


func _on_timer_timeout() -> void:
   
    
    processar_crescimento() 
