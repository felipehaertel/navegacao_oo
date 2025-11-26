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

@export var tamanho_celula: int = 64
@export var cor_linha: Color = Color.GRAY
@export var cor_ocupada: Color = Color.WHITE
@export var cor_origem: Color = Color.BLUE
@export var cor_destino: Color = Color.GREEN
@export var espessura_linha: float = 1.0
@export var margem_simbolo: float = 4.0

var pares_clicados: Array = [] 
var proximo_clique_e_origem: bool = true

var agentes: Array = [] 
var dados_custo_computacional: Array = [] 

var resolucao_tela_x: int = 0
var resolucao_tela_y: int = 0

var grid_manager: GridManager # Instância do Singleton (GridManager)
var ponto_caminho_factory: EstaticoFactory 
var agente_factory: AgenteFactory
var neighbor_finder: NeighborFinder # Instância do Adapter

func _ready():
	var viewport_size = get_viewport_rect().size
	resolucao_tela_x = int(viewport_size.x)
	resolucao_tela_y = int(viewport_size.y)
	
	# 1. SINGLETON: Inicializa o GridManager
	# Criamos o Singleton aqui, garantindo que seja único para o projeto.
	grid_manager = GridManager.new()
	var num_celulas_x = int(resolucao_tela_x / tamanho_celula)
	var num_celulas_y = int(resolucao_tela_y / tamanho_celula)
	grid_manager.inicializar_grid(num_celulas_x, num_celulas_y, tamanho_celula)
	
	# 2. ADAPTER: Inicializa o Adaptador padrão (8 direções)
	neighbor_finder = RectangularFinder.new(grid_manager) 
	
	# 3. ABSTRACT FACTORY: Inicializa a Fábrica Concreta para pontos estáticos
	ponto_caminho_factory = EstaticoFactory.new()
	
	# 4. FACTORY: Inicializa o AgenteFactory, passando o Singleton e o Adapter
	agente_factory = AgenteFactory.new(self, grid_manager, neighbor_finder)
	
	# Configura a ação 'change_finder'
	# Se ainda não estiver configurado no Godot:
	# Project -> Project Settings -> Input Map -> Crie 'change_finder' e atribua a tecla F
	print("Pressione [F] para alternar entre busca de 4 e 8 direções (ADAPTER).")
	queue_redraw() 

func _process(delta):
	var deve_redesenhar = false
	
	for agente in agentes:
		# Chama o método mover() do Decorator, que por sua vez chama o Agente Component
		if agente.mover(delta):
			deve_redesenhar = true
			
	if deve_redesenhar:
		queue_redraw()

# Adiciona um input handler para a tecla F para trocar o Adapter em tempo de execução
func _input(event):
	if event.is_action_pressed("change_finder"): 
		if neighbor_finder is RectangularFinder:
			neighbor_finder = HorizontalVerticalFinder.new(grid_manager)
			print("Adaptador trocado para: Horizontal/Vertical (4 direções).")
		else:
			neighbor_finder = RectangularFinder.new(grid_manager)
			print("Adaptador trocado para: Retangular (8 direções).")
			
		# Atualiza a referência na fábrica para que os NOVOS agentes usem o novo Adapter
		agente_factory.neighbor_finder = neighbor_finder
		get_viewport().set_input_as_handled()
		
	if event.is_action_pressed("ui_accept"): 
		print("--- Ativando Agentes em Lote (Lote de pontos) ---")
		ativar_agentes_em_lote()
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("gerar_aleatorios"):
		print("--- Gerando Agentes Aleatórios (Ação 'gerar_aleatorios') ---")
		# Gera entre 3 e 8 agentes aleatórios
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
	
	for agente in agentes:
		# Agente é o Decorator, mas suas propriedades de posição/caminho são acessíveis.
		if agente.caminho_a_seguir.size() > 0:
			var ponto_anterior: Vector2 = Vector2(agente.posicao_grid) * tamanho_celula + metade_celula
			
			for i in range(agente.indice_passo, agente.caminho_a_seguir.size()):
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

