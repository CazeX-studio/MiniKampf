extends SceneTree
## Projekt 14, K.5: Fähigkeiten des Novizen nach den Steckbriefen (Sitzung 28): Hieb, Schildstoß (Zugleiste),
## Doppelschlag (Mana, zwei Treffer), Erste Hilfe (heilt sich oder einen Verbündeten), Deckung geben (fängt einen Treffer ab),
## kleine Ult Sternenmut (erst ab der Festnacht, lädt durch perfekte Paraden).

var _fehler := 0


func _check(ok: bool, text: String) -> void:
	if not ok:
		print("FEHLER: " + text)
		_fehler += 1


func _ab(c: BattleState, f: Fighter, id: String) -> Dictionary:
	for ab in c.skills.abilities(f):
		if ab.id == id:
			return ab
	return {}


func _init() -> void:
	var c := BattleState.new(null, [] as Array[String], "", 2)
	c.setup = {helden = [{klasse = "novize", name = "Du", stufe = 1}, {klasse = "novize", name = "Tessa", stufe = 1}], wellen = []}
	c._create_heroes()
	var held: Fighter = c.heroes[0]
	var tessa: Fighter = c.heroes[1]
	var gegner := Fighter.new("Testgegner", "test", "Erde", false, 300, 10, Color.WHITE)
	c.enemies.append(gegner)
	var ids: Array = c.skills.abilities(held).map(func(a: Dictionary) -> String: return a.id)
	for id: String in ["schlag", "schildstoss", "doppelschlag", "erste_hilfe", "deckung"]:
		_check(id in ids, "Novize hat %s nicht" % id)
	_check(not "ult" in ids, "Sternenmut gibt es vor der Festnacht nicht")
	# Schildstoß schiebt auf der Zugleiste zurück
	var zeit := gegner.next_time
	c.execute(held, _ab(c, held, "schildstoss"), gegner)
	_check(gegner.next_time > zeit and gegner.hp < 300, "Schildstoß: kein Schaden oder keine Zugleiste")
	# Doppelschlag: zwei Treffer, kostet Mana
	var mana := held.mana
	var leben := gegner.hp
	c.execute(held, _ab(c, held, "doppelschlag"), gegner)
	_check(held.mana < mana, "Doppelschlag kostet kein Mana")
	_check(leben - gegner.hp >= 2 * 8, "Doppelschlag trifft nicht zweimal (%d Schaden)" % (leben - gegner.hp))
	# Erste Hilfe heilt sich selbst
	held.hp = 10
	held.mana = held.max_mana
	c.execute(held, _ab(c, held, "erste_hilfe"), held)
	_check(held.hp > 10, "Erste Hilfe heilt nicht")
	# Deckung geben: nach vorne, fängt einen Treffer für Tessa ab
	held.back_row = true
	held.mana = held.max_mana
	c.execute(held, _ab(c, held, "deckung"), tessa)
	_check(not held.back_row and tessa.has_meta("gedeckt_von"), "Deckung geben wirkt nicht")
	# Sternenmut: mit der Festnacht da, lädt durch perfekte Paraden
	var fest := BattleState.new(null, [] as Array[String], "", 2)
	BattleRequest.player_gear = {}
	BattleRequest.player_sternenmut = false
	BattleRequest.prepare("sternenfall", 9, 0)
	fest.setup = BattleRequest.setup
	fest._create_heroes()
	var n: Fighter = fest.heroes[0]
	_check("ult" in fest.skills.abilities(n).map(func(a: Dictionary) -> String: return a.id), "In der Festnacht fehlt Sternenmut")
	var ult_vorher := n.ult
	fest.skills.on_perfect_reaction(n, gegner)
	_check(n.ult > ult_vorher, "Perfekte Parade lädt Sternenmut nicht")
	# Nach der Festnacht gemerkt
	var state := WorldState.new()
	var p := state.add_player("a", "Test", "elf_m", WorldState.start_cell())
	state.apply_command("a", {type = "kampf_ergebnis", kampf = "sternenfall", gewonnen = true})
	_check(p.progress.flags.has("sternenmut"), "Sternenmut wird nach der Festnacht nicht gemerkt")
	print("novize_test: %s" % ("OK" if _fehler == 0 else "%d Fehler" % _fehler))
	quit(1 if _fehler > 0 else 0)
