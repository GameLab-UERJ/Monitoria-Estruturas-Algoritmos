class_name DroneInspetor
extends Drone

func _init(p_terreno: Terreno, x: int = 0, y: int = 0) -> void:
	super(p_terreno, x, y)

## Retorna a espécie presente na célula abaixo (ou texto vazio se não houver).
func identificar_especie() -> String:
	if estado_voo != EstadoVoo.EM_VOO or not _gastar_bateria(1):
		return ""
		
	var celula = _obter_celula_abaixo()
	if celula and celula.cultura != null:
		return celula.cultura.especie_id
	return ""

## Retorna a lista de doenças ativas na cultura inspecionada.
func escanear_doencas() -> Array[Cultura.Doenca]:
	if estado_voo != EstadoVoo.EM_VOO or not _gastar_bateria(1):
		return []
		
	var celula = _obter_celula_abaixo()
	if celula and celula.cultura != null:
		return celula.cultura.doencas.duplicate()
	return []

## Retorna o estágio da cultura (ou -1 se a célula não tiver cultura).
func verificar_estagio() -> int:
	if estado_voo != EstadoVoo.EM_VOO or not _gastar_bateria(1):
		return -1
		
	var celula = _obter_celula_abaixo()
	if celula and celula.cultura != null:
		return celula.cultura.estagio
	return -1

## Retorna o nível de umidade do solo (leitura de sensor multiespectral).
func ler_umidade_solo() -> float:
	if estado_voo != EstadoVoo.EM_VOO or not _gastar_bateria(1):
		return -1.0
		
	var celula = _obter_celula_abaixo()
	if celula:
		return celula.umidade
	return -1.0

## Gera um diagnóstico consolidado da parcela sobrevoada em forma de Dicionário.
func relatorio_completo() -> Dictionary:
	if estado_voo != EstadoVoo.EM_VOO or not _gastar_bateria(2):
		return {}
		
	var celula = _obter_celula_abaixo()
	if celula == null:
		return {}
		
	var info: Dictionary = {
		"coordenada": posicao,
		"umidade_solo": celula.umidade,
		"tipo_solo": celula.tipo_solo,
		"tem_cultura": celula.cultura != null
	}
	
	if celula.cultura != null:
		info["especie"] = celula.cultura.especie_id
		info["estagio"] = celula.cultura.estagio
		info["saude"] = celula.cultura.saude
		info["doencas"] = celula.cultura.doencas.duplicate()
		info["peso_estimado"] = celula.cultura.peso_base
		info["valor_estimado"] = celula.cultura.valor_base
		
	return info
