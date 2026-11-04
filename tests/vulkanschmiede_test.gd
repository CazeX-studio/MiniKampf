extends SceneTree
## D32: Vulkanschmiede der Ketten (Dungeon der Glutoase): Eingang hinter Hadraks Schmiede, drei Abschnitte, Monster,
## Kampf-Hintergrund. Aufruf: Godot --headless --path . -s tests/vulkanschmiede_test.gd

const MONSTER := ["schlackenkriecher", "glutgeist", "ambossknecht", "aschefalter", "magmaschnecke", "messingwaechter"]

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _eingang(world: WorldState, p: PlayerState) -> void:
	world.change_map(p, "glutoase", Vector2i(22, 43))
	for i in world.places.size():
		var o: Dictionary = world.places[i]
		if o.map == "glutoase" and o.art == "schmiede_eingang":
			world.apply_command("a", {type = "use", target = "ort:%d" % i})
			break
	for i in 100:
		world.tick(0.05)
		if p.in_dialog():
			world.apply_command("a", {type = "dialog_choose", index = 0})
			world.apply_command("a", {type = "dialog_next"})


## D32b: Lava-Takt im Kampf und die Eigenheiten der Monster, die mit der Lava spielen
func _lava_takt() -> void:
	_check(LavaTakt.reihe_in_runde(4) == "vorne" and LavaTakt.reihe_in_runde(8) == "hinten" and LavaTakt.reihe_in_runde(12) == "vorne"
			and LavaTakt.reihe_in_runde(5) == "", "Die Lava steigt abwechselnd vorne und hinten")
	var k := BattleState.new(null, [] as Array[String], "", 9)
	k.setup = {gegner_stufe = 18, dungeon = "vulkanschmiede", helden = [{klasse = "tank", name = "Vorne", stufe = 18},
			{klasse = "smith", name = "Hinten", stufe = 18}]}
	k._create_heroes()
	k.lava = LavaTakt.new(k)
	var vorne: Fighter = k.heroes[0]
	var hinten: Fighter = k.heroes[1]
	vorne.back_row = false
	hinten.back_row = true
	k.spawn_enemies(["schlackenkriecher", "glutgeist", "magmaschnecke"])
	k.lava.vor_dem_zug(LavaTakt.RUNDE * 1.5)
	_check(k.lava.angekuendigt == "vorne" and k.lava.oben == "", "Zwei Runden vorher angekündigt")
	var leben_vorne := vorne.hp
	var leben_hinten := hinten.hp
	k.lava.vor_dem_zug(LavaTakt.RUNDE * 3.5)
	_check(k.lava.oben == "vorne" and vorne.hp < leben_vorne and hinten.hp == leben_hinten, "Die Lava trifft nur die vordere Reihe")
	# Schlackenpanzer: in der Lava-Runde härter
	var kriecher: Fighter = k.enemies[0]
	k._monster_faehigkeit(kriecher, Sandbox.ENEMIES.schlackenkriecher.attacks[0])
	_check(int(kriecher.shields.values()[0]) == roundi(0.3 * kriecher.max_hp), "Schlackenpanzer ist in der Lava-Runde doppelt so stark")
	k.lava.vor_dem_zug(LavaTakt.RUNDE * 4.5)
	_check(k.lava.oben == "", "Danach sinkt die Lava wieder")
	# Magmaheilung nur, solange die Lava oben ist
	var schnecke: Fighter = k.enemies[2]
	schnecke.step = 0
	_check(k.faehigkeit_waehlen(schnecke).name == "Lavaspur", "Ohne Lava keine Magmaheilung")
	k.lava.oben = "hinten"
	schnecke.step = 0
	_check(k.faehigkeit_waehlen(schnecke).name == "Magmaheilung", "Mit Lava heilt die Magmaschnecke")
	k.lava.oben = ""
	# Letzte Glut: Der Glutgeist explodiert beim Tod und trifft die vordere Reihe
	var geist: Fighter = k.enemies[1]
	leben_vorne = vorne.hp
	leben_hinten = hinten.hp
	geist.hp = 1
	k.apply_damage(geist, 5)
	_check(not geist.is_alive() and vorne.hp < leben_vorne and hinten.hp == leben_hinten, "Letzte Glut: Der Glutgeist explodiert beim Tod")
	_check(Sandbox.ENCOUNTERS.vulkanschmiede.dungeon == "vulkanschmiede", "Vulkanschmiede auch im Übungskampf (Sandbox)")
	k.cleanup()


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "novize_m+m1", Vector2i(22, 43))
	p.progress.flags["klasse_bestaetigt"] = true
	p.progress.quests = {"abreise": "abgegeben", "nach_glutoase": "abgegeben", "klasse_lernen": "abgegeben", "rivale_kael": "aktiv"}
	_eingang(world, p)
	_check(p.map == "glutoase", "Vor dem Kampf gegen Kael versperren Ketten den Eingang")
	p.dialog = {}
	p.progress.quests["rivale_kael"] = "abgegeben"
	_eingang(world, p)
	_check(p.map == "vulkanschmiede", "Nach Kael geht es hinab in die Vulkanschmiede")
	var m: WorldMap = world.get_map("vulkanschmiede")
	_check(m.dungeon == "vulkanschmiede" and m.title == "Vulkanschmiede der Ketten", "Die Vulkanschmiede ist ein Dungeon")
	var teile := {}
	for o: Dictionary in m.baukasten.objekte:
		teile[o.teil] = true
	for teil: String in ["vs_esse", "vs_eisenwand", "vs_kettenbruecke", "vs_kettenwinde", "vs_anker", "vs_kuehlbecken"]:
		_check(teile.has(teil), "In der Vulkanschmiede steht %s" % teil)
	# Drei Abschnitte: Schmiedehallen, über die Kettenbrücken in die Ankerkammer
	_check(m.astar.get_point_path(p.cell, Vector2i(23, 10)).size() > 0, "Von den Schmiedehallen über die Kettenbrücken")
	_check(m.astar.get_point_path(p.cell, Vector2i(38, 15)).size() > 0, "Bis in die Ankerkammer")
	var gefunden := {}
	for w: Dictionary in GameData.wild_monsters():
		if w.karte == "vulkanschmiede":
			_check(w.dungeon == "vulkanschmiede" and w.hintergrund == "vulkanschmiede", "Kampf in der Vulkanschmiede mit eigenem Hintergrund")
			_check(int(w.stufe) >= 15 and int(w.stufe) <= 20, "Stufe 15–20 (%d)" % int(w.stufe))
			for id: String in w.gegner:
				gefunden[id] = true
	for id: String in MONSTER:
		var e: Dictionary = Sandbox.ENEMIES.get(id, {})
		_check(gefunden.has(id) and e.get("regelblatt", false) and e.attacks.size() >= 3 and GameData.get_file("kartenspiel").karten.has(id)
				and GameData.get_file("gegenstaende").has(GameData.get_file("beute").monster[id]), "%s lebt in der Vulkanschmiede (Beute, Karte)" % id)
	_check(Sandbox.ENEMIES.messingwaechter.has("selten"), "Der Messingwächter ist selten")
	_check(Backdrop.fighter_light("vulkanschmiede") != Color.WHITE, "Eigenes Licht im Kampf")
	_lava_takt()
	world.change_map(p, "vulkanschmiede", Vector2i(8, 28))
	world.apply_command("a", {type = "move", cell = Vector2i(8, 29)})
	for i in 300:
		world.tick(0.05)
	_check(p.map == "glutoase", "Unten durch den Gang zurück in die Stadt")
	Tageszeit.feste_stunde = -1.0
	print("Vulkanschmiede: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
