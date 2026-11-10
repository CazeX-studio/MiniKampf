extends SceneTree
## Spielstand-Editor (S5): Für jede Demo-Klasse an jeden Sprungpunkt springen. Danach steht der Auftrag an:
## Der Auftraggeber hat ein „!“ (oder der Auftrag ist schon aktiv), man steht auf einem begehbaren Feld, alle
## Aufträge davor sind erledigt. Dazu: Der Editor speichert Stufe, Gold, Gegenstände und Klasse.
## Aufruf: Godot --headless --path . -s tests/spielstand_editor_test.gd

const TEST_SAVE := "user://test_spielstand_editor.json"

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	Tageszeit.feste_stunde = 12.0
	for klasse: String in ["", "blade", "smith", "singer", "archer", "tamer"]:
		var fehler: Array = []
		var weg := Sprung.pfad(klasse)
		for ziel: String in weg:
			var world := WorldState.new()
			var p := world.add_player("a", "Test", "novize_w+w1", WorldState.start_cell())
			Sprung.springen(world, p, ziel, klasse)
			var info := GameData.quest(ziel)
			var stand := p.progress.quest_state(ziel)
			var ok := false
			if info.has("start_bei"):
				ok = stand == "neu" and world.npc_marker(p, str(info.start_bei)) == "!" and world.npcs[info.start_bei].map == p.map
			else:
				ok = stand in ["aktiv", "fertig"]
			var davor := weg.slice(0, weg.find(ziel)).all(func(q: String) -> bool: return p.progress.quest_state(q) == "abgegeben")
			if not ok or not davor or not world.is_walkable(p.cell, p.map):
				fehler.append("%s (%s, %s, Feld %s)" % [ziel, stand, p.map, p.cell])
			# Nach der Abreise: Klasse gewählt, nach dem Lernen kämpft man mit ihr
			if klasse != "" and weg.find(ziel) > weg.find("klasse_lernen") and p.progress.battle_class() != klasse:
				fehler.append("%s: kämpft als %s" % [ziel, p.progress.battle_class()])
		_check(fehler.is_empty(), "%s: %d Sprungpunkte %s" % [klasse if klasse != "" else "Novize", weg.size(), fehler])
	# Editor-Oberfläche: Stufe, Gold, Gegenstand, Sprung, Speichern
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	var skript: GDScript = load("res://scripts/welt/spielstand_editor.gd")
	skript.speicher = TEST_SAVE
	change_scene_to_file("res://scenes/spielstand_editor.tscn")
	await create_timer(0.3).timeout
	var ed: Node = current_scene
	ed.klasse_setzen("blade")
	ed.springen_zu("die_ketten")
	ed.stufe_setzen(17)
	ed.gold_dazu(1000)
	ed.gegenstand_dazu("heiltrank", 10)
	ed.speichern()
	var world := WorldState.new()
	var p := world.add_player("b", "Test", "novize_w+w1", WorldState.start_cell())
	SaveGame.path = TEST_SAVE
	SaveGame.load_into(p)
	SaveGame.path = SaveGame.DEFAULT_PATH
	_check(p.progress.level == 17 and p.progress.gold >= 1000 and p.progress.total_count("heiltrank") >= 10,
			"Gespeichert: Stufe %d, Gold %d, Heiltränke %d" % [p.progress.level, p.progress.gold, p.progress.total_count("heiltrank")])
	_check(p.progress.quest_state("rivale_kael") == "abgegeben" and p.progress.quest_state("die_ketten") == "aktiv" and p.map == "glutoase",
			"Gespeichert: Die Ketten unter dem Berg stehen an, Ort %s" % p.map)
	_check(p.progress.battle_class() == "blade", "Gespeichert: Klingentänzerin")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("FERTIG: %s" % ("alles gut" if _failed == 0 else "%d Fehler" % _failed))
	quit(1 if _failed > 0 else 0)
