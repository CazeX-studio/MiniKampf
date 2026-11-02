extends SceneTree
## Projekt 14, K.3: Fähigkeiten-Baum. Klassenstufe gibt Punkte, Reihen werden frei, Voraussetzungen gelten,
## Neuverteilen beim Lehrmeister (erstes Mal kostenlos). Im Kampf gibt es genau das Gelernte.

var _fehler := 0


func _check(ok: bool, text: String) -> void:
	if not ok:
		print("FEHLER: " + text)
		_fehler += 1


func _init() -> void:
	# Jeder Baum ist gültig
	var alle := GameData.get_file("faehigkeiten")
	for klasse: String in alle:
		if not alle[klasse] is Dictionary:
			continue
		_check(Sandbox.CLASSES.has(klasse), "Baum für unbekannte Klasse %s" % klasse)
		var ids: Array = []
		for f: Dictionary in alle[klasse].faehigkeiten:
			ids.append(f.id)
			_check(int(f.reihe) >= 1 and int(f.reihe) <= 4, "%s: falsche Reihe" % f.id)
		for f: Dictionary in alle[klasse].faehigkeiten:
			for andere: String in f.get("braucht", {}):
				_check(andere in ids, "%s braucht %s, das es nicht gibt" % [f.id, andere])
	var state := WorldState.new()
	var p := state.add_player("a", "Test", "elf_m", WorldState.start_cell())
	p.dialog = {}
	_check(p.progress.klassenstufe() == 0, "Ohne Klasse keine Klassenstufe")
	p.progress.add_xp(500)
	p.progress.flags["klasse"] = "archer"
	p.progress.flags["klasse_bestaetigt"] = true
	p.progress.flags["klasse_gelernt"] = true
	_check(p.progress.klassenstufe() == 1 and p.progress.freie_punkte() == 1, "Klassenstufe 1 mit einem Punkt (%d, %d)" % [p.progress.klassenstufe(), p.progress.freie_punkte()])
	# Erfahrung vor dem Lernen zählt nicht, danach schon
	p.progress.add_xp(250)
	_check(p.progress.klassenstufe() == 3, "Klassenstufe nach 250 Erfahrung (%d)" % p.progress.klassenstufe())
	state.apply_command("a", {type = "lernen", faehigkeit = "charge"})
	state.apply_command("a", {type = "lernen", faehigkeit = "charge"})
	_check(int(p.progress.faehigkeiten.get("charge", 0)) == 2 and p.progress.freie_punkte() == 1, "Lernen verbraucht Punkte")
	state.apply_command("a", {type = "lernen", faehigkeit = "volley"})
	_check(not p.progress.faehigkeiten.has("volley"), "Reihe 2 vor Klassenstufe 10 gelernt")
	p.progress.klassen_xp = 20000
	_check(Faehigkeiten.grund_gegen(p.progress, "rapid").begins_with("Braucht"), "Schnellfeuer ohne Schneller Schuss 3 lernbar")
	# Neu verteilen nur beim Lehrmeister, das erste Mal kostenlos
	state.apply_command("a", {type = "neu_verteilen"})
	_check(not p.progress.faehigkeiten.is_empty(), "Neu verteilen geht auch weit weg vom Lehrmeister")
	var fenn: Dictionary = state.npcs.get("fenn", {})
	_check(not fenn.is_empty(), "Lehrmeister Fenn fehlt")
	if not fenn.is_empty():
		p.map = fenn.map
		p.pos = Vector2(fenn.cell) + Vector2(1, 0)
		p.progress.gold = 0
		state.apply_command("a", {type = "neu_verteilen"})
		_check(p.progress.faehigkeiten.is_empty(), "Erstes Neuverteilen beim Lehrmeister klappt nicht")
		p.progress.faehigkeiten["charge"] = 1
		state.apply_command("a", {type = "neu_verteilen"})
		_check(not p.progress.faehigkeiten.is_empty(), "Zweites Neuverteilen ohne Geld geht trotzdem")
	# Feste Leiste: Gelerntes kommt von selbst drauf, man kann es herunternehmen
	p.progress.faehigkeiten.clear()
	p.progress.leiste = ["", "", "", "", "", ""]
	state.apply_command("a", {type = "lernen", faehigkeit = "charge"})
	state.apply_command("a", {type = "lernen", faehigkeit = "shot"})
	_check(p.progress.leiste[0] == "charge" and not "shot" in p.progress.leiste, "Leiste nach dem Lernen falsch: %s" % [p.progress.leiste])
	state.apply_command("a", {type = "leiste", faehigkeit = "charge", platz = -1})
	_check(not "charge" in p.progress.leiste, "Herunternehmen geht nicht")
	state.apply_command("a", {type = "leiste", faehigkeit = "ruhige_hand", platz = 2})
	_check(not "ruhige_hand" in p.progress.leiste, "Ungelerntes oder Passives auf der Leiste")
	state.apply_command("a", {type = "leiste", faehigkeit = "charge", platz = 3})
	_check(p.progress.leiste[3] == "charge", "Auf einen bestimmten Platz legen geht nicht")
	var gespeichert := Progress.new()
	gespeichert.load_dict(p.progress.to_dict())
	_check(gespeichert.leiste == p.progress.leiste, "Leiste wird nicht gespeichert")
	# Im Kampf: genau das Gelernte auf der Leiste (normaler Angriff und Ult immer)
	BattleRequest.player_bar = ["", "", "", "", "", ""]
	BattleRequest.player_skills = {charge = 1, net = 1}
	BattleRequest.player_skills_known = true
	BattleRequest.player_gear = {}
	BattleRequest.prepare("splitterbaer", 15, 0, "archer")
	var leer := BattleState.new(null, [] as Array[String], "", 1)
	leer.setup = BattleRequest.setup
	leer._create_heroes()
	var leer_ids: Array = leer.skills.abilities(leer.heroes[0]).map(func(a: Dictionary) -> String: return a.id)
	_check(not "charge" in leer_ids and "shot" in leer_ids and "ult" in leer_ids, "Gelernt, aber nicht auf der Leiste: %s" % [leer_ids])
	BattleRequest.player_bar = ["charge", "", "", "", "", ""]
	BattleRequest.player_skills = {charge = 1}
	BattleRequest.player_skills_known = true
	BattleRequest.player_gear = {}
	BattleRequest.prepare("splitterbaer", 15, 0, "archer")
	var kampf := BattleState.new(null, [] as Array[String], "", 1)
	kampf.setup = BattleRequest.setup
	kampf._create_heroes()
	var ids: Array = kampf.skills.abilities(kampf.heroes[0]).map(func(a: Dictionary) -> String: return a.id)
	_check("shot" in ids and "charge" in ids and "ult" in ids and "abwarten" in ids, "Im Kampf fehlt etwas: %s" % [ids])
	_check(not "volley" in ids and not "net" in ids and not "rapid" in ids, "Im Kampf ist Ungelerntes: %s" % [ids])
	# Prüfungen mit Phasen (Fenn) zeigen alles
	BattleRequest.prepare("fenns_pruefung", 10, 0, "archer")
	_check(not BattleRequest.setup.helden[0].has("faehigkeiten"), "Fenns Prüfung darf nicht nach dem Baum filtern")
	# D8c: die fünf neuen Fähigkeiten des Bogenschützen
	BattleRequest.player_bar = ["durchschlag", "schwachstelle", "elementpfeil", "rapid", "", ""]
	BattleRequest.player_skills = {durchschlag = 1, schwachstelle = 1, elementpfeil = 1, rapid = 1, jagdinstinkt = 1, adlerauge = 5, charge = 3, shot = 3}
	BattleRequest.player_munition = {feuerpfeil = 2}
	BattleRequest.prepare("splitterbaer", 25, 0, "archer")
	var b := BattleState.new(null, [] as Array[String], "", 4)
	b.setup = BattleRequest.setup
	b._create_heroes()
	var bogen: Fighter = b.heroes[0]
	var g1 := Fighter.new("Eins", "test", "Erde", false, 500, 10, Color.WHITE)
	var g2 := Fighter.new("Zwei", "test", "Erde", false, 500, 10, Color.WHITE)
	b.enemies.append_array([g1, g2])
	var abs := {}
	for a in b.skills.abilities(bogen):
		abs[a.id] = a
	for id: String in ["durchschlag", "schwachstelle", "elementpfeil", "rapid"]:
		_check(abs.has(id), "Bogenschütze hat %s nicht" % id)
	bogen.mana = bogen.max_mana
	b.execute(bogen, abs.durchschlag, g1)
	_check(g1.hp < 500 and g2.hp < 500, "Durchschlag trifft nicht zwei Gegner")
	b.execute(bogen, abs.schwachstelle, g2)
	_check(g2.vuln_turns >= 3, "Schwachstelle markiert nicht")
	var pfeil: Dictionary = abs.elementpfeil.duplicate()
	pfeil.choice = "feuerpfeil"
	b.execute(bogen, pfeil, g1)
	_check(g1.effekte.has("brennen") and int(bogen.wares.feuerpfeil) == 1, "Feuerpfeil setzt nicht in Brand oder wird nicht verbraucht")
	var vorher := g1.hp
	b.execute(bogen, abs.rapid, g1)
	_check(vorher - g1.hp >= 3 * 3, "Schnellfeuer trifft nicht mehrmals ein Ziel")
	b.skills.on_perfect_reaction(bogen, g1)
	_check(bogen.has_meta("jagdinstinkt"), "Jagdinstinkt wird nach perfektem Ausweichen nicht scharf")
	b.calc_damage(bogen, g1, 10.0, "ranged")
	_check(not bogen.has_meta("jagdinstinkt"), "Jagdinstinkt wird nicht verbraucht")
	# D8d: Monster-Zähmer
	BattleRequest.player_munition = {}
	BattleRequest.player_bar = ["switch", "lockfutter", "gemeinsam", "wachstum", "einschuechtern", "zweites_leben"]
	BattleRequest.player_skills = {switch = 1, lockfutter = 1, gemeinsam = 1, wachstum = 1, einschuechtern = 1, zweites_leben = 1, band = 5, rudelinstinkt = 1, auftritt = 2, cheer = 3, care = 3}
	BattleRequest.player_band = {moosling = 10}
	BattleRequest.prepare("splitterbaer", 25, 0, "tamer", ["moosling", "glutwelpe", "bachotter"])
	var z := BattleState.new(null, [] as Array[String], "", 6)
	z.setup = BattleRequest.setup
	z._create_heroes()
	var zaehmer: Fighter = z.heroes[0]
	var wild := Fighter.new("Wild", "wiesenhoppler", "Erde", false, 400, 10, Color.WHITE)
	z.enemies.append(wild)
	var zabs := {}
	for a in z.skills.abilities(zaehmer):
		zabs[a.id] = a
	_check(not zabs.has("command"), "Befehl gibt es beim Zähmer nicht mehr")
	for id: String in ["sling", "switch", "lockfutter", "gemeinsam", "wachstum", "einschuechtern", "tame", "ult"]:
		_check(zabs.has(id), "Zähmer hat %s nicht" % id)
	var moos: Fighter = zaehmer.monsters[0]
	_check(moos.power > zaehmer.monsters[1].power, "Band macht das lange Rudelmitglied nicht stärker")
	zaehmer.mana = zaehmer.max_mana
	z.execute(zaehmer, zabs.lockfutter, wild)
	_check(wild.has_meta("lockfutter"), "Lockfutter lenkt nicht ab")
	var wild_vorher := wild.hp
	z.execute(zaehmer, zabs.gemeinsam, wild)
	_check(wild_vorher - wild.hp > 8, "Gemeinsamer Angriff trifft nur einmal")
	var aktiv: Fighter = zaehmer.active_monster
	var leben := aktiv.max_hp
	z.execute(zaehmer, zabs.wachstum, null)
	_check(aktiv.max_hp > leben and aktiv.has_meta("wachstum"), "Wachstumsschub wirkt nicht")
	for i in 3:
		z._begin_turn(aktiv)
	_check(aktiv.max_hp == leben and not aktiv.has_meta("wachstum"), "Wachstumsschub hört nicht auf")
	z.execute(zaehmer, zabs.einschuechtern, null)
	_check(wild.schwach_turns == 2, "Einschüchtern wirkt nicht")
	# Zweites Leben: besiegtes Monster zurück, einmal pro Kampf
	zaehmer.monsters[2].hp = 0
	var leben_ab: Array = z.skills.abilities(zaehmer).filter(func(a: Dictionary) -> bool: return a.id == "zweites_leben")
	_check(not leben_ab.is_empty(), "Zweites Leben fehlt, obwohl ein Monster besiegt ist")
	if not leben_ab.is_empty():
		var wahl: Dictionary = leben_ab[0].duplicate()
		wahl.choice = zaehmer.monsters[2].klass
		z.execute(zaehmer, wahl, null)
		_check(zaehmer.monsters[2].is_alive(), "Zweites Leben holt das Monster nicht zurück")
		_check(z.skills.abilities(zaehmer).filter(func(a: Dictionary) -> bool: return a.id == "zweites_leben").is_empty(), "Zweites Leben geht zweimal")
	# Band wächst nach gewonnenen Kämpfen
	var welt := WorldState.new()
	var zp := welt.add_player("z", "Z", "elf_m", WorldState.start_cell())
	zp.progress.flags["klasse"] = "tamer"
	zp.progress.flags["klasse_gelernt"] = true
	zp.progress.flags["monster"] = ["moosling"]
	welt.apply_command("z", {type = "kampf_ergebnis", kampf = "splitterbaer", gewonnen = true})
	_check(int((zp.progress.flags.get("band", {}) as Dictionary).get("moosling", 0)) == 1, "Band zählt den Sieg nicht")
	# D8e: Rüstungsschmied
	BattleRequest.player_band = {}
	BattleRequest.player_bar = ["abfangen", "haerten", "gluehend", "ambossschlag", "gemeinsame_haerte", "reinforce"]
	BattleRequest.player_skills = {abfangen = 1, haerten = 1, gluehend = 1, ambossschlag = 1, gemeinsame_haerte = 1, reinforce = 1, gehaertet = 4, funkenflug = 2, meisterhand = 3, hammer = 3, anvil = 3}
	BattleRequest.player_skills_known = true
	BattleRequest.prepare("splitterbaer", 25, 0, "smith")
	var sm := BattleState.new(null, [] as Array[String], "", 8)
	sm.setup = BattleRequest.setup
	sm._create_heroes()
	var schmied: Fighter = sm.heroes[0]
	var wolf := Fighter.new("Wolf", "wiesenhoppler", "Erde", false, 400, 10, Color.WHITE)
	sm.enemies.append(wolf)
	var sabs := {}
	for a in sm.skills.abilities(schmied):
		sabs[a.id] = a
	for id: String in ["hammer", "armor", "abfangen", "haerten", "gluehend", "ambossschlag", "gemeinsame_haerte", "ult"]:
		_check(sabs.has(id), "Schmied hat %s nicht" % id)
	_check(int(sabs.armor.get("cd", 0)) == 1, "Meisterhand verkürzt die Abklingzeit nicht")
	schmied.mana = schmied.max_mana
	sm.execute(schmied, sabs.haerten, null)
	_check(schmied.hard == 2, "Härten gibt keine zwei Stufen")
	sm.execute(schmied, sabs.gemeinsame_haerte, null)
	_check(schmied.hard == 0 and schmied.shield_total() >= 12, "Gemeinsame Härte gibt den Schutz nicht weiter")
	sm.execute(schmied, sabs.gluehend, null)
	var vor := wolf.hp
	sm.skills.after_enemy_hit(wolf, schmied, "melee")
	_check(wolf.hp < vor and wolf.effekte.has("brennen"), "Glühende Rüstung verbrennt den Angreifer nicht")
	sm.execute(schmied, sabs.ambossschlag, null)
	_check(wolf.effekte.has("laehmen"), "Ambossschlag betäubt nicht")
	sm.execute(schmied, sabs.ult, null)
	_check(schmied.has_meta("meisterstueck") and schmied.hard == 5, "Meisterstück wirkt nicht")
	var vor2 := wolf.hp
	sm.skills.on_perfect_reaction(schmied, wolf)
	_check(wolf.hp < vor2, "Funkenflug trifft nicht")
	BattleRequest.player_bar = []
	BattleRequest.player_skills_known = false
	BattleRequest.player_skills = {}
	print("faehigkeiten_test: %s" % ("OK" if _fehler == 0 else "%d Fehler" % _fehler))
	quit(1 if _fehler > 0 else 0)
