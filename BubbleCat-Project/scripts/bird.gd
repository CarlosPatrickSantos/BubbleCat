extends CharacterBody2D

enum BirdState {
	warmup,
	fly,
	hurt
}

signal enter_hurt_state
signal scored

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var shield_sprite: AnimatedSprite2D = $ShieldSprite # <-- NOVO: Referência ao Sprite do escudo
@onready var shield_timer: Timer = $ShieldTimer # <-- NOVO
@onready var bubble_pop: AnimatedSprite2D = $BubblePop # <-- NOVO
@onready var sfx_player = $"../SfxPlayer"
@onready var warning_start_timer: Timer = $WarningStartTimer # <-- NOVO
@onready var shield_tween: Tween # <-- Adicionaremos o Tween na função _ready()
# ...

const SPEED = 300.0
const JUMP_VELOCITY = -100.0
const SHIELD_SOUND = preload("res://audio/bubbles.mp3")
const POP_SOUND = preload("res://audio/pop.mp3") # <-- NOVO

var status: BirdState
var has_shield = false # <-- NOVO: Variável de estado do escudo

func _ready() -> void:
	# Inicializa o Tween para gerenciar efeitos visuais suaves
	shield_tween = create_tween()
	shield_tween.stop() # Começa parado
	go_to_warmup_state()

func _physics_process(delta: float) -> void:
	
	match status:
		BirdState.warmup:
			warmup_state(delta)
		BirdState.fly:
			fly_state(delta)
		BirdState.hurt:
			hurt_state(delta)
		
	move_and_slide()
	
func go_to_warmup_state():
	status = BirdState.warmup
	anim.play("fly")
	
func go_to_fly_state():
	status = BirdState.fly
	anim.play("fly")
	fly()
	
func go_to_hurt_state():
	if status == BirdState.hurt:
		return
		
	status = BirdState.hurt
	anim.play("hurt")
	#anim.flip_v = true
	anim.rotation = 0
	velocity = Vector2.ZERO # <-- Importante: Parar o movimento horizontal e vertical
	#fly()
	emit_signal("enter_hurt_state")

func warmup_state(_delta):
	pass

func fly_state(delta):
	apply_gravity(delta)
	if Input.is_action_just_pressed("action"):
		fly()
		
	anim.rotation = atan(velocity.y * 0.002)
		
func hurt_state(_delta):
	#apply_gravity(delta)
	pass
	
func fly():
	velocity.y = JUMP_VELOCITY

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * 0.2 * delta

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Pipe") or area.is_in_group("EnemyBird"):
		# NOVO: Verifica se o escudo está ativo
		if has_shield:
			consume_shield() # Desativa o escudo
		else:
			go_to_hurt_state() # Perde se não tiver escudo
	elif area.is_in_group("Score"):
		emit_signal("scored")

func _on_game_enter_playing() -> void:
	go_to_fly_state()
	
# No final do bird.gd

func receive_shield():
	if !has_shield:
		has_shield = true
		shield_sprite.visible = true 
		shield_sprite.play("fada")
		
		# NOVO: Toca o som do escudo
		if sfx_player:
			# 1. ATRIBUI o som de bolhas ao player (substitui o som anterior)
			sfx_player.stream = SHIELD_SOUND
			# 2. TOCA o som
			sfx_player.play()
		# NOVO: Inicia o cronômetro
		shield_timer.start()
		# NOVO: Inicia o cronômetro de 7 segundos para o aviso
		warning_start_timer.start()
		print("Escudo recebido!")

# Esta função será criada ao conectar o sinal:
func _on_shield_timer_timeout():
	# Chamado quando o tempo do escudo acabar
	consume_shield()

func consume_shield():
	has_shield = false
	shield_sprite.stop()	
	shield_sprite.visible = false # Desativa o visual do escudo
	# NOVO: Garante que o timer pare e seja zerado, independentemente do motivo do consumo
	shield_timer.stop()
	# NOVO: Dispara as partículas de estouro
	
	if bubble_pop:
		bubble_pop.visible = true  # Torna o nó visível
		bubble_pop.play("estouro") # Inicia a animação de estouro (toca uma vez)eld_pop.emitting = true
	# NOVO: Toca o som de estouro
	if sfx_player:
		sfx_player.stream = POP_SOUND # Troca para o som de estouro
		sfx_player.play()
	# NOVO: Para o aviso visual e reseta a cor do escudo
	warning_start_timer.stop()
	shield_tween.stop()
	shield_sprite.modulate = Color(1, 1, 1, 1) # Garante que o escudo volte à cor normal
	print("Escudo consumido!")
	# Opcional: Adicionar um som de 'hit' ou 'escudo quebrado' aqui


func _on_bubble_pop_animation_finished() -> void:
	bubble_pop.visible = false
	
# No seu bird.gd

func _on_warning_start_timer_timeout():
	# Chamado em t=7 segundos. Começa o piscar.
	
	# 1. PARAR e DESTRUIR o Tween antigo (para garantir que não haja conflitos)
	if shield_tween != null:
		shield_tween.kill() # Usa 'kill' para parar e limpar completamente
		
	# 2. CRIAR um novo Tween limpo para o loop de piscar
	shield_tween = create_tween()
	
	# 3. Configurar o loop infinito (será parado por consume_shield)
	shield_tween.set_loops() 
	
	# 4. Configurar as etapas de piscar (Fade out e Fade in)
	
	# Primeira etapa: Fade out (transparência)
	shield_tween.tween_property(shield_sprite, "modulate", Color(1, 1, 1, 0.4), 0.2)
	
	# Segunda etapa: Fade in (volta ao normal)
	# O chain() é essencial para garantir que a segunda etapa comece após a primeira.
	shield_tween.chain().tween_property(shield_sprite, "modulate", Color(1, 1, 1, 1.0), 0.2)
