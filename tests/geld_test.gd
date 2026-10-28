extends SceneTree
## Prüft die Geld-Anzeige: eine Zahl (Bronze) wird als Bronze, Silber und Gold angezeigt.
## Aufruf: Godot --headless --path . --script res://tests/geld_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	_check(Geld.text(0) == "0 Bronze", "0 → 0 Bronze")
	_check(Geld.text(45) == "45 Bronze", "45 → 45 Bronze")
	_check(Geld.text(100) == "1 Silber", "100 → 1 Silber")
	_check(Geld.text(199) == "1 Silber 99 Bronze", "199 → 1 Silber 99 Bronze")
	_check(Geld.text(10000) == "1 Gold", "10000 → 1 Gold")
	_check(Geld.text(12345) == "1 Gold 23 Silber 45 Bronze", "12345 → 1 Gold 23 Silber 45 Bronze")
	_check(Geld.text(1000005) == "100 Gold 5 Bronze", "1000005 → 100 Gold 5 Bronze")
	_check(Geld.zerlegen(12345) == [1, 23, 45], "Zerlegen: [Gold, Silber, Bronze]")
	# Testknopf: Geld kommt dazu und die Münzen springen um
	var world := WorldState.new()
	var p := world.add_player("spieler", "Du", "vega", WorldState.start_cell())
	p.progress.gold = 9990
	world.apply_command("spieler", {type = "testgeld", betrag = 20})
	_check(p.progress.gold == 10010 and Geld.text(p.progress.gold) == "1 Gold 10 Bronze", "Testgeld: 9990 + 20 → 1 Gold 10 Bronze")
	print("Geld: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
