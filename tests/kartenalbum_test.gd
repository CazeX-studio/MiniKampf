extends SceneTree
## D15: Kartenalbum (Projekt 8, Schritt 1–3). Seiten je Region mit festen Plätzen und Zähler, verdeckte Karten in der
## Tasche (bei voller Tasche im Beute-Fenster), Aktivieren, Element und Schwäche, dazu das Fenster in Kreuzweg.
## D16: Besitzeffekte im Kampf und unter Werte, Deck für Kreuzweg-Karten, doppelte Karten bei Bingo verkaufen.
## Aufruf: Godot --headless --path . -s tests/kartenalbum_test.gd

var _failed := 0
var _frame := 0
var _town: Node


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	_test_daten()
	_test_welt()
	_test_boni()
	_test_deck_und_ankauf()
	_test_volle_seite()
	_test_marv()
	_test_verbessern()
	SaveGame.path = "user://test_kartenalbum.json"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveGame.path))
	change_scene_to_file("res://scenes/kreuzweg.tscn")


func _test_daten() -> void:
	var seiten := KartenAlbum.seiten()
	_check(seiten.size() >= 2 and seiten[0].name == "Kreuzweg" and seiten[1].name == "Grünwacht", "Seiten Kreuzweg und Grünwacht")
	var alle := {}
	for seite: Dictionary in seiten:
		for id: String in seite.karten:
			_check(not alle.has(id), "%s steht nur auf einer Seite" % id)
			alle[id] = true
			_check(KartenSpiel.card(id).has("name"), "%s ist eine Karte" % id)
			_check(FighterView.LOOKS.has(id), "%s hat ein Bild" % id)
			_check(Sandbox.ENEMIES.has(id) and KartenAlbum.info(id).element != "", "%s hat ein Element" % id)
	# Jedes Monster aus der Wildnis hat einen Platz im Album
	for m: Dictionary in GameData.wild_monsters():
		for id: String in m.gegner:
			_check(alle.has(id), "Monster %s hat einen Platz im Album" % id)
	_check(KartenAlbum.zaehler({windfalke = 2, steinkroete = 1, feldschleim = 0}, seiten[1]) == [2, seiten[1].karten.size()],
			"Zähler: verschiedene Karten, doppelte zählen einmal")
	var info := KartenAlbum.info("windfalke")
	_check(info.element == "Wind" and "Blitz" in info.schwaechen, "Windfalke: Wind, schwach gegen Blitz")


func _test_welt() -> void:
	Tageszeit.feste_stunde = 12.0
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "elf_m", Vector2i(6, 15))
	p.progress.items["sternentafel"] = 1
	world.card_rng.seed = 3
	world.card_rng.randf()
	# Eine Karte finden (der Kampf bestimmt sie vorher, wie am Ende des Kampfes angezeigt)
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "wild:0", gewonnen = true, karte = "windfalke"})
	_check(p.progress.item_count("monsterkarte_windfalke") == 1, "Gefundene Karte liegt verdeckt in der Tasche")
	_check(not p.progress.flags.get("karten", {}).has("windfalke"), "Im Album noch nicht")
	world.apply_command("a", {type = "karte_aktivieren", gegenstand = "monsterkarte_windfalke"})
	_check(int(p.progress.flags.karten.get("windfalke", 0)) == 1 and p.progress.item_count("monsterkarte_windfalke") == 0,
			"Aktivieren: im Album, die Tasche ist wieder frei")
	world.apply_command("a", {type = "karte_aktivieren", gegenstand = "monsterkarte_windfalke"})
	_check(int(p.progress.flags.karten.windfalke) == 1, "Ohne Karte in der Tasche passiert nichts")
	# Volle Tasche: Die Karte wartet im Beute-Fenster
	world.apply_command("a", {type = "test_tasche"})
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "wild:0", gewonnen = true, karte = "steinkroete"})
	_check(int(p.progress.loot.get("monsterkarte_steinkroete", 0)) == 1, "Tasche voll: Karte im Beute-Fenster")
	Tageszeit.feste_stunde = -1.0


