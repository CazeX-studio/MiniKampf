extends SceneTree
## Prüft den Klassenwahl-Bildschirm und den Abspann (mit Anzeige, ohne Fenster).
## Aufruf: Godot --headless --path . --script res://tests/klassenwahl_test.gd

var _failed := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var p := PlayerState.new("spieler", "Du", "elf_m", Vector2i(20, 36))
	p.progress.quests = {sternenfall = "abgegeben", abreise = "aktiv"}
	p.progress.flags = {"angekommen": true, "ausbildung_morgen": true, "abreise_angekuendigt": true, "sternenfall": true}
	p.progress.level = 9
	p.progress.items = {heiltrank = 2}
	SaveGame.save(p)

	change_scene_to_file("res://scenes/klassenwahl.tscn")
	await _frames(5)
	var screen: Node = current_scene
	_check(screen._list_buttons.size() == 11, "Alle 11 Klassen stehen zur Wahl")
	screen._select("kunoichi")
	_check(screen._title.text == "Kunoichi" and screen._info.text.contains("Siegelmeisterin Akane"), "Kunoichi mit Lehrmeisterin")
	_check(screen._ult.text.contains("Tausend Siegel"), "Ult-Vorschau")
	# A3: Klassen außerhalb der Demo sind sichtbar, aber gesperrt
	_check(screen._choose_button.disabled and screen._trial_button.disabled and screen._sperre.text.contains("später"), "Kunoichi kommt später: gesperrt")
	_check(screen._list_buttons["kunoichi"].text.contains("später") and not screen._list_buttons["blade"].text.contains("später"), "Liste zeigt, was später kommt")
	screen._trial()
	await _frames(3)
	_check(not current_scene is Combat, "Keine Probestunde einer gesperrten Klasse")

	# Probestunde von der Klassenwahl aus: danach zurück zur Klassenwahl
	screen._select("blade")
	screen._trial()
	await _frames(5)
	_check(current_scene is Combat and BattleRequest.return_scene == "res://scenes/klassenwahl.tscn", "Probestunde startet")
	var combat: Combat = current_scene
	_check(combat.state.heroes[0].klass == "blade", "Du spielst die Klingentänzerin")
	combat._back_to_world(true)
	await _frames(5)
	_check(current_scene.has_method("_select"), "Zurück auf der Klassenwahl")

	# Wählen
	current_scene._select("archer")
	current_scene._ask_confirm()
	current_scene._choose()
	await _frames(5)
	_check(SaveGame.get_flag("klasse") == "archer" and SaveGame.get_flag("klasse_gewaehlt") == "ja", "Wahl im Spielstand")
	_check(current_scene.has_method("local_player"), "Zurück in Kreuzweg")
	var local: PlayerState = current_scene.local_player()
	_check(local.progress.flags.get("klasse") == "archer", "Die Stadt kennt die Wahl")
	_check(local.progress.flags.has("kampf_gewonnen:probe:blade"), "Die Probestunde von der Klassenwahl zählt auch")

	# Beim Gesandten: nur die Klassen seiner Region, ohne „Wählen“
	Klassenwahl.region = "Glutoase"
	change_scene_to_file("res://scenes/klassenwahl.tscn")
	await _frames(5)
	screen = current_scene
	_check(screen._list_buttons.size() == 3 and screen._list_buttons.has("singer"), "Glutoase: drei Klassen")
	Klassenwahl.region = "Arkanum"
	change_scene_to_file("res://scenes/klassenwahl.tscn")
	await _frames(5)
	screen = current_scene
	_check(screen._list_buttons.size() == 2 and screen._list_buttons.has("tank") and screen._list_buttons.has("twilight"), "Arkanum: zwei Klassen")
	screen._select("twilight")
	screen._trial()
	await _frames(3)
	_check(not current_scene is Combat, "Arkanum: keine Probestunde (kommt später)")
	Klassenwahl.region = ""
	# Die Gesandten der anderen Regionen bleiben, bieten aber noch nichts an
	for g: String in ["gesandte_arkanum", "gesandte_messinghafen", "gesandte_nebelinseln"]:
		var text := JSON.stringify(GameData.dialog(g))
		_check(not text.contains("klassenwahl:") and text.contains("noch_zu"), "%s bietet noch nichts an" % g)
	_check(JSON.stringify(GameData.dialog("gesandte_glutoase")).contains("klassenwahl:Glutoase"), "Gesandte der Glutoase zeigt ihre Klassen")

	change_scene_to_file("res://scenes/abspann.tscn")
	await _frames(5)
	var texts := ""
	for label in current_scene.find_children("*", "Label", true, false):
		texts += label.text + " "
	_check(texts.contains("Bogenschütze") and texts.contains("nach Grünwacht") and texts.contains("Pfadmeister Fenn"), "Abspann nennt Klasse, Region, Lehrmeister")

	SaveGame.delete()
	print("Klassenwahl: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _check(condition: bool, text: String) -> void:
	if not condition:
		_failed += 1
		print("FEHLER: " + text)
