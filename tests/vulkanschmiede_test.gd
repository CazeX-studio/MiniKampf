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
	world.change_map(p, "glutoase", Vector2i(22, 2))
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


## D33: Zwischenboss Hammerbrüder (Doppelschlag oder Gleichschritt)
func _hammerbrueder() -> void:
	var k := BattleState.new(null, [] as Array[String], "", 11)
	k.setup = {gegner_stufe = 18, dungeon = "vulkanschmiede", helden = [{klasse = "tank", name = "A", stufe = 18},
			{klasse = "smith", name = "B", stufe = 18}]}
	k._create_heroes()
	k.dungeon = Vulkanschmiede.new(k)
	k.spawn_enemies(["hammerbruder_hammer", "hammerbruder_zange"])
	var hammer: Fighter = k.enemies[0]
	var zange: Fighter = k.enemies[1]
	k.dungeon.on_wave(0)
	_check(k.dungeon.modus in ["doppelschlag", "gleichschritt"], "Pro Kampf eine der beiden Mechaniken")
	var v: Vulkanschmiede = k.dungeon
	# Doppelschlag: angekündigt, jede Klasse kann einen Bruder stören
	v.modus = "doppelschlag"
	v._ausholen()
	_check(hammer.has_meta("holt_aus") and zange.has_meta("holt_aus") and "DOPPELSCHLAG" in v.intent(hammer), "Beide holen aus (angekündigt)")
	var aktionen := v.extra_abilities(k.heroes[0])
	_check(aktionen.size() == 1 and aktionen[0].id == "stoeren", "Jede Klasse kann „Bruder stören“")
	v.execute(k.heroes[1], aktionen[0], null)
	_check(not hammer.has_meta("holt_aus") and v.extra_abilities(k.heroes[0]).is_empty(), "Ein gestörter Bruder reicht")
	v._ausholen()
	v._doppelschlag(hammer)
	_check(k.allies().is_empty(), "Doppelschlag ohne Störung: die ganze Gruppe fällt")
	# Gleichschritt: liegt einer deutlich vorn, wird der schwächere rasend
	for h in k.heroes:
		h.hp = h.max_hp
	v.modus = "gleichschritt"
	zange.hp = roundi(zange.max_hp * 0.5)
	v.on_hit(null, zange, "", 0)
	_check(zange.has_meta("rasend") and not hammer.has_meta("rasend"), "Gleichschritt: der schwächere Bruder wird rasend")
	hammer.hp = roundi(hammer.max_hp * 0.55)
	v.on_hit(null, hammer, "", 0)
	_check(not zange.has_meta("rasend"), "Gleichmäßig geschwächt: er beruhigt sich")
	zange.hp = 0
	v.on_hit(null, zange, "", 0)
	_check(hammer.has_meta("rasend"), "Fällt einer, während der andere noch viel Leben hat, tobt der andere")
	k.cleanup()
	# In der Welt: auf der Plattform der Kettengänge, ein Kampf für die Gruppe
	var kampf: Dictionary = GameData.battle("hammerbrueder")
	_check(kampf.get("dungeon", "") == "vulkanschmiede" and kampf.get("merken", "") == "lauf:hammerbrueder", "Kampf gegen die Hammerbrüder")
	var orte: Array = GameData.get_file("karten").vulkanschmiede.orte.filter(func(o: Dictionary) -> bool: return o.dialog == "vs_hammerbrueder")
	_check(orte.size() == 2 and GameData.dialog("vs_hammerbrueder").size() > 0, "Die Brüder stehen in den Kettengängen")


