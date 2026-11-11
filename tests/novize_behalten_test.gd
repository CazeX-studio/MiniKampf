extends SceneTree
## A16: Novizen-Fähigkeiten nach der Klassenwahl behalten: eigene Reihe „Novize“ im Fähigkeiten-Baum (schon gelernt,
## keine Punkte), frei auf die Leiste legbar, im Kampf da, wenn sie auf der Leiste liegen.
## Aufruf: Godot --headless --path . -s tests/novize_behalten_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var p := Progress.new()
	p.flags = {"klasse": "archer", "klasse_gelernt": true}
	p.klassen_xp = 4100
	_check(Faehigkeiten.novize_behalten(p).is_empty(), "Ohne Lektionen bei Ye gibt es nichts zu behalten")
	for flag: String in Progress.NOVIZE_LEKTIONEN.values():
		p.flags[flag] = true
	var behalten := Faehigkeiten.novize_behalten(p)
	_check(Array(behalten) == ["schildstoss", "doppelschlag", "erste_hilfe", "deckung"],
			"Bogenschütze behält Schildstoß, Doppelschlag, Erste Hilfe und Deckung geben")
	_check(Faehigkeiten.fuer_leiste(p, "schildstoss") and not Faehigkeiten.fuer_leiste(p, "schlag"),
			"Novizen-Fähigkeiten dürfen auf die Leiste, der Hieb nicht (jede Klasse hat ihren Grundangriff)")
	var novize := Progress.new()
	novize.flags = p.flags.duplicate()
	novize.flags.erase("klasse")
	novize.flags.erase("klasse_gelernt")
	_check(Faehigkeiten.novize_behalten(novize).is_empty(), "Als Novize gibt es keine extra Reihe")

	# Fähigkeiten-Baum: oben die Reihe „Novize“, schon gelernt, nur „Auf die Leiste“
	var gesendet: Array = []
	FaehigkeitenBaum.gewaehlt = "schildstoss"
	var baum := FaehigkeitenBaum.new()
	root.add_child(baum)
	baum.bauen(p, func(b: Dictionary) -> void: gesendet.append(b), func() -> void: pass)
	await process_frame
	var anzahl: int = Faehigkeiten.baum("archer").faehigkeiten.size()
	_check(baum._felder.size() == anzahl + 1 + 4 and baum._felder.has("deckung"), "Baum mit Reihe „Novize“ (vier Felder)")
	var lernen := false
	var leiste: Button = null
	for b in baum.find_children("*", "Button", true, false):
		if (b as Button).text == GameData.text("faehigkeiten_lernen"):
			lernen = true
		if (b as Button).text == GameData.text("leiste_drauf"):
			leiste = b
	_check(not lernen and leiste != null, "Schildstoß gewählt: kein „Lernen“, aber „Auf die Leiste“")
	if leiste != null:
		leiste.pressed.emit()
	_check(gesendet.size() == 1 and gesendet[0].type == "leiste" and gesendet[0].faehigkeit == "schildstoss", "Auf die Leiste schickt den Befehl")
	baum.queue_free()
	FaehigkeitenBaum.gewaehlt = ""

	# In der Welt: auf die Leiste legen
	var w := WorldState.new()
	var sp := w.add_player("a", "Test", "novize_m+m1", Vector2i(30, 30))
	sp.progress.flags = p.flags.duplicate()
	sp.progress.klassen_xp = 4100
	w.apply_command("a", {type = "leiste", faehigkeit = "schildstoss", platz = -1})
	_check("schildstoss" in sp.progress.leiste, "Schildstoß liegt auf der Leiste")

	# Im Kampf: nur, was auf der Leiste liegt; wirkt wie beim Novizen
	var k := BattleState.new(null, [] as Array[String], "", 5)
	k.setup = {gegner_stufe = 10, helden = [{klasse = "archer", name = "Du", stufe = 12, novize_gelernt = ["schlag", "schildstoss", "doppelschlag"],
			faehigkeiten = {}, leiste = ["schildstoss", "", "", "", "", ""]}]}
	k._create_heroes()
	k.spawn_enemies(["wiesenhoppler"])
	var held: Fighter = k.heroes[0]
	var abs := k.skills.abilities(held)
	var stoss := abs.filter(func(ab: Dictionary) -> bool: return ab.id == "schildstoss")
	_check(stoss.size() == 1 and stoss[0].get("novize", false), "Im Kampf: Schildstoß ist als Bogenschütze da")
	_check(abs.all(func(ab: Dictionary) -> bool: return ab.id != "doppelschlag"), "Doppelschlag nicht, weil er nicht auf der Leiste liegt")
	var gegner: Fighter = k.enemies[0]
	var leben := gegner.hp
	var zug := gegner.next_time
	k.skills.execute(held, stoss[0], gegner)
	_check(gegner.hp < leben and gegner.next_time > zug, "Schildstoß trifft und schiebt den Gegner auf der Zugleiste zurück")
	k.cleanup()
	# Kampfstart aus der Welt: Die eigene Klasse bekommt mit, was sie bei Ye gelernt hat
	BattleRequest.player_novize = ["schlag", "schildstoss"]
	BattleRequest.player_skills_known = true
	BattleRequest.player_skills = {}
	BattleRequest.player_bar = ["schildstoss", "", "", "", "", ""]
	BattleRequest.prepare("kael_rivale", 16, 0, "blade")
	var spieler: Dictionary = BattleRequest.setup.helden[0]
	_check(spieler.klasse == "blade" and spieler.get("novize_gelernt", []).has("schildstoss") and spieler.get("leiste", []).has("schildstoss"),
			"Kampf aus der Welt: Klingentänzerin bringt Schildstoß von der Leiste mit")
	BattleRequest.player_novize = []
	BattleRequest.player_skills_known = false
	print("Novizen-Fähigkeiten behalten: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
