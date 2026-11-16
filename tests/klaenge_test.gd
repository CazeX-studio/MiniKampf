extends SceneTree
## P8: Alle Klänge sind da (freie Klänge als .ogg), Schritte haben Varianten, jeder Knopf klickt.
## Aufruf: Godot --headless --path . -s tests/klaenge_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	Geraeusche.einrichten()
	await process_frame
	await process_frame
	var g: Geraeusche = Geraeusche._instance
	_check(g != null and g.is_inside_tree(), "Geräusche hängen an der Wurzel")
	for sound: String in Geraeusche.SOUNDS:
		_check(g._streams.has(sound), "Klang „%s“ ist da" % sound)
	_check(g._streams.get("schritt", []).size() >= 3, "Schritte haben mehrere Varianten")
	_check(ResourceLoader.exists("res://assets/sfx/treffer.ogg") and not ResourceLoader.exists("res://assets/sfx/treffer.wav"),
			"Treffer ist der freie Klang, nicht mehr der erzeugte Platzhalter")
	# Ein neuer Knopf bekommt von selbst den Klick
	var knopf := Button.new()
	root.add_child(knopf)
	await process_frame
	_check(knopf.has_meta("klickt"), "Neuer Knopf klickt von selbst")
	knopf.pressed.emit()
	knopf.queue_free()
	print("Klänge: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
