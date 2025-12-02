extends Node2D

# Certifique-se que o nó raiz do Bird Inimigo é Area2D,
# caso contrário, a função _on_area_entered não será chamada.
# Se este script estiver em um Area2D, a linha 'extends Node2D' deve ser 'extends Area2D'

# Ajustei para extends Area2D, assumindo que esta é a cena do pássaro inimigo
# Se o seu pássaro é um Area2D, MUDAR A PRIMEIRA LINHA É ESSENCIAL.
# Mantenha extends Node2D se o nó raiz for Node2D e o Area2D for filho.

# Vamos assumir que o nó raiz é Area2D, como é padrão para colisores:
# extends Area2D 

func _process(delta: float) -> void:
	# Movimento horizontal
	position.x -= GameManager.speed * delta
	

func _on_area_entered(area: Area2D) -> void:
	# A colisão só acontece se a área que entrou estiver no grupo "Player"
	if area.is_in_group("Player"):
		
		# 1. Busca o nó principal 'Game' (a raiz da sua cena principal)
		# Nota: O nome "Game" deve ser o nome exato do nó raiz da sua primeira cena.
		var game_node = get_tree().get_root().get_node("Game")
		
		# 2. Chama a função de dano do jogo principal para checar escudo/Game Over
		if game_node:
			game_node._on_bird_enter_hurt_state()
		
		# O pássaro desaparece após a colisão
		queue_free()
		
# ----------------------------------------------------
# Nota: Adicione _ na frente de 'area' se você não a usar
func _on_score_area_area_entered(_area: Area2D) -> void:
	# Esta função é para a pontuação (Player passou sobre o pássaro)
	# Se a lógica de pontuação estiver aqui, você precisa do sinal:
	# get_tree().get_root().get_node("Game")._on_bird_scored() 
	pass
