extends RefCounted
# Responsável por criar instâncias de Agente, calcular suas rotas
# e armazenar métricas de desempenho.

const Agente = preload("res://Agente.gd") # Certifique-se de que o caminho está correto
const No = preload("res://No.gd") # Certifique-se de que o caminho está correto
const PontoCaminho = preload("res://PontoCaminho.gd")

var agente_contador: int = 0
var grid_instancia: Node2D # Referência ao script principal (GridAStar.gd) para acesso ao grid e A*

func _init(grid_ref: Node2D):
	grid_instancia = grid_ref
	
# Método Factory principal atualizado para aceitar PontoCaminho
func criar_agente(origem_ponto: PontoCaminho, destino_ponto: PontoCaminho, tamanho_celula: int, dados_custo_computacional: Array) -> Agente:
	
	# Obtém as coordenadas atuais dos Pontos de Caminho (importante para destinos dinâmicos)
	var origem: Vector2i = origem_ponto.get_posicao_atual()
	var destino: Vector2i = destino_ponto.get_posicao_atual()
	
	var caminho_encontrado: Array = []
	var tempo_gasto_ms: float = 0.0

	# 1. Medir o tempo de cálculo da rota usando o método A* do grid_instancia
	var tempo_inicio = Time.get_ticks_usec()
	caminho_encontrado = grid_instancia.encontrar_caminho_para(origem, destino)
	var tempo_fim = Time.get_ticks_usec()
	tempo_gasto_ms = (tempo_fim - tempo_inicio) / 1000.0 # Tempo em milissegundos
	
	if caminho_encontrado.is_empty():
		return null # Rota falhou, não cria o agente

	# 2. Incrementa o ID e cria o Agente
	agente_contador += 1
	var novo_agente = Agente.new(origem, agente_contador, tamanho_celula)
	novo_agente.set_caminho(caminho_encontrado)
	
	# 3. Armazena os dados de desempenho (passado como referência)
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
		
	return novo_agente
