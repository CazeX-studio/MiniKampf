extends SceneTree
## A13a: Dürrewald zwischen Glutoase und Grünwacht (Tor der Oase unten, Tiefwurzel oben, Monster Stufe 18–20).
## Aufruf: Godot --headless --path . -s tests/duerrewald_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _tick(w: WorldState, sekunden: float) -> void:
	var t := 0.0
	while t < sekunden:
		w.tick(0.1)
		t += 0.1
		if not w.players.a.dialog.is_empty():
			w.apply_command("a", {type = "dialog_next"})


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	var w := WorldState.new()
	var p := w.add_player("a", "Test", "novize_m+m1", Vector2i(23, 2))
	w.change_map(p, "glutoase", Vector2i(5, 30))
	p.dialog = {}
	var m := w.get_map("duerrewald")
	_check(m.title == "Dürrewald" and not m.baukasten.is_empty(), "Dürrewald aus dem Baukasten")
	# Das Tor der Oase führt hinein
	var tor := -1
	for i in w.places.size():
		if w.places[i].map == "glutoase" and w.places[i].art == "tor":
			tor = i
	w.apply_command("a", {type = "use", target = "ort:%d" % tor})
	_tick(w, 6.0)
	_check(p.map == "duerrewald", "Das Tor zum Dürrewald ist offen")
	# Von unten bis oben durchgehend begehbar, oben nach Tiefwurzel
	var oben: Dictionary = m.exits.filter(func(e: Dictionary) -> bool: return e.karte == "tiefwurzel")[0]
	_check(m.astar.get_point_path(p.cell, oben.rect.position).size() > 0, "Ein Weg führt von der Oase bis nach Grünwacht")
	w.change_map(p, "duerrewald", oben.rect.position + Vector2i(0, 1))
	w.apply_command("a", {type = "move", cell = oben.rect.position})
	_tick(w, 5.0)
	_check(p.map == "tiefwurzel", "Oben geht es nach Tiefwurzel")
	var zurueck: Array = w.get_map("tiefwurzel").exits.filter(func(e: Dictionary) -> bool: return e.karte == "duerrewald")
	_check(zurueck.size() == 1, "Von Tiefwurzel zurück in den Dürrewald")
	# Monster um Stufe 20, aus Steppe und Wald
	var arten := {}
	for wild: Dictionary in GameData.wild_monsters():
		if wild.karte == "duerrewald":
			_check(int(wild.stufe) >= 18 and int(wild.stufe) <= 20, "Stufe 18–20 (%s, %d)" % [wild.gegner[0], int(wild.stufe)])
			for g: String in wild.gegner:
				arten[g] = true
	_check(arten.has("steppenhyaene") and arten.has("heulwolf") and arten.has("rindenbaer"), "Steppen- und Waldmonster gemischt")
	# Heimweg aus der Glutoase: Der Wegweiser nimmt jetzt den Dürrewald
	w.change_map(p, "glutoase", Vector2i(5, 30))
	p.progress.quests["rueckkehr_gruenwacht"] = "aktiv"
	_check(w._karten_abstand(p, "wipfelheim") == 4, "Von der Glutoase nach Wipfelheim: vier Wechsel über den Dürrewald")
	Tageszeit.feste_stunde = -1.0
	print("Dürrewald: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
