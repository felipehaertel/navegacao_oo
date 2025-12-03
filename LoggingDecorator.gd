extends RefCounted
class_name LoggingDecorator

const Agente = preload("res://Agente.gd")

# Implementa a interface do Agente (Duck Typing)
var component: Agente
var dados_custo_computacional: Array 

func _init(agente: Agente, dados: Array):
	component = agente
	dados_custo_computacional = dados
	
	# Armazena os dados iniciais do planejamento (A*), decorando o Agente
	component.id = component.id # Garante que o ID está no Decorator
	
	var distancia_euclidiana = component.origem.distance_to(component.destino)
	
	# Armazena a métrica de custo computacional/geometria inicial
	dados_custo_computacional.append({
		"agente_id": component.id,
		"tempo_ms": Time.get_ticks_msec(), # Placeholder: deve ser preenchido após o A* real
		"passos": component.caminho_a_seguir.size(),
		"distancia": distancia_euclidiana,
		"origem": component.origem,
		"destino": component.destino
	})

# Encaminha chamadas importantes para o Agente (Componente)
# No caso do Command Pattern, o Agente real é passado como Receiver,
# então o Decorator foca principalmente na coleta de dados (logging).

# Getter para o Agente (importante para o GridAStar acessar as propriedades)
func get_component() -> Agente:
	return component
