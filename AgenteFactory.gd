extends RefCounted
# Responsável por criar instâncias de Agente, calcular suas rotas, 
# aplicar Decorators e armazenar métricas de desempenho.

# Preloads corrigidos
const Agente = preload("res://Agente.gd") 
const No = preload("res://No.gd") 
const PontoCaminho = preload("res://PontoCaminho.gd")
const GridManager = preload("res://GridManager.gd")
const NeighborFinder = preload("res://NeighborFinder.gd") # Importa a interface do Adapter
const LoggingDecorator = preload("res://LoggingDecorator.gd") 

var agente_contador: int = 0
var grid_instancia: Node2D # Referência à cena principal (para redraw)
var grid_manager: GridManager 
var neighbor_finder: NeighborFinder # O Adapter (pode ser Retangular ou Horizontal/Vertical)

func _init(grid_ref: Node2D, manager: GridManager, finder: NeighborFinder):
	grid_instancia = grid_ref
	grid_manager = manager
	neighbor_finder = finder
	
# O método A* é chamado a partir da cena principal, que usa o Adaptador atual.
func criar_agente(origem_ponto: PontoCaminho, destino_ponto: PontoCaminho, dados_custo_computacional: Array) -> Agente:
	
	var origem: Vector2i = origem_ponto.get_posicao_atual()
	var destino: Vector2i = destino_ponto.get_posicao_atual()
	
	var caminho_encontrado: Array = []
	var tempo_gasto_ms: float = 0.0

	# 1. Medir o tempo de cálculo da rota usando o Adapter atual
	var tempo_inicio = Time.get_ticks_usec()
	# Passa o 'neighbor_finder' atual para o A*
	caminho_encontrado = grid_instancia.encontrar_caminho_para(origem, destino, neighbor_finder)
	var tempo_fim = Time.get_ticks_usec()
	tempo_gasto_ms = (tempo_fim - tempo_inicio) / 1000.0 
	
	if caminho_encontrado.is_empty():
		return null 

	# 2. Cria o Agente COMPONENTE
	agente_contador += 1
	var novo_agente = Agente.new(origem, agente_contador, grid_manager.tamanho_celula)
	novo_agente.set_caminho(caminho_encontrado)
	
	# 3. Aplica o DECORATOR
	# Nota: Se o LoggingDecorator não for encontrado, ele causará erro aqui.
	var agente_decorado = LoggingDecorator.new(novo_agente)
	
	# 4. Armazena os dados de desempenho
	var dados_do_teste = {
		"agente_id": agente_contador,
		"tempo_ms": tempo_gasto_ms,
		"passos": caminho_encontrado.size(),
		"distancia": origem.distance_to(destino),
		"origem": origem,
		"destino": destino
	}
	dados_custo_computacional.append(dados_do_teste)
	
	print("Agente #%d criado (O: %s -> D: %s). Rota com %d passos. Tempo: %.2fms" % 
		[agente_contador, origem, destino, caminho_encontrado.size(), tempo_gasto_ms])
		
	return agente_decorado # Retorna o Agente Decorado
