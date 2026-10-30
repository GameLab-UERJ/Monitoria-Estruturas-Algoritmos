class_name DroneAgricultor
extends Drone

var inventario: Inventario
var capacidade_carga: int
var carga_atual: int

func _init(p_terreno: Terreno, x: int = 0, y: int = 0, p_capacidade_carga: int = 20) -> void:
	super(p_terreno, x, y)
	inventario = Inventario.new()
	capacidade_carga = p_capacidade_carga
	carga_atual = 0

## Realiza o plantio de uma semente na célula abaixo do drone.
func plantar(especie_id: String) -> bool:
	if estado_voo != EstadoVoo.EM_VOO or not inventario.tem_semente(especie_id):
		return false
		
	var celula = _obter_celula_abaixo()
	if celula == null or not celula.pode_plantar():
		return false
		
	if not _gastar_bateria(2):
		return false
		
	# Retira a semente do inventário e a transfere para a célula
	var semente = inventario.consumir_semente(especie_id)
	return celula.plantar(semente)

func colher() -> bool:
	if estado_voo != EstadoVoo.EM_VOO:
		return false
		
	var celula = _obter_celula_abaixo()
	if celula == null or celula.cultura == null:
		return false
		
	if celula.cultura.estagio != Cultura.Estagio.MATURACAO:
		return false
		
	# Verifica se a mochila suporta o peso do fruto maduro antes de gastar bateria
	if inventario.obter_peso_atual() + celula.cultura.peso_base > inventario.capacidade_peso_max:
		return false # Capacidade de peso excedida
		
	if not _gastar_bateria(2):
		return false
		
	var colheita = celula.colher()
	return inventario.adicionar(colheita)

## Esvazia o compartimento de carga na base agrícola (exige pouso de segurança).
func descarregar() -> int:
	if estado_voo != EstadoVoo.POUSADO:
		return 0 # Só descarrega fisicamente no solo
		
	var total_descarregado = carga_atual
	carga_atual = 0
	return total_descarregado
