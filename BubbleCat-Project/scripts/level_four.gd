extends Node2D 
# fase 4

enum GameState {
	title,
	playing,
	game_over
}

signal enter_title
signal enter_playing
signal enter_game_over


# REFERÊNCIAS DE NÓS (INCLUINDO ÁUDIO)
@onready var title: Sprite2D = $Title
@onready var game_over: Sprite2D = $GameOver
@onready var score: Label = $Score
@onready var game_over_delay: Timer = $GameOverDelay
@onready var music_player: AudioStreamPlayer2D = $MusicPlayer # Música de fundo (songstart.mp3)
@onready var sfx_player: AudioStreamPlayer2D = $SfxPlayer    # Efeito sonoro (gameover.mp3)
@onready var game_manager = get_node("/root/GameManager")
@onready var score_manager = $Score # <-- Se o Label da pontuação se chama "Score"
@onready var final_score_label: Label = $CanvasLayer/GameOverUI/ScoreAndRecordContainer/FinalScoreLabel # <-- CORRETO
@onready var high_score_label: Label = $CanvasLayer/GameOverUI/ScoreAndRecordContainer/HighScoreLabel   # <-- CORRETO
@onready var enemy_cobra_spawner = $EnemyCobraSpawner # <--- Adicione esta linha
@onready var game_over_ui_container: Control = $CanvasLayer/GameOverUI # <-- NOVO: Referência para o contêiner
# ...


var status: GameState
var can_restart = false
var last_shield_score = 0 # <-- NOVO: Para rastrear a última pontuação que concedeu um escudo

const GAMEOVER_SOUND = preload("res://audio/gameover.mp3") # Adicione esta linha!
# --- FUNÇÕES INICIAIS ---
const PORTAL = preload("res://entities/portal.tscn") # <-- NOVO: Referência à sua cena do Portal
const LEVEL_TWO_SCORE = 60

func _ready() -> void:
	# Conecta o sinal 'scored' do nó 'Bird' (Player) à função '_on_bird_scored' deste script (game.gd)
	# O nó Bird é filho direto do Game (Node2D), então usamos $Bird.
	#$GameOverDelay.connect("timeout", Callable(self, "_on_game_over_delay_timeout"))
	$Bird.connect("scored", Callable(self, "_on_bird_scored"))
	$Bird.connect("enter_hurt_state", Callable(self, "on_player_hurt"))
	score.text = str(GameManager.score) # <--- Define o Label de pontuação
	# ====================================================
	# Inicia o jogo no estado de Título
	go_to_plying_state()
	GameManager.speed = 150.0 # Ajuste este valor

func _process(_delta: float) -> void:
	# Lógica para alternar entre os estados do jogo
	match status:
		GameState.title:
			title_state()
		GameState.playing:
			playing_state()
		GameState.game_over:
			game_over_state()

# --- FUNÇÕES DE TRANSIÇÃO (Com Lógica de Áudio) ---

func go_to_title_state():
	# Transiciona para o estado de Título
	status = GameState.title
	title.visible = true
	game_over.visible = false
	score.visible = true
	
	#GameManager.reset()
	music_player.play() # Inicia a música de fundo
	emit_signal("enter_title")
	
func go_to_plying_state():
	# Transiciona para o estado de Jogo (Playing)
	status = GameState.playing
	title.visible = false
	score.visible = true
	# A música continua tocando
	emit_signal("enter_playing")
	
func go_to_game_over_state():
	# Transiciona para o estado de Fim de Jogo
	status = GameState.game_over
	game_over.visible = true
	game_over_delay.start()
	GameManager.speed = 0 # Para o movimento do cenário
	
	music_player.stop() # Para a música
	sfx_player.stream = GAMEOVER_SOUND
	sfx_player.play() # Toca o som de Game Over (SFX)

	# ===================================================
	# LÓGICA DE RECORDE
	# ===================================================
	
	# 1. Obtém a pontuação atual do Singleton
	var current_score: int = GameManager.score 
	
	# 2. Compara a pontuação atual com o Recorde salvo
	if current_score > GameManager.high_score:
		# 3. É um novo recorde! Atualiza e salva.
		GameManager.high_score = current_score
		GameManager.save_high_score(current_score)
		
	# ===================================================
	# ATUALIZAÇÃO DA INTERFACE DE GAME OVER
	# ===================================================
	
	# Exibe a pontuação final da rodada
	final_score_label.text = "SCORE: " + str(current_score)
	
	# Exibe o recorde atual (já atualizado se for o caso)
	high_score_label.text = "RECORDE: " + str(GameManager.high_score)
	
	# Torna o contêiner dos Labels visível (Usando a variável @onready)
	game_over_ui_container.visible = true 
	# === GARANTIR O TEMPO DE PAUSA AQUI ===
	# Define 2 segundos de pausa (se não estiver definido no Editor)
	game_over_delay.wait_time = 4.0 
	# ======================================
	
	# ===================================================
	
	game_over_delay.start()
	emit_signal("enter_game_over")

# --- FUNÇÕES DE ESTADO (Lógica de Jogo) ---

