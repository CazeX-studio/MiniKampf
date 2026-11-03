extends SceneTree
## Projekt 11: Kofi aus Kopf und Körper zusammensetzen. „Aus Teilen“ muss genauso aussehen wie das ganze Bild.


func _init() -> void:
	var fehler := 0
	if not FigurTeile.hat_teile("kofi"):
		print("FEHLER: Kofi hat keine Teile")
		quit(1)
		return
	for anim: String in ["idle", "run", "attack", "death", "idle_vorn", "run_hinten"]:
		var i := 0
		while ResourceLoader.exists(FighterView.sprite_path("kofi", anim, i)):
			var ganz: Image = (load(FighterView.sprite_path("kofi", anim, i)) as Texture2D).get_image()
			ganz.decompress()
			ganz.clear_mipmaps()
			ganz.convert(Image.FORMAT_RGBA8)
			FigurTeile.art = FigurTeile.Art.TEILE
			var teile := FigurTeile.bild("kofi", anim, i).get_image()
			teile.clear_mipmaps()
			var abweichung := 0
			for y in ganz.get_height():
				for x in ganz.get_width():
					var a := ganz.get_pixel(x, y)
					var b := teile.get_pixel(x, y)
					if absf(a.a - b.a) > 0.1 or (a.a > 0.5 and absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) > 0.15):
						abweichung += 1
			if abweichung > 0:
				print("FEHLER: kofi %s_f%d weicht an %d Punkten ab" % [anim, i, abweichung])
				fehler += 1
			FigurTeile.art = FigurTeile.Art.KOPFBLATT
			for kopf: String in FigurTeile.koepfe("kofi"):
				FigurTeile.kopf = kopf
				if FigurTeile.bild("kofi", anim, i) == null:
					print("FEHLER: kein Bild mit Kopf %s für %s_f%d" % [kopf, anim, i])
					fehler += 1
			FigurTeile.kopf = ""
			i += 1
	if FigurTeile.koepfe("kofi").size() < 2:
		print("FEHLER: Kofi sollte mindestens zwei Köpfe haben")
		fehler += 1
	# Novizen-Körper (grüner Platzhalter): immer zusammengesetzt, mit jedem Kopf, ohne grüne Reste
	FigurTeile.art = FigurTeile.Art.GANZ
	for koerper: String in ["novize_m", "novize_w", "bogen_m", "bogen_w", "zaehmer_m", "zaehmer_w"]:
		if not FigurTeile.koerper_liste().has(koerper):
			print("FEHLER: Körper %s fehlt" % koerper)
			fehler += 1
		fehler += _koerper_pruefen(koerper)
	FigurTeile.kopf = ""
	if FigurTeile.bild("kofi", "idle", 0) != null:
		print("FEHLER: bei „ganz“ darf nichts zusammengesetzt werden")
		fehler += 1
	fehler += _klassen_koerper()
	fehler += _klassen_waffen()
	print("figurteile_test: %s" % ("OK" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)


func _koerper_pruefen(koerper: String) -> int:
	var fehler := 0
	for kopf: String in FigurTeile.koepfe(koerper):
		FigurTeile.kopf = kopf
		for anim: String in ["idle", "run", "hit", "parry", "attack", "death", "victory", "cast", "idle_vorn", "run_vorn", "idle_hinten", "run_hinten"]:
			if not ResourceLoader.exists(FighterView.sprite_path(koerper, anim, 0)):
				continue
			var t := FigurTeile.bild(koerper, anim, 0)
			if t == null:
				print("FEHLER: %s %s ohne Bild (Kopf %s)" % [koerper, anim, kopf])
				fehler += 1
				continue
			var im := t.get_image()
			var gruen := 0
			for y in im.get_height():
				for x in im.get_width():
					var c := im.get_pixel(x, y)
					if c.a > 0.5 and c.g > c.r + 0.3 and c.g > c.b + 0.3:
						gruen += 1
			if gruen > 3:
				print("FEHLER: %s %s hat %d grüne Punkte (Kopf %s)" % [koerper, anim, gruen, kopf])
				fehler += 1
	return fehler


## D18: Wer die Klasse gelernt hat, trägt ihren Körper (Bogenschütze, Zähmer), der Kopf und das Aussehen bleiben.
func _klassen_koerper() -> int:
	var fehler := 0
	var faelle := [["novize_m+m1", "archer", "bogen_m+m1"], ["novize_w+w1#hut=geweihband", "tamer", "zaehmer_w+w1#hut=geweihband"],
			["bogen_m+m1", "", "novize_m+m1"], ["novize_m+m1", "blade", "novize_m+m1"], ["kofi", "archer", "kofi"],
			["zaehmer_w+w2", "archer", "bogen_w+w2"]]
	for fall: Array in faelle:
		var ergebnis := FigurTeile.mit_klasse(fall[0], fall[1])
		if ergebnis != fall[2]:
			print("FEHLER: %s als %s wird %s statt %s" % [fall[0], fall[1], ergebnis, fall[2]])
			fehler += 1
	# Im Kampf: die eigene Figur in Klassenkleidung, in der Probestunde einer Klasse ohne Körper wie bisher
	BattleRequest.player_look = "novize_w+w1"
	BattleRequest.prepare("wild:0", 12, 0, "archer")
	if BattleRequest.setup.helden[0].aussehen != "bogen_w+w1":
		print("FEHLER: Bogenschützin kämpft nicht in ihrer Kleidung: %s" % BattleRequest.setup.helden[0].aussehen)
		fehler += 1
	BattleRequest.prepare("probe:blade", 8, 0, "novize")
	if BattleRequest.setup.helden[0].aussehen != "":
		print("FEHLER: Probestunde Klingentänzerin sollte ihre eigene Figur zeigen")
		fehler += 1
	BattleRequest.player_look = ""
	BattleRequest.kampf_id = ""
	# In der Welt: nach dem Lernen der Klasse wechselt der Körper
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "novize_m+m2", Vector2i(6, 15))
	p.progress.flags["klasse"] = "archer"
	p.progress.flags["klasse_bestaetigt"] = true
	world.tick(1.1)
	if p.look != "novize_m+m2":
		print("FEHLER: vor dem Lernen schon Klassenkleidung")
		fehler += 1
	p.progress.flags["klasse_gelernt"] = true
	world.tick(1.1)
	if p.look != "bogen_m+m2":
		print("FEHLER: nach dem Lernen kein Bogenschützen-Körper: %s" % p.look)
		fehler += 1
	return fehler


