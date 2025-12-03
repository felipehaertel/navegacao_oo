extends Agente
class_name AgenteDecorator

var componente_decorado: Agente

func _init(agente_componente: Agente):
	
	# Armazena a referência ao componente
	self.componente_decorado = agente_componente
	
	# Copia as propriedades (necessário se estendermos RefCounted)
	if agente_componente:
		self.id = agente_componente.id
		self.posicao_grid = agente_componente.posicao_grid
		self.caminho_a_seguir = agente_componente.caminho_a_seguir
		self.indice_passo = agente_componente.indice_passo
		self.velocidade = agente_componente.velocidade
		self.posicao_pixel_atual = agente_componente.posicao_pixel_atual
		self.tamanho_celula = agente_componente.tamanho_celula

func set_caminho(caminho: Array):
	componente_decorado.set_caminho(caminho)

# Método de delegação principal: Chama o método do componente.
# Este é o método que os Decorators sobrescrevem.
func mover(delta: float):
	# Delega a chamada ao componente decorado
	return componente_decorado.mover(delta)
