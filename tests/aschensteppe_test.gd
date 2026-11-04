extends SceneTree
## D23 und D24: Aschensteppe (Straße von Kreuzweg zur Glutoase) mit dem Rastplatz der Karawanen, Palmenrast, Monster, die Terrassenstadt Glutoase.
## Aufruf: Godot --headless --path . -s tests/aschensteppe_test.gd

const MONSTER := ["steppenhyaene", "funkenechse", "steppenroller", "kaktusling", "aschefuchs", "schattenskarabaeus", "sonnenloewe"]

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	var world := WorldState.new()
	_check(world.maps.has("aschensteppe") and world.get_map("aschensteppe").title == "Aschensteppe", "Karte Aschensteppe")
	var p := world.add_player("a", "Test", "novize_m+m1", Vector2i(31, 62))
	p.progress.flags["klasse_bestaetigt"] = true
	world.apply_command("a", {type = "move", cell = Vector2i(31, 65)})
	for i in 300:
		world.tick(0.05)
	_check(p.map == "aschensteppe", "Durch das Südtor von Kreuzweg in die Aschensteppe")
	world.apply_command("a", {type = "move", cell = Vector2i(14, 0)})
	for i in 300:
		world.tick(0.05)
	_check(p.map == "kreuzweg", "Und zurück nach Kreuzweg")

	# Rastplatz der Karawanen: dort greifen keine Monster an, mit Wegelaterne
	var m: WorldMap = world.get_map("aschensteppe")
	world.change_map(p, "aschensteppe", Vector2i(13, 33))
	p.safe_time = 0.0
	_check(m.sicher.has_point(p.cell) and not world._can_meet_monster(p), "Am Rastplatz greifen keine Monster an")
	world.change_map(p, "aschensteppe", Vector2i(14, 12))
	p.safe_time = 0.0
	_check(world._can_meet_monster(p), "Draußen schon")
	_check(world.places.any(func(o: Dictionary) -> bool: return o.map == "aschensteppe" and o.art == "wegelaterne"), "Wegelaterne am Rastplatz")
	for w: Dictionary in world.monsters:
		if w.karte == "aschensteppe":
			_check(not Rect2(m.sicher).grow(4).has_point(Vector2(w.feld)), "Kein Monster am Rastplatz (%s)" % str(w.feld))

	# Monster nach Steckbrief (MONSTER.md)
	var arten := {}
	for w: Dictionary in GameData.wild_monsters():
		if w.karte == "aschensteppe":
			for id: String in w.gegner:
				arten[id] = true
			_check(int(w.stufe) >= 9 and int(w.stufe) <= 12, "Stufe 9–12 (%d)" % int(w.stufe))
	for id: String in MONSTER:
		_check(arten.has(id) and Sandbox.ENEMIES[id].get("regelblatt", false), "%s lebt in der Aschensteppe" % id)
		_check(GameData.get_file("kartenspiel").karten.has(id) and GameData.get_file("beute").monster.has(id), "%s: Karte und Beute" % id)
	_check(WorldState._seltenes(["sonnenloewe"]) == "sonnenloewe", "Sonnenlöwe ist selten")

	# D23b: Palmenrast südlich der Aschensteppe
	world.change_map(p, "aschensteppe", Vector2i(14, 56))
	world.apply_command("a", {type = "move", cell = Vector2i(14, 59)})
	for i in 300:
		world.tick(0.05)
	_check(p.map == "glutoase" and world.get_map("glutoase").title == "Glutoase", "Von der Aschensteppe nach Süden in die Glutoase (D24)")
	world.change_map(p, "glutoase", Vector2i(43, 11))
	world.apply_command("a", {type = "move", cell = Vector2i(45, 11)})
	for i in 300:
		world.tick(0.05)
	_check(p.map == "palmenrast" and world.get_map("palmenrast").title == "Palmenrast", "Durch das Osttor der Stadt in die Palmenrast")
	_check(world.get_map("palmenrast").baukasten.objekte.any(func(o: Dictionary) -> bool: return o.teil == "go_sternenduene"), "Xavinas Sternendüne steht da")
	var palmen := {}
	for w: Dictionary in GameData.wild_monsters():
		if w.karte == "palmenrast":
			for id: String in w.gegner:
				palmen[id] = true
			_check(int(w.stufe) >= 12 and int(w.stufe) <= 19, "Palmenrast Stufe 12–19 (%d)" % int(w.stufe))
	for id: String in ["sandwurm", "feuerechse", "glasskorpion", "oasenkroete", "staubgeist", "mondschakal", "stachelflitzer"]:
		_check(palmen.has(id) and Sandbox.ENEMIES[id].get("regelblatt", false) and GameData.get_file("kartenspiel").karten.has(id), "%s lebt in der Palmenrast" % id)
	_check(Sandbox.ENEMIES.stachelflitzer.get("flieht_nach", 0) == 3, "Stachelflitzer saust nach drei Runden davon")

	# D24: Die Terrassenstadt mit drei Stufen, Treppen und Lastenaufzug
	var stadt: WorldMap = world.get_map("glutoase")
	var teile := {}
	for o: Dictionary in stadt.baukasten.objekte:
		teile[o.teil] = true
	for teil: String in ["go_brunnen", "go_tanzplatz", "go_basar_a", "go_bank", "go_gasthaus", "go_krankenzelt", "go_karawanenplatz",
			"go_tareks_laden", "go_brakkus_werkstatt", "go_clan_werkstatt", "go_hadraks_schmiede", "go_treppe", "go_terrassenkante",
			"go_aufzug_unten", "go_aufzug_oben", "go_bergpfad", "go_tor_duerrewald"]:
		_check(teile.has(teil), "In der Stadt steht %s" % teil)
	world.change_map(p, "glutoase", Vector2i(23, 6))
	var oben: PackedVector2Array = stadt.astar.get_point_path(Vector2i(23, 6), Vector2i(22, 44))
	_check(oben.size() > 0, "Über die Treppen von der Oase bis hinauf zu Hadraks Schmiede")
	var aufzug := -1
	for i in world.places.size():
		if world.places[i].map == "glutoase" and world.places[i].art == "aufzug" and world.places[i].cell.y < 20:
			aufzug = i
	world.change_map(p, "glutoase", Vector2i(41, 18 - 1))
	world.apply_command("a", {type = "use", target = "ort:%d" % aufzug})
	for i in 100:
		world.tick(0.05)
	_check(p.cell.y > 36, "Mit dem Lastenaufzug nach oben")
	Tageszeit.feste_stunde = -1.0
	print("Aschensteppe: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
