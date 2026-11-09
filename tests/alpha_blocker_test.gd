extends SceneTree
## A1a: Blocker aus dem Alpha-Test (ALPHA_FEEDBACK.md Punkte 24, 30, 32, 40).
## Aufruf: Godot --headless --path . -s tests/alpha_blocker_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _reden(world: WorldState, p: PlayerState, dialog: String) -> void:
	world.start_dialog(p, dialog)
	for i in 60:
		if not p.in_dialog():
			break
		if world.dialog_view(p).antworten.is_empty():
			world.apply_command(p.id, {type = "dialog_next"})
		else:
			world.apply_command(p.id, {type = "dialog_choose", index = 0})


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	# Punkt 40: Nach der Glutoase zeigt der Wegweiser bis zum Seilaufzug, der Aufzug bringt einen nach Wipfelheim
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "novize_w+w1", Vector2i(23, 2))
	p.progress.flags = {"klasse": "blade", "klasse_gelernt": true, "klasse_bestaetigt": true, "tor_glutoase": true, "mira_entschieden": true}
	p.progress.quests = {"abreise": "abgegeben", "nach_glutoase": "abgegeben", "miras_splitter": "fertig"}
	world.change_map(p, "glutoase", Vector2i(25, 13))
	_reden(world, p, "hadrak")
	world.change_map(p, "kreuzweg", Vector2i(4, 29))
	_reden(world, p, "torwache_gruenwacht")
	_check(world._exit_towards(p, "wipfelheim") != Vector2i(-1, -1), "Kreuzweg: Wegweiser zum Westtor")
	world.change_map(p, "weg_gruenwacht", Vector2i(55, 9))
	_check(world._exit_towards(p, "wipfelheim") != Vector2i(-1, -1), "Weg nach Grünwacht: Wegweiser in den Wald")
	world.change_map(p, "waldboden", Vector2i(40, 18))
	var aufzug := world._exit_towards(p, "wipfelheim")
	_check(aufzug == Vector2i(20, 18), "Waldboden: Wegweiser zeigt auf den Seilaufzug")
	world.change_map(p, "waldboden", Vector2i(20, 19))
	var ort := world.usable_near(p)
	_check(ort.begins_with("ort:"), "Seilaufzug ist nebenan benutzbar")
	world.apply_command("a", {type = "use", target = ort})
	for i in 30:
		world.tick(0.1)
	_check(p.map == "wipfelheim", "Seilaufzug bringt einen nach Wipfelheim")

	# Punkt 32: Der Tanz mit der Pause geht auch tagsüber
	var w2 := WorldState.new()
	var q := w2.add_player("b", "Test", "novize_w+w1", Vector2i(23, 2))
	q.progress.flags = {"klasse": "blade", "klasse_gelernt": true}
	q.progress.quests = {"miras_lied": "abgegeben", "fest_der_glut": "aktiv"}
	w2.nacht = false
	w2.change_map(q, "glutoase", Vector2i(25, 13))
	w2.start_dialog(q, "samira")
	_check(w2.dialog_view(q).text.contains("erste Schritt"), "Tagsüber: Samira tanzt sofort")

	# Punkt 30: Kochende Brunnen zeigt den Weg zu beiden Wasserstellen
	var r := w2.add_player("c", "Test", "novize_w+w1", Vector2i(23, 2))
	r.progress.quests = {"nach_glutoase": "abgegeben", "kochende_brunnen": "aktiv"}
	w2.change_map(r, "palmenrast", Vector2i(20, 20))
	_check(w2._quest_place(r, "kochende_brunnen").get("feld") == Vector2i(5, 7), "Wegweiser zur Wasserstelle im Nordwesten")
	r.progress.flags["wasserstelle_nordwest"] = true
	_check(w2._quest_place(r, "kochende_brunnen").get("feld") == Vector2i(34, 6), "Danach zur dampfenden Wasserstelle")

	# Punkt 24: Nach dem Lernen der Klasse läuft man in Klassenkleidung; die Sternensängerin gibt es nur für Frauen (Marco, 09.11.)
	for klasse: String in FigurTeile.KLASSEN_KOERPER:
		for kopf: String in ["novize_m+m1", "novize_w+w1"]:
			if not FigurTeile.klasse_erlaubt(kopf, klasse):
				continue
			var neu := FigurTeile.mit_klasse(kopf, klasse)
			_check(not FigurTeile.koerper_von(neu).begins_with("novize"), "%s mit %s: %s" % [klasse, kopf, neu])
	_check(not FigurTeile.klasse_erlaubt("novize_m+m1", "singer"), "Männer können keine Sternensängerin werden")
	_check(FigurTeile.klasse_erlaubt("novize_w+w1", "singer"), "Frauen schon")
	_check(FigurTeile.klasse_erlaubt("novize_m+m1", "blade"), "Männer können Klingentänzer werden")
	print("Alpha-Blocker: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
