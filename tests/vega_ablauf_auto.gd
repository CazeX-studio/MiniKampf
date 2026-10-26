extends Node
## Spielt einen echten Kampf mit Vega automatisch (Schlag auf den Gegner, Parade im richtigen Moment) und schreibt
## mit, welche Animation sie zu jedem Zeitpunkt zeigt. Macht Bildschirmfotos in kurzen Abständen.
## Die Bilder landen im Ordner aus der Umgebungsvariable FOTO_ORDNER (sonst user://).

var _t := 0.0
var _combat: Node
var _vega: FighterView
var _last := ""
var _shot_t := 0.0
var _shots := 0


func _ready() -> void:
	BattleRequest.player_look = "vega"
	BattleRequest.prepare("wild:0", 10, 0, "")
	BattleRequest.reward = {erfahrung = 120, gold = 20, karte = "", stufen = []}
	_combat = load("res://scenes/kampf.tscn").instantiate()
	add_child(_combat)


func _process(delta: float) -> void:
	_t += delta
	if _vega == null:
		for f: Fighter in _combat.state.heroes:
			_vega = _combat.view(f)
		return
	var frames: Array = _vega._frames.get(_vega._anim, [])
	var now := "%s %s" % [_vega._anim, _vega.body.texture.resource_path.get_file()]
	if now != _last:
		print("%6.2f  %s  | %s" % [_t, now, _combat._turn_label.text])
		_last = now
	# Eigener Zug: Schlag auf den Gegner
	if _combat._grid.get_child_count() > 0 and not _combat._reacting:
		var first: Button = _combat._grid.get_child(0)
		if not first.disabled and first.text.contains("Schlag"):
			print("%6.2f  >>> Schlag" % _t)
			first.pressed.emit()
			for e: Fighter in _combat.state.enemies:
				if e.is_alive():
					_combat._on_fighter_tapped(e)
					break
	# Parade im richtigen Moment
	if _combat._reacting and _combat._react_press < 0.0 and _combat._react_time() >= _combat._react_duration:
		print("%6.2f  >>> Parieren" % _t)
		var key := InputEventKey.new()
		key.keycode = KEY_SPACE
		key.pressed = true
		Input.parse_input_event(key)
	_shot_t += delta
	if _shot_t >= 0.1 and _shots < 400:
		_shot_t = 0.0
		_shots += 1
		var folder := OS.get_environment("FOTO_ORDNER")
		get_viewport().get_texture().get_image().save_png("%s/ablauf_%03d.png" % [folder, _shots])
	if _t > 25.0:
		get_tree().quit()
