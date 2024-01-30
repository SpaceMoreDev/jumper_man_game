extends Node

var GameManager : Manager : 
	get:
		return _get_Manager()
	
var Score : int = 0:
	set(val):
		Score = val
		var newVal = str(Score)
		if Score > 10 and Score < 100:
			newVal = "[color=#66ff22]%s[/color]"%Score
			GameManager.emit_signal("newScore",1.2, .5)
		elif Score >= 100 and Score < 200:
			newVal = "[color=#FFA500]%s[/color]"%Score
			GameManager.emit_signal("newScore",1.5, 1)
		elif Score >= 200:
			GameManager.UI_ScoreParticle.emitting = true
			newVal = "[rainbow freq=1.0 sat=0.8 val=0.8]%s[/rainbow]"%Score
			GameManager.emit_signal("newScore",1.8, 2)
		GameManager.UI_Score.text = newVal

func _get_Manager() -> Manager :
	var manager = get_tree().get_first_node_in_group("Game Manager")
	return manager
