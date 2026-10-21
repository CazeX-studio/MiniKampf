class_name Musik
extends Node
## Musik für das ganze Spiel: spielt ein Stück in Schleife und blendet beim Wechsel sanft über.
## Aufruf von überall: Musik.play("stadt"). Der Spieler hängt sich beim ersten Aufruf selbst an die Wurzel
## des Spiels und bleibt beim Szenenwechsel bestehen. Taste M schaltet die Musik an und aus (wird gemerkt).
## Die Stücke sind Platzhalter, erzeugt mit tools/musik_erzeugen.gd.

const TRACKS := {
	stadt = "res://assets/musik/stadt.wav",
	nacht = "res://assets/musik/nacht.wav",
	kampf = "res://assets/musik/kampf.wav",
	boss = "res://assets/musik/boss.wav",
	wald = "res://assets/musik/wald.wav",
	wald_welk = "res://assets/musik/wald_welk.wav",
	wald_nacht = "res://assets/musik/wald_nacht.wav",
}
const SETTINGS := "user://einstellungen.json"
const VOLUME_DB := -8.0
const FADE := 1.2

static var enabled := true
## Lautstärke für alles, was das Spiel abspielt (0 bis 1), über den Regler im Menü und in der Stadt
static var volume := 0.8
static var _loaded := false
static var _instance: Musik

var current := ""
var _player: AudioStreamPlayer


## Spielt ein Stück (nichts passiert, wenn es schon läuft).
static func play(track: String) -> void:
	var node := _instance_node()
	if node != null:
		node._play(track)


## Musik an oder aus.
static func toggle() -> void:
	enabled = not enabled
	_save_settings()
	var node := _instance_node()
	if node == null:
		return
	if enabled and node.current != "":
		node._start(node.current)
	elif not enabled:
		node._fade_out(node._player)
		node._player = null


static func _instance_node() -> Musik:
	if not _loaded:
		_loaded = true
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(SETTINGS)) if FileAccess.file_exists(SETTINGS) else null
		if data is Dictionary:
			enabled = data.get("musik", true)
			volume = clampf(float(data.get("lautstaerke", volume)), 0.0, 1.0)
		_apply_volume()
	if _instance != null and is_instance_valid(_instance):
		return _instance
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	_instance = Musik.new()
	_instance.name = "Musik"
	_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	tree.root.add_child.call_deferred(_instance)
	return _instance


func _ready() -> void:
	# Ein Stück, das schon vor dem Einhängen gewünscht wurde, jetzt starten
	if current != "" and enabled and _player == null:
		_start(current)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_M:
		Musik.toggle()


func _play(track: String) -> void:
	if track == current or not TRACKS.has(track):
		return
	current = track
	if enabled and is_inside_tree():
		_start(track)


func _start(track: String) -> void:
	_fade_out(_player)
	_player = AudioStreamPlayer.new()
	_player.stream = load(TRACKS[track])
	_player.volume_db = -40.0
	_player.finished.connect(_player.play)
	add_child(_player)
	_player.play()
	create_tween().tween_property(_player, "volume_db", VOLUME_DB, FADE)


func _fade_out(player: AudioStreamPlayer) -> void:
	if player == null:
		return
	var tween := create_tween()
	tween.tween_property(player, "volume_db", -40.0, FADE)
	tween.tween_callback(player.queue_free)


## Lautstärke einstellen (0 bis 1) und merken.
static func set_volume(value: float) -> void:
	_instance_node()
	volume = clampf(value, 0.0, 1.0)
	_apply_volume()
	_save_settings()


static func _apply_volume() -> void:
	AudioServer.set_bus_mute(0, volume <= 0.001)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(volume, 0.001)))


static func _save_settings() -> void:
	var file := FileAccess.open(SETTINGS, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({musik = enabled, lautstaerke = volume}))


## Fertiger Lautstärke-Regler (Text + Schieberegler) zum Einbauen in Menüs.
static func make_slider(width := 220.0) -> HBoxContainer:
	_instance_node()
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	var label := Label.new()
	label.text = "Lautstärke"
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	box.add_child(label)
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 5
	slider.value = volume * 100.0
	slider.custom_minimum_size = Vector2(width, 24)
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.focus_mode = Control.FOCUS_NONE
	var percent := Label.new()
	percent.text = "%d %%" % int(slider.value)
	percent.custom_minimum_size = Vector2(48, 0)
	percent.add_theme_font_size_override("font_size", 15)
	slider.value_changed.connect(func(v: float) -> void:
		set_volume(v / 100.0)
		percent.text = "%d %%" % int(v))
	box.add_child(slider)
	box.add_child(percent)
	return box
