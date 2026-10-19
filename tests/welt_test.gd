extends SceneTree
## Prüft die Steuerung in der Welt ohne Grafik (WorldState-Befehle).
## Aufruf: Godot --headless --path . --script res://tests/welt_test.gd

var _failed := 0


func _initialize() -> void:
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
	var talked := []
	world.dialog_started.connect(func(player_id: String, npc_id: String, _lines: Array) -> void: talked.append([player_id, npc_id]))
	world.apply_command("b", {type = "interact"})
	_tick(world, 0.1)
	_check(talked == [["b", "ye"]], "Aktions-Taste neben Ye startet das Gespräch")
	# Weit weg: nichts passiert
	talked.clear()
	world.apply_command("a", {type = "interact"})
	_tick(world, 0.1)
	_check(talked.is_empty(), "Aktions-Taste ohne NPC in der Nähe macht nichts")
	# Klicken zum Hinlaufen geht weiterhin
	world.apply_command("a", {type = "move", cell = Vector2i(11, 15)})
	_tick(world, 5.0)
	_check(b.cell == Vector2i(13, 10) and p.cell == Vector2i(11, 15), "Klicken zum Hinlaufen funktioniert weiter")

	print("Welt-Steuerung: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


func _tick(world: WorldState, seconds: float) -> void:
	var t := 0.0
	while t < seconds:
		world.tick(0.05)
		t += 0.05


func _check(condition: bool, text: String) -> void:
	if not condition:
		_failed += 1
		print("FEHLER: " + text)
