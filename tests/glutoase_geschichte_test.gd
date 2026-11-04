extends SceneTree
## D28 und D29: Geschichte der Glutoase: Kochende Brunnen (Nadia, zwei Wasserstellen, Kampf, Brakkus' Ahnung) und
## Miras Lied (fünf Töne aufschreiben, der sechste fehlt), der Tanz mit der Pause und Kael in Hadraks Schmiede.
## Aufruf: Godot --headless --path . -s tests/glutoase_geschichte_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


## Gespräch führen; antworten: welche Antwort jeweils (sonst die erste)
func _reden(world: WorldState, p: PlayerState, dialog: String, antworten: Array = []) -> void:
	world.start_dialog(p, dialog)
	for i in 60:
		if not p.in_dialog():
			break
		if world.dialog_view(p).antworten.is_empty():
			world.apply_command(p.id, {type = "dialog_next"})
		else:
			world.apply_command(p.id, {type = "dialog_choose", index = antworten.pop_front() if not antworten.is_empty() else 0})


func _ort(world: WorldState, dialog: String) -> int:
	for i in world.places.size():
		if world.places[i].get("dialog", "") == dialog:
			return i
	return -1


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "novize_w+w1", Vector2i(23, 2))
	p.progress.flags["klasse"] = "blade"
	p.progress.flags["klasse_gelernt"] = true
	p.progress.quests = {"abreise": "abgegeben", "nach_glutoase": "abgegeben", "klasse_lernen": "abgegeben"}
	world.change_map(p, "glutoase", Vector2i(25, 13))
	_check(_ort(world, "wasserstelle_nordwest") >= 0 and _ort(world, "wasserstelle_nordost") >= 0, "Zwei Wasserstellen in der Palmenrast")

	_reden(world, p, "nadia")
	_check(p.progress.quest_state("kochende_brunnen") == "aktiv", "Nadia bittet um Hilfe: „Kochende Brunnen“")
	_reden(world, p, "wasserstelle_nordost")
	_check(not p.progress.flags.has("quelle_gekuehlt"), "Erst die Wasserstelle im Nordwesten")
	_reden(world, p, "wasserstelle_nordwest")
	_check(p.progress.flags.has("wasserstelle_nordwest"), "Nordwesten: Das Wasser ist warm wie Tee")
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "heisse_quelle", gewonnen = true})
	_check(p.progress.flags.has("quelle_gekuehlt"), "Nordosten: Kampf an der dampfenden Quelle gewonnen")
	_reden(world, p, "brakkus")
	_check(p.progress.flags.has("brakkus_ketten") and p.progress.quest_state("kochende_brunnen") == "fertig", "Brakkus ahnt: Hadraks Ketten geben nach")
	_reden(world, p, "nadia")
	_check(p.progress.quest_state("kochende_brunnen") == "abgegeben", "Zurück bei Nadia")

	# Miras Lied: falsche Töne lassen Mira noch einmal summen, die richtigen ergeben fünf Töne
	_reden(world, p, "mira_glutoase", [0, 1, 0, 1, 2, 0, 0])
	_check(p.progress.quest_state("miras_lied") == "abgegeben" and p.progress.flags.has("fuenf_toene"), "Mit Mira fünf Töne aufgeschrieben")
	_check(p.progress.item_count("miras_notenblatt") == 1, "Miras Notenblatt in der Tasche")
	var g: Dictionary = GameData.get_file("kaempfe").heisse_quelle
	_check(g.get("eigene_klasse", false) and g.merken == "quelle_gekuehlt", "Der Kampf an der Quelle ist ein Kampf mit der eigenen Klasse")

	# D29: Der Tanz mit der Pause (nur nachts), Kael provoziert Hadrak, Rivalenkampf in der Schmiede
	_reden(world, p, "samira")
	_check(p.progress.quest_state("fest_der_glut") == "aktiv", "Samira lädt zum Fest ein")
	world.nacht = false
	world.start_dialog(p, "samira")
	_check(world.dialog_view(p).text.contains("heute Nacht"), "Tagsüber: erst heute Nacht")
	world.apply_command("a", {type = "dialog_next"})
	world.nacht = true
	# Schritte: einmal falsch (Sprung), dann richtig; in der Pause erst weitertanzen, dann lauschen
	_reden(world, p, "samira", [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1])
	_check(p.progress.flags.has("sechster_ton"), "In der Pause den sechsten Ton gehört")
	_check(p.progress.quest_state("fest_der_glut") == "abgegeben" and p.progress.quest_state("rivale_kael") == "aktiv", "Kael fordert Hadrak heraus")
	world.change_map(p, "glutoase", Vector2i(26, 40))
	_check(world._npc_present(p, "kael_glutoase"), "Kael wartet in Hadraks Schmiede")
	_check(Sandbox.ENEMIES.has("kael_rivale") and ResourceLoader.exists("res://assets/figuren/kael_kampf_attack_anim_f3.png"), "Kael kämpft mit seinen eigenen Bildern")
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "kael_rivale", gewonnen = true})
	_reden(world, p, "hadrak")
	_check(p.progress.quest_state("rivale_kael") == "abgegeben", "Hadrak dankt (in zwei Worten)")
	_reden(world, p, "hadrak")
	_check(p.progress.flags.has("hadrak_gerannt"), "Nachts mit seinem Vertrauen: „Wir sind gerannt.“")
	Tageszeit.feste_stunde = -1.0
	print("Glutoase-Geschichte: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
