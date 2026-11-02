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
	_check(Faehigkeiten.grund_gegen(p.progress, "adlerauge") != "", "Fähigkeit „bald“ darf man noch nicht lernen")
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
	BattleRequest.player_skills_known = false
	BattleRequest.player_skills = {}
	print("faehigkeiten_test: %s" % ("OK" if _fehler == 0 else "%d Fehler" % _fehler))
	quit(1 if _fehler > 0 else 0)
