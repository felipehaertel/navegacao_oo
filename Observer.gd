extends RefCounted
class_name Observer

# Importa a classe Subject
const Subject = preload("res://Subject.gd")

# Método a ser implementado por observadores concretos
func update(subject: Object, event_data: Dictionary):
	push_error("Método 'update' não implementado no Observer base.")
