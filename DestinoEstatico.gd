extends PontoCaminho
class_name DestinoEstatico

# O Destino Estático é o alvo final, fixo.

func _init(coord: Vector2i, id: String):
	super._init(coord, id)
	
func is_estatico() -> bool:
	return true
