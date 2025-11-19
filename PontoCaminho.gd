extends RefCounted
class_name PontoCaminho

# Variável principal que armazena a posição, ou a posição alvo, do ponto.
var coordenada: Vector2i

# O ID da fábrica que o criou, para referência.
var factory_id: String

func _init(coord: Vector2i, id: String):
	coordenada = coord
	factory_id = id
	
# Método obrigatório que define se o ponto é fixo ou dinâmico
func is_estatico() -> bool:
	return true
	
# Método obrigatório para retornar a posição atual do ponto.
func get_posicao_atual() -> Vector2i:
	return coordenada
	
# Método que pode ser sobrescrito por Destinos Dinâmicos (não usado no Estático)
func atualizar_posicao(delta: float):
	pass
