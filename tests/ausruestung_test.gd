extends SceneTree
## Projekt 14, K.1: Werte für Waffen und Rüstung. Grundausrüstung ändert nichts, bessere Teile machen stärker,
## schwere Waffen kommen später dran, Verteidigung und Widerstand senken den Schaden, Vergleich mit Pfeilen.

var _fehler := 0


func _check(ok: bool, text: String) -> void:
	if not ok:
		print("FEHLER: " + text)
		_fehler += 1


func _init() -> void:
	# Jeder startet mit der Grundausrüstung, auch alte Spielstände
	var neu := Progress.new()
	_check(neu.ausruestung == Ausruestung.START, "Neuer Spielstand ohne Grundausrüstung")
	var alt := Progress.new()
	alt.load_dict({gold = 5})
	_check(alt.ausruestung == Ausruestung.START, "Alter Spielstand bekommt keine Grundausrüstung")
	# Alle Teile haben gültige Werte; Bonus-Werte passen zur Seltenheit
	for id: String in GameData.get_file("gegenstaende"):
		var t := Ausruestung.teil(id)
		if t.is_empty():
			continue
		var stufe := Ausruestung.SELTENHEITEN.find(str(t.get("seltenheit", "")))
		_check(stufe >= 0, "%s: unbekannte Seltenheit" % id)
		_check((t.get("boni", {}) as Dictionary).size() == stufe, "%s: %d Bonus-Werte, bei dieser Seltenheit gehören %d dazu" % [id, (t.get("boni", {}) as Dictionary).size(), stufe])
		_check(stufe < 2 or t.has("sonderwert"), "%s: ab Selten fehlt der Sonderwert" % id)
		_check(str(t.get("platz", "")) in ["waffe", "kopf", "koerper", "schuhe", "schmuck"], "%s: unbekannter Platz" % id)
		_check(str(t.platz) != "schmuck" or not (t.has("waffenkraft") or t.has("verteidigung") or t.has("widerstand")), "%s: Schmuck gibt nur Bonus-Werte" % id)
		_check(not t.has("tempo") or Ausruestung.TEMPO_WERT.has(str(t.tempo)), "%s: unbekanntes Waffen-Tempo" % id)
	# Grundausrüstung: alles wie vor der Ausrüstung
	var grund := Ausruestung.kampfwerte(Ausruestung.START)
	_check(is_equal_approx(grund.macht, 1.0) and is_equal_approx(grund.schutz, 1.0) and is_equal_approx(grund.magieschutz, 1.0)
			and grund.tempo == 0, "Grundausrüstung verändert den Kampf: %s" % grund)
	# Etwa ein Drittel der Kraft aus der Ausrüstung
	var s := Ausruestung.summe(Ausruestung.START)
	var anteil: float = float(s.waffenkraft) / (Grundwerte.BASE_ATTACK + s.waffenkraft)
	_check(anteil > 0.25 and anteil < 0.4, "Anteil der Ausrüstung am Angriff: %.2f" % anteil)
	# Schweres Breitschwert: stärker, aber langsamer
	var mit_breit := Ausruestung.START.duplicate()
	mit_breit.waffe = "breitschwert"
	var breit := Ausruestung.kampfwerte(mit_breit)
	_check(breit.macht > 1.0 and breit.tempo < 0 and breit.leben == 5, "Breitschwert wirkt falsch: %s" % breit)
	var vergleich := Ausruestung.vergleich("breitschwert", Ausruestung.START)
	_check("▲ Waffenkraft +4" in vergleich and "▼ Tempo -2" in vergleich and "6dff8a" in vergleich and "ff7070" in vergleich,
			"Vergleich zeigt die Pfeile nicht: %s" % vergleich)
	# Platte und Stoff
	var mit_kette := Ausruestung.START.duplicate()
	mit_kette.koerper = "kettenhemd"
	var kette := Ausruestung.kampfwerte(mit_kette)
	var mit_robe := Ausruestung.START.duplicate()
	mit_robe.koerper = "wollrobe"
	var robe := Ausruestung.kampfwerte(mit_robe)
	_check(kette.schutz < 1.0 and kette.magieschutz > 1.0, "Kettenhemd: mehr Verteidigung, weniger Widerstand")
	_check(robe.schutz > 1.0 and robe.magieschutz < 1.0, "Wollrobe: weniger Verteidigung, mehr Widerstand")
	# Anlegen und Ablegen in der Welt
	var state := WorldState.new()
	var p := state.add_player("a", "Test", "elf_m", WorldState.start_cell())
	p.progress.add_item("breitschwert", 1)
	p.progress.add_item("glueckskette", 2)
	state.apply_command("a", {type = "anlegen", gegenstand = "breitschwert"})
	_check(p.progress.ausruestung.waffe == "breitschwert" and p.progress.item_count("breitschwert") == 0
			and p.progress.item_count("kurzschwert") == 1, "Anlegen: Breitschwert auf den Platz, Kurzschwert in die Tasche")
	state.apply_command("a", {type = "anlegen", gegenstand = "glueckskette"})
	state.apply_command("a", {type = "anlegen", gegenstand = "glueckskette"})
	_check(p.progress.ausruestung.get("schmuck1", "") == "glueckskette" and p.progress.ausruestung.get("schmuck2", "") == "glueckskette",
			"Zwei Schmuckplätze")
	state.apply_command("a", {type = "ablegen", platz = "waffe"})
	_check(not p.progress.ausruestung.has("waffe") and p.progress.item_count("breitschwert") == 1, "Ablegen: zurück in die Tasche")
	var gespeichert := Progress.new()
	gespeichert.load_dict(p.progress.to_dict())
	_check(gespeichert.ausruestung == p.progress.ausruestung, "Ausrüstung wird nicht gespeichert")
	# Im Kampf: schwere Waffe = weniger Tempo (später dran), mehr Kraft; Verteidigung senkt Schaden
	var leicht := _held(Ausruestung.START)
	var schwer := _held(mit_breit)
	_check(schwer.tempo < leicht.tempo and schwer.turn_delay() > leicht.turn_delay(), "Schwere Waffe kommt nicht später dran")
	_check(schwer.power > leicht.power and schwer.max_hp == leicht.max_hp + 5, "Breitschwert macht im Kampf nicht stärker")
	var gepanzert := _held(mit_kette)
	_check(gepanzert.schutz < 1.0 and gepanzert.magieschutz > 1.0, "Kettenhemd wirkt im Kampf nicht")
	var kampf := BattleState.new(null, [] as Array[String], "", 1)
	var gegner := Fighter.new("Testgegner", "test", "Erde", false, 100, 10, Color.WHITE)
	var ohne_schutz := 0
	var mit_schutz := 0
	for i in 20:
		ohne_schutz += kampf.calc_damage(gegner, leicht, 20.0, "melee")
		mit_schutz += kampf.calc_damage(gegner, gepanzert, 20.0, "melee")
	_check(mit_schutz < ohne_schutz, "Verteidigung senkt den Schaden nicht (%d gegen %d)" % [mit_schutz, ohne_schutz])
	print("ausruestung_test: %s" % ("OK" if _fehler == 0 else "%d Fehler" % _fehler))
	quit(1 if _fehler > 0 else 0)


## Ein Novize der Stufe 1 mit dieser Ausrüstung, so wie ihn der Kampf aufbaut.
func _held(angelegt: Dictionary) -> Fighter:
	var kampf := BattleState.new(null, [] as Array[String], "", 1)
	kampf.setup = {helden = [{klasse = "novize", name = "Du", stufe = 1, ausruestung = Ausruestung.kampfwerte(angelegt)}], wellen = []}
	kampf._create_heroes()
	return kampf.heroes[0]
