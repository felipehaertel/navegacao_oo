extends Node2D

# Importa as classes
const Agente = preload("res://Agente.gd")
const AgenteFactory = preload("res://AgenteFactory.gd")
const No = preload("res://No.gd")
# Singleton
const GridManager = preload("res://GridManager.gd")
# Abstract Factory
const EstaticoFactory = preload("res://EstaticoFactory.gd") 
const PontoCaminho = preload("res://PontoCaminho.gd") 
# Adapter (Finder)
const NeighborFinder = preload("res://NeighborFinder.gd")
const RectangularFinder = preload("res://RectangularFinder.gd")
const HorizontalVerticalFinder = preload("res://HorizontalVerticalFinder.gd")
# Chain of Responsibility
const InitializerHandler = preload("res://InitializerHandler.gd")
const GridInitializationHandler = preload("res://GridInitializationHandler.gd")
const FactoryInitializationHandler = preload("res://FactoryInitializationHandler.gd")
# Command
const CommandHistory = preload("res://CommandHistory.gd")
const MoveAgentCommand = preload("res://MoveAgentCommand.gd")
# Observer 
const AgentLifecycleObserver = preload("res://AgentLifecycleObserver.gd")

@export var tamanho_celula: int = 64
@export var cor_linha: Color = Color.GRAY
@export var cor_ocupada: Color = Color.WHITE
@export var cor_origem: Color = Color.BLUE
@export var cor_destino: Color = Color.GREEN
@export var espessura_linha: float = 1.0
@export var margem_simbolo: float = 4.0

var pares_clicados: Array = [] 
var proximo_clique_e_origem: bool = true

var agentes: Array = [] # Contém Agentes Decorados (LoggingDecorator)
var dados_custo_computacional: Array = [] 

var resolucao_tela_x: int = 0
var resolucao_tela_y: int = 0

# Instâncias injetadas pelo Chain of Responsibility
var grid_manager: GridManager 
var ponto_caminho_factory: EstaticoFactory 
var agente_factory: AgenteFactory
var neighbor_finder: NeighborFinder 

# Command Pattern
var command_history: CommandHistory = CommandHistory.new()
var is_undo_mode: bool = false # Estado para desfazer

func _ready():
	var viewport_size = get_viewport_rect().size
	resolucao_tela_x = int(viewport_size.x)
	resolucao_tela_y = int(viewport_size.y)
	
	# --- CHAIN OF RESPONSIBILITY (CoR) ---
	var context: Dictionary = {}
	
	var grid_handler = GridInitializationHandler.new(viewport_size, tamanho_celula)
	var factory_handler = FactoryInitializationHandler.new(self) # Passa 'self' para o Observer

	# Monta a cadeia: Grid -> Factories
	grid_handler.set_next(factory_handler)
	
	if grid_handler.run(context):
		print("CoR: Inicialização do Sistema concluída com sucesso.")
		# Injeta as instâncias no GridAStar
		grid_manager = context.get("grid_manager")
		agente_factory = context.get("agent_factory")
		neighbor_finder = context.get("neighbor_finder")
		ponto_caminho_factory = context.get("path_point_factory")
	else:
		push_error("CoR: Falha na inicialização do sistema.")
		return
	
	# Configurações de input
	print("Pressione [F] para alternar entre busca de 4 e 8 direções (ADAPTER).")
	print("Pressione [A] para gerar agentes aleatórios.")
	print("Pressione [SPACE] para ativar os agentes clicados.")
	print("Pressione [U] para desfazer a última ação de movimento (COMMAND).")
	
	randomize()
	queue_redraw() 

# --- COMMAND: Executa a fila de comandos de movimento ---
func _process(delta):
	if is_undo_mode:
		return # Não processa movimento normal se estiver desfazendo

	var deve_redesenhar = false
	var current_time = Time.get_ticks_msec() # Usando timestamp

	# 1. Cria um MoveAgentCommand para cada agente
	for agente_decorado in agentes:
		# O Agente/LoggingDecorator é o Receiver
		var agente_component: Agente = agente_decorado.component # Acessa o Agente real
		
		if agente_component.step_index < agente_component.caminho_a_seguir.size():
			
			# Cria e armazena o comando para execução (e potencial undo)
			# O Receiver é o componente Agente (o objeto que realmente move)
			var command = MoveAgentCommand.new(agente_component, delta, current_time)
			command_history.add_command(command)
			
			# 2. Executa o comando (chama agent.move_receiver(delta))
			if command.execute():
				deve_redesenhar = true
		else:
			# Limpa o histórico de comandos para agentes parados (opcional, dependendo da necessidade de undo)
			pass 

	if deve_redesenhar:
		queue_redraw()