func _test_boni() -> void:
	for seite: Dictionary in KartenAlbum.seiten():
		for id: String in seite.karten:
			_check(not KartenAlbum.bonus(id).is_empty(), "%s hat einen Besitzeffekt" % id)
	var b := KartenAlbum.boni({feldschleim = 3, steinkroete = 1, windfalke = 1, dornling = 0})
	_check(b == {leben = 5, tempo = 1}, "Boni: doppelte zählen einmal, fehlende gar nicht (%s)" % str(b))
	_check(KartenAlbum.boni_text(b) == "+5 Leben · +1 Tempo", "Boni als Text")
	# Im Kampf: mehr Leben und Tempo als ohne Karten
	BattleRequest.player_gear = {}
	BattleRequest.player_card_bonus = {}
	BattleRequest.prepare("wild:0", 12, 0, "archer")
	var ohne := _held(BattleRequest.setup)
	BattleRequest.player_card_bonus = b
	BattleRequest.prepare("wild:0", 12, 0, "archer")
	var mit := _held(BattleRequest.setup)
	_check(mit.max_hp == ohne.max_hp + 5 and mit.tempo == ohne.tempo + 1, "Im Kampf: +5 Leben und +1 Tempo (%d/%d → %d/%d)" % [ohne.max_hp, ohne.tempo, mit.max_hp, mit.tempo])
	_check(is_equal_approx(float(BattleRequest.setup.helden[0].ausruestung.macht), 1.0), "Ohne eigene Ausrüstung bleibt die Stärke gleich")
	BattleRequest.player_card_bonus = {angriff = 2}
	BattleRequest.prepare("wild:0", 12, 0, "archer")
	_check(float(BattleRequest.setup.helden[0].ausruestung.macht) > 1.0, "Angriff-Bonus macht stärker")
	BattleRequest.player_card_bonus = {}
	BattleRequest.kampf_id = ""
	# Mana in der Welt: Grenze steigt mit Mana-Karten
	var pr := Progress.new()
	pr.flags["klasse"] = "singer"
	pr.flags["klasse_bestaetigt"] = true
	pr.flags["klasse_gelernt"] = true
	var vorher := pr.max_mana()
	pr.flags["karten"] = {irrlicht = 1}
	_check(pr.max_mana() == vorher + 3, "Irrlicht-Karte: +3 Mana auch in der Welt")


func _held(setup: Dictionary) -> Fighter:
	var st := BattleState.new(Node.new(), [] as Array[String], "", 7)
	st.setup = setup
	st._create_heroes()
	return st.heroes[0]


func _test_deck_und_ankauf() -> void:
	_check(KartenAlbum.deck({feldschleim = 1, rindenbaer = 1, donnerhirsch = 1, wiesenkobold = 2, dornling = 1, windfalke = 1}, ["feldschleim", "dornling"]).slice(0, 2) == ["feldschleim", "dornling"],
			"Deck: gewählte Karten zuerst")
	_check(KartenAlbum.deck({feldschleim = 1, rindenbaer = 1}, ["windfalke"]) == ["rindenbaer", "feldschleim"], "Deck: nur Karten, die man hat, Rest aufgefüllt")
	Tageszeit.feste_stunde = 12.0
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "elf_m", Vector2i(6, 15))
	p.progress.flags["karten"] = {feldschleim = 3, wiesenkobold = 1, ruepelkobold = 1, glutkobold = 1, dornling = 1, sturmkobold = 1}
	for id: String in ["feldschleim", "wiesenkobold", "ruepelkobold", "glutkobold", "dornling", "sturmkobold"]:
		world.apply_command("a", {type = "deck", karte = id})
	_check(p.progress.flags.deck.size() == 5 and not "sturmkobold" in p.progress.flags.deck, "Deck: höchstens 5 Karten")
	world.apply_command("a", {type = "deck", karte = "dornling"})
	_check(p.progress.flags.deck.size() == 4 and not "dornling" in p.progress.flags.deck, "Karte wieder aus dem Deck")
	world.apply_command("a", {type = "deck", karte = "rindenbaer"})
	_check(not "rindenbaer" in p.progress.flags.deck, "Karten, die man nicht hat, kommen nicht ins Deck")
	# Verkaufen nur bei Bingo, die letzte bleibt
	var gold := p.progress.gold
	world.apply_command("a", {type = "karte_verkaufen", karte = "feldschleim"})
	_check(p.progress.flags.karten.feldschleim == 3, "Ohne Laden kein Verkauf")
	p.shop = "salbei"
	world.apply_command("a", {type = "karte_verkaufen", karte = "feldschleim"})
	_check(p.progress.flags.karten.feldschleim == 3, "Salbei kauft keine Karten")
	p.shop = "bingo"
	world.apply_command("a", {type = "karte_verkaufen", karte = "feldschleim"})
	world.apply_command("a", {type = "karte_verkaufen", karte = "feldschleim"})
	world.apply_command("a", {type = "karte_verkaufen", karte = "feldschleim"})
	_check(p.progress.flags.karten.feldschleim == 1, "Bingo kauft die doppelten, die letzte bleibt")
	_check(p.progress.gold == gold + 2 * KartenAlbum.ankaufpreis("feldschleim") and KartenAlbum.ankaufpreis("feldschleim") > 0,
			"Geld steigt um ein paar Bronze (%d je Karte)" % KartenAlbum.ankaufpreis("feldschleim"))
	world.apply_command("a", {type = "karte_verkaufen", karte = "wiesenkobold"})
	_check(p.progress.flags.karten.wiesenkobold == 1, "Einzelne Karten verkauft man nicht")
	Tageszeit.feste_stunde = -1.0


