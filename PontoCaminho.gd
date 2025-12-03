extends RefCounted
class_name PontoCaminho

var posicao: Vector2i

func _init(p: Vector2i):
	posicao = p

func get_posicao_atual() -> Vector2i:
	return posicao
