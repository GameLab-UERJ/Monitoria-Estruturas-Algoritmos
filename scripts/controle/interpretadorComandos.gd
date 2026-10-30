class_name InterpretadorComandos
extends RefCounted

signal execucao_concluida
signal linha_executada(numero_linha: int, mensagem: String)
var velocidade_multiplicador: float = 1.0 # 1.0x (normal), 2.0x (rápido), 4.0x (muito rápido)

var drone: Drone
var cenario: Node2D
var editor: CodeEdit
var console: TextEdit
var executando: bool = false
var pausado: bool = false

# Armazena a linha onde a execução parou devido a um erro (inicia na linha 0)
var linha_progresso: int = 0

func _init(p_drone: Drone, p_cenario: Node2D, p_editor: CodeEdit, p_console: TextEdit) -> void:
	drone = p_drone
	cenario = p_cenario
	editor = p_editor
	console = p_console



## Avalia a condição booleana do loop
func _avaliar_condicao(condicao: String) -> bool:
	match condicao:
		"True": return true
		"False": return false
		"tem_agua()":
			if drone.has_method("tem_agua"):
				return drone.tem_agua()
			return false
	
	_log("[ERRO] Condição desconhecida: %s" % condicao)
	return false

## Conta quantos 'Tabs' existem no início da linha para determinar o escopo (bloco)
func _contar_tabs(linha: String) -> int:
	var abas = 0
	for i in range(linha.length()):
		if linha[i] == '\t':
			abas += 1
		else:
			break
	return abas

## Controles de Interface
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
		
		
		
## O novo motor de execução com suporte a 'while' e blocos indentados
func executar_codigo(codigo: String) -> void:
	executando = true
	pausado = false
	var linhas = codigo.split("\n")
	
	if linha_progresso >= linhas.size():
		linha_progresso = 0
		
	if linha_progresso == 0:
		_limpar_highlights(linhas.size())
		_log("[INFO] Iniciando execução...")
	
	var i = linha_progresso
	var ocorreu_erro = false
	
	while i < linhas.size() and executando:
		# Bloqueio de Pausa (O interpretador fica aguardando aqui enquanto estiver pausado)
		while pausado and executando:
			await cenario.get_tree().process_frame
			
		if not executando:
			break # Sai do loop principal se o botão Parar for clicado
			
		var linha_bruta = linhas[i]
		var linha_limpa = _limpar_linha(linha_bruta)
		
		if linha_limpa.is_empty():
			i += 1
			continue
			
		# ==========================================
		# DETECÇÃO DO COMANDO 'WHILE'
		# ==========================================
		if linha_limpa.begins_with("while") and linha_limpa.ends_with(":"):
			var condicao = linha_limpa.replace("while", "").replace(":", "").strip_edges()
			var indentacao_base = _contar_tabs(linha_bruta)
			
			# 1. Coleta todas as linhas subsequentes que formam o bloco do while (têm mais Tabs)
			var bloco = []
			var j = i + 1
			while j < linhas.size():
				var l_bruta = linhas[j]
				if _limpar_linha(l_bruta).is_empty():
					j += 1; continue
					
				if _contar_tabs(l_bruta) > indentacao_base:
					bloco.append({ "texto": _limpar_linha(l_bruta), "linha_real": j })
					j += 1
				else:
					break # Encontrou uma linha fora da indentação, encerra a coleta do bloco
					
			# 2. Executa o bloco inteiro em loop enquanto a condição for verdadeira
			var erro_no_loop = false
			while _avaliar_condicao(condicao) and executando:
				for cmd in bloco:
					# Checagem de pausa dentro do loop
					while pausado and executando: await cenario.get_tree().process_frame
					if not executando: break
					
					_limpar_highlights(linhas.size())
					editor.set_line_background_color(cmd.linha_real, Color(1.0, 0.85, 0.2, 0.35))
					
					var sucesso = await _interpretar_instrucao(cmd.texto, cmd.linha_real + 1)
					if not sucesso:
						editor.set_line_background_color(cmd.linha_real, Color(1.0, 0.2, 0.2, 0.4))
						_log("[ERRO] Falha dentro do loop na linha %d." % [cmd.linha_real + 1])
						erro_no_loop = true
						executando = false
						# Se falhar no loop, na próxima execução reinicia na linha do próprio 'while'
						linha_progresso = i 
						break
						
					cenario.atualizar_posicao_drone()
					await cenario.get_tree().create_timer(0.6 / velocidade_multiplicador).timeout
					
				if erro_no_loop or not executando:
					break # Quebra o while principal
					
			# 3. Pula o índice de leitura para fora do bloco após o while terminar
			i = j
			if erro_no_loop:
				execucao_concluida.emit()
				return
			continue

		# ==========================================
		# EXECUÇÃO NORMAL (COMANDOS FORA DE BLOCOS)
		# ==========================================
		_limpar_highlights(linhas.size())
		editor.set_line_background_color(i, Color(1.0, 0.85, 0.2, 0.35))
		
		var sucesso = await _interpretar_instrucao(linha_limpa, i + 1)
		if not sucesso:
			editor.set_line_background_color(i, Color(1.0, 0.2, 0.2, 0.4))
			_log("[ERRO] Execução pausada na linha %d." % [i + 1])
			linha_progresso = i
			executando = false
			cenario.atualizar_posicao_drone()
			execucao_concluida.emit()
			return
			
		cenario.atualizar_posicao_drone()
		await cenario.get_tree().create_timer(0.6 / velocidade_multiplicador).timeout
		i += 1
		
	# Finalização suave
	if executando: # Se não foi interrompido por erro ou botão parar
		linha_progresso = 0
		_limpar_highlights(linhas.size())
		_log("[FIM] Execução concluída!")
	
	executando = false
	execucao_concluida.emit()

