extends RefCounted
# Representa um agente que se move pelo grid.

var id: int
var posicao_grid: Vector2i # Coordenada atual do Agente (Origem)
var caminho_a_seguir: Array = [] # Lista de Vector2i (os passos)
var indice_passo: int = 0      # Índice do caminho_a_seguir
var velocidade: float = 4.0   # Velocidade de movimento (células por segundo)
var posicao_pixel_atual: Vector2 # Posição real em pixels para movimento suave
var tamanho_celula: int # Propriedade para calcular posições de pixel

func _init(origem: Vector2i, novo_id: int, celula_size: int):
	id = novo_id
	posicao_grid = origem
	tamanho_celula = celula_size
	
	# Ajusta a posição de pixels inicial para o centro da célula
	posicao_pixel_atual = Vector2(origem) * tamanho_celula + Vector2(tamanho_celula / 2.0, tamanho_celula / 2.0)
	
func set_caminho(caminho: Array):
	caminho_a_seguir = caminho
	indice_passo = 0
	
# Método de movimento (mover_agente do script principal)
func mover(delta: float):
	if caminho_a_seguir.is_empty():
		return false # Agente terminou o movimento ou não tem caminho
	
	var proxima_coord = caminho_a_seguir[indice_passo]
	
	var centro_proximo_passo = Vector2(proxima_coord) * tamanho_celula + Vector2(tamanho_celula / 2.0, tamanho_celula / 2.0)
	
	var distancia_a_percorrer = velocidade * tamanho_celula * delta
	
	var vetor_movimento = (centro_proximo_passo - posicao_pixel_atual).normalized() * distancia_a_percorrer
	
	if posicao_pixel_atual.distance_to(centro_proximo_passo) <= vetor_movimento.length():
		posicao_pixel_atual = centro_proximo_passo
		indice_passo += 1
		
		# Verifica se o caminho terminou
		if indice_passo >= caminho_a_seguir.size():
			caminho_a_seguir.clear()
			indice_passo = 0
			posicao_grid = proxima_coord
			return false # Movimento concluído
		else:
			posicao_grid = proxima_coord
			return true # Movimento em progresso
	else:
		posicao_pixel_atual += vetor_movimento
		return true # Movimento em progresso
