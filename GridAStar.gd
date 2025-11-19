extends Node2D

# Importa as classes separadas
const Agente = preload("res://Agente.gd")
const AgenteFactory = preload("res://AgenteFactory.gd")
const No = preload("res://No.gd")
# Importa a Fábrica Concreta de Origem/Destino
const EstaticoFactory = preload("res://EstaticoFactory.gd")
const PontoCaminho = preload("res://PontoCaminho.gd") # Para dicas de tipo

const ESTADO_LIVRE: int = 0
const ESTADO_OCUPADO: int = 1
const CUSTO_DIAGONAL: float = 1.414 
const CUSTO_RETO: float = 1.0

@export var tamanho_celula: int = 64
@export var cor_linha: Color = Color.GRAY
@export var cor_ocupada: Color = Color.WHITE
@export var cor_origem: Color = Color.BLUE
@export var cor_destino: Color = Color.GREEN
@export var espessura_linha: float = 1.0
@export var margem_simbolo: float = 4.0

# O array agora armazena instâncias de PontoCaminho, não apenas Vector2i
var pares_clicados: Array = [] # [Origem1, Destino1, Origem2, Destino2, ...]
var proximo_clique_e_origem: bool = true

var num_celulas_x: int = 0
var num_celulas_y: int = 0
var grid: Array = [] 
var agentes: Array = [] 
var dados_custo_computacional: Array = [] 

var resolucao_tela_x: int = 0
var resolucao_tela_y: int = 0

var agente_factory: AgenteFactory
# Nova variável para a Abstract Factory
var ponto_caminho_factory: EstaticoFactory # Usando a fábrica estática concreta

func _ready():
	var viewport_size = get_viewport_rect().size
	resolucao_tela_x = int(viewport_size.x)
	resolucao_tela_y = int(viewport_size.y)
	
	criar_grid()
	
	# Inicializa a Abstract Factory Concreta para pontos estáticos
	ponto_caminho_factory = EstaticoFactory.new()
	
	# Inicializa o AgenteFactory
	agente_factory = AgenteFactory.new(self) 
	
	queue_redraw() 

func criar_grid():
	num_celulas_x = int(resolucao_tela_x / tamanho_celula)
	num_celulas_y = int(resolucao_tela_y / tamanho_celula)
	
	grid.clear()
	for y in range(num_celulas_y):
		var linha: Array = []
		for x in range(num_celulas_x):
			linha.append(ESTADO_LIVRE) 
		grid.append(linha)

func _draw():
	# Desenho do Grid
	for x in range(num_celulas_x + 1):
		var inicio = Vector2(x * tamanho_celula, 0)
		var fim = Vector2(x * tamanho_celula, num_celulas_y * tamanho_celula) 
		draw_line(inicio, fim, cor_linha, espessura_linha)

	for y in range(num_celulas_y + 1):
		var inicio = Vector2(0, y * tamanho_celula)
		var fim = Vector2(num_celulas_x * tamanho_celula, y * tamanho_celula)
		draw_line(inicio, fim, cor_linha, espessura_linha)
		
	# Desenho de Obstáculos
	for y in range(num_celulas_y):
		for x in range(num_celulas_x):
			if grid[y][x] == ESTADO_OCUPADO:
				var rect = Rect2(x * tamanho_celula, y * tamanho_celula, tamanho_celula, tamanho_celula)
				draw_rect(rect, cor_ocupada)
				
	# Desenho de Pares Clicados (Origem/Destino)
	for i in range(pares_clicados.size()):
		var ponto: PontoCaminho = pares_clicados[i]
		var coord = ponto.get_posicao_atual() # Obtém a posição atual (fixa no caso Estático)
		var cor: Color
		
		if i % 2 == 0: # Índice 0, 2, 4... (Origem)
			cor = cor_origem
		else: # Índice 1, 3, 5... (Destino)
			cor = cor_destino
			
		desenhar_celula_especial(coord, cor)
		
	# Desenho de Agentes e Caminhos
	var cor_caminho: Color = Color.YELLOW
	var metade_celula = Vector2(tamanho_celula / 2.0, tamanho_celula / 2.0)
	var raio_agente: float = tamanho_celula / 3.0
	
	for agente in agentes:
		if agente.caminho_a_seguir.size() > 0:
			var ponto_anterior: Vector2 = Vector2(agente.posicao_grid) * tamanho_celula + metade_celula
			
			for i in range(agente.indice_passo, agente.caminho_a_seguir.size()):
				var ponto_atual: Vector2 = Vector2(agente.caminho_a_seguir[i]) * tamanho_celula + metade_celula
				draw_line(ponto_anterior, ponto_atual, cor_caminho, 3.0, true)
				ponto_anterior = ponto_atual
				
		# Cor do Agente baseada no ID (usando ID da Fábrica)
		draw_circle(agente.posicao_pixel_atual, raio_agente, Color.from_hsv(agente.id * 0.1, 0.8, 1.0))
						
