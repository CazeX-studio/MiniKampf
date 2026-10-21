extends SceneTree
## Prüft Grünwacht Schritt 1 ohne Grafik: mehrere Karten, der Weg von Kreuzweg über den Waldboden und den Seilaufzug
## nach Wipfelheim, der Auftrag „Der Weg nach Grünwacht“, die Figuren dort, Marv, der Koch-Stand und das Speichern.
## Aufruf: Godot --headless --path . --script res://tests/gruenwacht_test.gd

var _failed := 0


func _initialize() -> void:
	_test_maps()
	_test_journey()
	_test_old_save()
	_test_classes()
	_test_separate_maps()
	_test_save()
	_test_wild()
	_test_fenn("verschonen")
	_test_fenn("schiessen")
	_test_tamer(false)
	_test_tamer(true)
	_test_story("jaeger")
	_test_story("zaehmer")
	print("Grünwacht: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


## Die Karten aus data/karten.json: Jede Figur, jeder Ort und jedes Ausgangsziel ist vom Start der Karte aus erreichbar.
func _test_maps() -> void:
	var world := WorldState.new()
	for id: String in ["weg_gruenwacht", "waldboden", "wipfelheim"]:
		_check(world.maps.has(id), "Karte %s ist geladen" % id)
	_check(world.maps.kreuzweg.title == "Kreuzweg" and world.maps.wipfelheim.title == "Wipfelheim", "Karten haben Namen")
	for map_id: String in world.maps:
		var m: WorldMap = world.maps[map_id]
		_check(m.is_walkable(m.start), "%s: Start ist begehbar" % map_id)
		var spots: Array = []
		for id: String in world.npcs:
			if world.npcs[id].map == map_id:
				spots.append(["NPC " + id, world._free_neighbor(world.npcs[id].cell, m.start, map_id)])
		for i in world.places.size():
			if world.places[i].map == map_id:
				var cell: Vector2i = world.places[i].cell
				spots.append(["Ort %d" % i, cell if m.is_walkable(cell) else world._free_neighbor(cell, m.start, map_id)])
		for e: Dictionary in m.exits:
			_check(world.maps.has(e.karte) and world.maps[e.karte].is_walkable(e.feld), "%s: Ausgang nach %s führt auf ein freies Feld" % [map_id, e.karte])
			_check(not e.rect.has_point(e.feld) or e.karte != map_id, "%s: Ausgang führt nicht in sich selbst" % map_id)
			var inside := Vector2i(-1, -1)
			for y in range(e.rect.position.y, e.rect.end.y):
				for x in range(e.rect.position.x, e.rect.end.x):
					if m.is_walkable(Vector2i(x, y)):
						inside = Vector2i(x, y)
			spots.append(["Ausgang nach " + e.karte, inside])
		if map_id == WorldState.KREUZWEG:
			# Kreuzweg ist schon durch die anderen Tests abgedeckt, hier nur der neue Ausgang
			spots = spots.filter(func(s: Array) -> bool: return str(s[0]).begins_with("Ausgang"))
		for spot: Array in spots:
			var cell: Vector2i = spot[1]
			var reachable := cell != Vector2i(-1, -1) and not m.astar.get_id_path(m.start, cell).is_empty()
			_check(reachable, "%s: %s ist erreichbar" % [map_id, spot[0]])
	# Ankunftsfelder der Ausgänge liegen nicht selbst in einem Ausgang (sonst ginge es hin und her)
	for map_id: String in world.maps:
		for e: Dictionary in world.maps[map_id].exits:
			var back := false
			for other: Dictionary in world.maps[e.karte].exits:
				back = back or other.rect.has_point(e.feld)
			_check(not back, "Ankunft auf %s liegt nicht in einem Ausgang" % e.karte)


## Ein Bogenschütze verabschiedet sich von Ye und reist bis zu Ysolde.
func _test_journey() -> void:
	var world := WorldState.new()
	var notes: Array[String] = []
	world.notice.connect(func(_id: String, text: String) -> void: notes.append(text))
	var scenes: Array[String] = []
	world.scene_requested.connect(func(_id: String, scene: String) -> void: scenes.append(scene))
	var p := world.add_player("a", "Test", "elf_m", Vector2i(2, 22))

	# Vor der Klassenwahl führt die Weststraße nirgendwohin
	_walk(world, p, Vector2i(0, 22))
	_check(p.map == "kreuzweg", "Vor der Klassenwahl bleibt man in Kreuzweg")

	# Abschied von Ye: Abspann, danach steht man auf dem Weg, der Auftrag läuft
	p.progress.quests["abreise"] = "aktiv"
	p.progress.flags["klasse"] = "archer"
	p.progress.flags["klasse_gewaehlt"] = true
	world.start_dialog(p, "ye_tor")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("abreise") == "abgegeben", "Abreise abgeschlossen")
	_check("abspann" in scenes, "Abspann kommt")
	_check(p.map == "weg_gruenwacht" and p.cell == Vector2i(37, 6), "Danach steht man auf dem Weg nach Grünwacht")
	_check(p.progress.quest_state("nach_gruenwacht") == "aktiv", "Auftrag „Der Weg nach Grünwacht“ läuft")
	_check(world.objective(p).contains("Wipfelheim"), "Ziel zeigt den Weg nach Wipfelheim: " + world.objective(p))

	# Zurück nach Kreuzweg und wieder hinaus geht auch
	_walk(world, p, Vector2i(39, 6))
	_check(p.map == "kreuzweg" and p.cell == Vector2i(2, 22), "Nach Osten zurück nach Kreuzweg")
	_check(notes.has("– Kreuzweg –"), "Meldung beim Betreten einer Karte")
	_walk(world, p, Vector2i(0, 22))
	_check(p.map == "weg_gruenwacht", "Weststraße führt nach der Klassenwahl auf den Weg")

	# Über den Weg in den Wald, mit dem Steuerknopf (freies Laufen nach links oben = Westen)
	world.apply_command("a", {type = "steer", dir = Vector2(-0.5, -0.25)})
	for i in 600:
		world.tick(0.05)
		if p.map != "weg_gruenwacht":
			break
	world.apply_command("a", {type = "steer", dir = Vector2.ZERO})
	_check(p.map == "waldboden", "Frei gesteuert durch den Wald zum Waldboden")

	# Seilaufzug hinauf
	var lift := _place_target(world, "waldboden", "seilaufzug")
	world.apply_command("a", {type = "use", target = lift})
	_tick(world, 8.0)
	_check(p.map == "wipfelheim" and p.cell == Vector2i(6, 15), "Mit dem Seilaufzug nach Wipfelheim")
	_check(p.progress.flags.has("besucht:wipfelheim"), "Wipfelheim gilt als besucht")
	_check(world.objective(p).contains("Ysolde"), "Ziel: mit Ysolde reden")
	_check(world.npc_marker(p, "ysolde") == "?", "Über Ysolde steht ein „?“")

	# Marv spricht einen auf der Brücke an
	_walk(world, p, Vector2i(21, 13))
	_check(p.in_dialog() and p.dialog.id == "marv_gruenwacht", "Marv spricht einen in Wipfelheim an")
	world.apply_command("a", {type = "dialog_next"})
	_check(world.dialog_view(p).text.contains("Sternentafel"), "Marv will die Sternentafel")
	world.apply_command("a", {type = "dialog_choose", index = 1})
	_check(not p.in_dialog(), "Marv lässt einen gehen")

	# Ysolde
	var gold := p.progress.gold
	world.apply_command("a", {type = "talk", npc = "ysolde"})
	_tick(world, 6.0)
	_check(p.in_dialog() and p.dialog.id == "ysolde", "Gespräch mit Ysolde")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("nach_gruenwacht") == "abgegeben" and p.progress.gold == gold + 50, "Auftrag abgegeben, 50 Gold")
	var answers: Array = world.dialog_view(p).antworten
	_check("Wo finde ich Pfadmeister Fenn?" in answers, "Bogenschütze fragt nach Fenn")
	_check(not "Wo finde ich Professor Esche?" in answers and not "Meine Klasse lernt man nicht hier." in answers, "Keine Fragen anderer Klassen")
	world.apply_command("a", {type = "dialog_choose", index = answers.find("Wo finde ich Pfadmeister Fenn?")})
	_check(world.dialog_view(p).text.contains("Norden"), "Ysolde zeigt nach Norden")
	world.apply_command("a", {type = "dialog_next"})

	# Koch-Stand (Platzhalter) und Fenn
	var stand := _place_target(world, "wipfelheim", "leer")
	world.apply_command("a", {type = "use", target = stand})
	_tick(world, 6.0)
	_check(p.in_dialog() and p.dialog.id == "koch_stand", "Koch-Stand lässt sich ansehen")
	_check(world.dialog_view(p).text.contains("bald gekocht"), "Koch-Stand: Hier wird bald gekocht")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "talk", npc = "fenn"})
	_tick(world, 8.0)
	_check(p.in_dialog() and p.dialog.id == "fenn" and p.dialog.node == "start", "Fenn bietet seinem Schüler die Prüfung an")

	# Und wieder hinunter („Gleich.“)
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_choose", index = 1})
	world.apply_command("a", {type = "use", target = _place_target(world, "wipfelheim", "seilaufzug")})
	_tick(world, 8.0)
	_check(p.map == "waldboden", "Mit dem Seilaufzug wieder hinunter")


