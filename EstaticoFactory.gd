extends PontoCaminhoFactory
class_name EstaticoFactory

const OrigemEstatica = preload("res://OrigemEstatica.gd")
const DestinoEstatico = preload("res://DestinoEstatico.gd")

func _init():
	super._init("EstaticoFactory")
	
func criar_origem(coord: Vector2i) -> PontoCaminho:
	return OrigemEstatica.new(coord, factory_id)

func criar_destino(coord: Vector2i) -> PontoCaminho:
	return DestinoEstatico.new(coord, factory_id)
