extends FaseBase

func _ready() -> void:
	super._ready() 
	texto_objetivo_hub = "🎯 Missões Ativas:\n • Clique no botão Executar"
	titulo_tutorial = "Bem-vindo ao Jogo!"
	# Sobrescreve o código padrão do editor com a demonstração da Fase 0
	code_edit.text = "# Código de demonstração - Clique em Executar!\ndecolar()\nmover_cima()\nirrigar()\npousar()"

## A apresentação é concluída quando o drone irriga (0, 1) e pousa sem erros
func verificar_vitoria() -> bool:
	var celula_alvo: Celula = terreno_logico.obter_celula(0, 1)
	if celula_alvo == null:
		return false
		
	var irrigou = celula_alvo.esta_irrigada()
	var pousou = (drone_logico.estado_voo == Drone.EstadoVoo.POUSADO)
	return irrigou and pousou