## Wer die erste Stunde schon vor Grünwacht beendet hat, bekommt den Auftrag bei Ye am Tor nachträglich.
func _test_old_save() -> void:
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "elf_m", Vector2i(20, 36))
	p.progress.quests["abreise"] = "abgegeben"
	p.progress.flags["klasse"] = "kunoichi"
	p.progress.flags["klasse_bestaetigt"] = true
	p.progress.flags["ausbildung_morgen"] = true
	_check(world.npc_marker(p, "ye_tor") == "!", "Alter Spielstand: Ye am Tor hat ein „!“")
	world.apply_command("a", {type = "talk", npc = "ye_tor"})
	_tick(world, 4.0)
	_check(p.progress.quest_state("nach_gruenwacht") == "aktiv", "Ye gibt den Auftrag „Der Weg nach Grünwacht“")
	_check(world.dialog_view(p).text.contains("Westen"), "Ye zeigt nach Westen")


## Andere Klassen dürfen auch nach Grünwacht (Entscheidung 21.10.).
func _test_classes() -> void:
	for klasse: String in ["tamer", "ritualist"]:
		var world := WorldState.new()
		var p := world.add_player("a", "Test", "elf_m", Vector2i(6, 15))
		p.progress.flags["klasse"] = klasse
		p.progress.quests["nach_gruenwacht"] = "aktiv"
		world.change_map(p, "wipfelheim", Vector2i(16, 16))
		world.apply_command("a", {type = "talk", npc = "ysolde"})
		_tick(world, 4.0)
		world.apply_command("a", {type = "dialog_next"})
		world.apply_command("a", {type = "dialog_choose", index = 0})
		var answers: Array = world.dialog_view(p).antworten
		if klasse == "tamer":
			_check("Wo finde ich Professor Esche?" in answers, "Zähmer fragt nach Esche")
		else:
			_check("Meine Klasse lernt man nicht hier." in answers, "Ritualist: Klasse lernt man woanders")
			_check(not "Wo finde ich Pfadmeister Fenn?" in answers, "Ritualist fragt nicht nach Fenn")


