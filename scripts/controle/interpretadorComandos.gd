class_name InterpretadorComandos
extends RefCounted

signal execucao_concluida
signal linha_executada(numero_linha: int, mensagem: String)

var velocidade_multiplicador: float = 1.0

var drone: Drone
var cenario: Node2D
var editor: CodeEdit
var console: TextEdit
var executando: bool = false
var pausado: bool = false

var linha_progresso: int = 0
var erro_detectado: bool = false # Variável global de erro para propagação recursiva

func _init(p_drone: Drone, p_cenario: Node2D, p_editor: CodeEdit, p_console: TextEdit) -> void:
	drone = p_drone
	cenario = p_cenario
	editor = p_editor
	console = p_console

# ==========================================
# UTILITÁRIOS E CONTROLES
# ==========================================
func _avaliar_condicao(condicao: String) -> bool:
	match condicao:
		"True": return true
		"False": return false
		"tem_agua()": return drone.tem_agua() if drone.has_method("tem_agua") else false
		#abaxio estão as funções que devem ser implementadas no futuro	
		"tem_semente()": return drone.tem_semente() if drone.has_method("tem_semente") else false
		"pode_plantar()": return drone.pode_plantar() if drone.has_method("pode_plantar") else false
	
	_log("[ERRO] Condição desconhecida: %s" % condicao)
	return false

func _contar_tabs(linha: String) -> int:
	var abas = 0
	for i in range(linha.length()):
		if linha[i] == '\t': abas += 1
		else: break
	return abas

func _limpar_linha(linha: String) -> String:
	var pos_comentario = linha.find("#")
	if pos_comentario != -1: linha = linha.substr(0, pos_comentario)
	return linha.strip_edges()

func _limpar_highlights(total_linhas: int) -> void:
	for j in range(total_linhas): editor.set_line_background_color(j, Color(0, 0, 0, 0))

func _log(mensagem: String) -> void:
	console.text += mensagem + "\n"
	console.set_caret_line(console.get_line_count())

func parar_execucao() -> void:
	executando = false
	pausado = false
	linha_progresso = 0
	_limpar_highlights(editor.get_line_count())
	_log("[INFO] Execução parada pelo jogador.")

func pausar_execucao() -> void:
	if executando:
		pausado = not pausado
		_log("[INFO] Execução Pausada." if pausado else "[INFO] Retomando execução...")

func alternar_velocidade() -> float:
	if velocidade_multiplicador == 1.0: velocidade_multiplicador = 2.0
	elif velocidade_multiplicador == 2.0: velocidade_multiplicador = 4.0
	else: velocidade_multiplicador = 1.0
	return velocidade_multiplicador

# ==========================================
# MOTOR DE EXECUÇÃO RECURSIVA
# ==========================================
func executar_codigo(codigo: String) -> void:
	executando = true
	pausado = false
	erro_detectado = false
	var linhas_brutas = codigo.split("\n")
	
	# Prepara as linhas em um formato estruturado
	var lista_comandos = []
	for i in range(linhas_brutas.size()):
		lista_comandos.append({
			"texto": linhas_brutas[i],
			"texto_limpo": _limpar_linha(linhas_brutas[i]),
			"linha_real": i,
			"indentacao": _contar_tabs(linhas_brutas[i])
		})
	
	if linha_progresso >= lista_comandos.size():
		linha_progresso = 0
		
	if linha_progresso == 0:
		_limpar_highlights(lista_comandos.size())
		_log("[INFO] Iniciando execução...")
		
	await _executar_bloco_recursivo(lista_comandos, linha_progresso, lista_comandos.size())
	
	if executando and not erro_detectado:
		linha_progresso = 0
		_limpar_highlights(lista_comandos.size())
		_log("[FIM] Execução concluída!")
		
	executando = false
	execucao_concluida.emit()

