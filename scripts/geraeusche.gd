class_name Geraeusche
extends Node
## Geräusche im Kampf (Schlag, Treffer, Parade, Zauber …). Aufruf von überall: Geraeusche.play("treffer").
## Hängt sich wie die Musik beim ersten Aufruf selbst an die Wurzel des Spiels. Die Lautstärke kommt vom
## gemeinsamen Regler (Musik.volume); Taste M schaltet nur die Musik ab, nicht die Geräusche.
## Die Geräusche sind Platzhalter, erzeugt mit tools/sounds_erzeugen.gd.

const SOUNDS := ["schlag", "wurf", "treffer", "kritisch", "parade", "perfekt", "zauber", "heilung"]
const PATH := "res://assets/sfx/%s.wav"
const VOLUME_DB := -4.0
## So viele Geräusche können gleichzeitig klingen
const VOICES := 6

static var _instance: Geraeusche

var _streams := {}
var _players: Array[AudioStreamPlayer] = []
var _next := 0


static func play(sound: String, pitch := 1.0) -> void:
	if _instance == null or not is_instance_valid(_instance):
		var tree := Engine.get_main_loop() as SceneTree
		if tree == null:
			return
		# Lautstärke-Einstellung laden (das macht die Musik beim ersten Aufruf, ein leerer Name spielt nichts)
		Musik.play("")
		_instance = Geraeusche.new()
		_instance.name = "Geraeusche"
		_instance.process_mode = Node.PROCESS_MODE_ALWAYS
		tree.root.add_child.call_deferred(_instance)
	_instance._play(sound, pitch)


func _init() -> void:
	for sound: String in SOUNDS:
		if ResourceLoader.exists(PATH % sound):
			_streams[sound] = load(PATH % sound)
	for i in VOICES:
		var player := AudioStreamPlayer.new()
		player.volume_db = VOLUME_DB
		add_child(player)
		_players.append(player)


func _play(sound: String, pitch: float) -> void:
	if not _streams.has(sound):
		return
	var player := _players[_next]
	_next = (_next + 1) % _players.size()
	player.stream = _streams[sound]
	# Etwas Abwechslung, damit dasselbe Geräusch nicht immer gleich klingt
	player.pitch_scale = pitch * randf_range(0.94, 1.06)
	if player.is_inside_tree():
		player.play()
	else:
		player.play.call_deferred()