## D34: Endboss Kettenschmied (Lavaflut und Gefesselt, Phase 2 mit Kühlbecken und Panzer)
func _kettenschmied() -> void:
	var k := BattleState.new(null, [] as Array[String], "", 13)
	k.setup = {gegner_stufe = 20, dungeon = "vulkanschmiede", helden = [{klasse = "tank", name = "A", stufe = 20},
			{klasse = "smith", name = "B", stufe = 20}, {klasse = "archer", name = "C", stufe = 20}]}
	k._create_heroes()
	k.lava = LavaTakt.new(k)
	var v := Vulkanschmiede.new(k)
	k.dungeon = v
	k.spawn_enemies(["kettenschmied_1"])
	v.on_wave(0)
	var ks := v.ks
	var boss: Fighter = k.enemies[0]
	var a: Fighter = k.heroes[0]
	var b: Fighter = k.heroes[1]
	var dritter: Fighter = k.heroes[2]
	_check(ks.anker == ["fest", "fest", "fest"] and "Anker" in v.intent(boss), "Drei Anker, angezeigt beim Kettenschmied")
	ks.anker_ziehen(boss)
	_check(ks.anker.count("wackelt") == 1, "Er reißt an einer Kette: ein Anker wackelt")
	var hammer := v.extra_abilities(a).filter(func(x: Dictionary) -> bool: return x.id == "anker")
	_check(hammer.size() == 1, "Jede Klasse kann den Anker festhämmern")
	v.execute(a, hammer[0], null)
	_check(ks.anker.count("wackelt") == 0, "Festgehämmert hält er wieder")
	for i in 3:
		ks.anker_ziehen(boss)
	_check(ks.anker.count("lose") == 2, "Ohne Hämmern löst sich ein Anker nach dem anderen")
	ks.anker_ziehen(boss)
	_check(k.allies().is_empty(), "Alle drei lose: Lavaflut, die Gruppe fällt")
	for h in k.heroes:
		h.hp = h.max_hp
	# Gefesselt: geteilter Schaden, ein Dritter zerschlägt die Kette
	ks.gefesselt.assign([a, b])
	var la := a.hp
	var lb := b.hp
	k.apply_damage(a, 20)
	_check(la - a.hp > 0 and lb - b.hp > 0 and absi((la - a.hp) - (lb - b.hp)) <= 12, "Gefesselt: beide teilen den Schaden")
	_check(v.extra_abilities(a).all(func(x: Dictionary) -> bool: return x.id != "kette"), "Die Gefesselten selbst können die Kette nicht zerschlagen")
	var kette := v.extra_abilities(dritter).filter(func(x: Dictionary) -> bool: return x.id == "kette")
	_check(kette.size() == 1, "Ein Dritter kann die Kette zerschlagen")
	v.execute(dritter, kette[0], null)
	_check(ks.gefesselt.is_empty(), "Kette zerschlagen")
	# Phase 2: Entfesselt
	boss.hp = 0
	v.check_phase()
	var zwei := v._find("kettenschmied_2")
	var becken := v._find("kuehlbecken")
	_check(ks.phase2 and zwei != null and becken != null and k.lava == null, "Phase 2: entfesselt, mit Kühlbecken, die Lava steigt jetzt stufenweise")
	var vorher := becken.hp
	k.apply_damage(becken, 15, a)
	_check(becken.hp == vorher and a.has_meta("nass"), "Wer ins Kühlbecken schlägt, wird nass")
	var leben := zwei.hp
	k.apply_damage(zwei, 20, dritter)
	_check(leben - zwei.hp == roundi(20 * Kettenschmied.PANZER_DURCH) and ks.panzer == Kettenschmied.PANZER, "Der Panzer hält einen Teil ab")
	k.apply_damage(zwei, 30, a)
	_check(ks.panzer == Kettenschmied.PANZER - 1, "Nass und hart getroffen: ein Stück Panzer splittert ab")
	ks.gefesselt.assign([a, b])
	_check(v.extra_abilities(dritter).all(func(x: Dictionary) -> bool: return x.id != "kette"), "Glühende Kette: erst zerschlagen, wenn beide nass sind")
	k.apply_damage(becken, 15, b)
	_check(v.extra_abilities(dritter).any(func(x: Dictionary) -> bool: return x.id == "kette"), "Beide nass: jetzt geht es")
	zwei.hp = 0
	v.check_phase()
	_check(not becken.is_alive() and k.alive(k.enemies).is_empty(), "Kettenschmied besiegt: der Kampf ist vorbei")
	k.cleanup()
	var kampf: Dictionary = GameData.battle("kettenschmied")
	_check(kampf.get("merken", "") == "lauf:kettenschmied", "Kampf gegen den Kettenschmied")
	var orte: Array = GameData.get_file("karten").vulkanschmiede.orte.filter(func(o: Dictionary) -> bool: return o.dialog == "vs_kettenschmied")
	_check(orte.size() == 1 and orte[0].wenn.gemerkt == "lauf:hammerbrueder", "Er wartet in der Ankerkammer, erst nach den Hammerbrüdern")


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
	_hammerbrueder()
	_kettenschmied()
	world.change_map(p, "vulkanschmiede", Vector2i(8, 28))
	world.apply_command("a", {type = "move", cell = Vector2i(8, 29)})
	for i in 300:
		world.tick(0.05)
	_check(p.map == "glutoase", "Unten durch den Gang zurück in die Stadt")
	Tageszeit.feste_stunde = -1.0
	print("Vulkanschmiede: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
