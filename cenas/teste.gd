extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_testar_sistema_completo()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _testar_sistema_completo() -> void:
	var terreno = Terreno.new(5, 5)
	var celula = terreno.obter_celula(1, 0)
	celula.tipo_solo = Celula.TipoSolo.TERRA_ARADA
	
	# 1. Simula uma planta já crescida com praga
	var milho_adulto = Cultura.new("milho", Cultura.Estagio.MATURACAO)
	milho_adulto.adicionar_doenca(Cultura.Doenca.PRAGA)
	celula.plantar(milho_adulto)
	
	# 2. Drone Inspetor faz a varredura
	var inspetor = DroneInspetor.new(terreno, 0, 0)
	inspetor.decolar()
	inspetor.mover_direita() # Move para (1, 0)
	
	var diagnostico = inspetor.relatorio_completo()
	print("Diagnóstico:", diagnostico)
	# Saída esperada: { especie: "milho", estagio: 3, doencas: [0], peso_estimado: 0.5, valor_estimado: 15.0, ... }
	inspetor.pousar()
	
	# 3. Teste do Inventário e Capacidade de Carga (Problema da Mochila)
	var inventario_drone = Inventario.new(1.0) # Limite de apenas 1.0 kg
	
	var semente_1 = Cultura.new("milho", Cultura.Estagio.SEMENTE) # 0.05 kg
	var fruto_1 = Cultura.new("milho", Cultura.Estagio.MATURACAO) # 0.50 kg
	var fruto_2 = Cultura.new("milho", Cultura.Estagio.MATURACAO) # 0.50 kg
	var fruto_3 = Cultura.new("feijao", Cultura.Estagio.MATURACAO) # 0.30 kg
	
	inventario_drone.adicionar(semente_1) # Peso: 0.05 kg
	inventario_drone.adicionar(fruto_1)  # Peso: 0.55 kg
	
	# Tentar adicionar fruto_2 (0.55 + 0.50 = 1.05 kg > 1.0 kg) deve falhar
	var coube_fruto_2 = inventario_drone.adicionar(fruto_2)
	print("Coube o fruto 2? ", coube_fruto_2) # false
	
	# Mas o fruto_3 é feijão (0.30 kg), totalizando 0.85 kg <= 1.0 kg
	var coube_fruto_3 = inventario_drone.adicionar(fruto_3)
	print("Coube o fruto 3? ", coube_fruto_3) # true
	print("Valor total na mochila: R$", inventario_drone.obter_valor_total())
