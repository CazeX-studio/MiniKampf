extends SceneTree
## Prüft den Klassenwahl-Bildschirm und den Abspann (mit Anzeige, ohne Fenster).
## Aufruf: Godot --headless --path . --script res://tests/klassenwahl_test.gd

var _failed := 0
## Ein Feld neben Nalia, der Gesandten der Glutoase
const NALIA_NAEHE := Vector2i(54, 29)


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
	# A4: Probestunde beim Gesandten, danach zurück in die Stadt, der Gesandte überreicht das Abzeichen
	# (eigener Spielstand mitten im Auftrag „Die Gesandten“, danach wieder der alte)
	var alter_stand := FileAccess.get_file_as_string(SaveGame.path)
	var mitten := PlayerState.new("spieler", "Du", "elf_m", NALIA_NAEHE)
	mitten.progress.quests = {erster_gruppenkampf = "abgegeben", gesandte = "aktiv"}
	mitten.progress.flags = {"angekommen": true, "ausbildung_morgen": true}
	mitten.progress.level = 4
	SaveGame.save(mitten)
	screen._select("blade")
	screen._trial()
	await _frames(5)
	_check(current_scene is Combat and BattleRequest.return_scene == "res://scenes/kreuzweg.tscn", "Nach der Probestunde beim Gesandten geht es in die Stadt")
	_check(Klassenwahl.nach_probestunde == "gesandte_glutoase", "Danach spricht Nalia einen an")
	current_scene._back_to_world(true)
	await _frames(5)
	_check(current_scene.has_method("local_player") and Klassenwahl.nach_probestunde == "", "Zurück in Kreuzweg")
	var ich: PlayerState = current_scene.local_player()
	for i in 600:
		if ich.in_dialog():
			break
		await process_frame
	_check(ich.in_dialog() and current_scene.state.dialog_view(ich).text.contains("Abzeichen"), "Nalia überreicht das Abzeichen")
	for i in 5:
		current_scene.state.apply_command(ich.id, {type = "dialog_next"})
	_check(ich.progress.item_count("probe_abzeichen") == 1, "Abzeichen in der Tasche")
	current_scene.state.start_dialog(ich, "gesandte_glutoase")
	_check(not current_scene.state.dialog_view(ich).text.contains("Abzeichen"), "Beim nächsten Mal wieder die Klassen")
	current_scene.state.apply_command(ich.id, {type = "dialog_choose", index = 2})
	current_scene._no_save = true
	var datei := FileAccess.open(SaveGame.path, FileAccess.WRITE)
	datei.store_string(alter_stand)
	datei = null
	Klassenwahl.region = "Glutoase"
	change_scene_to_file("res://scenes/klassenwahl.tscn")
	await _frames(5)
	screen = current_scene
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
	# A3b: die fünf Demo-Klassen haben ein gemaltes Klassenbild, die späteren noch nicht
	for id: String in ["smith", "archer", "blade", "tamer", "singer"]:
		_check(Klassenwahl.klassenbild(id) != null, "Klassenbild fehlt: %s" % id)
	_check(Klassenwahl.klassenbild("tank") == null, "Magier-Tank hat noch kein Klassenbild")

	print("Klassenwahl: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _check(condition: bool, text: String) -> void:
	if not condition:
		_failed += 1
		print("FEHLER: " + text)
