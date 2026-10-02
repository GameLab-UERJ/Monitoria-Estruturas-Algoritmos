extends Node
class_name GerenciadorDeFases

static var missao_atual: int = 1

# --- ESTATÍSTICAS DINÂMICAS DA EXECUÇÃO ATUAL ---
var plantas_plantadas: Dictionary = {}
var plantas_coletadas: Dictionary = {}

var sementes_no_inventario: int = 0
var erros_cometidos: int = 0 
var qtd_repeat_usados: int = 0 

var passos: int = 0
var obj_passos: int = 15 

var obj_sim: bool = false

@onready var objetivo_label = $"../CanvasLayer/PromptdeComando/Hud/Estagio e objetivo/ObjetivoLabel"
@onready var estagio_label = $"../CanvasLayer/PromptdeComando/Hud/Estagio e objetivo/EstágioLabel"
@onready var passos_bar = $"../CanvasLayer/PromptdeComando/Hud/contador de passos/PassoBar"
@onready var frutas_bar = $"../CanvasLayer/PromptdeComando/Hud/Plantas/FrutaBar"

@onready var progresso_label = $"../CanvasLayer/ProgressoLabel"

func _ready():
	configurar_missao()

func configurar_missao():
	obj_sim = false
	plantas_plantadas.clear()
	plantas_coletadas.clear()
	sementes_no_inventario = 0
	erros_cometidos = 0
	qtd_repeat_usados = 0
	passos = 0
	
	var caminho = "res://missions/Missão " + str(missao_atual) + ".json"
	if FileAccess.file_exists(caminho):
		var arquivo = FileAccess.open(caminho, FileAccess.READ)
		var dados = JSON.parse_string(arquivo.get_as_text())
		arquivo.close()
		obj_passos = dados.get("objetivo_passos", 15)
		sementes_no_inventario = dados.get("objetivo_frutas", 0)
		
	estagio_label.text = "Missão " + str(missao_atual)
	
	if passos_bar:
		passos_bar.max_value = obj_passos
		passos_bar.value = 0
		
	if frutas_bar:
		frutas_bar.max_value = sementes_no_inventario
		frutas_bar.value = 0
	
	match missao_atual:
		1: objetivo_label.text = "Plante 2 vermelhas. Limite: " + str(obj_passos) + " passos."
		2: objetivo_label.text = "Plante 2 azuis, colete 1 amarela. Limite: " + str(obj_passos) + " passos."
		3: objetivo_label.text = "Plante 3 vermelhas, 2 azuis. Limite: " + str(obj_passos) + " passos."
		4: objetivo_label.text = "Plante 3 vermelhas, 3 azuis, colete 2 amarelas."
		5: objetivo_label.text = "Use 'repeat'. Plante a linha vermelha e zere o inventário."
		6: objetivo_label.text = "Use 2 'repeats'. Plante faixa vermelha e azul."
		7: objetivo_label.text = "Operação Autônoma. Use 'repeat' na rota."
		
	atualizar_texto_progresso()

# --- FUNÇÃO QUE DESENHA O TEXTO NA TELA DINAMICAMENTE ---
func atualizar_texto_progresso():
	if progresso_label:
		var txt = "--- Status do Drone ---\n"
		txt += "Passos: " + str(passos) + " / " + str(obj_passos) + "\n"
		
		# Lê o dicionário de plantadas e cria o texto dinamicamente (ex: "1 Roxa | 2 Laranjas")
		if plantas_plantadas.size() > 0:
			var textos_plantadas = []
			for cor in plantas_plantadas.keys():
				textos_plantadas.append(str(plantas_plantadas[cor]) + " " + cor.capitalize())
			txt += "Plantadas: " + " | ".join(textos_plantadas) + "\n"
			
		# Lê o dicionário de coletadas da mesma forma
		if plantas_coletadas.size() > 0:
			var textos_coletadas = []
			for cor in plantas_coletadas.keys():
				textos_coletadas.append(str(plantas_coletadas[cor]) + " " + cor.capitalize())
			txt += "Coletadas: " + " | ".join(textos_coletadas) + "\n"
			
		txt += "Sementes Restantes: " + str(sementes_no_inventario)
		
		if erros_cometidos > 0:
			txt += "\nErros cometidos: " + str(erros_cometidos)
			
		progresso_label.text = txt

# --- FUNÇÕES DE REGISTRO DINÂMICAS ---
func add_passo():
	passos += 1
	if passos_bar:
		passos_bar.value = passos
	atualizar_texto_progresso()

func registrar_plantio(cor: String):
	# Se a cor já existe no dicionário, soma +1. Se não, cria com valor 1.
	plantas_plantadas[cor] = plantas_plantadas.get(cor, 0) + 1
	sementes_no_inventario -= 1
	
	if frutas_bar:
		var total_plantado = 0
		for qtd in plantas_plantadas.values(): 
			total_plantado += qtd
		frutas_bar.value = total_plantado
		
	atualizar_texto_progresso()

func registrar_coleta(cor: String):
	plantas_coletadas[cor] = plantas_coletadas.get(cor, 0) + 1
	atualizar_texto_progresso()

func registrar_erro():
	erros_cometidos += 1
	atualizar_texto_progresso()

func registrar_uso_comandos(repeats: int):
	qtd_repeat_usados = repeats

# --- VALIDAÇÃO FINAL (Verifica as chaves específicas que as missões pedem) ---
func validar_missao_fim_de_execucao():
	if obj_sim: return
	if passos > obj_passos: return
	
	# Extraímos as quantidades específicas que as regras do GDD testam
	var p_verm = plantas_plantadas.get("vermelha", 0)
	var p_azul = plantas_plantadas.get("azul", 0)
	var c_amar = plantas_coletadas.get("amarela", 0)
	
	var sucesso = false
	
	match missao_atual:
		1: sucesso = (p_verm == 2 and p_azul == 0 )
		2: sucesso = (p_azul == 2 and c_amar == 1 )
		3: sucesso = (p_verm == 3 and p_azul == 2 and sementes_no_inventario == 0 )
		4: sucesso = (p_verm == 3 and p_azul == 3 and c_amar == 2 )
		5: sucesso = (p_verm > 0 and qtd_repeat_usados == 1 and sementes_no_inventario == 0 )
		6: sucesso = (p_verm > 0 and p_azul > 0 and qtd_repeat_usados == 2 and sementes_no_inventario == 0)
		7: sucesso = (qtd_repeat_usados >= 1 and sementes_no_inventario == 0 and  p_verm > 0 and p_azul > 0 and c_amar > 0)
			
	if sucesso:
		objetivo_label.text = "Missão concluída com sucesso!"
		obj_sim = true
		await get_tree().create_timer(4.0).timeout
		avancar_missao()

func avancar_missao():
	if missao_atual < 7:
		missao_atual += 1
		get_tree().reload_current_scene() 
	else:
		objetivo_label.text = "Certificação completa!"
