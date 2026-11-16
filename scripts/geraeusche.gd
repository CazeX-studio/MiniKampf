class_name Geraeusche
extends Node
## Geräusche im Kampf (Schlag, Treffer, Parade, Zauber …). Aufruf von überall: Geraeusche.play("treffer").
## Hängt sich wie die Musik beim ersten Aufruf selbst an die Wurzel des Spiels. Die Lautstärke kommt vom
## gemeinsamen Regler (Musik.volume); Taste N schaltet nur die Musik ab, nicht die Geräusche.
## Seit P8 (16.11.2026) freie Klänge (CC0, OpenGameArt, CREDITS.md), eingebaut und in der Lautstärke angeglichen mit
## tools/klaenge_einbauen.py. Klänge mit Varianten (schritt_0, schritt_1, …) spielen jedes Mal eine andere.
## Jeder Knopf im Spiel klickt von selbst (Geraeusche.einrichten hängt sich an neue Knöpfe).

const SOUNDS := ["schlag", "wurf", "treffer", "kritisch", "parade", "perfekt", "zauber", "heilung", "stufe",
		"klick", "fenster", "muenzen", "aufheben", "anlegen", "auftrag", "schritt"]
## Erst .ogg (freie Klänge), sonst der alte Platzhalter als .wav
const PATHS := ["res://assets/sfx/%s.ogg", "res://assets/sfx/%s.wav"]
const VOLUME_DB := -4.0
## So viele Geräusche können gleichzeitig klingen
const VOICES := 8

static var _instance: Geraeusche

var _streams := {}
var _players: Array[AudioStreamPlayer] = []
var _next := 0


static func play(sound: String, pitch := 1.0) -> void:
	einrichten()
	if _instance != null:
		_instance._play(sound, pitch)


## Hängt die Geräusche an die Wurzel des Spiels (einmal). Danach klickt jeder Knopf von selbst.
static func einrichten() -> void:
	if _instance != null and is_instance_valid(_instance):
		return
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	# Lautstärke-Einstellung laden (das macht die Musik beim ersten Aufruf, ein leerer Name spielt nichts)
	Musik.play("")
	_instance = Geraeusche.new()
	_instance.name = "Geraeusche"
	_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	tree.root.add_child.call_deferred(_instance)


func _ready() -> void:
	# Klick bei jedem Knopf (auch bei Knöpfen, die später entstehen)
	get_tree().node_added.connect(_knopf_anhaengen)
	for knopf in get_tree().root.find_children("*", "BaseButton", true, false):
		_knopf_anhaengen(knopf)


func _knopf_anhaengen(node: Node) -> void:
	if node is BaseButton and not node.has_meta("klickt"):
		node.set_meta("klickt", true)
		(node as BaseButton).pressed.connect(func() -> void: _play("klick", 1.0))


func _init() -> void:
	for sound: String in SOUNDS:
		var stream := _laden(sound)
		if stream != null:
			_streams[sound] = [stream]
			continue
		# Varianten: schritt_0, schritt_1, …
		var varianten := []
		for i in 10:
			var v := _laden("%s_%d" % [sound, i])
			if v == null:
				break
			varianten.append(v)
		if not varianten.is_empty():
			_streams[sound] = varianten
	for i in VOICES:
		var player := AudioStreamPlayer.new()
		player.volume_db = VOLUME_DB
		add_child(player)
		_players.append(player)


static func _laden(name: String) -> AudioStream:
	for pfad: String in PATHS:
		if ResourceLoader.exists(pfad % name):
			return load(pfad % name)
	return null


func _play(sound: String, pitch: float) -> void:
	if not _streams.has(sound):
		return
	var player := _players[_next]
	_next = (_next + 1) % _players.size()
	var varianten: Array = _streams[sound]
	player.stream = varianten.pick_random()
	# Etwas Abwechslung, damit dasselbe Geräusch nicht immer gleich klingt
	player.pitch_scale = pitch * randf_range(0.94, 1.06)
	if player.is_inside_tree():
		player.play()
	else:
		player.play.call_deferred()
