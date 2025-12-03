extends Observer
class_name AgentLifecycleObserver

# Importa a classe Agente (para constantes de evento)
const Agente = preload("res://Agente.gd")
const Observer = preload("res://Observer.gd")

# Referência à cena principal (GridAStar.gd) para executar ações
var parent_node: Node2D 

func _init(parent: Node2D):
	parent_node = parent

func update(subject: Object, event_data: Dictionary):
	# O 'subject' é o objeto Agente real.
	var agent: Agente = subject
	
	if event_data.has("event_type"):
		match event_data.event_type:
			Agente.EVENT_DESTINATION_REACHED:
				print("Observer: Agente ", agent.id, " atingiu o destino. Recriando.")
				# Chama o método de recriação no GridAStar
				parent_node.recreate_agent(agent)
			Agente.EVENT_PATH_BLOCKED:
				print("Observer: Agente ", agent.id, " bloqueado. Tentando recalcular...")