## Alterna entre as velocidades: 1.0x -> 2.0x -> 4.0x -> volta para 1.0x
func alternar_velocidade() -> float:
	if velocidade_multiplicador == 1.0:
		velocidade_multiplicador = 2.0
	elif velocidade_multiplicador == 2.0:
		velocidade_multiplicador = 4.0
	else:
		velocidade_multiplicador = 1.0
	
	return velocidade_multiplicador

func _interpretar_instrucao(comando: String, num_linha: int) -> bool:
	match comando:
		"decolar()":
			if drone.decolar():
				_log("Linha %d: decolar() -> Sucesso" % num_linha)
				await cenario.drone_visual.animar_decolagem()
				return true
			else:
				_log("Linha %d: Falha ao decolar" % num_linha)
				return false
				
		"pousar()":
			if drone.pousar():
				_log("Linha %d: pousar() -> Sucesso" % num_linha)
				await cenario.drone_visual.animar_pouso()
				return true
			else:
				_log("Linha %d: Falha ao pousar" % num_linha)
				return false
				
		"mover_cima()":
			return await _executar_movimento_com_animacao(drone.mover_cima(), "mover_cima()", num_linha)
			
		"mover_baixo()":
			return await _executar_movimento_com_animacao(drone.mover_baixo(), "mover_baixo()", num_linha)
			
		"mover_esquerda()":
			return await _executar_movimento_com_animacao(drone.mover_esquerda(), "mover_esquerda()", num_linha)
			
		"mover_direita()":
			return await _executar_movimento_com_animacao(drone.mover_direita(), "mover_direita()", num_linha)
			
		"irrigar()":
			if not drone.has_method("irrigar"):
				_log("Linha %d: Falha -> Drone não possui a ferramenta de irrigação." % num_linha)
				return false
				
			# Validações detalhadas para mensagens de erro claras
			if drone.estado_voo != Drone.EstadoVoo.EM_VOO:
				_log("Linha %d: Falha ao irrigar -> O drone precisa estar voando!" % num_linha)
				return false
				
			if "agua_atual" in drone and drone.agua_atual <= 0:
				_log("Linha %d: Falha ao irrigar -> Reservatório de água vazio (0/%d)!" % [num_linha, drone.capacidade_agua])
				return false
				
			if drone.bateria < 5:
				_log("Linha %d: Falha ao irrigar -> Bateria insuficiente!" % num_linha)
				return false
				
			if drone.irrigar():
				_log("Linha %d: irrigar() -> Solo irrigado com sucesso! (Água restante: %d)" % [num_linha, drone.agua_atual])
				cenario.atualizar_visual_terreno_irrigado(drone.posicao)
				cenario.atualizar_telemetria_geral() # Atualiza o HUD na hora
				return true
			else:
				_log("Linha %d: Falha desconhecida ao irrigar." % num_linha)
				return false
				
		_:
			_log("Linha %d: Comando desconhecido: '%s'" % [num_linha, comando])
			return false

func _executar_movimento_com_animacao(resultado: bool, nome_cmd: String, num_linha: int) -> bool:
	if resultado:
		_log("Linha %d: %s -> Sucesso" % [num_linha, nome_cmd])
		cenario.drone_visual.animar_voando()
		return true
	else:
		_log("Linha %d: %s falhou (Borda atingida ou estado inválido)" % [num_linha, nome_cmd])
		
		# Verifica o estado lógico do drone (se está em voo) e passa como argumento (true/false)
		var esta_voando = (drone.estado_voo == Drone.EstadoVoo.EM_VOO)
		await cenario.drone_visual.animar_batida(esta_voando)
		
		return false

func _limpar_linha(linha: String) -> String:
	var pos_comentario = linha.find("#")
	if pos_comentario != -1:
		linha = linha.substr(0, pos_comentario)
	return linha.strip_edges()

func _limpar_highlights(total_linhas: int) -> void:
	for j in range(total_linhas):
		editor.set_line_background_color(j, Color(0, 0, 0, 0))

func _log(mensagem: String) -> void:
	console.text += mensagem + "\n"
	console.set_caret_line(console.get_line_count())
