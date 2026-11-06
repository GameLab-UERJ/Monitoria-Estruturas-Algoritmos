extends CodeEdit

func _ready() -> void:
	_configurar_syntax_highlighter()
	# Habilita o menu de sugestões nativo do CodeEdit
	code_completion_enabled = true
	
	# Conecta o sinal a este próprio script
	if not code_completion_requested.is_connected(_ao_pedir_autocompletar):
		code_completion_requested.connect(_ao_pedir_autocompletar)

func _configurar_syntax_highlighter() -> void:
	var highlighter = CodeHighlighter.new()
	
	highlighter.number_color = Color("#b5cea8")
	highlighter.symbol_color = Color("#d4d4d4")
	highlighter.function_color = Color("#dcdcaa")
	highlighter.member_variable_color = Color("#9cdcfe")
	
	highlighter.add_color_region("#", "", Color("#6a9955"), true)
	
	var keywords = ["if", "else", "elif", "while", "for", "in", "def", "return", "pass", "and", "or", "not"]
	for kw in keywords:
		highlighter.add_keyword_color(kw, Color("#c586c0"))
		
	var funcoes_drone = ["decolar", "pousar", "mover_cima", "mover_baixo", "mover_esquerda", "mover_direita"]
	for fn in funcoes_drone:
		highlighter.add_keyword_color(fn, Color("#4ec9b0"))
		
	self.syntax_highlighter = highlighter

## Preenche o menu suspenso de autocompletar (completar conforme criamos novos comandos)
func _ao_pedir_autocompletar() -> void:
	var comandos_disponiveis = [
		"decolar()", 
		"pousar()", 
		"mover_cima()", 
		"mover_baixo()", 
		"mover_esquerda()", 
		"mover_direita()", 
		"irrigar()",
		"tem_agua()",
		"while",
		"if"
	]
	
	# Limpa opções antigas caso existam para evitar duplicação
	for comando in comandos_disponiveis:
		# KIND_FUNCTION coloca um ícone padrão de "função" ao lado da sugestão
		add_code_completion_option(CodeEdit.KIND_FUNCTION, comando, comando)
		
	# Atualiza a interface e exibe o menu na tela
	update_code_completion_options(true)
