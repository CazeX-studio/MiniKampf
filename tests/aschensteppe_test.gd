extends SceneTree
## D23a: Aschensteppe (Straße von Kreuzweg zur Glutoase) mit dem Rastplatz der Karawanen und ihren Monstern.
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
	Tageszeit.feste_stunde = -1.0
	print("Aschensteppe: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
