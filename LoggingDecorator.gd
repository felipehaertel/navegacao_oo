extends AgenteDecorator
class_name LoggingDecorator

# A classe base AgenteDecorator já resolve a herança de Agente,
# então não precisamos de preloads aqui.

func _init(agente_componente: Agente):
	# Chamada obrigatória para o construtor da classe base (AgenteDecorator).
	# Isso inicializa 'self.componente_decorado'
	super._init(agente_componente)

func mover(delta: float):
	# Usa a propriedade renomeada 'componente_decorado' da classe base AgenteDecorator
	var movimento_anterior = componente_decorado.posicao_grid
	
	# Chama o método original do componente (delega através do AgenteDecorator base)
	var em_movimento = super.mover(delta) 
	
	if em_movimento and componente_decorado.posicao_grid != movimento_anterior:
		# Log extra para cada movimento de célula
		print("[LOG/DECORATOR] Agente #%d movendo de %s para %s" % [componente_decorado.id, movimento_anterior, componente_decorado.posicao_grid])
	elif not em_movimento and not componente_decorado.caminho_a_seguir.is_empty():
		print("[LOG/DECORATOR] Agente #%d PAROU no destino: %s" % [componente_decorado.id, componente_decorado.posicao_grid])
		
	return em_movimento
