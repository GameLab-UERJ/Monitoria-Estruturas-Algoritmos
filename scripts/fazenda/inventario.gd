class_name Inventario
extends RefCounted

var capacidade_peso_max: float
var itens: Array[Cultura] = []

func _init(p_capacidade_peso_max: float = 15.0) -> void:
	capacidade_peso_max = p_capacidade_peso_max

## Retorna a soma de peso de todas as culturas/sementes armazenadas.
func obter_peso_atual() -> float:
	var total: float = 0.0
	for item in itens:
		total += item.peso_base
	return total

## Retorna o valor de mercado somado de todos os itens guardados.
func obter_valor_total() -> float:
	var total: float = 0.0
	for item in itens:
		total += item.valor_base
	return total

## Tenta adicionar uma cultura ao inventário respeitando o limite de peso.
func adicionar(item: Cultura) -> bool:
	if item == null:
		return false
	if obter_peso_atual() + item.peso_base > capacidade_peso_max:
		return false # Excederia a capacidade de carga do drone
		
	itens.append(item)
	return true

## Verifica se há ao menos uma semente da espécie indicada.
func tem_semente(especie_id: String) -> bool:
	for item in itens:
		if item.especie_id == especie_id and item.estagio == Cultura.Estagio.SEMENTE:
			return true
	return false

## Remove e retorna a primeira semente da espécie encontrada para o plantio.
func consumir_semente(especie_id: String) -> Cultura:
	for i in range(itens.size()):
		var item = itens[i]
		if item.especie_id == especie_id and item.estagio == Cultura.Estagio.SEMENTE:
			itens.remove_at(i)
			return item
	return null

## Remove e retorna todos os itens no estágio de maturação (descarregamento).
func descarregar_colheitas() -> Array[Cultura]:
	var colhidos: Array[Cultura] = []
	var restantes: Array[Cultura] = []
	for item in itens:
		if item.estagio == Cultura.Estagio.MATURACAO:
			colhidos.append(item)
		else:
			restantes.append(item)
	itens = restantes
	return colhidos