## Figuren und Mitspieler auf anderen Karten: nicht zu sehen, nicht anzusprechen, keine gemeinsame Szene.
func _test_separate_maps() -> void:
	var world := WorldState.new()
	var a := world.add_player("a", "A", "elf_m", Vector2i(16, 16))
	var b := world.add_player("b", "B", "elf_f", Vector2i(16, 16))
	world.change_map(a, "wipfelheim", Vector2i(16, 16))
	_check(world.npc_visible(a, "ysolde") and not world.npc_visible(b, "ysolde"), "Ysolde ist nur in Wipfelheim zu sehen")
	_check(not world.npc_visible(a, "hanne"), "Hanne ist in Wipfelheim nicht zu sehen")
	_check(not world.can_use(b, "npc:ysolde"), "Ysolde ist aus Kreuzweg nicht anzusprechen")
	world.group_members = func(_id: String) -> Array: return ["a", "b"]
	world.group_leader = func(_id: String) -> String: return "a"
	world.apply_command("a", {type = "talk", npc = "ysolde"})
	_tick(world, 4.0)
	_check(a.in_dialog() and not a.dialog.has("szene"), "Gruppe auf verschiedenen Karten: allein im Gespräch")
	_check(not b.in_dialog(), "Wer auf einer anderen Karte steht, wird nicht hineingeholt")


