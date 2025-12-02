extends Node2D

# 1. Pré-carrega a cena do pássaro inimigo
const ENEMY_BIRD = preload("res://entities/enemy_bird.tscn")

# 2. Configurações de tempo para gerar os pássaros
@export var spawn_time: float = 1.5 # Tempo entre cada pássaro
var time_until_spawn: float = 0.0
var can_spawn: bool = true # Novo: Flag de controle

# Posições onde os pássaros podem nascer (entre o topo e o centro da tela)
var min_y: float = 100.0
var max_y: float = 400.0

func _process(delta: float) -> void:
	if !can_spawn: # SE NÃO PODE GERAR, RETORNA
		return
	
	time_until_spawn -= delta
	
	if time_until_spawn <= 0:
		spawn_bird()
		time_until_spawn = spawn_time # Reinicia o temporizador

func spawn_bird():
	# 1. Instancia o pássaro
	var bird_instance = ENEMY_BIRD.instantiate()
	
	# 2. Adiciona o pássaro como filho do EnemyBirdSpawner
	add_child(bird_instance)
	
	# 3. Escolhe uma posição Y aleatória dentro do limite da tela
	var random_y = randf_range(min_y, max_y)
	
	# 4. Posiciona o pássaro para nascer fora da tela, à direita
	# O valor 350 deve estar fora da tela para garantir que ele entre com o movimento
	bird_instance.position = Vector2(350, random_y)
