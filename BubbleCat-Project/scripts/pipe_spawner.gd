extends Node2D

const PIPES = preload("res://entities/pipes.tscn")

@onready var timer: Timer = $Timer

var random = RandomNumberGenerator.new()

func spawn_pipes():
	var new_pipes = PIPES.instantiate()
	add_child(new_pipes)
	new_pipes.position.y = random.randf_range(-60, 60)

func _on_timer_timeout() -> void:
	spawn_pipes()

func _on_game_enter_playing() -> void:
	spawn_pipes()
	timer.start()

func _on_game_enter_game_over() -> void:
	timer.stop()
# NOVO: Função para parar a geração de canos (Chamada pelo game.gd)
func stop_spawning():
	timer.stop()
