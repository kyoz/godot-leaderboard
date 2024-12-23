extends Node

signal on_error(error_code)
signal on_completed()

var leaderboard = null


# Change this to _ready() if you want automatically init
func init():
	if Engine.has_singleton("Leaderboard"):
		leaderboard = Engine.get_singleton("Leaderboard")
		init_signals()


func init_signals():
	leaderboard.connect("error", self, "_on_error")
	leaderboard.connect("completed", self, "_on_completed")


func _on_error(error_code):
	emit_signal("on_error", error_code)


func _on_completed():
	emit_signal("on_completed")


func show():
	if not leaderboard:
		not_found_plugin()
		return
	
	leaderboard.show()
	

func not_found_plugin():
	print('[Leaderboard] Not found plugin. Please ensure that you checked Leaderboard plugin in the export template')
