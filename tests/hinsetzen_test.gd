extends SceneTree
## Projekt 14, K.2: Hinsetzen füllt das Mana, am Lagerfeuer schneller, Losgehen lässt aufstehen.
## Kämpfe in der Wildnis beginnen mit dem Mana aus der Welt, Lektionen in Kreuzweg mit vollem Mana.

var _fehler := 0


func _check(ok: bool, text: String) -> void:
	if not ok:
		print("FEHLER: " + text)
		_fehler += 1


func _init() -> void:
	var state := WorldState.new()
	var p := state.add_player("a", "Test", "elf_m", WorldState.start_cell())
	p.dialog = {}
	_check(p.progress.max_mana() == int(Grundwerte.for_level(1).mana), "Höchstes Mana des Novizen falsch (%d)" % p.progress.max_mana())
	# Hinsetzen in Kreuzweg (kein Lagerfeuer)
	p.progress.mana_anteil = 0.0
	state.apply_command("a", {type = "hinsetzen"})
	_check(p.sitting, "Hinsetzen geht nicht")
	for i in 20:
		state.tick(0.1)
	var langsam := p.progress.mana_anteil
	_check(langsam > 0.0 and langsam < 0.5, "Sitzen füllt das Mana nicht oder zu schnell (%.2f nach 2 Sekunden)" % langsam)
	# Losgehen: wieder aufstehen
	p.steer = Vector2(1, 0)
	state.tick(0.1)
	_check(not p.sitting, "Beim Losgehen bleibt die Figur sitzen")
	p.steer = Vector2.ZERO
	# Am Lagerfeuer (Rastplatz auf dem Weg nach Grünwacht) schneller
	var weg := state.get_map("weg_gruenwacht")
	var feuer := Vector2.ZERO
	for o: Dictionary in weg.baukasten.get("objekte", []):
		if str(o.get("teil", "")) == "lagerfeuer":
			feuer = Vector2(float(o.feld[0]), float(o.feld[1]))
	_check(feuer != Vector2.ZERO, "Kein Lagerfeuer auf dem Weg nach Grünwacht gefunden")
	_check(weg.near_campfire(feuer + Vector2(2, 0), WorldState.CAMPFIRE_RANGE), "Neben dem Lagerfeuer wird es nicht erkannt")
	_check(not weg.near_campfire(feuer + Vector2(12, 0), WorldState.CAMPFIRE_RANGE), "Weit weg zählt als Lagerfeuer")
	_check(WorldState.CAMPFIRE_MANA > WorldState.SIT_MANA, "Am Lagerfeuer füllt es sich nicht schneller")
	# Voll wird es irgendwann
	state.apply_command("a", {type = "hinsetzen"})
	for i in 400:
		state.tick(0.1)
	_check(is_equal_approx(p.progress.mana_anteil, 1.0), "Mana wird beim Sitzen nicht voll (%.2f)" % p.progress.mana_anteil)
	# Gespeichert
	p.progress.mana_anteil = 0.4
	var neu := Progress.new()
	neu.load_dict(p.progress.to_dict())
	_check(is_equal_approx(neu.mana_anteil, 0.4), "Mana wird nicht gespeichert")
	# Kampf in der Wildnis beginnt mit dem Mana aus der Welt, Lektion mit vollem
	BattleRequest.player_mana_share = 0.5
	BattleRequest.player_gear = {}
	BattleRequest.prepare("splitterbaer", 15, 0, "archer")
	_check(is_equal_approx(float(BattleRequest.setup.helden[0].get("mana_anteil", -1.0)), 0.5), "Kampf in der Wildnis bekommt das Mana nicht mit")
	var kampf := BattleState.new(null, [] as Array[String], "", 1)
	kampf.setup = BattleRequest.setup
	kampf._create_heroes()
	var h: Fighter = kampf.heroes[0]
	_check(h.max_mana > 0 and h.mana == roundi(h.max_mana * 0.5), "Held beginnt nicht mit halbem Mana (%d von %d)" % [h.mana, h.max_mana])
	BattleRequest.prepare("probestunde", 1, 0)
	_check(not BattleRequest.setup.helden[0].has("mana_anteil"), "Probestunde sollte mit vollem Mana beginnen")
	# Ergebnis: übriges Mana kommt in die Welt zurück
	state.apply_command("a", {type = "kampf_ergebnis", kampf = "splitterbaer", gewonnen = true, mana_anteil = 0.25})
	_check(is_equal_approx(p.progress.mana_anteil, 0.25), "Übriges Mana kommt nicht in die Welt zurück")
	BattleRequest.player_mana_share = 1.0
	print("hinsetzen_test: %s" % ("OK" if _fehler == 0 else "%d Fehler" % _fehler))
	quit(1 if _fehler > 0 else 0)
