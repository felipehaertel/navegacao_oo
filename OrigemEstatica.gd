extends PontoCaminho
class_name OrigemEstatica

# A Origem Estática é apenas um ponto de partida fixo.

func _init(coord: Vector2i, id: String):
	super._init(coord, id)
	
func is_estatico() -> bool:
	return true
