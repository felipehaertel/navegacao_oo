extends Command
class_name MoveAgentCommand

# Importa a classe Agente
const Agente = preload("res://Agente.gd")

var delta: float
var original_pixel_pos: Vector2
var original_grid_pos: Vector2i
var original_step_index: int

func _init(r: Agente, d: float, time: float):
	super._init(r, time)
	delta = d

func execute() -> bool:
	var agent: Agente = receiver
	
	# Guarda o estado original para Unexecute
	original_pixel_pos = agent.posicao_pixel_atual
	original_grid_pos = agent.posicao_grid
	original_step_index = agent.step_index
	
	# Executa a ação real no Receiver (Agente)
	return agent.move_receiver(delta) 

func unexecute():
	var agent: Agente = receiver
	# Restaura o estado para desfazer
	agent.posicao_pixel_atual = original_pixel_pos
	agent.posicao_grid = original_grid_pos
	agent.step_index = original_step_index
	
	print("Undo: Agente ", agent.id, " retrocedeu para ", original_grid_pos)