func _test_save() -> void:
	var path := "user://spielstand_test_gruenwacht.json"
	SaveGame.path = path
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "elf_m", Vector2i(6, 15))
	world.change_map(p, "wipfelheim", Vector2i(6, 15))
	SaveGame.save(p)
	var q := PlayerState.new("b", "Test", "elf_m", Vector2i(1, 1))
	_check(SaveGame.load_into(q), "Spielstand lädt")
	_check(q.map == "wipfelheim" and q.cell == Vector2i(6, 15), "Spielstand merkt sich Karte und Feld")
	q.map = "gibt_es_nicht"
	world.fix_position(q)
	_check(q.map == "kreuzweg" and world.is_walkable(q.cell), "Unbekannte Karte im Spielstand: zurück nach Kreuzweg")
	q.map = "wipfelheim"
	q.cell = Vector2i(0, 0)
	world.fix_position(q)
	_check(q.map == "wipfelheim" and q.cell == world.maps.wipfelheim.start, "Belegtes Feld im Spielstand: an den Start der Karte")
	SaveGame.delete()
	SaveGame.path = SaveGame.DEFAULT_PATH


## Schritt 2: Monster auf dem Weg und dem Waldboden, Kampf mit der eigenen Klasse, Erfahrung bis Stufe 20.
func _test_wild() -> void:
	_check(GameData.max_level() == 20, "Höchststufe der Demo ist 20")
	var levels: Array[int] = []
	for m: Dictionary in GameData.wild_monsters():
		if m.karte == "weg_gruenwacht":
			_check(m.stufe >= 10 and m.stufe <= 15, "Monster auf dem Weg: Stufe 10–15 (%d)" % m.stufe)
		elif m.karte == "waldboden":
			_check(m.stufe >= 15 and m.stufe <= 20, "Monster im Wald: Stufe 15–20 (%d)" % m.stufe)
		levels.append(m.stufe)
	_check(levels.min() == 10 and levels.max() == 20, "Monster von Stufe 10 bis 20")

	# Kampf mit der eigenen Klasse, Stärke nach Stufe
	_check(BattleRequest.prepare("wild:0", 12, 0, "archer"), "Kampf gegen ein Monster lässt sich vorbereiten")
	var hero: Dictionary = BattleRequest.setup.helden[0]
	_check(hero.klasse == "archer" and is_equal_approx(float(hero.macht), BattleRequest.hero_power(12)), "Man kämpft als Bogenschütze mit Stärke nach Stufe")
	_check(BattleRequest.setup.gegner_stufe == GameData.wild_monsters()[0].stufe and BattleRequest.setup.hintergrund == "wald", "Monster haben ihre Stufe, Hintergrund Wald")
	BattleRequest.prepare("wild:0", 12, 0, "")
	_check(BattleRequest.setup.helden[0].klasse == "novize", "Ohne Klasse kämpft man als Novize")
	BattleRequest.prepare("probe:archer", 5, 0, "tamer")
	_check(BattleRequest.setup.helden[0].klasse == "archer" and not BattleRequest.setup.helden[0].has("macht"), "Probestunden bleiben wie bisher")
	var group := BattleRequest.build_group("wild:1", [{name = "A", stufe = 11, klasse = "tank"}, {name = "B", stufe = 12, klasse = "singer"}])
	_check(group.helden[0].klasse == "tank" and group.helden[1].klasse == "singer", "Gruppenkampf: jeder mit seiner Klasse")
	BattleRequest.kampf_id = ""

	# In der Welt: hineinlaufen startet den Kampf
	var world := WorldState.new()
	var battles: Array[String] = []
	world.battle_requested.connect(func(_id: String, kampf: String) -> void: battles.append(kampf))
	var p := world.add_player("a", "Test", "elf_m", Vector2i(37, 6))
	p.progress.flags["klasse"] = "archer"
	p.progress.level = 10
	p.progress.xp = 2700
	world.change_map(p, "weg_gruenwacht", Vector2i(37, 6))
	var index := -1
	for i in world.monsters.size():
		if world.monsters[i].karte == "weg_gruenwacht" and index < 0:
			index = i
	var target := "monster:%d" % index
	_check(world.can_use(p, target), "Monster ist zu sehen")
	world.apply_command("a", {type = "use", target = target})
	_tick(world, 6.0)
	_check(battles == ["wild:%d" % index], "Antippen: hinlaufen, der Kampf beginnt (genau einmal)")
	var gold := p.progress.gold
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "wild:%d" % index, gewonnen = true})
	_check(p.progress.xp > 2700 and p.progress.gold > gold, "Sieg: Erfahrung und Gold")
	_check(not world.can_use(p, target), "Besiegtes Monster ist eine Weile weg")
	_tick(world, 2.0)
	_check(battles.size() == 1, "Kein neuer Kampf mit dem besiegten Monster")
	p.progress.flags["besiegt:monster:%d" % index] = Time.get_unix_time_from_system() - WorldState.MONSTER_RESPAWN - 1.0
	_check(world.can_use(p, target), "Nach einer Weile ist es wieder da")
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "wild:%d" % index, gewonnen = false})
	_check(p.cell == world.maps.weg_gruenwacht.start, "Niederlage: Man wacht am Start der Karte auf")

	# Erfahrung reicht bis Stufe 20
	p.progress.add_xp(20000)
	_check(p.progress.level == 20, "Stufe 20 ist erreichbar")

	# Gruppe: Wer in der Nähe steht, kämpft mit
	var w2 := WorldState.new()
	var group_battles: Array = []
	w2.group_battle_requested.connect(func(ids: Array, kampf: String) -> void: group_battles.append([ids, kampf]))
	var a := w2.add_player("a", "A", "elf_m", Vector2i(1, 1))
	var b := w2.add_player("b", "B", "elf_f", Vector2i(1, 1))
	w2.group_members = func(_id: String) -> Array: return ["a", "b"]
	var m: Dictionary = w2.monsters[index]
	w2.change_map(a, "weg_gruenwacht", m.feld + Vector2i(2, 0))
	w2.change_map(b, "weg_gruenwacht", m.feld + Vector2i(3, 0))
	w2.apply_command("a", {type = "use", target = target})
	_tick(w2, 3.0)
	_check(group_battles.size() == 1 and group_battles[0][0].size() == 2, "Gruppe in der Nähe kämpft gemeinsam gegen das Monster")


