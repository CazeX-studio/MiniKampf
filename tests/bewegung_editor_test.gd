extends SceneTree
## Bewegungs- und Effekt-Editor (S3a): Für jede Klasse jede Fähigkeit einmal auslösen, jede Bewegung und jeden Effekt
## abspielen (Fehler im Ablauf zeigen sich als SCRIPT ERROR). Dazu: Die Effekt-Liste ist aktuell (tools/fx_liste.py).
## Aufruf: Godot --headless --path . -s tests/bewegung_editor_test.gd   (optional: -- <Klasse>)

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	_run.call_deferred()


func _warten(sekunden: float) -> void:
	await create_timer(sekunden, true, false, false).timeout


func _run() -> void:
	# Effekt-Liste passt zu den Quellen
	var namen: Dictionary = GameData.get_file("fx_namen")
	var quelle := FileAccess.get_file_as_string("res://scripts/kampf/faehigkeit_fx.gd")
	var fehlt := (namen.ablaeufe as Array).filter(func(n: String) -> bool: return not quelle.contains('"%s"' % n))
	_check(fehlt.is_empty() and namen.ablaeufe.size() >= 60, "Effekt-Liste passt zu faehigkeit_fx.gd (sonst: python3 tools/fx_liste.py)")
	var bilder := 0
	for n: String in namen.bilder:
		if ResourceLoader.exists("res://assets/fx/%s_f0.png" % n):
			bilder += 1
	_check(bilder == namen.bilder.size(), "Alle Bildfolgen der Liste gibt es")
	var editor_skript: GDScript = load("res://scripts/kampf/bewegung_editor.gd")
	var args := OS.get_cmdline_user_args()
	var klassen: Array = [args[0]] if not args.is_empty() else Sandbox.CLASSES.keys()
	for klasse: String in klassen:
		editor_skript.klasse = klasse
		editor_skript.aussehen = ""
		editor_skript.monster = "wiesenhoppler"
		change_scene_to_file("res://scenes/bewegung_editor.tscn")
		await _warten(0.5)
		var ed: Node = current_scene
		Engine.time_scale = 6.0
		var knoepfe: Array = []
		for i in 20:
			knoepfe = ed._faehigkeiten_box.get_children()
			if not knoepfe.is_empty():
				break
			await _warten(0.2)
		var ausgeloest := 0
		for knopf: Button in knoepfe:
			if knopf.text.begins_with("Heiltrank") or knopf.text.begins_with("Mana"):
				continue
			for i in 80:
				if ed._kampf._current == ed._held and not ed._kampf._grid_buttons().is_empty():
					break
				await _warten(0.1)
			knopf.pressed.emit()
			if ed._status.text != "":
				print("        %s: %s (am Zug: %s, Held: %s)" % [knopf.text, ed._status.text, ed._kampf._current.klass if ed._kampf._current else "-", ed._held.klass])
			if ed._status.text == "":
				ausgeloest += 1
			await _warten(0.4)
		_check(ausgeloest >= knoepfe.size() - 3, "%s: %d von %d Fähigkeiten ausgelöst" % [klasse, ausgeloest, knoepfe.size()])
	# Bewegungen für Held und Monster, alle Effekte (bei der letzten Klasse)
	var ed: Node = current_scene
	for auf_monster: bool in [false, true]:
		ed._auf_monster = auf_monster
		for knopf: Button in ed._bewegt_knopf.get_parent().get_children():
			if knopf != ed._bewegt_knopf:
				knopf.pressed.emit()
				await _warten(0.2)
	for i in namen.ablaeufe.size():
		FaehigkeitFx.spielen(ed._kampf, namen.ablaeufe[i], ed._held, ed._gegner, 0)
		await _warten(0.15)
	for n: String in namen.bilder:
		FxBild.spawn(ed._kampf._field, n, Vector2(400, 300), 0.3)
	await _warten(1.0)
	_check(true, "Bewegungen und %d Effekte abgespielt" % (namen.ablaeufe.size() + namen.bilder.size()))
	Engine.time_scale = 1.0
	change_scene_to_file("res://scenes/editor.tscn")
	await _warten(0.2)
	print("Bewegungs-Editor: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
