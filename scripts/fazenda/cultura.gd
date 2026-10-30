class_name Cultura
extends RefCounted

enum Estagio { SEMENTE, BROTO, CRESCIMENTO, MATURACAO }
enum Doenca { PRAGA, FUNGO, BACTERIA }

# Configuração base das espécies agrícolas
const DADOS_ESPECIE = {
	"milho": {
		"dias_maturacao": 9,
		"tolerancia_seca": 0.3,
		"peso_semente": 0.05,
		"peso_colheita": 0.50,
		"valor_semente": 2.0,
		"valor_colheita": 15.0
	},
	"feijao": {
		"dias_maturacao": 6,
		"tolerancia_seca": 0.2,
		"peso_semente": 0.02,
		"peso_colheita": 0.30,
		"valor_semente": 1.5,
		"valor_colheita": 10.0
	}
}

var especie_id: String
var estagio: Estagio
var dias_plantio: int
var saude: float
var doencas: Array[Doenca]

# Atributos para otimização e problema da mochila
var peso_base: float
var valor_base: float

func _init(p_especie_id: String, p_estagio: Estagio = Estagio.SEMENTE) -> void:
	assert(DADOS_ESPECIE.has(p_especie_id), "Espécie agrícola desconhecida!")
	especie_id = p_especie_id
	estagio = p_estagio
	dias_plantio = 0
	saude = 1.0
	doencas = []
	_atualizar_metricas_economicas()

func tem_doenca() -> bool:
	return not doencas.is_empty()

func adicionar_doenca(doenca: Doenca) -> void:
	if not doencas.has(doenca):
		doencas.append(doenca)

func processar_dia(umidade_solo: float, fertilidade_solo: float) -> void:
	var dados = DADOS_ESPECIE[especie_id]
	dias_plantio += 1
	
	if umidade_solo < dados["tolerancia_seca"]:
		saude = clamp(saude - 0.2, 0.0, 1.0)
	
	if tem_doenca():
		saude = clamp(saude - (0.1 * doencas.size()), 0.0, 1.0)
		
	_atualizar_estagio(dados["dias_maturacao"])

func _atualizar_estagio(dias_max: int) -> void:
	if saude <= 0.0:
		return
		
	var progresso = float(dias_plantio) / float(dias_max)
	if progresso >= 1.0:
		estagio = Estagio.MATURACAO
	elif progresso >= 0.6:
		estagio = Estagio.CRESCIMENTO
	elif progresso >= 0.3:
		estagio = Estagio.BROTO
		
	_atualizar_metricas_economicas()

## Atualiza peso_base e valor_base conforme a fase de desenvolvimento.
func _atualizar_metricas_economicas() -> void:
	var dados = DADOS_ESPECIE[especie_id]
	match estagio:
		Estagio.SEMENTE:
			peso_base = dados["peso_semente"]
			valor_base = dados["valor_semente"]
		Estagio.BROTO, Estagio.CRESCIMENTO:
			# Estágios intermediários têm peso gradual e baixo valor de revenda
			peso_base = lerp(dados["peso_semente"], dados["peso_colheita"], 0.4)
			valor_base = dados["valor_semente"] * 0.5
		Estagio.MATURACAO:
			peso_base = dados["peso_colheita"]
			# Plantas doentes ou com baixa saúde têm perda de valor de mercado
			valor_base = dados["valor_colheita"] * saude
