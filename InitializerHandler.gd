extends RefCounted
class_name InitializerHandler

var next_handler: InitializerHandler = null

# Adicionado construtor explícito para que as classes filhas possam chamar super._init()
func _init():
	pass

# Define o próximo Handler na cadeia
func set_next(handler: InitializerHandler) -> InitializerHandler:
	next_handler = handler
	return handler

# Método principal para processar a inicialização. Deve ser sobrescrito.
func handle_initialization(context: Dictionary) -> bool:
	push_error("Método 'handle_initialization' não implementado.")
	return false

# Método de execução que chama o próximo na cadeia
func run(context: Dictionary) -> bool:
	if handle_initialization(context):
		if next_handler:
			return next_handler.run(context)
		return true # Fim da cadeia e sucesso
	return false # Falha na inicialização