func _input(event):
	if event.is_action_pressed("change_finder"): 
		# Lógica para alternar o Adapter
		if neighbor_finder is RectangularFinder:
			neighbor_finder = HorizontalVerticalFinder.new(grid_manager)
			print("Adaptador trocado para: Horizontal/Vertical (4 direções).")
		else:
			neighbor_finder = RectangularFinder.new(grid_manager)
			print("Adaptador trocado para: Retangular (8 direções).")
			
		agente_factory.neighbor_finder = neighbor_finder
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("undo_move"): 
		if not command_history.history.is_empty():
			is_undo_mode = true
			command_history.undo_last()
			is_undo_mode = false
			queue_redraw()
		else:
			print("Histórico de comandos vazio.")
		get_viewport().set_input_as_handled()
		
	if event.is_action_pressed("iniciar_lote"): 
		print("--- Ativando Agentes em Lote (Lote de pontos) ---")
		ativar_agentes_em_lote()
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("gerar_aleatorios"):
		print("--- Gerando Agentes Aleatórios ---")
		gerar_agentes_aleatorios(randi_range(3, 8))
		get_viewport().set_input_as_handled()

func pixel_para_grid_coord(posicao_pixel: Vector2) -> Vector2i:
	var grid_x = floor(posicao_pixel.x / tamanho_celula)
	var grid_y = floor(posicao_pixel.y / tamanho_celula)
	return Vector2i(grid_x, grid_y)

func _unhandled_input(event):
	# Usa as propriedades do Singleton
	var num_celulas_x = grid_manager.num_celulas_x
	var num_celulas_y = grid_manager.num_celulas_y
	
	var mouse_pos = get_global_mouse_position() 
	var grid_coord = pixel_para_grid_coord(mouse_pos)
	var x = grid_coord.x
	var y = grid_coord.y

	if not (x >= 0 and x < num_celulas_x and y >= 0 and y < num_celulas_y):
		return
	
	if event is InputEventMouseButton and event.pressed:
		
		var estado_atual = grid_manager.get_estado_celula(grid_coord)
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Singleton: Altera o estado do grid
			var novo_estado = GridManager.ESTADO_OCUPADO if estado_atual == GridManager.ESTADO_LIVRE else GridManager.ESTADO_LIVRE
			grid_manager.set_estado_celula(grid_coord, novo_estado)
			
			# Lógica de remoção de O/D
			for i in range(pares_clicados.size() - 1, -1, -1):
				var ponto: PontoCaminho = pares_clicados[i]
				if ponto.get_posicao_atual() == grid_coord:
					print("Removendo ponto de O/D de célula ocupada.")
					pares_clicados.remove_at(i)
					proximo_clique_e_origem = pares_clicados.size() % 2 == 0 
					
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# Abstract Factory: Cria o Ponto de Caminho
			if estado_atual == GridManager.ESTADO_OCUPADO:
				print("Não é possível definir Origem/Destino em um obstáculo.")
				return
				
			var novo_ponto: PontoCaminho
			
			if proximo_clique_e_origem:
				novo_ponto = ponto_caminho_factory.criar_origem(grid_coord)
				print("Origem %d definida em: %s (Próximo: Destino)" % [pares_clicados.size() / 2 + 1, grid_coord])
			else:
				novo_ponto = ponto_caminho_factory.criar_destino(grid_coord)
				print("Destino %d definido em: %s (Próximo: Origem)" % [pares_clicados.size() / 2, grid_coord])

			pares_clicados.append(novo_ponto)
			proximo_clique_e_origem = not proximo_clique_e_origem
		
		queue_redraw()
		get_viewport().set_input_as_handled()
		
