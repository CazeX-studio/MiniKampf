extends SceneTree
## Prüft den Gürtel (Projekt 5, Schritt 1): vier Plätze, Stapel bis 5, nur Tränke, zurück in die Tasche,
## Tränke im Kampf zählen mit und werden zuerst vom Gürtel genommen, Speichern.
## Aufruf: Godot --headless --path . --script res://tests/guertel_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	var world := WorldState.new()
	var p := world.add_player("spieler", "Du", "vega", WorldState.start_cell())
	p.progress.items = {heiltrank = 12, kraut = 3}
	world.apply_command("spieler", {type = "guertel_ablegen", gegenstand = "kraut"})
	_check(p.progress.belt_count("kraut") == 0, "Kräuter dürfen nicht an den Gürtel")
	world.apply_command("spieler", {type = "guertel_ablegen", gegenstand = "heiltrank"})
	_check(p.progress.belt[0] == {id = "heiltrank", anzahl = 5} and p.progress.item_count("heiltrank") == 7, "Erster Platz: 5 Heiltränke, 7 bleiben in der Tasche")
	world.apply_command("spieler", {type = "guertel_ablegen", gegenstand = "heiltrank"})
	world.apply_command("spieler", {type = "guertel_ablegen", gegenstand = "heiltrank"})
	_check(p.progress.belt_count("heiltrank") == 12 and p.progress.item_count("heiltrank") == 0 and p.progress.belt[2].anzahl == 2,
			"Drei Plätze belegt (5, 5, 2), Tasche leer")
	_check(p.progress.potion_count("heiltrank") == 12, "Im Kampf zählen die Tränke am Gürtel mit")
	p.progress.items["heiltrank"] = 1
	world.apply_command("spieler", {type = "guertel_ablegen", gegenstand = "heiltrank"})
	_check(p.progress.belt[2].anzahl == 3, "Angefangener Platz wird aufgefüllt")
	# Kampf: 4 Tränke verbraucht, zuerst vom Gürtel
	p.progress.items["heiltrank"] = 2
	world.apply_command("spieler", {type = "kampf_ergebnis", kampf = "gruppenkampf", gewonnen = false, traenke_benutzt = 4})
	_check(p.progress.belt_count("heiltrank") == 9 and p.progress.item_count("heiltrank") == 2, "Verbrauchte Tränke kommen zuerst vom Gürtel")
	world.apply_command("spieler", {type = "guertel_nehmen", platz = 1})
	_check(p.progress.belt[1].is_empty() and p.progress.item_count("heiltrank") == 7, "Gürtelplatz zurück in die Tasche")
	var saved := Progress.new()
	saved.load_dict(p.progress.to_dict())
	_check(saved.belt_count("heiltrank") == p.progress.belt_count("heiltrank") and saved.belt.size() == Progress.BELT_SLOTS, "Gürtel wird gespeichert")
	print("Gürtel: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
