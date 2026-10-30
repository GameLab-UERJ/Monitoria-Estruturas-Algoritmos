class_name EditorCodigo
extends PanelContainer

signal codigo_enviado(texto: String)

@onready var campo_texto: TextEdit = $VBoxContainer/CodeEdit
@onready var console_saida: RichTextLabel = $VBoxContainer/RichTextLabel

func _on_btn_executar_pressed() -> void:
	var codigo = campo_texto.text
	if codigo.strip_edges() == "":
		exibir_no_console("[color=red]Erro: O editor está vazio.[/color]")
		return
		
	# Dispara o sinal que o JogoPrincipal está ouvindo
	codigo_enviado.emit(codigo)

func exibir_no_console(mensagem: String) -> void:
	console_saida.append_text("\n" + mensagem)
