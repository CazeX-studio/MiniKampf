extends SceneTree
## D22a: Monster nach Regelblatt (MONSTER.md, data/monster.json): Werte nach Rolle und Stufe, Fähigkeiten mit Effekten,
## Kreuzwegfelder und Hirschtal (Weg nach Grünwacht), seltene Monster.
## Aufruf: Godot --headless --path . -s tests/monster_regelblatt_test.gd

const KREUZWEGFELDER := ["tauschleim", "wiesenhoppler", "knollenkaefer", "loewenzahnling", "funkenflirr", "glutigel", "kronenschleim"]
const HIRSCHTAL := ["borstenkeiler", "dornenranke", "bachkrebs", "zankelster", "heulwolf", "irrlicht", "kronhirsch"]
const ANZAHL := {"tag": 2, "nacht": 3, "selten": 4}

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var daten: Dictionary = GameData.get_file("monster")
	var effekte := Effekte.ARTEN.keys()
	for gebiet: Array in [KREUZWEGFELDER, HIRSCHTAL]:
		var elemente := {}
		for id: String in gebiet:
			var m: Dictionary = daten[id]
			var art := "selten" if m.has("selten") else str(m.get("zeit", "tag"))
			_check(m.faehigkeiten.size() == ANZAHL[art], "%s: %d Fähigkeiten (%s)" % [id, ANZAHL[art], art])
			_check((Elements.NATURE.has(m.element) or m.element in ["Licht", "Schatten"]) and m.element != "Sternenkraft", "%s: ein Element (%s)" % [id, m.element])
			elemente[m.element] = true
			for fa: Dictionary in m.faehigkeiten:
				var liste: Array = [] if not fa.has("effekt") else (fa.effekt if fa.effekt is Array else [fa.effekt])
				for fx: Dictionary in liste:
					_check(effekte.has(fx.art), "%s/%s nutzt einen Baustein der Effekt-Liste" % [id, fa.name])
					if fx.art in ["laehmen", "festhalten"]:
						_check(int(fx.get("zuege", 1)) <= 1, "%s/%s: höchstens eine Runde" % [id, fa.name])
			_check(Sandbox.ENEMIES[id].get("regelblatt", false), "%s ist im Spiel" % id)
			_check(ResourceLoader.exists("res://assets/figuren/%s_spezial_anim_f0.png" % id), "%s hat eine eigene Bewegung" % id)
			_check(GameData.get_file("beute").monster.has(id) and GameData.item(GameData.get_file("beute").monster[id]).get("material", false),
					"%s lässt Material fallen" % id)
		_check(elemente.size() >= 3, "Mindestens drei Elemente im Gebiet")

	# Werte aus der Tabelle: Nacht etwa +15 %, Brocken +50 % Leben, gleiche Rolle = gleiche Werte
	var r: Dictionary = daten._rollen
	_check(Sandbox.ENEMIES.zankelster.hp == int(r.angreifer.leben) and Sandbox.ENEMIES.zankelster.tempo == int(r.angreifer.tempo), "Angreifer nach Tabelle")
	_check(Sandbox.ENEMIES.heulwolf.hp == roundi(float(r.angreifer.leben) * 1.15), "Nacht-Monster etwa 15 % stärker")
	_check(Sandbox.ENEMIES.kronhirsch.hp == roundi(float(r.tank.leben) * 1.5), "Seltener Brocken: 50 % mehr Leben")
	_check(Sandbox.ENEMIES.bachkrebs.hp == Sandbox.ENEMIES.dornenranke.hp, "Gleiche Rolle, gleiche Werte")

	# Im Kampf: Schutz für sich, Heilen anderer, Herbeirufen einmal pro Kampf, mehrere Treffer
	var kampf := BattleState.new(null, [] as Array[String], "", 3)
	kampf.setup = {gegner_stufe = 10}
	kampf.spawn_enemies(["bachkrebs", "irrlicht"])
	var krebs: Fighter = kampf.enemies[0]
	var licht: Fighter = kampf.enemies[1]
	_check(int(krebs.get_meta("stufe")) == 10, "Stufe aus dem Kampf")
	kampf._monster_faehigkeit(krebs, Sandbox.ENEMIES.bachkrebs.attacks[1])
	_check(krebs.shields.size() == 1, "Panzer hoch: Schutz für sich")
	kampf._monster_faehigkeit(krebs, Sandbox.ENEMIES.bachkrebs.attacks[1])
	_check(int(krebs.shields.values()[0]) == roundi(0.3 * krebs.max_hp), "Schutz stapelt nicht")
	krebs.hp = 10
	var vorher := krebs.hp
	kampf._monster_faehigkeit(licht, Sandbox.ENEMIES.irrlicht.attacks[1])
	_check(krebs.hp > vorher, "Lichtfunke heilt den Bachkrebs")
	var wolf_kampf := BattleState.new(null, [] as Array[String], "", 4)
	wolf_kampf.setup = {gegner_stufe = 9}
	wolf_kampf.spawn_enemies(["heulwolf"])
	var heulen: Dictionary = Sandbox.ENEMIES.heulwolf.attacks[1]
	wolf_kampf._monster_faehigkeit(wolf_kampf.enemies[0], heulen)
	wolf_kampf._monster_faehigkeit(wolf_kampf.enemies[1], heulen)
	_check(wolf_kampf.enemies.size() == 2 and wolf_kampf.enemies[1].klass == "heulwolf", "Heulen ruft einen zweiten Heulwolf, nur einmal")
	var lehr := BattleState.new(null, [] as Array[String], "", 5)
	lehr.spawn_enemies(["knollenkaefer"])
	_check(int(lehr.enemies[0].get_meta("stufe")) == 3, "Lernkampf ohne Stufe: kleinste Stufe aus dem Steckbrief")

	# Hirschtal auf dem Weg nach Grünwacht, seltener Kronhirsch mit besonderer Karte
	var weg := GameData.wild_monsters().filter(func(m: Dictionary) -> bool: return m.karte == "weg_gruenwacht")
	var arten := {}
	for m: Dictionary in weg:
		for id: String in m.gegner:
			arten[id] = true
		_check(int(m.stufe) >= 5 and int(m.stufe) <= 12, "Hirschtal Stufe 5–12 (%d)" % int(m.stufe))
	_check(arten.keys().all(func(id: String) -> bool: return HIRSCHTAL.has(id)) and arten.size() == HIRSCHTAL.size(), "Weg nach Grünwacht: die Hirschtal-Monster")
	_check(WorldState._seltenes(["kronhirsch"]) == "kronhirsch" and WorldState._seltenes(["heulwolf"]) == "", "Kronhirsch ist selten")
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "novize_m+m1", Vector2i(30, 30))
	var index := -1
	for i in world.monsters.size():
		if world.monsters[i].gegner == ["kronhirsch"]:
			index = i
	_check(world.battle_reward(p, "wild:%d" % index, true).karte == "kronhirsch", "Kronhirsch bringt immer seine Karte")
	_check(GameData.get_file("kartenspiel").karten.has("kronhirsch"), "Kronhirsch-Karte gibt es")
	print("Monster-Regelblatt: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