# A* agora recebe o Adaptador (NeighborFinder) para se tornar flexível
func encontrar_caminho_para(inicio: Vector2i, fim: Vector2i, finder: NeighborFinder) -> Array:
	
	if inicio == fim:
		return []

	var lista_aberta: Array = [] 
	var lista_fechada: Array = [] 
	var no_mapa: Dictionary = {} 

	var no_origem = No.new(inicio)
	no_origem.g_custo = 0.0
	no_origem.h_custo = calcular_heuristica(inicio, fim)
	no_origem.f_custo = no_origem.h_custo
	lista_aberta.append(no_origem)
	no_mapa[inicio] = no_origem

	while not lista_aberta.is_empty():
		var atual: No = encontrar_menor_custo_f(lista_aberta)
		
		if atual == null: 
			break
			
		lista_aberta.erase(atual)
		lista_fechada.append(atual)
		
		if atual.coord == fim:
			return recriar_caminho(atual)

		# CHAMA O ADAPTER (Finder) para obter os vizinhos e o custo
		var vizinhos_coords = finder.get_neighbors(atual.coord)
		
		for vizinho_coord in vizinhos_coords:
			
			# Obtém o custo do movimento do Adapter (pode ser 1.0, 1.414, ou INF para proibido)
			var custo_movimento = finder.get_movement_cost(atual.coord, vizinho_coord) 
			
			# Se o custo for INF, a rota é inválida para este Finder (ex: diagonal no 4-finder)
			if custo_movimento == INF:
				continue
				
			var no_vizinho: No
			
			if not no_mapa.has(vizinho_coord):
				no_vizinho = No.new(vizinho_coord)
				no_mapa[vizinho_coord] = no_vizinho
			else:
				no_vizinho = no_mapa[vizinho_coord]

			if no_vizinho in lista_fechada:
				continue

			var novo_g_custo = atual.g_custo + custo_movimento

			if novo_g_custo < no_vizinho.g_custo or no_vizinho.g_custo == INF:
				no_vizinho.g_custo = novo_g_custo
				no_vizinho.h_custo = calcular_heuristica(vizinho_coord, fim)
				no_vizinho.f_custo = no_vizinho.g_custo + no_vizinho.h_custo
				no_vizinho.pai = atual
				
				if not no_vizinho in lista_aberta:
					lista_aberta.append(no_vizinho)

	return []

func encontrar_menor_custo_f(lista_aberta: Array) -> No:
	# Encontra o nó com menor custo F na lista aberta
	var menor_f = INF
	var melhor_no = null
	
	for no in lista_aberta:
		if no is No and no.f_custo < menor_f:
			menor_f = no.f_custo
			melhor_no = no
	
	return melhor_no

func recriar_caminho(no_destino: No) -> Array:
	# Reconstrói o caminho
	var caminho_reverso: Array = []
	var atual = no_destino
	
	while atual != null:
		caminho_reverso.append(atual.coord)
		atual = atual.pai
	
	caminho_reverso.reverse()
	if caminho_reverso.size() > 0:
		caminho_reverso.remove_at(0) 
		
	return caminho_reverso

func criar_e_ativar_agente(origem_ponto: PontoCaminho, destino_ponto: PontoCaminho) -> bool:
	
	# Passa os pontos para a Fábrica (que aplica o Decorator e usa o Adapter)
	var novo_agente = agente_factory.criar_agente(origem_ponto, destino_ponto, dados_custo_computacional)
	
	if novo_agente != null:
		agentes.append(novo_agente)
		return true
	else:
		print("Não foi possível encontrar uma rota de %s para %s. Agente não criado." % [origem_ponto.get_posicao_atual(), destino_ponto.get_posicao_atual()])
		return false

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
	agentes.clear() 
	
	# Corrigido: Declaração das variáveis no escopo da função
	var origem_aleatoria: Vector2i 
	var destino_aleatoria: Vector2i # Corrigida a grafia para 'destino_aleatoria'
	
	for i in range(quantidade):
		
		var tentativas = 0
		while tentativas < 100:
			origem_aleatoria = Vector2i(randi_range(0, grid_manager.num_celulas_x - 1), randi_range(0, grid_manager.num_celulas_y - 1))
			destino_aleatoria = Vector2i(randi_range(0, grid_manager.num_celulas_x - 1), randi_range(0, grid_manager.num_celulas_y - 1))
			
			var estado_origem = grid_manager.get_estado_celula(origem_aleatoria)
			var estado_destino = grid_manager.get_estado_celula(destino_aleatoria)
			
			# Condição para validação
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
