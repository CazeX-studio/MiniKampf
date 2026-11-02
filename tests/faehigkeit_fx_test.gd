extends SceneTree
## D9b, D9c: Jede eigene Bewegung läuft im echten Kampfbild durch und lässt die Figuren an ihrem Platz zurück.

const NAMEN := ["schildstoss_anlauf", "schildstoss_treffer", "hieb", "erste_hilfe", "deckung", "deckung_funke",
		"sternenmut_an", "sternenmut_schlag", "schnellschuss", "spannen", "ladeschuss", "durchschlag", "durchschlag_weiter",
		"hagel_auf", "hagel_regen", "netzpfeil", "schnellfeuer", "schnellfeuer_ende", "schwachstelle", "elementpfeil", "jaegerpfeil"]


func _initialize() -> void:
	var fehler := 0
	BattleRequest.kampf_id = ""
	BattleRequest.setup = {}
	Sandbox.team = ["archer", "tank"] as Array[String]
	var kampf: Control = load("res://scenes/kampf.tscn").instantiate()
	root.add_child(kampf)
	await create_timer(1.0).timeout
	var state: BattleState = kampf.state
	var f: Fighter = state.heroes[0]
	var ziel: Fighter = state.alive(state.enemies)[0]
	var v: FighterView = kampf.view(f)
	var v_ziel: FighterView = kampf.view(ziel)
	var ort := v.position
	var ort_ziel := v_ziel.position
	var feld_kinder: int = kampf._field.get_child_count()
	for name: String in NAMEN:
		await FaehigkeitFx.spielen(kampf, name, f, ziel, 1)
		await create_timer(0.8).timeout
		if v.position != ort or v_ziel.position != ort_ziel:
			print("FEHLER: %s lässt eine Figur verschoben zurück" % name)
			fehler += 1
		# Der Kampf läuft nebenher weiter, ein Treffer darf die Figur gerade bewegen
		var warten := 0
		while v.body.position != v._home and warten < 30:
			await create_timer(0.1).timeout
			warten += 1
		if v.body.position != v._home:
			print("FEHLER: %s: Körper nicht zurück" % name)
			fehler += 1
	# Ohne Ziel und ohne Grafik darf nichts passieren
	await FaehigkeitFx.spielen(kampf, "hieb", f, null, 0)
	await create_timer(1.2).timeout
	if kampf._field.get_child_count() > feld_kinder + 2:
		print("FEHLER: Effekte bleiben liegen: ", kampf._field.get_child_count() - feld_kinder)
		fehler += 1
	print("Fähigkeiten-Effekte geprüft, Fehler: ", fehler)
	quit(1 if fehler > 0 else 0)
