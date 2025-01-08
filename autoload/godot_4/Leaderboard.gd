extends Node

signal on_authenticated(is_authenticated: bool)
signal on_leaderboard_error(error_code: String)
signal on_leaderboard_event(event_code: String)
signal on_high_score_fetched(highscore: int)

var leaderboard: Object = null

var is_authenticated := false


# Change this to _ready() if you want automatically init
func init() -> void:
	if Engine.has_singleton("Leaderboard"):
		leaderboard = Engine.get_singleton("Leaderboard")
		init_signals()


func init_signals() -> void:
	leaderboard.on_authenticated.connect(func(_is_authenticated: bool) -> void:
		if _is_authenticated == true:
			is_authenticated = true
		
		on_authenticated.emit(is_authenticated)
	)
	leaderboard.on_leaderboard_error.connect(func(error_code: String) -> void:
		on_leaderboard_error.emit(error_code)
		print(error_code)
	)
	leaderboard.on_leaderboard_event.connect(func(event_code: String) -> void:
		on_leaderboard_event.emit(event_code)
	)
	
	leaderboard.on_high_score_fetched.connect(func(highscore: int) -> void:
		if highscore is int and highscore > 0:
			on_high_score_fetched.emit(highscore)
	)


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
