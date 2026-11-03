extends SceneTree
## D15: Kartenalbum (Projekt 8, Schritt 1–3). Seiten je Region mit festen Plätzen und Zähler, verdeckte Karten in der
## Tasche (bei voller Tasche im Beute-Fenster), Aktivieren, Element und Schwäche, dazu das Fenster in Kreuzweg.
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
		_check(reiter.size() >= 2 and reiter[0].text == "Kreuzweg: 2 / 7", "Reiter mit Zähler (%s)" % (reiter[0].text if not reiter.is_empty() else "–"))
		_check(_town._album_grid.get_child_count() == 7, "Kreuzweg-Seite: 7 feste Plätze")
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
		print("Kartenalbum: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
		quit(_failed)
	return false
