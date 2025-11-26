extends RefCounted
class_name Agente

# Componente principal para o Padrão Decorator.
# O método 'mover' deve ser o método comum implementado por todos os Decorators.

var id: int
var posicao_grid: Vector2i 
var caminho_a_seguir: Array = [] 
var indice_passo: int = 0      
var velocidade: float = 4.0   
var posicao_pixel_atual: Vector2 
var tamanho_celula: int 

func _init(origem: Vector2i, novo_id: int, celula_size: int):
	id = novo_id
	posicao_grid = origem
	tamanho_celula = celula_size
	
	posicao_pixel_atual = Vector2(origem) * tamanho_celula + Vector2(tamanho_celula / 2.0, tamanho_celula / 2.0)
	
func set_caminho(caminho: Array):
	caminho_a_seguir = caminho
	indice_passo = 0
	
# Método COMPONENTE PRINCIPAL
func mover(delta: float):
	if caminho_a_seguir.is_empty() or indice_passo >= caminho_a_seguir.size():
		return false 
	
	var proxima_coord = caminho_a_seguir[indice_passo]
	
	var centro_proximo_passo = Vector2(proxima_coord) * tamanho_celula + Vector2(tamanho_celula / 2.0, tamanho_celula / 2.0)
	
	var distancia_a_percorrer = velocidade * tamanho_celula * delta
	
	var vetor_movimento = (centro_proximo_passo - posicao_pixel_atual).normalized() * distancia_a_percorrer
	
	if posicao_pixel_atual.distance_to(centro_proximo_passo) <= vetor_movimento.length():
		posicao_pixel_atual = centro_proximo_passo
		indice_passo += 1
		posicao_grid = proxima_coord
		
		if indice_passo >= caminho_a_seguir.size():
			caminho_a_seguir.clear()
			indice_passo = 0
			return false 
		else:
			return true 
	else:
		posicao_pixel_atual += vetor_movimento
		return true