func pixel_para_grid_coord(posicao_pixel: Vector2) -> Vector2i:
	var grid_x = floor(posicao_pixel.x / tamanho_celula)
	var grid_y = floor(posicao_pixel.y / tamanho_celula)
	return Vector2i(grid_x, grid_y)

func _unhandled_input(event):
	var mouse_pos = get_global_mouse_position() 
	var grid_coord = pixel_para_grid_coord(mouse_pos)
	var x = grid_coord.x
	var y = grid_coord.y

	if not (x >= 0 and x < num_celulas_x and y >= 0 and y < num_celulas_y):
		return
	
	if event is InputEventMouseButton and event.pressed:
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Lógica para cliques em células ocupadas
			grid[y][x] = ESTADO_OCUPADO if grid[y][x] == ESTADO_LIVRE else ESTADO_LIVRE
			
			# Lógica para remover Origem/Destino se o obstáculo for adicionado em cima
			for i in range(pares_clicados.size() - 1, -1, -1):
				var ponto: PontoCaminho = pares_clicados[i]
				if ponto.get_posicao_atual() == grid_coord:
					print("Removendo ponto de O/D de célula ocupada.")
					pares_clicados.remove_at(i)
					proximo_clique_e_origem = pares_clicados.size() % 2 == 0 # Ajusta o próximo clique
					
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# Adiciona o ponto usando a Abstract Factory
			if grid[y][x] == ESTADO_OCUPADO:
				print("Não é possível definir Origem/Destino em um obstáculo.")
				return
				
			var novo_ponto: PontoCaminho
			
			if proximo_clique_e_origem:
				# Cria uma Origem Estática
				novo_ponto = ponto_caminho_factory.criar_origem(grid_coord)
				print("Origem %d definida em: %s (Próximo: Destino)" % [pares_clicados.size() / 2 + 1, grid_coord])
			else:
				# Cria um Destino Estático
				novo_ponto = ponto_caminho_factory.criar_destino(grid_coord)
				print("Destino %d definido em: %s (Próximo: Origem)" % [pares_clicados.size() / 2, grid_coord])

			pares_clicados.append(novo_ponto)

			# Alterna o estado para o próximo clique
			proximo_clique_e_origem = not proximo_clique_e_origem
		
		queue_redraw()
		get_viewport().set_input_as_handled()
		
func desenhar_celula_especial(coord: Vector2i, cor: Color):
	var x = coord.x
	var y = coord.y
	
	var rect = Rect2(x * tamanho_celula, y * tamanho_celula, tamanho_celula, tamanho_celula)
	var rect_menor = rect.grow(-margem_simbolo)
	draw_rect(rect_menor, cor)
	
func calcular_heuristica(a: Vector2i, b: Vector2i) -> float:
	# Heurística de distância Euclidiana
	return a.distance_to(b)

func encontrar_menor_custo_f(lista_aberta: Array) -> No:
	# Encontra o nó com menor custo F na lista aberta (parte do A*)
	var menor_f = INF
	var melhor_no = null
	
	for no in lista_aberta:
		# Verifica se o nó é uma instância de No antes de acessar f_custo (para evitar erros)
		if no is No and no.f_custo < menor_f:
			menor_f = no.f_custo
			melhor_no = no
	
	return melhor_no

func recriar_caminho(no_destino: No) -> Array:
	# Reconstrói o caminho do nó destino para a origem (parte do A*)
	var caminho_reverso: Array = []
	var atual: No = no_destino
	
	while atual != null:
		caminho_reverso.append(atual.coord)
		atual = atual.pai
	
	caminho_reverso.reverse()
	if caminho_reverso.size() > 0:
		# Remove o nó de origem do caminho a ser seguido, já que o agente já está nele
		caminho_reverso.remove_at(0) 
		
	return caminho_reverso

func encontrar_caminho_para(inicio: Vector2i, fim: Vector2i) -> Array:
	# Implementação do algoritmo A* (busca de caminho)
	
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
		
		if atual == null: # Caso de erro ou lista aberta vazia
			break
			
		lista_aberta.erase(atual)
		lista_fechada.append(atual)
		
		if atual.coord == fim:
			var temp_caminho = recriar_caminho(atual)
			return temp_caminho

		for dx in range(-1, 2):
			for dy in range(-1, 2):
				if dx == 0 and dy == 0:
					continue 
				
				var vizinho_coord = atual.coord + Vector2i(dx, dy)
				
				# Checagem de limites
				if vizinho_coord.x < 0 or vizinho_coord.x >= num_celulas_x or \
				   vizinho_coord.y < 0 or vizinho_coord.y >= num_celulas_y:
					continue

				# Checagem de obstáculo
				if grid[vizinho_coord.y][vizinho_coord.x] == ESTADO_OCUPADO:
					continue
				
				var custo_movimento = CUSTO_RETO if dx == 0 or dy == 0 else CUSTO_DIAGONAL
				var no_vizinho: No
				
				# Lógica para reutilizar ou criar o nó
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

	# print("Caminho NÃO encontrado!")
	return []

