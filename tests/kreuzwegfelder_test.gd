extends SceneTree
## A14: Kreuzwegfelder als eigenes Gebiet vor der Stadt (Südtor, Seitentor am Trainingsplatz, weiter in die Aschensteppe).
## Aufruf: Godot --headless --path . -s tests/kreuzwegfelder_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _gehen(w: WorldState, p: PlayerState, feld: Vector2i) -> void:
	w.apply_command(p.id, {type = "move", cell = feld})
	for i in 600:
		w.tick(0.05)
		if not p.is_moving():
			break


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	var w := WorldState.new()
	var p := w.add_player("a", "Test", "novize_m+m1", Vector2i(31, 62))
	p.dialog = {}
	p.progress.flags["angekommen"] = true
	var m := w.get_map("kreuzwegfelder")
	_check(m.title == "Kreuzwegfelder" and not m.baukasten.is_empty(), "Kreuzwegfelder aus dem Baukasten")
	_gehen(w, p, Vector2i(31, 65))
	_check(p.map == "kreuzweg", "Vor der Anmeldung in der Gilde bleibt das Südtor zu")
	p.progress.flags["gilde_angemeldet"] = true
	_gehen(w, p, Vector2i(31, 65))
	_check(p.map == "kreuzwegfelder", "Nach der Anmeldung: durch das Südtor auf die Felder")
	# Weiter in die Aschensteppe erst nach der Klassenwahl
	_gehen(w, p, Vector2i(20, 35))
	_check(p.map == "kreuzwegfelder", "Vor der Klassenwahl geht es nicht weiter in die Aschensteppe")
	p.progress.flags["klasse_bestaetigt"] = true
	_gehen(w, p, Vector2i(20, 35))
	_check(p.map == "aschensteppe", "Nach der Klassenwahl weiter in die Aschensteppe")
	# Seitentor am Trainingsplatz
	w.change_map(p, "kreuzweg", Vector2i(3, 45))
	_gehen(w, p, Vector2i(0, 45))
	_check(p.map == "kreuzwegfelder" and p.cell.x < 10, "Seitentor am Trainingsplatz führt oben links auf die Felder")
	_gehen(w, p, Vector2i(4, 0))
	_check(p.map == "kreuzweg" and w.get_map("kreuzweg").is_walkable(p.cell), "Und zurück durch das Seitentor")
	# Monster nach Steckbrief: Stufe 1–8
	var arten := {}
	for wild: Dictionary in GameData.wild_monsters():
		if wild.karte == "kreuzwegfelder":
			_check(int(wild.stufe) >= 1 and int(wild.stufe) <= 8, "Stufe 1–8 (%s, %d)" % [wild.gegner[0], int(wild.stufe)])
			_check(m.is_walkable(Vector2i(int(wild.feld[0]), int(wild.feld[1]))), "%s steht auf freiem Feld" % wild.gegner[0])
			for g: String in wild.gegner:
				arten[g] = true
	for id: String in ["tauschleim", "wiesenhoppler", "knollenkaefer", "loewenzahnling", "funkenflirr", "glutigel", "kronenschleim"]:
		_check(arten.has(id) and KartenSpiel.card(id).has("name"), "%s lebt auf den Feldern und hat eine Karte" % id)
	Tageszeit.feste_stunde = -1.0
	print("Kreuzwegfelder: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
