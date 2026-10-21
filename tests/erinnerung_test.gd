extends SceneTree
## Prüft die Erinnerungs-Szene (Grünwacht Schritt 6) mit Anzeige, ohne Fenster: Alle Schritte von Rowans Erinnerung
## lassen sich durchtippen, Figuren erscheinen und bewegen sich, am Ende geht es zurück.
## Aufruf: Godot --headless --path . --script res://tests/erinnerung_test.gd

var _failed := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	Erinnerung.id = "rowan"
	Erinnerung.return_scene = "res://scenes/menu.tscn"
	change_scene_to_file("res://scenes/erinnerung.tscn")
	await _frames(5)
	var screen: Erinnerung = current_scene
	_check(screen != null and screen._figures.size() == 4, "Erinnerung mit vier Figuren")
	_check(screen._text.text.contains("Splitter"), "Erster Text: der Splitter wird warm")
	var steps: int = GameData.get_file("erinnerungen").rowan.schritte.size()
	var seen_moving := false
	var seen_ysolde := false
	for i in steps - 1:
		while screen._busy:
			seen_moving = seen_moving or screen._figures.rowan.moving
			await _frames(1)
		screen.next_step()
		await _frames(2)
		seen_ysolde = seen_ysolde or screen._who.text == "Ysolde"
	_check(seen_moving, "Die Fliehenden laufen")
	_check(seen_ysolde, "Ysolde spricht")
	_check(screen._figures.rowan.facing == 1, "Rowan dreht sich zu Ysolde um")
	while screen._busy:
		await _frames(1)
	screen.next_step()
	for i in 100:
		await create_timer(0.05).timeout
		if not current_scene is Erinnerung:
			break
	_check(current_scene != null and not current_scene is Erinnerung, "Am Ende zurück (hier: ins Menü)")
	_check(Erinnerung.id == "", "Erinnerung ist vorbei")
	Erinnerung.return_scene = "res://scenes/kreuzweg.tscn"
	print("Erinnerung: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _check(condition: bool, text: String) -> void:
	if not condition:
		_failed += 1
		print("FEHLER: " + text)