## D18b: Bogen und Schleuder an der Hand, beim Schuss der gespannte Bogen; im Aussehen nicht wählbar.
func _klassen_waffen() -> int:
	var fehler := 0
	var daten: Dictionary = FigurTeile._alle()
	for koerper: String in ["bogen_m", "bogen_w", "zaehmer_m", "zaehmer_w"]:
		var waffe := "langbogen" if koerper.begins_with("bogen") else "schleuder"
		if FigurTeile._waffe_von(koerper + "+m1#waffe=krummklinge", "krummklinge") != waffe:
			print("FEHLER: %s trägt nicht immer %s" % [koerper, waffe])
			fehler += 1
		for bild: String in ["idle_f0", "run_f1", "attack_f2", "idle_vorn_f0"]:
			if not daten[koerper].get(bild, {}).has("griff"):
				print("FEHLER: %s %s hat keinen Handpunkt" % [koerper, bild])
				fehler += 1
		if daten[koerper].get("death_f5", {}).has("griff"):
			print("FEHLER: %s hält beim Fallen noch die Waffe" % koerper)
			fehler += 1
	if daten.bogen_m.attack_f2.get("waffe_bild", "") != "langbogen_gespannt" or daten.bogen_w.cast_f0.get("waffe_bild", "") != "langbogen_gespannt":
		print("FEHLER: beim Schuss kein gespannter Bogen")
		fehler += 1
	if FigurTeile.waffe_auswahl().has("langbogen") or FigurTeile.waffe_auswahl().has("schleuder") or not FigurTeile.waffe_auswahl().has("krummklinge"):
		print("FEHLER: Klassenwaffen dürfen im Aussehen nicht wählbar sein")
		fehler += 1
	if FigurTeile.bild("bogen_m+m1", "attack", 2) == null:
		print("FEHLER: Bogenschütze mit gespanntem Bogen lässt sich nicht zeichnen")
		fehler += 1
	return fehler
