extends SceneTree
## Prüft Kreuzweg-Karten (Grünwacht Schritt 9): Regeln, Computer-Gegner, Sternentafel bei Bingo, Marv (genau eine
## Partie), Oma Hagebutte, Monsterkarten als Beute und den Spieltisch mit Anzeige.
## Aufruf: Godot --headless --path . --script res://tests/kartenspiel_test.gd

var _failed := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_rules()
	_test_opponents()
	_test_world()
	await _test_table()
	print("Kartenspiel: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


func _test_rules() -> void:
	var g := KartenSpiel.new(["rindenbaer", "feldschleim"], ["feldschleim", "wiesenkobold"])
	_check(g.place(KartenSpiel.SPIELER, 1, 4), "Spieler legt in die Mitte")
	_check(not g.place(KartenSpiel.SPIELER, 0, 3), "Zweimal hintereinander geht nicht")
	_check(not g.place(KartenSpiel.GEGNER, 0, 4), "Besetztes Feld geht nicht")
	# Gegner legt rechts neben den Feldschleim (links 3 gegen rechts 3): kein Umdrehen bei Gleichstand
	g.place(KartenSpiel.GEGNER, 0, 5)
	_check(g.board[4].besitzer == KartenSpiel.SPIELER, "Gleich hohe Zahlen drehen nicht um")
	# Rindenbär (unten 5) über die Gegnerkarte (oben 2 beim Feldschleim) legen: umdrehen
	g.place(KartenSpiel.SPIELER, 0, 2)
	_check(g.board[5].besitzer == KartenSpiel.SPIELER and g.last_flips == [5], "Höhere Zahl dreht die Nachbarkarte um")
	_check(g.score(KartenSpiel.SPIELER) == 3 and g.score(KartenSpiel.GEGNER) == 1, "Punkte: Feld und Hand zählen")
	var deck := KartenSpiel.best_deck({feldschleim = 2, rindenbaer = 1, donnerhirsch = 1, wiesenkobold = 3})
	_check(deck.size() == 5 and deck[0] in ["rindenbaer", "donnerhirsch"], "Deck: die fünf stärksten Karten")


## Computer gegen Computer: Gegen Marv (legt irgendwas) gewinnt man meistens, Oma Hagebutte ist mit Startkarten schwer.
func _test_opponents() -> void:
	var data: Dictionary = GameData.get_file("kartenspiel")
	var starter := KartenSpiel.best_deck(_count(data.startkarten))
	var strong := ["rindenbaer", "donnerhirsch", "wilde_glutwelpe", "wilder_bachotter", "windfalke"]
	var rates := {}
	for test: Array in [["marv", starter], ["oma_hagebutte", starter], ["oma_hagebutte", strong]]:
		var wins := 0
		var rng := RandomNumberGenerator.new()
		rng.seed = 5
		for i in 200:
			var g := KartenSpiel.new(test[1], data.gegner[test[0]].deck, i % 2)
			while not g.finished():
				var move := g.computer_move("schlau", rng, KartenSpiel.SPIELER) if g.turn == KartenSpiel.SPIELER \
						else g.computer_move(data.gegner[test[0]].spielweise, rng)
				g.place(g.turn, move.x, move.y)
			if g.score(KartenSpiel.SPIELER) > g.score(KartenSpiel.GEGNER):
				wins += 1
		rates[test[0] + (" stark" if test[1] == strong else "")] = wins / 2
	print("  Siege in %%: %s" % rates)
	_check(rates.marv >= 70, "Gegen Marv gewinnt man mit den Startkarten meistens (%d %%)" % rates.marv)
	_check(rates.oma_hagebutte < 50, "Oma Hagebutte schlägt die Startkarten meistens (%d %%)" % rates.oma_hagebutte)
	_check(rates["oma_hagebutte stark"] >= 40, "Mit Grünwacht-Karten ist Oma schaffbar (%d %%)" % rates["oma_hagebutte stark"])


func _count(ids: Array) -> Dictionary:
	var result := {}
	for id: String in ids:
		result[id] = int(result.get(id, 0)) + 1
	return result


func _test_world() -> void:
	var world := WorldState.new()
	var scenes: Array[String] = []
	world.scene_requested.connect(func(_id: String, scene: String) -> void: scenes.append(scene))
	var p := world.add_player("a", "Test", "elf_m", Vector2i(10, 31))
	p.progress.flags["klasse"] = "archer"
	p.progress.flags["klasse_bestaetigt"] = true
	p.progress.quests["nach_gruenwacht"] = "abgegeben"
	p.progress.gold = 700
	_check(world.shop_wares("bingo_heimkehr").filter(func(w: Dictionary) -> bool: return w.gegenstand == "sternentafel")[0].preis == 600, "Heimkehrer-Preis: 600 Gold")
	_check(world.shop_wares("bingo").filter(func(w: Dictionary) -> bool: return w.gegenstand == "sternentafel")[0].preis == 5000, "In Akt 1 bleibt sie zu teuer")

	# Marv in Wipfelheim gibt den Auftrag
	world.change_map(p, "wipfelheim", Vector2i(21, 13))
	_tick(world, 1.0)
	_check(p.in_dialog() and p.dialog.id == "marv_gruenwacht", "Marv spricht einen an")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_choose", index = 0})
	world.apply_command("a", {type = "dialog_next"})
	_check(p.progress.quest_state("marvs_partie") == "aktiv" and world.npc_marker_side(p, "marv_gruenwacht"), "Nebenauftrag „Marvs Partie“ (blau)")
	_check(world.objective(p).contains("Sternentafel") or world.objective(p) == "", "Ziel: Sternentafel kaufen")

	# Bei Bingo in Kreuzweg kaufen
	world.change_map(p, "kreuzweg", Vector2i(10, 31))
	world.apply_command("a", {type = "talk", npc = "bingo"})
	_tick(world, 3.0)
	_check(p.dialog.get("node", "") == "heimkehr", "Bingo begrüßt Heimkehrer")
	world.apply_command("a", {type = "dialog_choose", index = 1})
	world.apply_command("a", {type = "kaufen", gegenstand = "sternentafel"})
	_check(p.progress.item_count("sternentafel") == 1 and p.progress.gold == 100, "Sternentafel für 600 Gold gekauft")
	world.apply_command("a", {type = "laden_zu"})

	# Die eine Partie mit Marv
	world.change_map(p, "wipfelheim", Vector2i(21, 14))
	world.apply_command("a", {type = "talk", npc = "marv_gruenwacht"})
	_tick(world, 2.0)
	_check(p.dialog.get("node", "") == "tafel_da", "Marv sieht die Tafel")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(scenes == ["kartenspiel:marv"] and p.progress.flags.get("karten", {}).size() == 7, "Partie beginnt, 7 Startkarten")
	world.apply_command("a", {type = "karten_ergebnis", gegner = "marv", gewonnen = true})
	_check(p.progress.flags.has("gespielt:marv") and p.progress.quest_state("marvs_partie") == "fertig", "Partie gespielt")
	world.apply_command("a", {type = "talk", npc = "marv_gruenwacht"})
	_tick(world, 2.0)
	world.apply_command("a", {type = "dialog_next"})
	_check(p.progress.flags.has("erfolg:marv_hatte_zeit"), "Erfolg „Marv hatte Zeit“")
	world.apply_command("a", {type = "talk", npc = "marv_gruenwacht"})
	_tick(world, 2.0)
	_check(world.dialog_view(p).text.contains("Eichhörnchen"), "Danach nur noch Ausreden")
	world.apply_command("a", {type = "dialog_next"})

	# Oma Hagebutte: Karte beim ersten Sieg
	world.apply_command("a", {type = "talk", npc = "oma_hagebutte"})
	_tick(world, 4.0)
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(scenes.back() == "kartenspiel:oma_hagebutte", "Partie gegen Oma Hagebutte")
	var gold := p.progress.gold
	world.apply_command("a", {type = "karten_ergebnis", gegner = "oma_hagebutte", gewonnen = true})
	_check(int(p.progress.flags.karten.get("wilder_moosling", 0)) == 1 and p.progress.gold == gold + 40, "Sieg: Moosling-Karte und Gold")
	world.apply_command("a", {type = "karten_ergebnis", gegner = "oma_hagebutte", gewonnen = true})
	_check(int(p.progress.flags.karten.get("wilder_moosling", 0)) == 1, "Die Karte gibt es nur beim ersten Sieg")
	_check(p.progress.quest_state("omas_herausforderung") == "fertig", "Nebenauftrag „Omas Herausforderung“ erfüllt")
	world.apply_command("a", {type = "talk", npc = "oma_hagebutte"})
	_tick(world, 4.0)
	_check(world.dialog_view(p).text.contains("vierzig Jahren!"), "Oma ist geschlagen")
	world.apply_command("a", {type = "dialog_next"})
	_check(p.progress.quest_state("omas_herausforderung") == "abgegeben", "Omas Herausforderung abgegeben")

	# Monsterkarten als Beute in der Wildnis
	world.card_rng.seed = 1
	var before := 0
	for id: String in p.progress.flags.karten:
		before += int(p.progress.flags.karten[id])
	for i in 30:
		world.apply_command("a", {type = "kampf_ergebnis", kampf = "wild:1", gewonnen = true})
	var after := 0
	for id: String in p.progress.flags.karten:
		after += int(p.progress.flags.karten[id])
	_check(after > before and int(p.progress.flags.karten.get("steinkroete", 0)) > 0, "Monsterkarten als Beute (%d neue)" % (after - before))


## Der Spieltisch mit Anzeige: eine ganze Partie durchtippen, danach ist das Ergebnis da.
func _test_table() -> void:
	KartenTisch.gegner = "marv"
	KartenTisch.deck = ["rindenbaer", "donnerhirsch", "windfalke", "steinkroete", "wilder_moosling"]
	KartenTisch.return_scene = "res://scenes/menu.tscn"
	change_scene_to_file("res://scenes/kartentisch.tscn")
	await _frames(5)
	var table: KartenTisch = current_scene
	_check(table != null and table._hand_box.get_child_count() == 5, "Spieltisch mit fünf Karten auf der Hand")
	var rng := RandomNumberGenerator.new()
	for i in 20:
		if table._over:
			break
		while table._waiting:
			await create_timer(0.1).timeout
		if table._over:
			break
		var move := table.game.computer_move("schlau", rng, KartenSpiel.SPIELER)
		table._selected = move.x
		table._on_cell(move.y)
		await _frames(2)
	_check(table._over and not KartenTisch.ergebnis.is_empty() and KartenTisch.ergebnis.gegner == "marv", "Partie zu Ende, Ergebnis für die Welt")
	table._leave()
	await _frames(5)
	_check(not current_scene is KartenTisch, "Danach zurück")
	KartenTisch.ergebnis = {}
	KartenTisch.return_scene = "res://scenes/kreuzweg.tscn"


func _tick(world: WorldState, seconds: float) -> void:
	for i in int(seconds / 0.05):
		world.tick(0.05)


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failed += 1
	print("%s %s" % ["OK    " if ok else "FEHLER", what])