func _draw():
	# Usa as propriedades do Singleton
	var num_celulas_x = grid_manager.num_celulas_x
	var num_celulas_y = grid_manager.num_celulas_y
	
	# Desenho do Grid
	for x in range(num_celulas_x + 1):
		var inicio = Vector2(x * tamanho_celula, 0)
		var fim = Vector2(x * tamanho_celula, num_celulas_y * tamanho_celula) 
		draw_line(inicio, fim, cor_linha, espessura_linha)

	for y in range(num_celulas_y + 1):
		var inicio = Vector2(0, y * tamanho_celula)
		var fim = Vector2(num_celulas_x * tamanho_celula, y * tamanho_celula)
		draw_line(inicio, fim, cor_linha, espessura_linha)
		
	# Desenho de Obstáculos (obtidos do Singleton)
	for y in range(num_celulas_y):
		for x in range(num_celulas_x):
			if grid_manager.get_estado_celula(Vector2i(x, y)) == GridManager.ESTADO_OCUPADO:
				var rect = Rect2(x * tamanho_celula, y * tamanho_celula, tamanho_celula, tamanho_celula)
				draw_rect(rect, cor_ocupada)
				
	# Desenho de Pares Clicados e Agentes (restante do código...)
	for i in range(pares_clicados.size()):
		var ponto: PontoCaminho = pares_clicados[i]
		var coord = ponto.get_posicao_atual()
		var cor: Color
		
		if i % 2 == 0: 
			cor = cor_origem
		else:
			cor = cor_destino
			
		desenhar_celula_especial(coord, cor)
		
	var cor_caminho: Color = Color.YELLOW
	var metade_celula = Vector2(tamanho_celula / 2.0, tamanho_celula / 2.0)
	var raio_agente: float = tamanho_celula / 3.0
	
	for agente_decorado in agentes:
		# Acessa o componente Agente real
		var agente: Agente = agente_decorado.component 
		
		# Agente é o Componente, mas suas propriedades de posição/caminho são acessíveis.
		if agente.caminho_a_seguir.size() > 0:
			var ponto_anterior: Vector2 = Vector2(agente.posicao_grid) * tamanho_celula + metade_celula
			
			for i in range(agente.step_index, agente.caminho_a_seguir.size()):
				var ponto_atual: Vector2 = Vector2(agente.caminho_a_seguir[i]) * tamanho_celula + metade_celula
				draw_line(ponto_anterior, ponto_atual, cor_caminho, 3.0, true)
				ponto_anterior = ponto_atual
				
		draw_circle(agente.posicao_pixel_atual, raio_agente, Color.from_hsv(agente.id * 0.1, 0.8, 1.0))
		
func desenhar_celula_especial(coord: Vector2i, cor: Color):
	var x = coord.x
	var y = coord.y
	
	var rect = Rect2(x * tamanho_celula, y * tamanho_celula, tamanho_celula, tamanho_celula)
	var rect_menor = rect.grow(-margem_simbolo)
	draw_rect(rect_menor, cor)
	
func calcular_heuristica(a: Vector2i, b: Vector2i) -> float:
	return a.distance_to(b)

# Renomeado para uso interno e pelo AgenteFactory
func find_path_for_agent(start: Vector2i, target: Vector2i, finder: NeighborFinder) -> Array:
	
	if start == target:
		return []

	var open_list: Array = [] 
	var closed_list: Array = [] 
	var node_map: Dictionary = {} 

	var origin_node = No.new(start)
	origin_node.g_custo = 0.0
	origin_node.h_custo = calcular_heuristica(start, target)
	origin_node.f_custo = origin_node.h_custo
	open_list.append(origin_node)
	node_map[start] = origin_node

	while not open_list.is_empty():
		var current: No = find_lowest_f_cost(open_list)
		
		if current == null: 
			break
			
		open_list.erase(current)
		closed_list.append(current)
		
		if current.coord == target:
			return reconstruct_path(current)

		# CHAMA O ADAPTER (Finder) para obter os vizinhos e o custo
		var neighbors_coords = finder.get_neighbors(current.coord)
		
		for neighbor_coord in neighbors_coords:
			
			# Obtém o custo do movimento do Adapter
			var movement_cost = finder.get_movement_cost(current.coord, neighbor_coord) 
			
			if movement_cost == INF:
				continue
				
			var neighbor_node: No
			
			if not node_map.has(neighbor_coord):
				neighbor_node = No.new(neighbor_coord)
				node_map[neighbor_coord] = neighbor_node
			else:
				neighbor_node = node_map[neighbor_coord]

			if neighbor_node in closed_list:
				continue

			var new_g_cost = current.g_custo + movement_cost

			if new_g_cost < neighbor_node.g_custo or neighbor_node.g_custo == INF:
				neighbor_node.g_custo = new_g_cost
				neighbor_node.h_custo = calcular_heuristica(neighbor_coord, target)
				neighbor_node.f_custo = neighbor_node.g_custo + neighbor_node.h_custo
				neighbor_node.pai = current
				
				if not neighbor_node in open_list:
					open_list.append(neighbor_node)

	return []

func find_lowest_f_cost(open_list: Array) -> No:
	# Encontra o nó com menor custo F na lista aberta
	var lowest_f = INF
	var best_node = null
	
	for no in open_list:
		if no is No and no.f_custo < lowest_f:
			lowest_f = no.f_custo
			best_node = no
	
	return best_node

func reconstruct_path(destination_node: No) -> Array:
	# Reconstrói o caminho
	var reverse_path: Array = []
	var current = destination_node
	
	while current != null:
		reverse_path.append(current.coord)
		current = current.pai
	
	reverse_path.reverse()
	if reverse_path.size() > 0:
		reverse_path.remove_at(0) 
		
	return reverse_path

