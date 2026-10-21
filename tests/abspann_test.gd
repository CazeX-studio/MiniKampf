extends SceneTree
## Prüft den Abspann am Ende von Grünwacht (mit Anzeige, ohne Fenster): Rückblick auf die eigenen Entscheidungen.
## Aufruf: Godot --headless --path . --script res://tests/abspann_test.gd

var _failed := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	SaveGame.path = "user://spielstand_test_abspann.json"
	var p := PlayerState.new("spieler", "Du", "elf_m", Vector2i(16, 15))
	p.map = "wipfelheim"
	p.progress.flags = {"klasse": "archer", "hirsch_verschont": true, "urbaum_gerettet": true, "wahrheit_wipfelheim": true}
	SaveGame.save(p)
	Abspann.variante = "gruenwacht"
	change_scene_to_file("res://scenes/abspann.tscn")
	await _frames(5)
	var texts := ""
	for label in current_scene.find_children("*", "Label", true, false):
		texts += label.text + " "
	_check(texts.contains("Ende von Grünwacht"), "Titel: Ende von Grünwacht")
	_check(texts.contains("Silberhirsch verschont") and texts.contains("Urbaum lebt") and texts.contains("Wahrheit über Rowan"), "Rückblick auf die Entscheidungen")
	_check(not texts.contains("gefallen") and not texts.contains("Kobalt"), "Nur, was man selbst entschieden hat")
	var buttons := current_scene.find_children("*", "Button", true, false)
	_check(buttons.size() == 2 and buttons[0].text == "Zurück nach Wipfelheim", "Knopf: Zurück nach Wipfelheim")
	buttons[0].pressed.emit()
	await _frames(5)
	_check(current_scene.has_method("local_player") and current_scene.local_player().map == "wipfelheim", "Zurück in Wipfelheim")
	_check(Abspann.variante == "", "Abspann von Akt 1 bleibt unverändert")
	SaveGame.delete()
	SaveGame.path = SaveGame.DEFAULT_PATH
	print("Abspann: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _check(condition: bool, text: String) -> void:
	if not condition:
		_failed += 1
		print("FEHLER: " + text)