## Schritt 3: Fenns Prüfung. Wer den Silberhirsch verschont, besteht mit Erfolg; wer schießt, besteht auch, Fenn ist enttäuscht.
func _test_fenn(choice: String) -> void:
	var world := WorldState.new()
	var battles: Array[String] = []
	world.battle_requested.connect(func(_id: String, kampf: String) -> void: battles.append(kampf))
	var p := world.add_player("a", "Test", "elf_m", Vector2i(6, 15))
	p.progress.flags["klasse"] = "archer"
	p.progress.quests["nach_gruenwacht"] = "abgegeben"
	p.progress.level = 12
	world.change_map(p, "wipfelheim", Vector2i(16, 5))
	_check(world.npc_marker(p, "fenn") == "!", "Fenn hat ein „!“ für den Bogenschützen")
	var other := world.add_player("b", "Zähmer", "elf_f", Vector2i(6, 15))
	other.progress.flags["klasse"] = "tamer"
	other.progress.quests["nach_gruenwacht"] = "abgegeben"
	world.change_map(other, "wipfelheim", Vector2i(16, 6))
	_check(world.npc_marker(other, "fenn") == "", "Für den Zähmer kein „!“ bei Fenn")

	world.apply_command("a", {type = "talk", npc = "fenn"})
	_tick(world, 4.0)
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("fenns_pruefung") == "aktiv" and battles == ["fenns_pruefung"], "Prüfung beginnt mit dem Kampf an den Scheiben")
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "fenns_pruefung", gewonnen = true})
	_check(p.progress.flags.has("fenn_ziele"), "Erstes und zweites Ziel geschafft")
	_check(world.objective(p).contains("Silberhirsch"), "Ziel: den Silberhirsch aufspüren")

	var deer := _place_target(world, "waldboden", "silberhirsch")
	_check(not world.can_use(p, deer), "Der Hirsch ist oben in Wipfelheim nicht zu sehen")
	world.change_map(p, "waldboden", Vector2i(14, 12))
	_check(world.can_use(p, deer), "Der Silberhirsch steht im Wald")
	world.apply_command("a", {type = "use", target = deer})
	for i in 600:
		world.tick(0.05)
		if p.in_dialog():
			break
	_check(p.in_dialog() and p.dialog.id == "silberhirsch", "Hinlaufen ohne Monsterkampf, der Hirsch sieht dich an")
	_check(battles.size() == 1, "Auf dem Weg zum Hirsch kein Kampf (um Monster herum gelaufen)")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_choose", index = 1 if choice == "verschonen" else 0})
	world.apply_command("a", {type = "dialog_next"})
	_check(p.progress.quest_state("fenns_pruefung") == "fertig", "Drittes Ziel erledigt (%s)" % choice)
	_check(not world.can_use(p, deer), "Der Hirsch ist danach weg")

	world.change_map(p, "wipfelheim", Vector2i(16, 5))
	world.apply_command("a", {type = "talk", npc = "fenn"})
	_tick(world, 4.0)
	world.apply_command("a", {type = "dialog_next"})
	_check(p.progress.quest_state("fenns_pruefung") == "abgegeben" and p.progress.flags.has("klasse_gelernt"), "Prüfung bestanden (%s)" % choice)
	if choice == "verschonen":
		_check(p.progress.flags.has("erfolg:jaeger_schiesst_nicht"), "Erfolg „Ein Jäger weiß, wann er nicht schießt“")
	else:
		_check(not p.progress.flags.has("erfolg:jaeger_schiesst_nicht") and world.dialog_view(p).text.contains("nicht die Prüfung"), "Fenn ist enttäuscht")

	# Der Kampf selbst: zwei Lektionen, als Bogenschütze
	BattleRequest.prepare("fenns_pruefung", 12, 0, "archer")
	_check(BattleRequest.setup.helden[0].klasse == "archer" and BattleRequest.setup.phasen.size() == 2, "Scheibenkampf: Bogenschütze, zwei Lektionen")
	BattleRequest.kampf_id = ""


