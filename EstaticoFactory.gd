extends RefCounted
class_name EstaticoFactory

const PontoCaminho = preload("res://PontoCaminho.gd")

func criar_origem(pos: Vector2i) -> PontoCaminho:
	print("Factory: Criando Ponto de Origem em ", pos)
	return PontoCaminho.new(pos)

func criar_destino(pos: Vector2i) -> PontoCaminho:
	print("Factory: Criando Ponto de Destino em ", pos)
	return PontoCaminho.new(pos)
