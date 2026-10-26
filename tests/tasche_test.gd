extends SceneTree
## Test für die Tasche mit Kästchen: neue Gegenstände ins erste freie Kästchen, Verschieben,
## leere Gegenstände verschwinden, und die Reihenfolge übersteht Speichern und Laden.
## Aufruf: Godot --headless --path . --script res://tests/tasche_test.gd


func _initialize() -> void:
	var failed := 0
	var p := Progress.new()
	p.add_item("heiltrank", 3)
	p.add_item("kraut", 2)
	failed += _check("30 Kästchen", p.bag_slots().size(), Progress.BAG_SIZE)
	failed += _check("Trank im ersten Kästchen", p.bag_slots()[0], "heiltrank")
	failed += _check("Kraut im zweiten Kästchen", p.bag_slots()[1], "kraut")
	p.move_slot(0, 7)
	failed += _check("Trank verschoben", p.bag_slots()[7], "heiltrank")
	failed += _check("altes Kästchen leer", p.bag_slots()[0], "")
	p.move_slot(1, 7)
	failed += _check("Tausch: Kraut jetzt in 7", p.bag_slots()[7], "kraut")
	failed += _check("Tausch: Trank jetzt in 1", p.bag_slots()[1], "heiltrank")
	p.add_item("buerste", 1)
	failed += _check("Neues ins erste freie Kästchen", p.bag_slots()[0], "buerste")
	p.add_item("kraut", 1)
	failed += _check("Mehr vom Gleichen bleibt im Kästchen", p.bag_slots()[7], "kraut")
	p.add_item("kraut", -3)
	failed += _check("Aufgebraucht = Kästchen leer", p.bag_slots()[7], "")
	# Speichern und Laden (auch über das Netz geht der Spielstand als Dictionary)
	var copy := Progress.new()
	copy.load_dict(JSON.parse_string(JSON.stringify(p.to_dict())))
	failed += _check("Reihenfolge gespeichert", copy.bag_slots().slice(0, 3), ["buerste", "heiltrank", ""])
	# Alter Spielstand ohne Kästchen: Gegenstände werden einfach der Reihe nach eingeräumt
	var old := Progress.new()
	old.load_dict({items = {heiltrank = 2, kraut = 1}})
	failed += _check("Alter Spielstand", old.bag_slots().slice(0, 2).size(), 2)
	failed += _check("Alter Spielstand ohne Lücke", old.bag_slots().count(""), Progress.BAG_SIZE - 2)
	# Gegenstände direkt gesetzt (wie in manchen Tests): trotzdem in der Tasche
	var direct := Progress.new()
	direct.items = {heiltrank = 3}
	failed += _check("Direkt gesetzt", direct.bag_slots()[0], "heiltrank")
	print("Tasche: %s" % ("alles richtig" if failed == 0 else "%d Fehler" % failed))
	quit(failed)


func _check(what: String, got: Variant, want: Variant) -> int:
	if got == want:
		return 0
	print("FEHLER: %s – bekommen %s, erwartet %s" % [what, got, want])
	return 1
