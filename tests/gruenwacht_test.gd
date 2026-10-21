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
	_check(p.in_dialog() and p.dialog.id == "fenn" and p.dialog.node == "schueler", "Fenn erkennt seinen Schüler")

	# Und wieder hinunter
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
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
