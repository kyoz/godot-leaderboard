extends Node


func _ready():
	Leaderboard.init()
	
	var _o = Leaderboard.connect("on_completed", self, "_on_completed")
	var _o2 = Leaderboard.connect("on_error", self, "_on_error")


func _on_error(error_code):
	print("Leaderboard failed with error: " + error_code)


func _on_completed():
	print("Leaderboard Completed")


func _on_Button_pressed():
	Leaderboard.show()