## Schritt 4: Zähmer-Start bei Esche, Kobalt fordert heraus (Sieg oder Niederlage), Tilda bringt das Zähmen bei.
func _test_tamer(kobalt_won: bool) -> void:
	var world := WorldState.new()
	var battles: Array[String] = []
	world.battle_requested.connect(func(_id: String, kampf: String) -> void: battles.append(kampf))
	var p := world.add_player("a", "Test", "elf_m", Vector2i(6, 15))
	p.progress.flags["klasse"] = "tamer"
	p.progress.quests["nach_gruenwacht"] = "abgegeben"
	p.progress.level = 13
	world.change_map(p, "wipfelheim", Vector2i(14, 22))
	_check(world.npc_marker(p, "esche") == "!" and world.npc_marker(p, "fenn") == "", "Zähmer: „!“ bei Esche, nicht bei Fenn")
	world.apply_command("a", {type = "talk", npc = "esche"})
	_tick(world, 3.0)
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	var answers: Array = world.dialog_view(p).antworten
	_check(answers.size() == 4 and str(answers[1]).begins_with("Glutwelpe"), "Esche zeigt die drei Start-Monster")
	world.apply_command("a", {type = "dialog_choose", index = 1})
	_check(p.progress.flags.get("monster", []) == ["glutwelpe"] and p.progress.item_count("schleuder") == 1, "Glutwelpe gewählt, Schleuder bekommen")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	_check(not p.in_dialog() or p.dialog.id == "kobalt", "Esche ist fertig")
	_tick(world, 1.0)
	_check(p.in_dialog() and p.dialog.id == "kobalt" and world.dialog_view(p).text.contains("Bachotter"), "Kobalt fordert heraus und nimmt den Bachotter")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(battles == ["kobalt_bachotter"], "Rivalenkampf beginnt")
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "kobalt_bachotter", gewonnen = kobalt_won})
	_check(p.progress.flags.has("kobalt_gekaempft") and p.progress.quest_state("esches_monster") == "fertig", "Nach dem Rivalenkampf geht es weiter (%s)" % ("Sieg" if kobalt_won else "Niederlage"))
	_check(p.progress.flags.has("erfolg:rivale_kobalt") == kobalt_won, "Erfolg „Rivale besiegt“ nur beim Sieg")
	world.apply_command("a", {type = "talk", npc = "kobalt"})
	_tick(world, 3.0)
	_check(world.dialog_view(p).text.contains("Glück gehabt" if kobalt_won else "Trainier mal mehr"), "Kobalt reagiert auf den Ausgang")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "talk", npc = "esche"})
	_tick(world, 3.0)
	world.apply_command("a", {type = "dialog_next"})
	_check(p.progress.quest_state("esches_monster") == "abgegeben", "Esches Auftrag abgegeben")

	# Tilda: ein Monster in der Wildnis zähmen
	_check(world.npc_marker(p, "tilda") == "!", "Tilda hat ein „!“")
	world.change_map(p, "wipfelheim", Vector2i(27, 16))
	world.apply_command("a", {type = "talk", npc = "tilda"})
	_tick(world, 3.0)
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	_check(p.progress.quest_state("tildas_unterricht") == "aktiv", "Tildas Unterricht läuft")
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "wild:0", gewonnen = true, gezaehmt = ["windfalke"]})
	_check(p.progress.flags.monster == ["glutwelpe", "windfalke"], "Gezähmter Windfalke bleibt im Rudel")
	_check(p.progress.quest_state("tildas_unterricht") == "fertig", "Erstes Zähmen erfüllt Tildas Auftrag")
	world.apply_command("a", {type = "talk", npc = "tilda"})
	_tick(world, 3.0)
	world.apply_command("a", {type = "dialog_next"})
	_check(p.progress.quest_state("tildas_unterricht") == "abgegeben" and p.progress.flags.has("klasse_gelernt"), "Tilda: Du bist jetzt Zähmer")
	for i in 5:
		world.apply_command("a", {type = "kampf_ergebnis", kampf = "wild:0", gewonnen = true, gezaehmt = ["steinkroete"]})
	_check(p.progress.flags.monster.size() == Sandbox.MAX_MONSTERS, "Rudel höchstens 5 Monster")

	# Im Kampf: das eigene Rudel statt aller drei Start-Monster
	BattleRequest.prepare("wild:0", 13, 0, "tamer", ["glutwelpe", "windfalke"])
	_check(BattleRequest.setup.helden[0].monster == ["glutwelpe", "windfalke"], "Kampf mit dem eigenen Rudel")
	BattleRequest.kampf_id = ""


