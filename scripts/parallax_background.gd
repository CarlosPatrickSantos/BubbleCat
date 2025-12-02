# parallax_background.gd (Novo Script)
extends ParallaxBackground

# Certifique-se de que o GameManager.gd esteja disponível para este script
# ou que GameManager seja um singleton (recomendado)

func _process(delta):
	# A propriedade scroll_offset controla a posição horizontal do fundo.
	# Adicionamos a velocidade do GameManager a ela a cada frame (delta).
	
	# NOTA: O ParallaxBackground espera um valor POSITIVO para se mover
	# para a esquerda. Se GameManager.speed for -300, use `-GameManager.speed`.
	
	# Exemplo: Se o GameManager.speed for -300 (obstáculos se movendo para a esquerda):
	# O Parallax Background precisa se mover para a direita para simular o avanço.
	# Mas, devido à maneira como o Godot calcula a rolagem do Parallax,
	# ele precisa de um valor POSITIVO para a rolagem visual para a esquerda.
	
	# A melhor prática é usar a velocidade de rolagem dos obstáculos:
	var inverse_speed = -GameManager.speed # Geralmente -300
	
	# Movimenta a tela. Multiplicamos a velocidade pela delta:
	scroll_offset.x += inverse_speed * delta 
	
	# Se scroll_speed for negativo, o fundo se move para a esquerda.
	# Se scroll_speed for positivo, o fundo se move para a direita (como a câmera em jogos de plataforma).
	
	# Teste se 'scroll_speed' ou '-scroll_speed' dá o efeito desejado!
