extends Node


func _ready():
	pass
	Leaderboard.init()
	Leaderboard.on_completed.connect(_on_completed)
	Leaderboard.on_error.connect(_on_error)


func _on_error(error_code):
	print("Leaderboard failed with error: " + error_code)


func _on_completed():
	print("Leaderboard Completed")


func _on_button_pressed():
	Leaderboard.show()
