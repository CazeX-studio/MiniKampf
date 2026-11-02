extends SceneTree
## Misst, wie lange die Spiel-Logik von Kreuzweg pro Bild rechnet (alle _process-Aufrufe eines Bildes zusammen).
## Aufruf: Godot --headless --path . -s tests/leistung_messen.gd [-- <bilder>]
## Ausgabe: Durchschnitt, Mitte und langsamste Bilder in Millisekunden. Kein Prüftest (heißt nicht *_test.gd).
## Mit Bild (ohne --headless, z. B. über xvfb-run) misst es stattdessen die ganze Zeit pro Bild samt Zeichnen.
## Im Browser ist alles etwa zwei- bis dreimal langsamer; für ruckelfreie 60 Bilder pro Sekunde bleiben 16 ms pro Bild.

var _frames := 0
var _total := 600
var _warmup := 60
var _times: Array[float] = []
var _start := 0
var _mit_bild := false
## Zum Vergleichen: „ohne_licht“ schaltet alle Lichter aus
var _schalter: PackedStringArray
var _letztes := 0


## Läuft vor allen anderen Knoten (merkt sich den Anfang) bzw. nach allen (trägt die Zeit ein).
class Uhr extends Node:
	var mess: Callable

	func _process(_delta: float) -> void:
		mess.call()


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	for a: String in args:
		if a.is_valid_int():
			_total = int(a)
	_schalter = args
	# Eigener Spielstand, damit Marcos echter Spielstand unberührt bleibt
	SaveGame.path = "user://leistung_messen.json"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveGame.path))
	_mit_bild = DisplayServer.get_name() != "headless"
	if _mit_bild:
		# Nicht auf den Bildschirm warten, sonst misst man nur die Bildrate
		Engine.max_fps = 0
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var vorher := Uhr.new()
	vorher.process_priority = -100000
	vorher.mess = func() -> void:
		var jetzt := Time.get_ticks_usec()
		if _mit_bild and _letztes != 0 and _frames > _warmup:
			_times.append((jetzt - _letztes) / 1000.0)
		_letztes = jetzt
		_start = jetzt
	var nachher := Uhr.new()
	nachher.process_priority = 100000
	nachher.mess = func() -> void:
		if not _mit_bild and _frames > _warmup:
			_times.append((Time.get_ticks_usec() - _start) / 1000.0)
	root.add_child.call_deferred(vorher)
	root.add_child.call_deferred(nachher)
	change_scene_to_file("res://scenes/kreuzweg.tscn")


func _process(_delta: float) -> bool:
	_frames += 1
	# Die Figur läuft hin und her über den Platz, damit Kamera, Sortieren und Wegweiser arbeiten
	var welt := current_scene
	# Gespräche (z. B. die Einleitung) durchklicken, damit die Figur wirklich läuft
	if welt != null and welt.has_method("local_player") and welt.local_player().in_dialog() and _frames % 5 == 0:
		var antworten: Array = welt.state.dialog_view(welt.local_player()).get("antworten", [])
		welt.state.apply_command(welt.local_id, {type = "dialog_choose", index = 0} if not antworten.is_empty() else {type = "dialog_next"})
	if welt != null and welt.has_method("local_player") and _frames % 90 == 10:
		var p: PlayerState = welt.local_player()
		var ziel := Vector2i(int(p.pos.x) + (6 if (_frames / 90) % 2 == 0 else -6), int(p.pos.y))
		welt.state.apply_command(welt.local_id, {type = "move", cell = ziel})
	if _frames == _warmup:
		var lichter := root.find_children("*", "Light2D", true, false)
		var an := lichter.filter(func(l: Light2D) -> bool: return l.is_visible_in_tree() and l.enabled).size()
		print("Lichter: %d (davon an: %d), Knoten: %d" % [lichter.size(), an, root.get_child_count() + root.find_children("*", "", true, false).size()])
		if "ohne_licht" in _schalter:
			for l: Light2D in lichter:
				l.enabled = false
	if _frames >= _total + _warmup:
		_times.sort()
		var sum := 0.0
		for t in _times:
			sum += t
		print(("Mit Bild – " if _mit_bild else "Nur Logik – ") + "Bilder: %d  Durchschnitt: %.2f ms  Mitte: %.2f ms  langsamste 1 %%: %.2f ms  langsamstes: %.2f ms" % [
				_times.size(), sum / _times.size(), _times[_times.size() / 2],
				_times[int(_times.size() * 0.99)], _times[-1]])
		quit()
	return false
