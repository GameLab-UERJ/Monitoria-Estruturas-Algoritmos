class_name DroneIrrigador
extends Drone

var agua_atual: float
var capacidade_agua: float
var taxa_irrigacao: float

func _init(p_terreno: Terreno, x: int = 0, y: int = 0, p_capacidade_agua: float = 10.0) -> void:
	super(p_terreno, x, y)
	capacidade_agua = p_capacidade_agua
	agua_atual = capacidade_agua
	taxa_irrigacao = 1# 0.4

## Asperge uma quantidade de água controlada sobre a célula diretamente abaixo.
func irrigar() -> bool:
	# O drone precisa estar sobrevoando a plantação
	if estado_voo != EstadoVoo.EM_VOO:
		return false
		
	if agua_atual < taxa_irrigacao:
		return false # Reservatório insuficiente
		
	# Usa o método padrão do terreno para pegar a célula na posição atual
	var celula = terreno.obter_celula(posicao.x, posicao.y)
	if celula == null:
		return false
		
	# Se a sua classe base usa _gastar_bateria ou bateria direta, ajuste conforme sua base:
	if "bateria" in self and bateria < 5:
		return false
	elif has_method("_gastar_bateria") and not _gastar_bateria(1):
		return false
	elif "bateria" in self:
		bateria -= 5

	# Executa o método correto da célula (irrigar)
	if celula.has_method("irrigar"):
		celula.irrigar(taxa_irrigacao)
	elif celula.has_method("regar"):
		celula.regar(taxa_irrigacao)
		
	agua_atual -= taxa_irrigacao
	return true

## Reabastece o tanque de água (exige retorno ao solo).
func reabastecer_agua() -> bool:
	if estado_voo != EstadoVoo.POUSADO:
		return false # Procedimento de abastecimento exige pouso
		
	agua_atual = capacidade_agua
	return true
	
## Retorna verdadeiro enquanto houver água suficiente para pelo menos mais uma irrigação
func tem_agua() -> bool:
	return agua_atual >= taxa_irrigacao
