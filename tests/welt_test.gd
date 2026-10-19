extends SceneTree
## Prüft die Welt ohne Grafik: Steuerung, Gespräche mit Antworten, Aufträge, Gold, Tasche,
## Erfahrung und Stufen, Speichern und Laden.
## Aufruf: Godot --headless --path . --script res://tests/welt_test.gd

var _failed := 0


func _initialize() -> void:
	_test_steering()
	_test_building_blocks()
	print("Welt: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


func _test_steering() -> void:
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "elf_m", Vector2i(11, 19))

	# Nach oben steuern: Der Spieler läuft auf dem Bildschirm nach oben (Feld x und y werden kleiner)
	var start := p.pos
	world.apply_command("a", {type = "steer", dir = Vector2(0, -1)})
	_tick(world, 0.5)
	_check(p.pos.x < start.x and p.pos.y < start.y, "Steuern nach oben bewegt den Spieler")
	_check(p.is_walking(), "Spieler gilt beim Steuern als laufend")
	world.apply_command("a", {type = "steer", dir = Vector2.ZERO})
	var stop := p.pos
	_tick(world, 0.5)
	_check(p.pos == stop, "Loslassen hält den Spieler an")

	# Gegen ein Haus steuern: Der Spieler darf nie auf einem gesperrten Feld stehen
	world.apply_command("a", {type = "steer", dir = Vector2(1, -1)})
	var ok := true
	for i in 200:
		world.tick(0.05)
		if not world.is_walkable(p.cell):
			ok = false
	_check(ok, "Häuser und Bäume halten den Spieler auf")
	world.apply_command("a", {type = "steer", dir = Vector2.ZERO})

	# Neben Ye stellen und "Aktion": Das Gespräch beginnt
	var b := world.add_player("b", "Test 2", "elf_m", Vector2i(13, 10))
	world.apply_command("b", {type = "interact"})
	_tick(world, 0.1)
	_check(b.in_dialog(), "Aktions-Taste neben Ye startet das Gespräch")
	# Weit weg: nichts passiert
	world.apply_command("a", {type = "move", cell = Vector2i(3, 11)})
	_tick(world, 6.0)
	world.apply_command("a", {type = "interact"})
	_tick(world, 0.1)
	_check(not p.in_dialog(), "Aktions-Taste ohne etwas in der Nähe macht nichts")
	# Klicken zum Hinlaufen geht weiterhin
	world.apply_command("a", {type = "move", cell = Vector2i(11, 15)})
	_tick(world, 5.0)
	_check(p.cell == Vector2i(11, 15), "Klicken zum Hinlaufen funktioniert weiter")


func _test_building_blocks() -> void:
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "elf_m", Vector2i(11, 19))
	var notices: Array[String] = []
	world.notice.connect(func(_id: String, text: String) -> void: notices.append(text))

	# Gespräch mit Ye: Begrüßung, dann Frage mit drei Antworten
	world.apply_command("a", {type = "talk", npc = "ye"})
	_tick(world, 6.0)
	_check(p.in_dialog() and world.dialog_view(p).wer == "Ye", "Hinlaufen zu Ye startet das Gespräch")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	var view := world.dialog_view(p)
	_check(view.antworten.size() == 3, "Ye stellt eine Frage mit drei Antworten")
	world.apply_command("a", {type = "dialog_next"})
	_check(world.dialog_view(p) == view, "Weiter geht nicht, solange eine Antwort gewählt werden muss")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(world.dialog_view(p).text.begins_with("Merk dir eins"), "Antwort 1 führt zum passenden Text")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_choose", index = 2})
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("kraeuter_fuer_ye") == "aktiv", "Auftrag wird über eine Antwort angenommen")
	_check("Neuer Auftrag: Kräuter für Ye (Probe-Auftrag)" in notices, "Meldung „Neuer Auftrag“ kommt")
	world.apply_command("a", {type = "dialog_next"})
	_check(not p.in_dialog(), "Gespräch endet")

	# Drei Kräuter sammeln
	for i in world.pickups.size():
		world.apply_command("a", {type = "use", target = "punkt:%d" % i})
		_tick(world, 8.0)
	_check(p.progress.item_count("kraut") == 3, "Drei Silberkräuter in der Tasche")
	_check(not world.can_use(p, "punkt:0"), "Ein eingesammeltes Kraut ist für diesen Spieler weg")
	_check(p.progress.quest_state("kraeuter_fuer_ye") == "fertig", "Auftrag ist erfüllt, sobald alle Kräuter da sind")

	# Abgeben: Belohnung, Stufe 2
	world.apply_command("a", {type = "talk", npc = "ye"})
	_tick(world, 8.0)
	_check(world.dialog_view(p).antworten.size() == 1, "Ye fragt nach den Kräutern")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("kraeuter_fuer_ye") == "abgegeben", "Auftrag ist abgegeben")
	_check(p.progress.gold == 30 and p.progress.item_count("heiltrank") == 1 and p.progress.item_count("kraut") == 0,
		"Belohnung: 30 Gold und ein Heiltrank, die Kräuter sind weg")
	_check(p.progress.xp == 120 and p.progress.level == 2, "120 Erfahrung = Stufe 2")
	_check("Stufe 2 erreicht!" in notices, "Meldung „Stufe 2 erreicht!“ kommt")

	# Stufen bis 10, nicht weiter
	p.progress.add_xp(100000)
	_check(p.progress.level == 10 and p.progress.xp_range().y == -1, "Höchststufe ist 10")

	# Speichern und Laden
	SaveGame.save(p)
	var copy := PlayerState.new("b", "Kopie", "elf_m", Vector2i(0, 0))
	_check(SaveGame.load_into(copy), "Spielstand lässt sich laden")
	_check(copy.progress.to_dict() == p.progress.to_dict() and copy.cell == p.cell, "Geladener Stand ist gleich")
	# Entscheidungen (z. B. Urbaum) bleiben im Spielstand, auch wenn danach normal gespeichert wird
	SaveGame.set_flag("pilzhoehle_urbaum", "retten")
	var again := PlayerState.new("d", "Wieder", "elf_m", Vector2i(0, 0))
	SaveGame.load_into(again)
	SaveGame.save(again)
	_check(SaveGame.get_flag("pilzhoehle_urbaum") == "retten", "Gespeicherte Entscheidung bleibt erhalten")
	SaveGame.delete()
	_check(SaveGame.get_flag("pilzhoehle_urbaum") == "", "Neu beginnen löscht auch die Entscheidung")
	_check(not SaveGame.load_into(PlayerState.new("c", "Neu", "elf_m", Vector2i(0, 0))), "Gelöschter Spielstand ist weg")


func _tick(world: WorldState, seconds: float) -> void:
	var t := 0.0
	while t < seconds:
		world.tick(0.05)
		t += 0.05


func _check(condition: bool, text: String) -> void:
	if not condition:
		_failed += 1
		print("FEHLER: " + text)
