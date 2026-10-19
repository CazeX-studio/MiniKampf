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
	var p := world.add_player("a", "Test", "elf_m", WorldState.start_cell())
	var notices: Array[String] = []
	world.notice.connect(func(_id: String, text: String) -> void: notices.append(text))

	# Ankunft: Einleitung am Stadttor, danach der erste Auftrag
	world.apply_command("a", {type = "start"})
	_check(p.in_dialog() and world.dialog_view(p).wer == "Erzähler", "Beim Betreten kommt die Einleitung")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	_check(not p.in_dialog(), "Einleitung endet")
	_check(p.progress.quest_state("ankunft") == "aktiv", "Auftrag „Ankunft in Kreuzweg“ läuft")
	_check(world.objective(p) == "Bei Schreiberin Lene anmelden", "Ziel-Hinweis zeigt die Anmeldung")
	_check(world.npc_marker(p, "schreiberin") == "?" and world.npc_marker(p, "ye") == "", "Zeichen ? über der Gildenschreiberin")
	world.apply_command("a", {type = "start"})
	_check(not p.in_dialog(), "Die Einleitung kommt nur einmal")

	# Ye vor der Anmeldung: schickt einen zur Gilde
	_talk(world, p, "ye")
	_check(world.dialog_view(p).text.contains("Gilde eintragen"), "Ye schickt Unangemeldete zur Gilde")
	world.apply_command("a", {type = "dialog_next"})

	# Anmeldung bei der Gildenschreiberin (mit Nachfrage)
	_talk(world, p, "schreiberin")
	_check(world.dialog_view(p).antworten.size() == 2, "Schreiberin fragt, ob sie dich eintragen soll")
	world.apply_command("a", {type = "dialog_choose", index = 1})
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("ankunft") == "abgegeben" and p.progress.quest_state("zu_ye") == "aktiv", "Angemeldet, weiter zu Ye")
	_check(not "Auftrag erfüllt: Ankunft in Kreuzweg – zurück zum Auftraggeber!" in notices, "Keine überflüssige Meldung bei sofortiger Abgabe")
	world.apply_command("a", {type = "dialog_next"})
	_check(world.npc_marker(p, "ye") == "?", "Zeichen ? über Ye")

	# Bei Ye melden, Fragen stellen, ersten Auftrag annehmen
	_talk(world, p, "ye")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	_check(world.dialog_view(p).antworten.size() == 3, "Ye fragt nach Fragen (drei Antworten)")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(world.dialog_view(p).text.contains("Schild hoch"), "Antwort 1: Schild hoch, Schild runter")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_choose", index = 2})
	world.apply_command("a", {type = "dialog_choose", index = 1})
	_check(p.progress.quest_state("erster_auftrag") == "neu", "„Später“ nimmt den Auftrag nicht an")
	world.apply_command("a", {type = "dialog_next"})
	_check(world.npc_marker(p, "ye") == "!", "Zeichen ! über Ye, solange sein Auftrag offen ist")
	_talk(world, p, "ye")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("erster_auftrag") == "aktiv", "Erster Auftrag angenommen")
	world.apply_command("a", {type = "dialog_next"})

	# Schmiedin Bescheid sagen, drei Kräuter sammeln
	_check(world.npc_marker(p, "schmiedin") == "?", "Zeichen ? über der Schmiedin")
	_talk(world, p, "schmiedin")
	world.apply_command("a", {type = "dialog_next"})
	_check(p.progress.flags.has("schmiedin_bescheid") and world.npc_marker(p, "schmiedin") == "", "Schmiedin weiß Bescheid")
	for i in world.pickups.size():
		world.apply_command("a", {type = "use", target = "punkt:%d" % i})
		_tick(world, 10.0)
	_check(p.progress.item_count("kraut") == 3, "Drei Silberkräuter in der Tasche")
	_check(not world.can_use(p, "punkt:0"), "Ein eingesammeltes Kraut ist für diesen Spieler weg")
	_check(p.progress.quest_state("erster_auftrag") == "fertig", "Auftrag ist erfüllt")
	_check(world.objective(p) == "Zurück zu Ausbilder Ye" and world.npc_marker(p, "ye") == "?", "Ziel: zurück zu Ye")

	# Abgeben: Belohnung, Stufe 2
	_talk(world, p, "ye")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("erster_auftrag") == "abgegeben", "Auftrag ist abgegeben")
	_check(p.progress.gold == 25 and p.progress.item_count("heiltrank") == 1 and p.progress.item_count("kraut") == 0,
		"Belohnung: 25 Gold und ein Heiltrank, die Kräuter sind weg")
	_check(p.progress.xp == 100 and p.progress.level == 2, "100 Erfahrung = Stufe 2")
	_check("Stufe 2 erreicht!" in notices, "Meldung „Stufe 2 erreicht!“ kommt")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	_check(not p.in_dialog() and world.objective(p) == "", "Alles erledigt, kein offenes Ziel")

	# Grundausbildung: Ye steht jetzt am Stadttor
	_check(not world.npc_visible(p, "ye") and world.npc_visible(p, "ye_tor"), "Ye ist von der Gilde ans Stadttor gegangen")
	_check(world.npc_marker(p, "ye_tor") == "!", "Zeichen ! über Ye am Tor")
	var battles: Array[String] = []
	world.battle_requested.connect(func(_id: String, kampf: String) -> void: battles.append(kampf))
	_talk(world, p, "ye_tor")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("grundausbildung") == "aktiv", "Grundausbildung angenommen")
	for lesson: String in ["lektion_tempo", "lektion_faehigkeiten", "lektion_parieren", "lektion_reihen"]:
		if not p.in_dialog():
			_talk(world, p, "ye_tor")
		world.apply_command("a", {type = "dialog_choose", index = 0})
		_check(battles.back() == lesson and not p.in_dialog(), "Ye startet " + lesson)
		# Verlieren zählt nicht, gewinnen schon
		world.apply_command("a", {type = "kampf_ergebnis", kampf = lesson, gewonnen = false})
		_check(not world.goal_done(p, {art = "kampf", kampf = lesson}), lesson + " verloren: noch nicht bestanden")
		world.apply_command("a", {type = "kampf_ergebnis", kampf = lesson, gewonnen = true})
		_check(world.goal_done(p, {art = "kampf", kampf = lesson}), lesson + " gewonnen: bestanden")
	_check(p.progress.quest_state("grundausbildung") == "fertig", "Alle vier Lektionen bestanden")
	var xp_before := p.progress.xp
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "lektion_tempo", gewonnen = true})
	_check(p.progress.xp == xp_before, "Erfahrung gibt es nur beim ersten Sieg")
	_talk(world, p, "ye_tor")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("grundausbildung") == "abgegeben", "Grundausbildung abgegeben")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("erster_gruppenkampf") == "aktiv" and battles.back() == "gruppenkampf", "Gruppenkampf beginnt")
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "gruppenkampf", gewonnen = true})
	_check(world.npc_marker(p, "ye_tor") == "?", "Zurück zu Ye nach dem Gruppenkampf")
	_talk(world, p, "ye_tor")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("erster_gruppenkampf") == "abgegeben", "Gruppenkampf abgegeben")
	_check(p.progress.xp == 700 and p.progress.level == 5, "Nach der Grundausbildung: Stufe 5 (700 Erfahrung)")
	_check(p.progress.item_count("heiltrank") == 3 and p.progress.gold == 75, "Belohnungen: 3 Heiltränke, 75 Gold")
	world.apply_command("a", {type = "dialog_next"})
	_check(not p.in_dialog() and world.objective(p) == "", "Grundausbildung vorbei, kein offenes Ziel")

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


## Zum NPC laufen und warten, bis das Gespräch beginnt.
func _talk(world: WorldState, p: PlayerState, npc: String) -> void:
	world.apply_command(p.id, {type = "talk", npc = npc})
	_tick(world, 10.0)
