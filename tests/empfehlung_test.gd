extends SceneTree
## A19: Die Stadtwachen verlangen Ye's Empfehlungsschreiben (design.md: Novizen kommen ohne nicht in die Städte).
## Aufruf: Godot --headless --path . -s tests/empfehlung_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _gehen(w: WorldState, p: PlayerState, feld: Vector2i) -> void:
	w.apply_command(p.id, {type = "move", cell = feld})
	for i in 300:
		w.tick(0.05)
		if not p.is_moving():
			break


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	var w := WorldState.new()
	var meldungen: Array[String] = []
	w.notice.connect(func(_id: String, text: String) -> void: meldungen.append(text))
	var p := w.add_player("a", "Test", "novize_m+m1", Vector2i(31, 62))
	p.dialog = {}
	p.progress.flags["klasse_bestaetigt"] = true
	w.change_map(p, "aschensteppe", Vector2i(14, 56))
	_gehen(w, p, Vector2i(14, 59))
	_check(p.map == "aschensteppe" and meldungen.has(GameData.text("wache_halt")), "Ohne Schreiben: Die Stadtwache hält dich vor der Glutoase auf")
	# Lene stellt ein neues aus
	w.change_map(p, "kreuzweg", Vector2i(30, 30))
	w.start_dialog(p, "schreiberin")
	_check(w.dialog_view(p).text.contains("Empfehlungsschreiben"), "Lene merkt, dass das Schreiben fehlt")
	w.apply_command("a", {type = "dialog_next"})
	_check(p.progress.item_count("empfehlungsschreiben") == 1, "Lene schreibt ein neues")
	meldungen.clear()
	w.change_map(p, "aschensteppe", Vector2i(14, 56))
	_gehen(w, p, Vector2i(14, 59))
	_check(p.map == "glutoase" and meldungen.has(GameData.text("wache_durch")), "Mit Schreiben: Die Wache winkt dich hinein")
	meldungen.clear()
	w.change_map(p, "aschensteppe", Vector2i(14, 56))
	_gehen(w, p, Vector2i(14, 59))
	_check(p.map == "glutoase" and not meldungen.has(GameData.text("wache_durch")), "Beim zweiten Mal ohne Meldung")
	# Auf dem Rückweg vom Glutgrat fragt niemand
	var q := w.add_player("b", "Test", "novize_m+m1", Vector2i(31, 62))
	q.progress.flags["klasse_bestaetigt"] = true
	w.change_map(q, "glutgrat", Vector2i(20, 33))
	q.dialog = {}
	_gehen(w, q, Vector2i(20, 35))
	_check(q.map == "glutoase", "Vom Glutgrat zurück in die Stadt geht ohne Prüfung")
	# Alter Spielstand: Wer schon abgereist ist, hat das Schreiben
	var alt := Progress.new()
	alt.load_dict({quests = {abreise = "abgegeben"}, flags = {klasse_bestaetigt = true}})
	_check(alt.item_count("empfehlungsschreiben") == 1, "Alter Spielstand nach der Abreise bekommt das Schreiben")
	Tageszeit.feste_stunde = -1.0
	print("Empfehlungsschreiben: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
