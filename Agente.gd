extends RefCounted
class_name Agente

# Importa as classes necessárias
const Subject = preload("res://Subject.gd")
const GridManager = preload("res://GridManager.gd")

# Constantes para eventos
const EVENT_DESTINATION_REACHED = "DESTINATION_REACHED"
const EVENT_PATH_BLOCKED = "PATH_BLOCKED"

# --- Propriedades de Agente ---
var id: int = 0
var velocidade: float = 200.0
var tempo_percorrido: float = 0.0
var origem: Vector2i
var destino: Vector2i
var posicao_grid: Vector2i
var posicao_pixel_atual: Vector2
# Tipagem estrita
var caminho_a_seguir: Array[Vector2i] = []
var step_index: int = 0
var grid_manager: GridManager 
var cell_size: int

# Instância do Subject para Composition (Composição)
var subject_notifier: Subject = Subject.new()

# --- Interface Subject (Delegada para o Subject real) ---
func attach(observer: Object):
	subject_notifier.attach(observer)

func detach(observer: Object):
	subject_notifier.detach(observer)

func notify(event_data: Dictionary):
	# Notifica, passando 'self' (o Agente) como o objeto que mudou.
	subject_notifier.notify_with_subject(self, event_data)
# -------------------------------------------------------

# Tipando o parâmetro 'path' como Array para resolver a inconsistência de tipo.
func _init(i: int, o: Vector2i, d: Vector2i, path: Array, manager: Object, c_size: int):
	id = i
	origem = o
	destino = d
	
	caminho_a_seguir = [] 
	for coord in path:
		caminho_a_seguir.append(coord as Vector2i) # Garante que cada elemento seja Vector2i
	
	grid_manager = manager
	cell_size = c_size
	
	posicao_grid = origem
	posicao_pixel_atual = Vector2(origem) * cell_size + Vector2(cell_size / 2.0, cell_size / 2.0)
	step_index = 0
	
# --- Receiver Method (Chamado pelo MoveAgentCommand) ---
func move_receiver(delta: float) -> bool:
	if caminho_a_seguir.is_empty() or step_index >= caminho_a_seguir.size():
		if step_index >= caminho_a_seguir.size():
			notify({"event_type": EVENT_DESTINATION_REACHED, "agent_id": id})
			return false
		return false

	var target_grid_coord: Vector2i = caminho_a_seguir[step_index]
	var target_pixel_pos: Vector2 = Vector2(target_grid_coord) * cell_size + Vector2(cell_size / 2.0, cell_size / 2.0)
	
	var distancia_passo = posicao_pixel_atual.distance_to(target_pixel_pos)
	var passo_maximo = velocidade * delta
	
	if distancia_passo <= passo_maximo:
		posicao_pixel_atual = target_pixel_pos
		posicao_grid = target_grid_coord
		step_index += 1
		
		if step_index < caminho_a_seguir.size():
			var next_coord = caminho_a_seguir[step_index]
			if not grid_manager.is_valid_coord(next_coord) or grid_manager.get_estado_celula(next_coord) == 1:
				notify({"event_type": EVENT_PATH_BLOCKED, "agent_id": id})
				return false
				
		return true
	else:
		posicao_pixel_atual = posicao_pixel_atual.move_toward(target_pixel_pos, passo_maximo)
		return true
