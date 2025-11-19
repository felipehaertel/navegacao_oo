extends RefCounted
class_name PontoCaminhoFactory

# ID da fábrica, útil para logs ou switch de comportamento
var factory_id: String

func _init(id: String):
	factory_id = id

# Método de fábrica abstrato: Deve ser implementado por fábricas concretas.
func criar_origem(coord: Vector2i) -> PontoCaminho:
	push_error("Método 'criar_origem' deve ser implementado por uma Fábrica Concreta.")
	return null

# Método de fábrica abstrato: Deve ser implementado por fábricas concretas.
func criar_destino(coord: Vector2i) -> PontoCaminho:
	push_error("Método 'criar_destino' deve ser implementado por uma Fábrica Concreta.")
	return null
