extends RefCounted
# Representa um nó na busca A*.

var g_custo: float = INF   # Custo do início (Origem) até este nó.
var h_custo: float = 0.0   # Custo heurístico (estimativa) até o destino.
var f_custo: float = INF   # Custo total: F = G + H (F = G + H)
var coord: Vector2i        # Posição (x, y) no grid.
var pai = null         # O nó anterior no caminho.

func _init(c: Vector2i):
	coord = c
