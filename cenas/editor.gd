extends CodeEdit

func _ready() -> void:
	_configurar_syntax_highlighter()

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
