extends Sprite2D

func _process(delta: float) -> void:
	position.x -= GameManager.speed * delta
	if position.x <= -24:
		position.x += 24
		
