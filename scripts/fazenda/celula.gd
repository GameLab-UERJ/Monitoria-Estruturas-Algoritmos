class_name Celula
extends RefCounted

enum TipoSolo { GRAMA, TERRA_SECA, TERRA_ARADA }
enum Ocupacao { LIVRE, PLANTA, OBSTACULO, ESTRUTURA }

var tipo_solo: TipoSolo
var ocupacao: Ocupacao
var umidade: float # Escala 0.0 (seco) a 1.0 (encharcado). Afeta a saúde diária da cultura.
var fertilidade: float # Escala 0.0 (estéril) a 1.0 (altamente fértil).

# Referência à instância da planta. Null significa célula vazia.
var cultura: Cultura 

func _init(p_tipo_solo: TipoSolo = TipoSolo.TERRA_SECA, p_ocupacao: Ocupacao = Ocupacao.LIVRE) -> void:
	tipo_solo = p_tipo_solo
	ocupacao = p_ocupacao
	umidade = 0.4
	fertilidade = 0.5
	cultura = null

func pode_plantar() -> bool:
	return tipo_solo == TipoSolo.TERRA_ARADA and ocupacao == Ocupacao.LIVRE and cultura == null

func plantar(nova_cultura: Cultura) -> bool:
	if pode_plantar():
		cultura = nova_cultura
		ocupacao = Ocupacao.PLANTA
		return true
	return false

func regar(quantidade: float) -> void:
	umidade = clamp(umidade + quantidade, 0.0, 1.0)

func arar_terra() -> bool:
	if ocupacao != Ocupacao.LIVRE:
		return false # Não ara sobre pedras ou culturas existentes
	tipo_solo = TipoSolo.TERRA_ARADA
	return true

# Retorna a cultura para o inventário do drone e limpa a célula
func colher() -> Cultura:
	if cultura != null and cultura.estagio == Cultura.Estagio.MATURACAO:
		var colheita = cultura
		cultura = null
		ocupacao = Ocupacao.LIVRE
		tipo_solo = TipoSolo.TERRA_SECA # Colheita degrada o preparo do solo
		return colheita
	return null

# Delega o avanço do tempo para a planta, enviando as condições locais
func avancar_dia() -> void:
	umidade = clamp(umidade - 0.1, 0.0, 1.0)
	if cultura != null:
		cultura.processar_dia(umidade, fertilidade)

## Aumenta a umidade da célula até o limite máximo de 1.0
func irrigar(quantidade: float = 0.5) -> void:
	umidade = clampf(umidade + quantidade, 0.0, 1.0)

## Define o limiar visual para saber se o solo está molhado
func esta_irrigada() -> bool:
	return umidade >= 0.5