func criar_e_ativar_agente(origem_ponto: PontoCaminho, destino_ponto: PontoCaminho) -> bool:
	
	# Passa os pontos para a Fábrica (que aplica o Decorator e usa o Observer/Adapter)
	# O agente_factory.criar_agente retorna LoggingDecorator
	var novo_agente_decorado = agente_factory.criar_agente(origem_ponto, destino_ponto, dados_custo_computacional)
	
	if novo_agente_decorado != null:
		agentes.append(novo_agente_decorado)
		return true
	else:
		print("Não foi possível encontrar uma rota de %s para %s. Agente não criado." % [origem_ponto.get_posicao_atual(), destino_ponto.get_posicao_atual()])
		return false

# --- OBSERVER: Lógica chamada pelo AgentLifecycleObserver ---
func recreate_agent(agent_component: Agente):
	# 1. Remove o agente da lista (LoggingDecorator)
	var agent_to_remove = null
	for agent_decorated in agentes:
		if agent_decorated.component == agent_component:
			agent_to_remove = agent_decorated
			break
	
	if agent_to_remove:
		agentes.erase(agent_to_remove)
	
	# 2. Recria um novo agente a partir da origem antiga (para simular recriação)
	var new_origem = ponto_caminho_factory.criar_origem(agent_component.origem)
	var new_destino = ponto_caminho_factory.criar_destino(agent_component.destino)
	
	criar_e_ativar_agente(new_origem, new_destino)
	
	# Força o redesenho imediato
	queue_redraw()

func ativar_agentes_em_lote():
	if pares_clicados.size() % 2 != 0:
		print("Erro: Clique em um ponto de Destino para completar o último par.")
		return
	
	if pares_clicados.is_empty():
		print("Nenhuma Origem/Destino definido para criar agentes.")
		return
		
	for i in range(0, pares_clicados.size(), 2):
		var origem_ponto: PontoCaminho = pares_clicados[i]
		var destino_ponto: PontoCaminho = pares_clicados[i+1]

		criar_e_ativar_agente(origem_ponto, destino_ponto)

	pares_clicados.clear()
	proximo_clique_e_origem = true
	queue_redraw()

func gerar_agentes_aleatorios(quantidade: int):
	# Limpa todos os agentes e o histórico de comandos para começar limpo
	agentes.clear() 
	command_history.history.clear() 
	
	var origem_aleatoria: Vector2i 
	var destino_aleatoria: Vector2i 
	
	for i in range(quantidade):
		
		var tentativas = 0
		while tentativas < 100:
			origem_aleatoria = Vector2i(randi_range(0, grid_manager.num_celulas_x - 1), randi_range(0, grid_manager.num_celulas_y - 1))
			destino_aleatoria = Vector2i(randi_range(0, grid_manager.num_celulas_x - 1), randi_range(0, grid_manager.num_celulas_y - 1))
			
			var estado_origem = grid_manager.get_estado_celula(origem_aleatoria)
			var estado_destino = grid_manager.get_estado_celula(destino_aleatoria)
			
			if estado_origem == GridManager.ESTADO_LIVRE and estado_destino == GridManager.ESTADO_LIVRE and origem_aleatoria != destino_aleatoria:
				
				var origem_ponto = ponto_caminho_factory.criar_origem(origem_aleatoria)
				var destino_ponto = ponto_caminho_factory.criar_destino(destino_aleatoria)
				
				if criar_e_ativar_agente(origem_ponto, destino_ponto):
					break
					
			tentativas += 1
		
		if tentativas == 100:
			print("Alerta: Não foi possível gerar o Agente #%d com rota válida." % (i + 1))
	
	randomize()

func exportar_dados_csv():
	if dados_custo_computacional.is_empty():
		print("Nenhum dado para exportar.")
		return
		
	var nome_arquivo = "user://dados_custo_a_star.csv"
	var arquivo = FileAccess.open(nome_arquivo, FileAccess.WRITE) 
	
	if arquivo == null:
		print("ERRO: Não foi possível abrir o arquivo para escrita. Verifique permissões ou caminho.")
		return
	
	var cabecalho = "Agente_ID;Tempo_ms;Passos_Rota;Distancia_Reta;Origem_X;Origem_Y;Destino_X;Destino_Y\n"
	arquivo.store_string(cabecalho)
	
	for dado in dados_custo_computacional:
		var linha_csv = "%d;%.4f;%d;%.4f;%d;%d;%d;%d\n" % [
			dado.agente_id,
			dado.tempo_ms,
			dado.passos,
			dado.distancia,
			dado.origem.x,
			dado.origem.y,
			dado.destino.x,
			dado.destino.y
		]
		arquivo.store_string(linha_csv)
		
	arquivo.close()
	print("Dados exportados com sucesso para: ", nome_arquivo)
