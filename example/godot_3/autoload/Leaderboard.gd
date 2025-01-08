extends Node

signal on_authenticated(is_authenticated)
signal on_leaderboard_error(error_code)
signal on_leaderboard_event(event_code)
signal on_high_score_fetched(highscore)

var leaderboard: Object = null

var is_authenticated := false


# Change this to _ready() if you want automatically init
func init() -> void:
	if Engine.has_singleton("Leaderboard"):
		leaderboard = Engine.get_singleton("Leaderboard")
		init_signals()


func init_signals() -> void:
	var _s1 = leaderboard.connect("on_authenticated", self, "_on_authenticated")
	var _s2 = leaderboard.connect("on_leaderboard_error", self, "_on_leaderboard_error")
	var _s3 = leaderboard.connect("on_leaderboard_event", self, "_on_leaderboard_event")
	var _s4 = leaderboard.connect("on_high_score_fetched", self, "_on_high_score_fetched")


func _on_authenticated(is_authenticated):
	if is_authenticated == true:
		is_authenticated = true
	
	emit_signal("on_authenticated", is_authenticated)


func _on_leaderboard_error(error_code):
	emit_signal("on_leaderboard_error", error_code)
	print(error_code)


func _on_leaderboard_event(event_code):
	emit_signal("on_leaderboard_event", event_code)


func _on_high_score_fetched(highscore):
	if typeof(highscore) == TYPE_INT and highscore > 0:
		emit_signal("on_high_score_fetched", highscore)


func check_authenticated() -> bool:
	if not leaderboard:
		not_found_plugin()
		return false
	
	return leaderboard.check_authenticated()


func signIn() -> void:
	if not leaderboard:
		not_found_plugin()
		return
	
	leaderboard.signIn()


func fetchHighScore(leaderboard_id: String) -> void:
	if not leaderboard:
		not_found_plugin()
		return
	
	if not is_authenticated:
		return
	
	leaderboard.fetchHighScore(leaderboard_id)


func submitHighScore(leaderboard_id: String, score: int) -> void:
	if not leaderboard:
		not_found_plugin()
		return
	
	if not is_authenticated:
		return
	
	leaderboard.submitHighScore(leaderboard_id, score)


func show(leaderboard_id: String) -> void:
	if not leaderboard:
		not_found_plugin()
		return
	
	leaderboard.show(leaderboard_id)


func not_found_plugin() -> void:
	print('[Leaderboard] Not found plugin. Please ensure that you checked Rating plugin in the export template')