# NOVO MÉTODO AUXILIAR que usa a Fábrica
func criar_e_ativar_agente(origem_ponto: PontoCaminho, destino_ponto: PontoCaminho) -> bool:
	
	# Delega a criação do agente e cálculo do caminho para a fábrica
	var novo_agente = agente_factory.criar_agente(origem_ponto, destino_ponto, tamanho_celula, dados_custo_computacional)
	
	if novo_agente != null:
		agentes.append(novo_agente)
		return true
	else:
		print("Não foi possível encontrar uma rota de %s para %s. Agente não criado." % [origem_ponto.get_posicao_atual(), destino_ponto.get_posicao_atual()])
		return false

func _process(delta):
	# Usa o método mover isolado na classe Agente
	for i in range(agentes.size() - 1, -1, -1):
		var agente = agentes[i]
		var em_movimento = agente.mover(delta)
		
		# Opcional: Remover agente se o movimento estiver concluído
		# if not em_movimento and agente.caminho_a_seguir.is_empty():
		# 	agentes.remove_at(i) 
	
	if agentes.size() > 0:
		queue_redraw()
		
	if Input.is_action_just_pressed("ui_accept"): 
		print("--- Ativando Agentes em Lote (SPACE) ---")
		ativar_agentes_em_lote()
		
	if Input.is_action_just_pressed("gerar_aleatorios"):
		print("--- Gerando Agentes Aleatórios (A) ---")
		gerar_agentes_aleatorios(randi_range(2, 10))
		
	if Input.is_action_just_pressed("exportar_dados"):
		exportar_dados_csv()

func ativar_agentes_em_lote():
	# Verifica se há um número ímpar de cliques (um par incompleto)
	if pares_clicados.size() % 2 != 0:
		print("Erro: Clique em um ponto de Destino para completar o último par.")
		return
	
	if pares_clicados.is_empty():
		print("Nenhuma Origem/Destino definido para criar agentes.")
		return
		
	# Processa os pares e cria os agentes
	for i in range(0, pares_clicados.size(), 2):
		var origem_ponto: PontoCaminho = pares_clicados[i]
		var destino_ponto: PontoCaminho = pares_clicados[i+1]

		# Usa o auxiliar que invoca a Fábrica
		criar_e_ativar_agente(origem_ponto, destino_ponto)

	# Limpa o estado após a criação
	pares_clicados.clear()
	proximo_clique_e_origem = true
	queue_redraw()

func gerar_agentes_aleatorios(quantidade: int):
	# Limpa agentes antigos para um novo teste
	agentes.clear() 
	# A fábrica é responsável por resetar o contador interno, mas podemos limpar o array global de dados
	# agente_factory.agente_contador = 0 # Isso pode ser feito dentro da fábrica se necessário, mas mantemos o controle aqui por simplicidade.
	
	for i in range(quantidade):
		var origem_aleatoria: Vector2i = Vector2i()
		var destino_aleatorio: Vector2i = Vector2i()
		
		var tentativas = 0
		while tentativas < 100:
			origem_aleatoria = Vector2i(randi_range(0, num_celulas_x - 1), randi_range(0, num_celulas_y - 1))
			destino_aleatorio = Vector2i(randi_range(0, num_celulas_x - 1), randi_range(0, num_celulas_y - 1))
			
			if grid[origem_aleatoria.y][origem_aleatoria.x] == ESTADO_LIVRE and \
			   grid[destino_aleatorio.y][destino_aleatorio.x] == ESTADO_LIVRE and \
			   origem_aleatoria != destino_aleatorio:
				
				# Usa a fábrica estática para criar os pontos temporários
				var origem_ponto = ponto_caminho_factory.criar_origem(origem_aleatoria)
				var destino_ponto = ponto_caminho_factory.criar_destino(destino_aleatorio)
				
				# A fábrica tenta criar o agente e só retorna true se o caminho for encontrado
				if criar_e_ativar_agente(origem_ponto, destino_ponto):
					break
					
			tentativas += 1
		
		if tentativas == 100:
			print("Alerta: Não foi possível gerar o Agente #%d com rota válida." % (i + 1))
	
	randomize()

func exportar_dados_csv():
	# Exporta os dados coletados pela Fábrica
	if dados_custo_computacional.is_empty():
		print("Nenhum dado para exportar.")
		return
		
	var nome_arquivo = "user://dados_custo_a_star.csv"
	var arquivo = FileAccess.open(nome_arquivo, FileAccess.WRITE) 
	
	if arquivo == null:
		print("ERRO: Não foi possível abrir o arquivo para escrita. Verifique permissões ou caminho.")
		return
	
	# Cabeçalho do CSV
	var cabecalho = "Agente_ID;Tempo_ms;Passos_Rota;Distancia_Reta;Origem_X;Origem_Y;Destino_X;Destino_Y\n"
	arquivo.store_string(cabecalho)
	
	# Escreve os dados
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
