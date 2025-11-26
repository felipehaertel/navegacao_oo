extends Agente
class_name AgenteDecorator

# O Decorator deve conter uma referência ao componente que está decorando.
# Esta referência NÃO DEVE ser declarada como "Agente" para evitar o conflito de nome.
var componente_decorado: Agente

# O _init aqui agora se alinha melhor com a Godot
func _init(agente_componente: Agente):
	# O construtor da classe base (Agente) é chamado automaticamente.
	
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
