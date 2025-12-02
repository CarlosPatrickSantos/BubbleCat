extends Node

const DEFAULT_SPEED = 100

# Nome do arquivo de salvamento no disco do jogador
const SAVE_PATH = "user://game_save.cfg"
var score = 0
var speed = 0
# Variável para guardar o recorde atual na memória
var high_score: int = 0
# Variável para manipular o arquivo de salvamento
var config = ConfigFile.new()

func _ready():
	# Tenta carregar o recorde ao iniciar o jogo
	load_high_score()

# Função para carregar o Recorde do arquivo
func load_high_score():
	# Tenta carregar o arquivo
	var error = config.load(SAVE_PATH)
	
	# Se o arquivo existir (erro == OK), lê o valor.
	if error == OK:
		# Lê o valor da seção "Scores", chave "HighScore". 
		# O segundo valor (0) é o padrão se a chave não existir.
		high_score = config.get_value("Scores", "HighScore", 0)
	else:
		# Se o arquivo não existir ou houver erro, high_score permanece 0.
		print("Arquivo de salvamento não encontrado. High Score é 0.")

# Função para salvar o Recorde no arquivo
func save_high_score(score_to_save: int):
	# Salva o novo valor na seção "Scores", chave "HighScore"
	config.set_value("Scores", "HighScore", score_to_save)
	
	# Escreve o arquivo no disco (o user:// garante que é no diretório do usuário)
	config.save(SAVE_PATH)
	print("Novo Recorde salvo:", score_to_save)

func reset():
	score = 0
	speed = DEFAULT_SPEED
