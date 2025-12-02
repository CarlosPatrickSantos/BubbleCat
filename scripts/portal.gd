# portal.gd
extends Area2D # AGORA ESTÁ CERTO!

# Sinal que o Game (game.gd) irá capturar para mudar de cena
signal player_entered_portal

func _ready() -> void:
	# Garante que a animação comece
	$AnimatedSprite2D.play("default") 

func _process(delta: float) -> void:
	# Movimento para a esquerda (traz o portal para a tela)
	position.x -= GameManager.speed * delta
	
	# Limpeza
	if position.x < -100:
		queue_free()

# Função chamada quando um corpo (o Bird) entra no Area2D
# ATENÇÃO: Conecte o sinal 'body_entered' do Portal (Area2D) para esta função!
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Bird": # Nome do seu jogador na cena game.tscn
		emit_signal("player_entered_portal") # Dispara o sinal
		set_deferred("monitoring", false) # <--- CORRIGIDO
		#call_deferred("queue_free") # Adicione esta linha se você quiser que o portal suma.
