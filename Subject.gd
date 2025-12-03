extends RefCounted
class_name Subject

var observers: Array = []

func attach(observer: Object):
	if not observer in observers:
		observers.append(observer)

func detach(observer: Object):
	if observer in observers:
		observers.erase(observer)

func notify(event_data: Dictionary):
	notify_with_subject(self, event_data)

# Método usado para Composição/Delegation
func notify_with_subject(subject_instance: Object, event_data: Dictionary):
	for observer in observers:
		observer.update(subject_instance, event_data)
