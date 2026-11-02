extends SceneTree
## D9a: Filmische Ult. Beim ersten Mal immer ganz, danach auf kurz stellbar; nach dem Film ist das Kampffeld wie vorher.


func _initialize() -> void:
	var fehler := 0
	Musik.ist_ult_kurz()
	var alt_kurz := Musik.ult_kurz
	var alt_gesehen: Array = Musik._ult_gesehen.duplicate()
	Musik._ult_gesehen = []
	Musik.ult_kurz = true
	if Musik.ult_dauer("archer", UltFilm.LANG, UltFilm.KURZ) != UltFilm.LANG:
		print("FEHLER: Beim ersten Mal muss die Ult ganz laufen")
		fehler += 1
	if Musik.ult_dauer("archer", UltFilm.LANG, UltFilm.KURZ) != UltFilm.KURZ:
		print("FEHLER: Beim zweiten Mal muss die Ult kurz sein")
		fehler += 1
	Musik.ult_kurz = false
	if Musik.ult_dauer("archer", UltFilm.LANG, UltFilm.KURZ) != UltFilm.LANG:
		print("FEHLER: Ohne die Einstellung bleibt die Ult lang")
		fehler += 1
	Musik.ult_kurz = true

	var kampf := Control.new()
	kampf.size = Vector2(1280, 720)
	root.add_child(kampf)
	var feld := Control.new()
	kampf.add_child(feld)
	var figur := Fighter.new("Probe", "archer", "Bogenschütze", true, 100, 10, Color.WHITE)
	var ansicht := FighterView.new()
	ansicht.setup(figur)
	feld.add_child(ansicht)
	var kinder := feld.get_child_count()
	var ebenen := kampf.get_child_count()
	var start := Time.get_ticks_msec()
	await UltFilm.abspielen(kampf, feld, ansicht, "archer", "Jägerpfeil")
	var dauer := (Time.get_ticks_msec() - start) / 1000.0
	await process_frame
	await process_frame
	if absf(dauer - UltFilm.KURZ) > 0.3:
		print("FEHLER: Film dauerte %.2f Sekunden" % dauer)
		fehler += 1
	if feld.scale != Vector2.ONE or ansicht.z_index != 0:
		print("FEHLER: Kampffeld ist nach dem Film verändert")
		fehler += 1
	if feld.get_child_count() != kinder or kampf.get_child_count() != ebenen:
		print("FEHLER: Film ist nicht aufgeräumt")
		fehler += 1

	Musik._ult_gesehen = alt_gesehen
	Musik.ult_kurz = alt_kurz
	Musik._save_settings()
	print("Ult-Film geprüft, Fehler: ", fehler)
	quit(1 if fehler > 0 else 0)
