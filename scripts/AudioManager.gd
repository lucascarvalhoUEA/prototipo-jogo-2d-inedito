## AudioManager.gd
## Autoload Singleton — toca efeitos sonoros e música de fundo em loop manual.

extends Node

const SFX: Dictionary = {
	"whoosh": preload("res://assets/audio/whoosh.wav"),
	"thud": preload("res://assets/audio/thud.wav"),
	"crash": preload("res://assets/audio/crash.wav"),
	"hit": preload("res://assets/audio/hit.wav"),
	"pickup": preload("res://assets/audio/coin-pickup.wav"),
	"laser": preload("res://assets/audio/laser.wav"),
}
const MUSIC_THEME: AudioStream = preload("res://assets/audio/theme.wav")
const SFX_POOL_SIZE: int = 8

var _sfx_pool: Array[AudioStreamPlayer] = []
var _next_player_index: int = 0
var _music_player: AudioStreamPlayer


func _ready() -> void:
	# Continua tocando com o jogo pausado (menu de pausa)
	process_mode = Node.PROCESS_MODE_ALWAYS

	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(p)
		_sfx_pool.append(p)

	_music_player = AudioStreamPlayer.new()
	_music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_music_player.stream = MUSIC_THEME
	_music_player.volume_db = -8.0
	_music_player.finished.connect(_on_music_finished)
	add_child(_music_player)


func play_sfx(name: String, volume_db: float = 0.0) -> void:
	if not SFX.has(name):
		return
	var player: AudioStreamPlayer = _sfx_pool[_next_player_index]
	_next_player_index = (_next_player_index + 1) % _sfx_pool.size()
	player.stream = SFX[name]
	player.volume_db = volume_db
	player.play()


func play_music() -> void:
	if _music_player.playing:
		return
	_music_player.play()


func stop_music() -> void:
	_music_player.stop()


func _on_music_finished() -> void:
	# Loop manual (independe da flag de loop do arquivo importado)
	_music_player.play()