## Schritt 5: Ysolde und Tilda streiten über die veränderten Tiere, man entscheidet selbst (Ruf), danach kommt Kael.
func _test_story(side: String) -> void:
	var world := WorldState.new()
	var battles: Array[String] = []
	world.battle_requested.connect(func(_id: String, kampf: String) -> void: battles.append(kampf))
	var p := world.add_player("a", "Test", "elf_m", Vector2i(6, 15))
	p.progress.flags["klasse"] = "ritualist"
	p.progress.quests["nach_gruenwacht"] = "abgegeben"
	p.progress.level = 15
	world.change_map(p, "wipfelheim", Vector2i(15, 15))
	_check(world.npc_marker(p, "ysolde") == "!", "Ysolde hat ein „!“ (für alle Klassen)")
	world.apply_command("a", {type = "talk", npc = "ysolde"})
	_tick(world, 2.0)
	for i in 3:
		world.apply_command("a", {type = "dialog_next"})
	_check(p.progress.quest_state("veraenderte_tiere") == "aktiv", "Auftrag „Leuchtende Tiere“ läuft")
	_check(world.objective(p).contains("Tilda"), "Ziel: Tilda fragen")
	var beast := _place_target(world, "waldboden", "splittertier")
	world.change_map(p, "waldboden", Vector2i(22, 3))
	_check(not world.can_use(p, beast), "Das Tier ist erst nach Tildas Sicht zu finden")
	world.change_map(p, "wipfelheim", Vector2i(27, 16))
	world.apply_command("a", {type = "talk", npc = "tilda"})
	_tick(world, 3.0)
	_check(world.dialog_view(p).text.contains("Jagen?"), "Tilda widerspricht Ysolde")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	world.change_map(p, "waldboden", Vector2i(22, 3))
	_check(world.can_use(p, beast), "Der Splitter-Rindenbär steht im Wald")
	world.apply_command("a", {type = "use", target = beast})
	_tick(world, 3.0)
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_choose", index = 0 if side == "jaeger" else 1})
	_check(battles == ["splitterbaer"], "Kampf gegen den Splitter-Rindenbär")
	var other := "zaehmer" if side == "jaeger" else "jaeger"
	_check(world.reputation(p, side) == 15 and world.reputation(p, other) == -10, "Ruf: %s +15, %s -10" % [side, other])
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "splitterbaer", gewonnen = false})
	_check(world.can_use(p, beast) and p.progress.quest_state("veraenderte_tiere") == "aktiv", "Verloren: Der Bär ist noch da")
	world.apply_command("a", {type = "use", target = beast})
	_tick(world, 4.0)
	_check(p.dialog.get("node", "") == "nochmal", "Zweiter Versuch ohne neue Entscheidung")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "splitterbaer", gewonnen = true})
	_check(world.reputation(p, side) == 15, "Ruf zählt nur einmal")
	_check(p.progress.quest_state("veraenderte_tiere") == "fertig" and not world.can_use(p, beast), "Tier besiegt, zurück zu Ysolde")

	world.change_map(p, "wipfelheim", Vector2i(15, 15))
	world.apply_command("a", {type = "talk", npc = "ysolde"})
	_tick(world, 2.0)
	_check(world.dialog_view(p).text.contains("Ein Tier weniger" if side == "jaeger" else "nicht getötet"), "Ysolde reagiert auf die Entscheidung")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	_check(p.progress.quest_state("veraenderte_tiere") == "abgegeben", "Auftrag abgegeben")
	_check(world.npc_visible(p, "kael"), "Kael ist jetzt in Wipfelheim")
	_tick(world, 1.0)
	_check(p.in_dialog() and p.dialog.id == "kael", "Kael spricht einen an")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_choose", index = 0})
	world.apply_command("a", {type = "dialog_next"})
	_check(p.progress.flags.has("kael_getroffen") and world.dialog_view(p).text.contains("leer"), "Kael: Rowans Grab ist leer")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "talk", npc = "ysolde"})
	_tick(world, 2.0)
	_check(world.dialog_view(p).text.contains("Hör nicht auf ihn"), "Ysolde verschließt sich")
	world.change_reputation(p, side, 500)
	_check(world.reputation(p, side) == WorldState.REPUTATION_MAX, "Ruf höchstens 100")


func _place_target(world: WorldState, map_id: String, art: String) -> String:
	for i in world.places.size():
		if world.places[i].map == map_id and world.places[i].art == art:
			return "ort:%d" % i
	return ""


## Zu einem Feld laufen (angetippt) und die Welt laufen lassen, bis man da ist oder die Karte gewechselt hat.
func _walk(world: WorldState, p: PlayerState, cell: Vector2i) -> void:
	var map := p.map
	world.apply_command(p.id, {type = "move", cell = cell})
	for i in 400:
		world.tick(0.05)
		if p.map != map or (not p.is_moving() and not p.in_dialog()) or p.in_dialog():
			break


func _tick(world: WorldState, seconds: float) -> void:
	for i in int(seconds / 0.05):
		world.tick(0.05)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failed += 1
	print("%s %s" % ["OK    " if ok else "FEHLER", what])
