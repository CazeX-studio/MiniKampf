extends SceneTree
## Sternenfresser leicht abgeschwächt (Marco, 11.11.2026): Einen ungeblockten Treffer übersteht jeder einmal,
## und er greift öfter die Hauptperson (echte Spieler) an, damit sie perfekt parieren und den Panzer öffnen kann.
## Aufruf: Godot --headless --path . -s tests/sternenfresser_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _kampf(seed_wert: int) -> BattleState:
	var k := BattleState.new(null, [] as Array[String], "", seed_wert)
	k.setup = {gegner_stufe = 5, helden = [{klasse = "archer", name = "Ich", stufe = 5},
			{klasse = "novize", name = "Begleiter", stufe = 5, computer = true}, {klasse = "novize", name = "Begleiterin", stufe = 5, computer = true}]}
	k._create_heroes()
	k.spawn_enemies(["sternenfresser"])
	return k


func _initialize() -> void:
	var k := _kampf(7)
	var e: Fighter = k.enemies[0]
	var ich: Fighter = k.heroes[0]
	# Öfter die Hauptperson: Sternenschlag (Einzelziel) trifft in den meisten Fällen den Spieler
	var auf_mich := 0
	for i in 400:
		if k._monster_ziele(Sandbox.ENEMIES.sternenfresser.attacks[0], e)[0] == ich:
			auf_mich += 1
	_check(auf_mich > 260, "Der Sternenfresser greift meist die Hauptperson an (%d von 400)" % auf_mich)
	_check(k._monster_ziele(Sandbox.ENEMIES.sternenfresser.attacks[1], e).size() == 3, "Splitterregen trifft weiter alle")
	# Ein ungeblockter Treffer (keine Reaktion): knapp überlebt, der zweite ist tödlich
	ich.reaction = ""
	await k.enemy_attack(e, [ich] as Array[Fighter], 28, "melee", "Sternenschlag")
	_check(ich.is_alive() and ich.hp <= roundi(ich.max_hp * 0.1), "Erster Treffer ohne Block: knapp überlebt (%d/%d)" % [ich.hp, ich.max_hp])
	await k.enemy_attack(e, [ich] as Array[Fighter], 28, "melee", "Sternenschlag")
	_check(not ich.is_alive(), "Zweiter Treffer ohne Block: besiegt")
	# Der angekündigte Sternenschlund bleibt streng
	var k2 := _kampf(8)
	var e2: Fighter = k2.enemies[0]
	var ich2: Fighter = k2.heroes[0]
	ich2.reaction = ""
	e2.set_meta("streng", true)
	await k2.enemy_attack(e2, [ich2] as Array[Fighter], 28, "melee", "Sternenschlund")
	_check(not ich2.is_alive(), "Sternenschlund ohne perfekte Parade: sofort besiegt")
	k.cleanup()
	k2.cleanup()
	print("Sternenfresser: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
