extends SceneTree
## Die Demo endet nach beiden Regionen (Marco, 06.11.): Am Ende der Glutoase startet der Weg nach Grünwacht und
## umgekehrt; die Torwache schickt einen dann ohne zweites „Ende von Akt 1“ los.
## Aufruf: Godot --headless --path . -s tests/zwei_regionen_test.gd

var _failed := 0
var _szenen: Array[String] = []


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _reden(world: WorldState, p: PlayerState, dialog: String, antworten: Array = []) -> void:
	world.start_dialog(p, dialog)
	for i in 60:
		if not p.in_dialog():
			break
		if world.dialog_view(p).antworten.is_empty():
			world.apply_command(p.id, {type = "dialog_next"})
		else:
			world.apply_command(p.id, {type = "dialog_choose", index = antworten.pop_front() if not antworten.is_empty() else 0})


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	# Glutoase zuerst (Klingentänzerin): Hadrak beendet die Region
	var world := WorldState.new()
	world.scene_requested.connect(func(_id: String, szene: String) -> void: _szenen.append(szene))
	var p := world.add_player("a", "Test", "novize_w+w1", Vector2i(23, 2))
	p.progress.flags = {"klasse": "blade", "klasse_gelernt": true, "tor_glutoase": true, "mira_entschieden": true}
	p.progress.quests = {"abreise": "abgegeben", "nach_glutoase": "abgegeben", "miras_splitter": "fertig"}
	world.change_map(p, "glutoase", Vector2i(25, 13))
	_reden(world, p, "hadrak")
	_check(p.progress.quest_state("miras_splitter") == "abgegeben", "Ende der Glutoase")
	_check(p.progress.quest_state("nach_gruenwacht") == "aktiv", "Danach: Der Weg nach Grünwacht")
	_check(_szenen == ["abspann:glutoase"], "Abspann der Glutoase")
	_check(not Abspann.demo_zu_ende(p.progress.quests), "Demo noch nicht zu Ende")
	# Am Westtor: kein zweites Ende von Akt 1
	_szenen.clear()
	_reden(world, p, "torwache_gruenwacht")
	_check(p.progress.flags.has("tor_gruenwacht") and _szenen.is_empty(), "Torwache schickt einen ohne Abspann nach Grünwacht")
	# Grünwacht zu Ende: jetzt ist die Demo durch, und der Weg in die Glutoase startet nicht noch einmal
	p.progress.quests["die_wahrheit"] = "fertig"
	p.progress.flags["wahrheit_entschieden"] = true
	world.change_map(p, "wipfelheim", Vector2i(16, 15))
	_reden(world, p, "ysolde")
	_check(p.progress.quest_state("die_wahrheit") == "abgegeben", "Ende von Grünwacht")
	_check(p.progress.quest_state("nach_glutoase") == "abgegeben", "Weg in die Glutoase bleibt erledigt")
	_check(Abspann.demo_zu_ende(p.progress.quests), "Demo nach beiden Regionen zu Ende")

	# Grünwacht zuerst (Bogenschütze): Ysolde beendet die Region, danach geht es in die Glutoase
	var world2 := WorldState.new()
	var q := world2.add_player("b", "Test", "novize_w+w1", Vector2i(23, 2))
	q.progress.flags = {"klasse": "archer", "klasse_gelernt": true, "tor_gruenwacht": true, "wahrheit_entschieden": true}
	q.progress.quests = {"abreise": "abgegeben", "nach_gruenwacht": "abgegeben", "die_wahrheit": "fertig"}
	world2.change_map(q, "wipfelheim", Vector2i(16, 15))
	_reden(world2, q, "ysolde")
	_check(q.progress.quest_state("nach_glutoase") == "aktiv", "Bogenschütze: danach der Weg in die Glutoase")
	_reden(world2, q, "torwache_glutoase")
	_check(q.progress.flags.has("tor_glutoase"), "Torwache am Südtor schickt einen los")
	print("Zwei Regionen: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
