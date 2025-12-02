# enemy_bird.gd
extends Area2D

# Controle do movimento ondulatório (Sobe e Desce)
@export var amplitude_y: float = 20.0 # Altura máxima da subida/descida
@export var frequency_y: float = 3.0  # Velocidade do voo (quão rápido ele ondula)

var time: float = 0.0

func _process(delta: float) -> void:
	# 1. Movimento horizontal (baseado na velocidade do jogo)
	position.x -= GameManager.speed * delta 
	
	# 2. Movimento vertical sinusoidal (voo suave)
	time += delta
	# Faz o pássaro subir e descer suavemente
	position.y += sin(time * frequency_y) * amplitude_y * delta # Adicione delta para suavizar

	
	# 3. Limpeza: Se o pássaro sair da tela, ele é removido
	if position.x < -100:
		queue_free()

# Conecta o sinal 'area_entered' do Area2D à esta função
func _on_area_entered(area: Area2D) -> void:
	# O player Bird (seu BubbleCat) deve estar no grupo "Player" para esta checagem
	if area.is_in_group("Player"): 
		
		# Chama a lógica de dano do Bird (Bird.gd)
		# Reutilizamos a função de colisão do Bird para que ele use o escudo ou vá para Game Over
		var player_node = area.get_parent() 
		if player_node.has_method("_on_hitbox_area_entered"):
			player_node._on_hitbox_area_entered(self)
		
		# O pássaro desaparece após a colisão
		queue_free()