## D17: volle Seite -> Titel und Kopfbedeckung, volles Album -> Kartenrücken
func _test_volle_seite() -> void:
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "elf_m", Vector2i(6, 15))
	p.look = "novize_w"
	_check(not world.hut_frei(p, "geweihband") and world.hut_frei(p, "wanderhut"), "Belohnungs-Hut ist erst gesperrt, der Wanderhut nicht")
	world.apply_command("a", {type = "aussehen", hut = "geweihband"})
	_check(FigurTeile.aussehen_von(p.look).get("hut", "") != "geweihband", "Gesperrten Hut kann man nicht aufsetzen")
	var seiten := KartenAlbum.seiten()
	for karte: String in seiten[1].karten.slice(1):
		world.add_card(p, karte)
	_check(not p.progress.flags.has("titel"), "Fast volle Seite: noch keine Belohnung")
	world.add_card(p, seiten[1].karten[0])
	_check(p.progress.flags.get("titel", "") == "Kenner von Grünwacht", "Volle Seite: Titel „Kenner von Grünwacht“")
	_check(world.hut_frei(p, "geweihband") and not world.hut_frei(p, "sternreif"), "Volle Seite: die Kopfbedeckung der Region")
	world.apply_command("a", {type = "aussehen", hut = "geweihband"})
	_check(FigurTeile.aussehen_von(p.look).get("hut", "") == "geweihband", "Jetzt lässt sie sich aufsetzen")
	_check(FigurTeile.hut_liste().has("geweihband") and FigurTeile.hut_belohnung("geweihband"), "Kopfbedeckung steht in der Hut-Liste")
	_check(not p.progress.flags.has("kartenruecken"), "Noch kein Kartenrücken (Kreuzweg fehlt)")
	world.apply_command("a", {type = "test_album", seite = 0})
	_check(p.progress.flags.get("titel", "") == "Kenner von Kreuzweg" and world.hut_frei(p, "sternreif"), "Testknopf füllt Kreuzweg: Titel und Kopfbedeckung")
	# Seit D23 gibt es die Glutoase-Seite: erst mit ihr ist das Album voll
	_check(not p.progress.flags.has("kartenruecken"), "Noch kein Kartenrücken (Glutoase fehlt)")
	world.apply_command("a", {type = "test_album", seite = 2})
	_check(p.progress.flags.get("kartenruecken", "") == "sterne", "Volles Album: Sternen-Kartenrücken")
	var vorher := p.progress.flags.duplicate(true)
	world.add_card(p, "windfalke")
	_check(p.progress.flags.titel == vorher.titel, "Belohnung gibt es nur einmal")


func _test_marv() -> void:
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "elf_m", Vector2i(6, 15))
	p.progress.quests["marvs_traum"] = "abgegeben"
	p.progress.flags["karten"] = {feldschleim = 1}
	_check(world._entry_node(p, "marv") == "danach", "Nur Startkarten: Marv hat nichts Neues zu sagen")
	p.progress.flags["karten"] = {feldschleim = 1, windfalke = 1}
	_check(world._entry_node(p, "marv") == "neue_karte", "Neue Karte: Marv spricht sie an")
	world.start_dialog(p, "marv")
	_check(world.dialog_view(p).text.contains("Windfalke"), "Marv nennt die Karte beim Namen")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	_check(world._entry_node(p, "marv") == "danach", "Danach kennt er sie")


