extends SceneTree
## Prüft den Abspann am Ende von Grünwacht (mit Anzeige, ohne Fenster): Rückblick auf die eigenen Entscheidungen.
## Aufruf: Godot --headless --path . --script res://tests/abspann_test.gd

var _failed := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	SaveGame.path = "user://spielstand_test_abspann.json"
	Tester.datei = "user://tester_test_abspann.json"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Tester.datei))
	Tester.neu_laden()
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
	# Erst eine Region durch: noch kein Ende der Demo, die Reise geht in die Glutoase weiter (Marco, 06.11.)
	_check(texts.contains("weiter in die Glutoase") and not texts.contains("AST-"), "Nach der ersten Region: weiter in die Glutoase, noch kein Code")
	_check(buttons.size() == 2 and buttons[0].text == "Zurück nach Wipfelheim" and buttons[0].visible, "Knopf: Zurück nach Wipfelheim")
	buttons[0].pressed.emit()
	await _frames(5)
	_check(current_scene.has_method("local_player") and current_scene.local_player().map == "wipfelheim", "Zurück in Wipfelheim")
	_check(Abspann.variante == "", "Abspann von Akt 1 bleibt unverändert")
	# D35: Ende der Glutoase
	# (Die Welt speichert beim Verlassen selbst: darum die Merker beim Spieler in der Welt setzen)
	var spieler: PlayerState = current_scene.local_player()
	spieler.progress.flags = {"klasse": "smith", "sechster_ton": true, "kael_besiegt_glutoase": true, "mira_hoert": true}
	spieler.progress.quests["die_wahrheit"] = "abgegeben"
	spieler.progress.quests["miras_splitter"] = "abgegeben"
	Abspann.variante = "glutoase"
	change_scene_to_file("res://scenes/abspann.tscn")
	await _frames(5)
	texts = ""
	for label in current_scene.find_children("*", "Label", true, false):
		texts += label.text + " "
	_check(texts.contains("Ende der Glutoase") and texts.contains("sechsten Ton gehört") and texts.contains("Kael") and texts.contains("Mira trägt den Splitter"),
			"Ende der Glutoase mit Rückblick")
	_check(not texts.contains("Mira ist gesund"), "Nur Miras Weg, den man gewählt hat")
	buttons = current_scene.find_children("*", "Button", true, false)
	# Beide Regionen durch: Ende der Demo mit Tester-Code, erst nur „Abschluss melden“ (S1)
	_check(texts.contains("Ende der Demo") and Tester.code() != "" and texts.contains(Tester.code()), "Ende der Demo mit Tester-Code")
	_check(buttons.size() == 3 and buttons[0].text == "Abschluss melden" and buttons[0].visible and not buttons[1].visible and not buttons[2].visible,
			"Zuerst nur Abschluss melden")
	buttons[0].pressed.emit()
	_check(not buttons[0].visible and buttons[1].visible and buttons[1].text == "Zurück in die Glutoase" and Tester.gemeldet(), "Nach dem Melden: zurück oder Menü")
	SaveGame.delete()
	SaveGame.path = SaveGame.DEFAULT_PATH
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Tester.datei))
	print("Abspann: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _check(condition: bool, text: String) -> void:
	if not condition:
		_failed += 1
		print("FEHLER: " + text)
