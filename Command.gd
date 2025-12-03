extends RefCounted
class_name Command

# Receiver é o objeto que executa a lógica (ex: Agente)
var receiver: Object = null
var timestamp: float = 0.0

func _init(r: Object, time: float):
	receiver = r
	timestamp = time

func execute() -> bool:
	push_error("Método 'execute' não implementado.")
	return false

func unexecute():
	push_error("Método 'unexecute' não implementado.")
