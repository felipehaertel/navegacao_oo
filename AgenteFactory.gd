extends RefCounted
class_name AgenteFactory

# Importa as classes
const Agente = preload("res://Agente.gd")
const LoggingDecorator = preload("res://LoggingDecorator.gd")
const Observer = preload("res://Observer.gd")
const GridManager = preload("res://GridManager.gd")
const NeighborFinder = preload("res://NeighborFinder.gd")
const PontoCaminho = preload("res://PontoCaminho.gd")

var parent_node: Node2D
var grid_manager: GridManager
var neighbor_finder: NeighborFinder # Adapter
var observer: Observer # Observer para ciclo de vida
var next_agent_id: int = 1

func _init(parent: Node2D, manager: GridManager, finder: NeighborFinder, obs: Observer):
	parent_node = parent
	grid_manager = manager
	neighbor_finder = finder
	observer = obs

func criar_agente(origem_ponto: PontoCaminho, destino_ponto: PontoCaminho, dados_custo_computacional: Array) -> LoggingDecorator:
	
	# Chamada para o método A* no GridAStar (parent_node)
	var caminho = parent_node.find_path_for_agent(origem_ponto.get_posicao_atual(), destino_ponto.get_posicao_atual(), neighbor_finder)
	
	if caminho.is_empty():
		return null

	var novo_agente = Agente.new(
		next_agent_id, 
		origem_ponto.get_posicao_atual(), 
		destino_ponto.get_posicao_atual(), 
		caminho, 
		grid_manager, 
		grid_manager.tamanho_celula
	)
	next_agent_id += 1
	
	# 1. OBSERVER: Anexa o Observer de ciclo de vida
	# O Agente é o Subject
	novo_agente.attach(observer)
	
	# 2. DECORATOR: Envolve o Agente com o Decorator de Logging
	var agente_decorado = LoggingDecorator.new(novo_agente, dados_custo_computacional)
	
	return agente_decorado
