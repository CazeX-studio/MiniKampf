extends SceneTree
## D20a: Hutmacher Hatta, Hüte der Regionen, Monster-Beute und Zeichen über den Diensten.
## Aufruf: Godot --headless --path . -s tests/hutmacher_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	var huete := ["gruene_kapuze", "filzhut", "kopftuch", "schmiedekappe", "wachhelm", "kochmuetze", "stoffmuetze", "gelehrtenhut"]
	for hut: String in huete:
		_check(FigurTeile.hut_liste().has(hut) and FigurTeile.hut_belohnung(hut), "Hut %s ist da und erst nach dem Tausch wählbar" % hut)
		for r: String in ["seite", "vorn", "hinten"]:
			_check(ResourceLoader.exists("res://assets/teile/hut/%s_%s.png" % [hut, r]), "Bild %s %s" % [hut, r])
	var tausch: Dictionary = GameData.get_file("laeden").hatta.tausch
	_check(tausch.keys().size() == huete.size(), "Hatta tauscht alle acht Hüte")
	for z: String in ["muenze", "truhe", "hut", "laterne"]:
		_check(UiStil.zeichen(z) != null, "Zeichen %s" % z)

	var world := WorldState.new()
	_check(world.npcs.has("hatta") and world.npcs.hatta.zeichen == "hut", "Hatta steht in Kreuzweg, mit Hut-Zeichen")
	_check(world.npcs.bingo.zeichen == "muenze" and world.npcs.bank_kreuzweg.zeichen == "truhe" and world.npcs.salbei.zeichen == "muenze"
			and world.npcs.bank_wipfelheim.zeichen == "truhe", "Zeichen über Bingo, Salbei und den Banken")
	_check(world.places.any(func(o: Dictionary) -> bool: return o.zeichen == "laterne"), "Laterne über der Wegelaterne")
	# Seit 10.11. eigenes Welt-Blatt mit Zylinder und Maßband (GRAFIK_AUFTRAG.md B6h)
	_check(world.npcs.hatta.look == "hatta" and ResourceLoader.exists(FighterView.sprite_path("hatta", "run_hinten", 3)), "Hatta mit eigenen Bildern")

	# Beute: Nach Siegen in der Wildnis fällt Material
	var p := world.add_player("a", "Test", "novize_m+m1", Vector2i(6, 15))
	world.card_rng.seed = 11
	var falke := -1
	for i in world.monsters.size():
		if world.monsters[i].gegner == ["windfalke"]:
			falke = i
	for n in 10:
		world.apply_command("a", {type = "kampf_ergebnis", kampf = "wild:%d" % falke, gewonnen = true})
	var federn := p.progress.item_count("falkenfeder")
	_check(federn >= 4 and federn <= 10, "Windfalken lassen meistens eine Falkenfeder fallen (%d von 10)" % federn)

	# Bei Hatta tauschen: erst zu wenig, dann genug
	world.change_map(p, "kreuzweg", Vector2i(44, 16))
	p.shop = "hatta"
	p.progress.gold = 10
	world.apply_command("a", {type = "hut_tauschen", hut = "filzhut"})
	_check(not world.hut_frei(p, "filzhut"), "Zu wenig Bronze: kein Hut")
	p.progress.gold = 100
	world.apply_command("a", {type = "hut_tauschen", hut = "filzhut"})
	_check(world.hut_frei(p, "filzhut") and p.progress.gold == 70 and p.progress.item_count("falkenfeder") == federn - 4,
			"Getauscht: Filzhut frei, 4 Federn und 30 Bronze weg")
	world.apply_command("a", {type = "hut_tauschen", hut = "filzhut"})
	_check(p.progress.gold == 70, "Denselben Hut tauscht man nicht zweimal")
	world.apply_command("a", {type = "hut_tauschen", hut = "wachhelm"})
	_check(not world.hut_frei(p, "wachhelm"), "Ohne die Beute kein Wachhelm")
	world.apply_command("a", {type = "aussehen", hut = "filzhut"})
	_check(FigurTeile.aussehen_von(p.look).hut == "filzhut", "Den eingetauschten Hut kann man aufsetzen")
	Tageszeit.feste_stunde = -1.0
	print("Hutmacher: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
