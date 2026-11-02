extends SceneTree
## Projekt 14, K.4: Effekt-Liste als feste Bausteine. Jeder Effekt wirkt und sieht gleich aus, egal wer ihn auslöst.

var _fehler := 0


func _check(ok: bool, text: String) -> void:
	if not ok:
		print("FEHLER: " + text)
		_fehler += 1


func _init() -> void:
	var c := BattleState.new(null, [] as Array[String], "", 5)
	c.setup = {helden = [{klasse = "novize", name = "Du", stufe = 1}, {klasse = "novize", name = "Tessa", stufe = 1}], wellen = []}
	c._create_heroes()
	var held: Fighter = c.heroes[0]
	var freund: Fighter = c.heroes[1]
	var gegner := Fighter.new("Testgegner", "test", "Erde", false, 200, 10, Color.WHITE)
	var zweiter := Fighter.new("Zweiter", "test", "Erde", false, 200, 10, Color.WHITE)
	c.enemies.append_array([gegner, zweiter])
	_check(Effekte.ARTEN.size() == 9, "Die Effekt-Liste hat %d statt 9 Bausteine" % Effekte.ARTEN.size())
	# Brennen: Schaden zu Beginn des Zuges
	Effekte.anwenden(c, held, gegner, "brennen")
	var vorher := gegner.hp
	c._begin_turn(gegner)
	_check(gegner.hp < vorher, "Brennen macht keinen Schaden")
	# Gift stapelt bis 3
	for i in 5:
		Effekte.anwenden(c, held, gegner, "gift")
	_check(int(gegner.effekte.gift.stapel) == 3, "Gift stapelt falsch (%d)" % int(gegner.effekte.gift.stapel))
	# Schattenmale bis 5
	for i in 7:
		Effekte.anwenden(c, held, gegner, "schattenmale")
	_check(int(gegner.effekte.schattenmale.stapel) == 5, "Schattenmale stapeln falsch")
	# Gleiches Aussehen, egal wer: Monster und Held lösen denselben Effekt aus
	Effekte.anwenden(c, gegner, freund, "gift")
	Effekte.anwenden(c, held, zweiter, "gift")
	_check(Effekte.zustaende(freund) == Effekte.zustaende(zweiter), "Gift sieht beim Helden anders aus als beim Monster")
	# Lähmen: Zug fällt aus
	Effekte.anwenden(c, held, zweiter, "laehmen")
	c._begin_turn(zweiter)
	_check(c._gelaehmt, "Lähmen setzt den Zug nicht aus")
	c._begin_turn(zweiter)
	_check(not c._gelaehmt, "Lähmen hält zu lange")
	# Festhalten: keine Reihe wechseln, nicht abwarten
	Effekte.anwenden(c, gegner, held, "festhalten")
	_check(c.skills.blocked_reason(held, {id = "row", target = "none"}) == "Festgehalten", "Festgehalten kann die Reihe wechseln")
	_check(c.skills.blocked_reason(held, c.skills.wait_ability()) == "Festgehalten", "Festgehalten kann abwarten")
	# Verfehlen: der nächste Angriff geht daneben, danach trifft er wieder
	Effekte.anwenden(c, gegner, held, "verfehlen")
	_check(c.hit(held, gegner, 10.0, "melee") == 0, "Verfehlen: Der Angriff hat getroffen")
	_check(c.hit(held, gegner, 10.0, "melee") > 0, "Nach Verfehlen trifft der Angriff nicht wieder")
	# Zugleiste schieben
	var zeit := zweiter.next_time
	Effekte.anwenden(c, held, zweiter, "zugleiste", 0.5)
	_check(zweiter.next_time > zeit, "Zugleiste schieben wirkt nicht")
	# Heilen und Schutz
	freund.hp = 10
	Effekte.anwenden(c, held, freund, "heilen", 15.0)
	_check(freund.hp > 10, "Heilen heilt nicht")
	Effekte.anwenden(c, held, freund, "schutz", 12.0)
	_check(freund.shield_total() >= 12, "Schutz gibt keinen Schild")
	# Dauer läuft ab
	Effekte.anwenden(c, held, freund, "brennen", 1.0, 1)
	c._begin_turn(freund)
	_check(not freund.effekte.has("brennen"), "Brennen hört nicht auf")
	# Sandbox: Knopf zum Auslösen (nur mit Effekt-Probe, nicht in Kämpfen aus der Welt)
	var probe := BattleState.new(null, ["novize"] as Array[String], "beides", 1)
	probe.setup = {}
	Sandbox.effekt_probe = true
	var h2 := Fighter.new("Du", "novize", "Novize", true, 50, 10, Color.WHITE)
	var ids: Array = probe.skills.abilities(h2).map(func(a: Dictionary) -> String: return a.id)
	_check("effekt_probe" in ids, "Sandbox ohne Knopf „Effekt auslösen“")
	_check(not "effekt_probe" in c.skills.abilities(held).map(func(a: Dictionary) -> String: return a.id), "Effekt-Probe in einem Kampf aus der Welt")
	Sandbox.effekt_probe = false
	print("effekte_test: %s" % ("OK" if _fehler == 0 else "%d Fehler" % _fehler))
	quit(1 if _fehler > 0 else 0)