## Retorna o próximo índice a ser lido na lista pai
func _executar_bloco_recursivo(comandos: Array, indice_inicio: int, total_linhas_editor: int) -> int:
	var i = indice_inicio
	
	while i < comandos.size() and executando and not erro_detectado:
		while pausado and executando: await cenario.get_tree().process_frame
		if not executando: break
			
		var cmd = comandos[i]
		if cmd.texto_limpo.is_empty():
			i += 1; continue
			
		# DETECÇÃO DE 'WHILE'
		if cmd.texto_limpo.begins_with("while") and cmd.texto_limpo.ends_with(":"):
			var resultado_coleta = _coletar_sub_bloco(comandos, i, cmd.indentacao)
			var bloco_while = resultado_coleta.bloco
			var condicao = cmd.texto_limpo.replace("while", "").replace(":", "").strip_edges()
			
			while _avaliar_condicao(condicao) and executando and not erro_detectado:
				await _executar_bloco_recursivo(bloco_while, 0, total_linhas_editor)
				
			i = resultado_coleta.proximo_indice
			continue
			
		# DETECÇÃO DE 'IF - ELSE'
		if cmd.texto_limpo.begins_with("if ") and cmd.texto_limpo.ends_with(":"):
			var resultado_coleta_if = _coletar_sub_bloco(comandos, i, cmd.indentacao)
			var bloco_if = resultado_coleta_if.bloco
			var proximo_indice = resultado_coleta_if.proximo_indice
			var bloco_else = []
			
			# Verifica se tem 'else'
			if proximo_indice < comandos.size():
				var possivel_else = comandos[proximo_indice]
				if possivel_else.texto_limpo == "else:" and possivel_else.indentacao == cmd.indentacao:
					var resultado_coleta_else = _coletar_sub_bloco(comandos, proximo_indice, cmd.indentacao)
					bloco_else = resultado_coleta_else.bloco
					proximo_indice = resultado_coleta_else.proximo_indice
					
			var condicao = cmd.texto_limpo.replace("if ", "").replace(":", "").strip_edges()
			
			if _avaliar_condicao(condicao):
				await _executar_bloco_recursivo(bloco_if, 0, total_linhas_editor)
			else:
				if bloco_else.size() > 0:
					await _executar_bloco_recursivo(bloco_else, 0, total_linhas_editor)
					
			i = proximo_indice
			continue
			
		# EXECUÇÃO NORMAL (AÇÃO DO DRONE)
		_limpar_highlights(total_linhas_editor)
		editor.set_line_background_color(cmd.linha_real, Color(1.0, 0.85, 0.2, 0.35))
		
		var sucesso = await _interpretar_instrucao(cmd.texto_limpo, cmd.linha_real + 1)
		
		if not sucesso:
			editor.set_line_background_color(cmd.linha_real, Color(1.0, 0.2, 0.2, 0.4))
			_log("[ERRO] Falha na execução da linha %d." % [cmd.linha_real + 1])
			linha_progresso = cmd.linha_real
			erro_detectado = true
			break
			
		cenario.atualizar_posicao_drone()
		await cenario.get_tree().create_timer(0.6 / velocidade_multiplicador).timeout
		i += 1
		
	return i

## Coleta todas as linhas que têm indentação maior do que a linha de origem
func _coletar_sub_bloco(comandos_pai: Array, indice_origem: int, indentacao_base: int) -> Dictionary:
	var sub_bloco = []
	var j = indice_origem + 1
	
	while j < comandos_pai.size():
		var cmd = comandos_pai[j]
		if cmd.texto_limpo.is_empty():
			j += 1; continue
			
		if cmd.indentacao > indentacao_base:
			sub_bloco.append(cmd)
			j += 1
		else: break
			
	return { "bloco": sub_bloco, "proximo_indice": j }

# ==========================================
# INSTRUÇÕES DO DRONE
# ==========================================
func _interpretar_instrucao(comando: String, num_linha: int) -> bool:
	match comando:
		"decolar()":
			if drone.decolar():
				_log("Linha %d: decolar() -> Sucesso" % num_linha)
				await cenario.drone_visual.animar_decolagem()
				return true
			return _falha("Falha ao decolar", num_linha)
				
		"pousar()":
			if drone.pousar():
				_log("Linha %d: pousar() -> Sucesso" % num_linha)
				await cenario.drone_visual.animar_pouso()
				return true
			return _falha("Falha ao pousar", num_linha)
				
		"mover_cima()": return await _executar_movimento_com_animacao(drone.mover_cima(), "mover_cima()", num_linha)
		"mover_baixo()": return await _executar_movimento_com_animacao(drone.mover_baixo(), "mover_baixo()", num_linha)
		"mover_esquerda()": return await _executar_movimento_com_animacao(drone.mover_esquerda(), "mover_esquerda()", num_linha)
		"mover_direita()": return await _executar_movimento_com_animacao(drone.mover_direita(), "mover_direita()", num_linha)
			
		"irrigar()":
			if not drone.has_method("irrigar"): return _falha("Drone não possui a ferramenta de irrigação.", num_linha)
			if drone.estado_voo != Drone.EstadoVoo.EM_VOO: return _falha("O drone precisa estar voando!", num_linha)
			if "agua_atual" in drone and drone.agua_atual <= 0: return _falha("Reservatório vazio (0/%d)!" % drone.capacidade_agua, num_linha)
			if drone.bateria < 5: return _falha("Bateria insuficiente!", num_linha)
				
			if drone.irrigar():
				_log("Linha %d: irrigar() -> Solo irrigado! (Água restante: %d)" % [num_linha, drone.agua_atual])
				cenario.atualizar_visual_terreno_irrigado(drone.posicao)
				if cenario.has_method("atualizar_telemetria_geral"):
					cenario.atualizar_telemetria_geral()
				return true
			return _falha("Falha desconhecida ao irrigar.", num_linha)
				
		_: return _falha("Comando desconhecido: '%s'" % comando, num_linha)

func _executar_movimento_com_animacao(resultado: bool, nome_cmd: String, num_linha: int) -> bool:
	if resultado:
		_log("Linha %d: %s -> Sucesso" % [num_linha, nome_cmd])
		cenario.drone_visual.animar_voando()
		return true
	else:
		_log("Linha %d: %s falhou (Borda atingida ou estado inválido)" % [num_linha, nome_cmd])
		var esta_voando = (drone.estado_voo == Drone.EstadoVoo.EM_VOO)
		await cenario.drone_visual.animar_batida(esta_voando)
		return false

func _falha(motivo: String, linha: int) -> bool:
	_log("Linha %d: Falha -> %s" % [linha, motivo])
	return false
