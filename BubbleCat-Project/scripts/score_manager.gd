extends Label

var score = 0

func _on_bird_scored() -> void:
	score += 1
	self.text = str(score)