func title_state():
	# Espera por uma ação (clique/toque) para começar
	if Input.is_action_just_pressed("action"):
		go_to_plying_state()
		return
	
func playing_state():
	# O jogo está ativo, a lógica principal está em player.gd e obstacle.gd
	pass
	
func game_over_state():
	# Espera pelo atraso e, em seguida, por uma ação para recarregar a cena
	if Input.is_action_just_pressed("action") and can_restart:
		get_tree().reload_current_scene()

# --- FUNÇÕES CONECTADAS (Sinais) ---

func _on_bird_enter_hurt_state() -> void:
	# 1. Busca o nó do player (Bird) para checar o escudo
	var player_node = $Bird

	if player_node.has_shield:
		# 2. Se tiver escudo, chama a função que desativa o escudo e salva o player
		player_node.consume_shield()
		# O jogo NÃO deve ir para Game Over
	else:
		# 3. Se NÃO tiver escudo, o jogo vai para Game Over
		go_to_game_over_state()

func _on_game_over_delay_timeout() -> void:
	# Permite que o jogo seja reiniciado após um pequeno atraso
	GameManager.reset()
	music_player.stop() #
	can_restart = true
	get_tree().change_scene_to_file("res://scene/game.tscn")
# No final do game.gd

# game.gd

# FUNÇÃO DE PONTUAÇÃO (Onde o erro estava no bloco IF)
func _on_bird_scored():
	# Atualiza a pontuação
	GameManager.score += 1
	score.text = str(GameManager.score)
	
	var current_score = GameManager.score
	
	# ===================================================
	# GERAÇÃO DO PORTAL (USANDO O SPANWER DA FASE 2)
	# ===================================================
	if GameManager.score == LEVEL_TWO_SCORE:
		call_deferred("spawn_portal")
		
		# Para de gerar INIMIGOS para dar tempo do jogador ver o portal
		if is_instance_valid(enemy_cobra_spawner):
			enemy_cobra_spawner.can_spawn = false # OU enemy_bird_spawner.stop_spawning() se você tiver essa função.
	# ===================================================
	# GERAÇÃO DO PORTAL (USANDO O SPANWER DA FASE 2)
	# ===================================================
	if GameManager.score == LEVEL_TWO_SCORE:
		call_deferred("spawn_portal")
		
		# Para de gerar INIMIGOS para dar tempo do jogador ver o portal
		if is_instance_valid(enemy_cobra_spawner):
			enemy_cobra_spawner.can_spawn = false # OU enemy_bird_spawner.stop_spawning() se você tiver essa função.
	
	
	# Lógica de concessão de escudo (indentação verificada)
	if current_score > 0 and current_score % 10 == 0 and current_score > last_shield_score:
		
		# Assume que o Bird é o filho direto do Game.
		var player_node = $Bird # MUDE $Bird PARA O CAMINHO CORRETO DO SEU PLAYER NA CENA
		
		# Verifica se o Player NÃO tem escudo antes de conceder (Impede acúmulo no game.gd)
		if !player_node.has_shield:
			player_node.receive_shield()
			last_shield_score = current_score # Marca o ponto onde o escudo foi dado
			
			

# FUNÇÃO DE SPAWN DO PORTAL (CORREÇÃO DE INDENTAÇÃO AQUI)
# Esta função DEVE estar fora de qualquer outra função (no corpo principal do script)
func spawn_portal():
	print("Tentando instanciar o Portal...") # <--- Adicione esta linha
	var portal_instance = PORTAL.instantiate()
	add_child(portal_instance)
	
	# CONECTA O SINAL DO PORTAL à função que mudará a cena
	portal_instance.connect("player_entered_portal", Callable(self, "_on_portal_entered"))
	
	# Posiciona o portal para aparecer à direita da tela (onde os canos nascem)
	# O valor Y (0) o coloca no centro vertical.
	portal_instance.position = Vector2(350, 256)

# FUNÇÃO DE ENTRADA NO PORTAL (CORREÇÃO DE INDENTAÇÃO AQUI)
# Esta função DEVE estar fora de qualquer outra função
func _on_portal_entered():
	# 1. Para o movimento de tudo
	GameManager.speed = 0 
	
	# 2. Esconde o player (faz o BubbleCat sumir no portal)
	$Bird.visible = false 
	
	# 3. Remoção do Player de forma segura (para evitar o erro CollisionObject)
	$Bird.queue_free.call_deferred()
	
	# Armazena a função de troca de cena em um objeto chamável (Callable)
	#var change_scene_callable = Callable(get_tree(), "change_scene_to_file").bind("res://scene/game.tscn")
	
	# Executa a ação de forma ADIADA (após o frame de física)
	#change_scene_callable.call_deferred() # <--- CORREÇÃO FINAL DA TRANSIÇÃO
	
	# FUTURO: Quando a cena level_two.tscn estiver pronta, troque o print por:
	#get_tree().change_scene_to_file("res://scene/game.tscn")
	get_tree().change_scene_to_file.call_deferred("res://scene/game.tscn")
	# Adicione esta função ao level_two.gd:
func on_player_hurt():
	# O Player foi atingido, então chame a lógica de Game Over
	go_to_game_over_state()