func _test_verbessern() -> void:
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "elf_m", Vector2i(6, 15))
	world.card_rng.seed = 5
	p.progress.flags["karten"] = {rindenbaer = 12}
	p.progress.gold = 100000
	var grund := int(KartenAlbum.bonus("rindenbaer").leben)
	world.apply_command("a", {type = "karte_verbessern", karte = "rindenbaer"})
	_check(int(p.progress.flags.karten_stufe.rindenbaer) == 1 and p.progress.flags.karten.rindenbaer == 11
			and p.progress.gold == 100000 - KartenAlbum.verbessern_preis(1), "+1: eine doppelte Karte und Bronze sind weg")
	for i in 3:
		world.apply_command("a", {type = "karte_verbessern", karte = "rindenbaer"})
	_check(int(p.progress.flags.karten_stufe.rindenbaer) == 4, "Bis +4 klappt es immer")
	_check(int(KartenAlbum.boni_von(p.progress.flags).leben) > grund, "Der Besitzeffekt ist gestiegen (%d → %d)" % [grund, KartenAlbum.boni_von(p.progress.flags).leben])
	var fehlschlag := false
	for i in 7:
		var vorher := int(p.progress.flags.karten_stufe.rindenbaer)
		var karten_vorher := int(p.progress.flags.karten.rindenbaer)
		if karten_vorher < 2:
			break
		world.apply_command("a", {type = "karte_verbessern", karte = "rindenbaer"})
		if int(p.progress.flags.karten_stufe.rindenbaer) == vorher:
			fehlschlag = true
			_check(int(p.progress.flags.karten.rindenbaer) == karten_vorher - 1, "Fehlschlag: Stufe bleibt, doppelte Karte ist weg")
	_check(fehlschlag, "Ab +5 klappt es manchmal nicht")
	p.progress.flags["karten"] = {rindenbaer = 1}
	var stufe := int(p.progress.flags.karten_stufe.rindenbaer)
	world.apply_command("a", {type = "karte_verbessern", karte = "rindenbaer"})
	_check(int(p.progress.flags.karten_stufe.rindenbaer) == stufe and p.progress.flags.karten.rindenbaer == 1, "Ohne doppelte Karte kein Verbessern")
	p.progress.flags["karten"] = {windfalke = 30}
	p.progress.flags["karten_stufe"] = {windfalke = 10}
	world.apply_command("a", {type = "karte_verbessern", karte = "windfalke"})
	_check(p.progress.flags.karten.windfalke == 30, "+10 ist das Höchste")


func _process(_delta: float) -> bool:
	_frame += 1
	if _frame == 20:
		_town = current_scene
		var p: PlayerState = _town.local_player()
		p.progress.flags["karten"] = {feldschleim = 2, dornling = 1}
		p.progress.items["monsterkarte_sturmkobold"] = 1
		_town._toggle_panel("album")
		_check(_town._panel.visible and _town._panel_title.text == "Kartenalbum", "Album-Fenster öffnet sich")
	if _frame == 24:
		var reiter: Array = _town._album_tabs.get_children()
		_check(reiter.size() >= 2 and reiter[0].text == "Kreuzweg: 2 / 14", "Reiter mit Zähler (%s)" % (reiter[0].text if not reiter.is_empty() else "–"))
		_check(_town._album_grid.get_child_count() == 14, "Kreuzweg-Seite: 14 feste Plätze (seit A14 mit den Monstern der Kreuzwegfelder)")
		_town._album_karte = "feldschleim"
		_town._fill_panel()
	if _frame == 28:
		_check(_town._panel_text.get_parsed_text().contains("Element: Wasser"), "Angetippte Karte: Element steht da")
		_town._album_karte = "wiesenkobold"
		_town._fill_panel()
	if _frame == 32:
		_check(_town._panel_text.get_parsed_text().contains("noch nicht"), "Fehlende Karte: kein Element, nur Hinweis")
		_town._album_seite = 1
		_town._fill_panel()
	if _frame == 36:
		_check(_town._album_grid.get_child_count() == KartenAlbum.seiten()[1].karten.size(), "Grünwacht-Seite blättern")
		# Aktivieren in der Tasche: Aufdeck-Moment und Karte im Album
		_town._panel_text.meta_clicked.emit("aktivieren:monsterkarte_sturmkobold")
	if _frame == 40:
		var p: PlayerState = _town.local_player()
		_check(int(p.progress.flags.karten.get("sturmkobold", 0)) == 1, "In der Tasche aktiviert: im Album")
		_town._toggle_panel("werte")
		_check(_town._panel_text.get_parsed_text().contains("Karten im Album: +2 Leben"), "Werte (C) zeigt, was die Karten bringen")
		print("Kartenalbum: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
		quit(_failed)
	return false
