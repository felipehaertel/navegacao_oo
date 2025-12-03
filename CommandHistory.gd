extends RefCounted
class_name CommandHistory

# Importa a classe Command base
const Command = preload("res://Command.gd")

var history: Array[Command] = []
var max_history_size: int = 100

func add_command(command: Command):
	history.append(command)
	if history.size() > max_history_size:
		history.remove_at(0)

func execute_last() -> bool:
	if history.is_empty():
		return false
	var command: Command = history.back()
	return command.execute()

func undo_last():
	if history.is_empty():
		return
	var command: Command = history.pop_back()
	command.unexecute()
	print("Undo: Comando desfeito.")
