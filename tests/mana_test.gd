extends SceneTree
## Projekt 14, K.2: Mana nur durch Handeln. Kein Mana von selbst, normaler Angriff etwas, perfekte Parade mehr,
## Abwarten etwas, Manatränke; Abklingzeiten nur für die stärksten Fähigkeiten. Dazu ein Probekampf:
## Ein normaler Kampf ohne Trank soll 3 bis 5 Runden dauern.

var _fehler := 0


func _check(ok: bool, text: String) -> void:
	if not ok:
		print("FEHLER: " + text)
		_fehler += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var kampf := BattleState.new(null, [] as Array[String], "", 3)
	kampf.setup = {helden = [{klasse = "novize", name = "Du", stufe = 1, manatraenke = 2}], wellen = []}
	kampf._create_heroes()
	var h: Fighter = kampf.heroes[0]
	var gegner := Fighter.new("Testgegner", "test", "Erde", false, 500, 10, Color.WHITE)
	kampf.enemies.append(gegner)
	# Kein Mana von selbst
	h.mana = 10
	kampf._begin_turn(h)
	_check(h.mana == 10, "Mana füllt sich zu Beginn des Zuges von selbst (%d)" % h.mana)
	# Normaler Angriff gibt etwas Mana
	var schlag: Dictionary = kampf.skills.abilities(h)[0]
	_check(kampf.skills.is_basic_attack(h, schlag.id), "Der Schlag gilt nicht als normaler Angriff")
	kampf.execute(h, schlag, gegner)
	_check(h.mana > 10, "Normaler Angriff gibt kein Mana (%d)" % h.mana)
	# Doppelschlag kostet Mana und gibt keins
	var kraft: Dictionary = kampf.skills.abilities(h).filter(func(a: Dictionary) -> bool: return a.id == "doppelschlag")[0]
	_check(not kraft.has("cd"), "Doppelschlag hat eine Abklingzeit (nur die stärksten Fähigkeiten haben eine)")
	_check(not kampf.skills.is_basic_attack(h, "doppelschlag"), "Doppelschlag gilt als normaler Angriff")
	# Die stärksten Fähigkeiten behalten ihre Abklingzeit (Beispiel: Bann-Zeichen des Tanks)
	var tank_kampf := BattleState.new(null, [] as Array[String], "", 3)
	tank_kampf.setup = {helden = [{klasse = "tank", name = "Tank", stufe = 1}], wellen = []}
	tank_kampf._create_heroes()
	var bann: Array = tank_kampf.skills.abilities(tank_kampf.heroes[0]).filter(func(a: Dictionary) -> bool: return a.id == "ban")
	_check(not bann.is_empty() and int(bann[0].get("cd", 0)) == 3, "Bann-Zeichen hat seine Abklingzeit verloren")
	# Perfekte Parade gibt mehr als ein Angriff
	h.mana = 0
	var parade := kampf.gain_mana(h, BattleState.MANA_PERFECT)
	h.mana = 0
	var angriff := kampf.gain_mana(h, BattleState.MANA_ATTACK)
	_check(parade > angriff and angriff > 0, "Perfekte Parade (%d) muss mehr geben als ein Angriff (%d)" % [parade, angriff])
	# Abwarten gibt etwas Mana
	h.mana = 0
	kampf.execute(h, kampf.skills.wait_ability(), null)
	_check(h.mana > 0, "Abwarten gibt kein Mana")
	# Manatrank
	h.mana = 0
	var trank: Array = kampf.skills.abilities(h).filter(func(a: Dictionary) -> bool: return a.id == "manatrank_trinken")
	_check(not trank.is_empty(), "Novize mit Manatränken hat keinen Knopf dafür")
	if not trank.is_empty():
		kampf.execute(h, trank[0], h)
		_check(h.mana == Skills.NOVIZE.manatrank and h.wares.manatrank == 1, "Manatrank wirkt nicht (%d Mana)" % h.mana)
	# Probekampf: Gruppenkampf auf den Kreuzwegfeldern, ohne Trank
	var runden: Array[int] = []
	for seed in [1, 2, 3, 4, 5, 6]:
		runden.append(await _probekampf(seed))
	var summe := 0
	for r in runden:
		summe += r
	var schnitt := float(summe) / runden.size()
	print("Probekampf: Runden des Spielers je Kampf %s, im Schnitt %.1f" % [runden, schnitt])
	_check(schnitt >= 3.0 and schnitt <= 5.5, "Ein normaler Kampf dauert im Schnitt %.1f Runden (Ziel 3 bis 5)" % schnitt)
	print("mana_test: %s" % ("OK" if _fehler == 0 else "%d Fehler" % _fehler))
	quit(1 if _fehler > 0 else 0)


func _probekampf(seed: int) -> int:
	BattleRequest.player_gear = {}
	BattleRequest.player_mana_potions = 0
	BattleRequest.prepare("gruppenkampf", 3, 0)
	var steuerer := Steuerer.new()
	root.add_child(steuerer)
	steuerer.state = BattleState.new(steuerer, [] as Array[String], "", seed)
	steuerer.state.setup = BattleRequest.setup
	steuerer.state.max_turns = 60
	await steuerer.state.run()
	var r := steuerer.runden
	steuerer.queue_free()
	return r


## Spielt wie ein normaler Spieler: Doppelschlag, wenn das Mana reicht, sonst Hieb; jede dritte Parade perfekt.
class Steuerer extends Node:
	var state: BattleState
	var runden := 0
	var _paraden := 0

	func play(_events: Array[Dictionary]) -> void:
		pass

	func choose_action(f: Fighter) -> Dictionary:
		if f == state.heroes[0]:
			runden += 1
		var ziele := state.alive(state.enemies)
		var liste := state.skills.abilities(f)
		for ab: Dictionary in liste:
			if ab.id == "doppelschlag" and state.skills.blocked_reason(f, ab) == "":
				return {ab = ab, target = ziele[0]}
		return {ab = liste[0], target = ziele[0]}

	func react(_a: Fighter, _t: Fighter, _d: float) -> Variant:
		_paraden += 1
		return 2 if _paraden % 3 == 0 else 1

	func choose_option(_title: String, options: Array[Dictionary]) -> String:
		return options[0].id
