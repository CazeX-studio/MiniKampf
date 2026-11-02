extends SceneTree
## Projekt 13, Schritt 4: Hut und Rückenteil als Schichten. In allen Richtungen und Bewegungen der Novizen-Körper
## muss ein Bild entstehen, der Hut darf nicht abgeschnitten sein, und ohne Schichten bleibt alles wie vorher.
## Mit Umgebungsvariable FOTO_ORDNER werden die Bilder dort als PNG gespeichert (zum Anschauen).

const ANIMS := ["idle", "run", "attack", "hit", "parry", "victory", "cast", "death",
		"idle_vorn", "run_vorn", "idle_hinten", "run_hinten"]


func _init() -> void:
	var fehler := 0
	var ordner := OS.get_environment("FOTO_ORDNER")
	if not FigurTeile.hut_liste().has("wanderhut") or not FigurTeile.ruecken_liste().has("reiseumhang"):
		print("FEHLER: Wanderhut oder Reiseumhang fehlt in data/aussehen_teile.json")
		quit(1)
		return
	for koerper: String in ["novize_m", "novize_w"]:
		for kopf: String in FigurTeile.passende_koepfe(koerper):
			for anim: String in ANIMS:
				var i := 0
				while ResourceLoader.exists(FighterView.sprite_path(koerper, anim, i)):
					var figur := "%s+%s" % [koerper, kopf]
					var ohne := FigurTeile.bild(figur, anim, i)
					var mit := FigurTeile.bild(FigurTeile.mit_aussehen(figur, {hut = "wanderhut", ruecken = "reiseumhang"}), anim, i)
					if ohne == null or mit == null:
						print("FEHLER: kein Bild für %s %s_f%d" % [figur, anim, i])
						fehler += 1
						i += 1
						continue
					var bild := mit.get_image()
					bild.clear_mipmaps()
					# Nichts darf am Rand anstoßen (sonst ist es abgeschnitten); unten stehen die Füße
					var sichtbar := bild.get_used_rect()
					if sichtbar.position.x <= 0 or sichtbar.position.y <= 0 or sichtbar.end.x >= bild.get_width():
						print("FEHLER: %s %s_f%d ist abgeschnitten (%s in %s)" % [figur, anim, i, sichtbar, bild.get_size()])
						fehler += 1
					# Die Füße bleiben unten in der Mitte: Breite und Höhe wachsen gleichmäßig
					var unterschied := mit.get_size() - ohne.get_size()
					if int(unterschied.x) != 2 * FigurTeile.RAND_SCHICHT or int(unterschied.y) != FigurTeile.RAND_SCHICHT:
						print("FEHLER: %s %s_f%d hat die falsche Größe" % [figur, anim, i])
						fehler += 1
					if ordner != "" and kopf == FigurTeile.passende_koepfe(koerper)[0]:
						bild.save_png("%s/%s_%s_f%d.png" % [ordner, koerper, anim, i])
					i += 1
	fehler += _umfaerben_pruefen(ordner)
	fehler += _plaetze_pruefen()
	fehler += _waffe_pruefen(ordner)
	print("aussehen_schichten_test: %s" % ("OK" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)


## Projekt 13, Schritt 5: Umfärben. Der Umhang wechselt die Farbe, der Novizen-Körper bleibt, wie er ist.
func _umfaerben_pruefen(ordner: String) -> int:
	var fehler := 0
	if not FigurTeile.paletten_liste().has("glutschmiede"):
		print("FEHLER: Palette „glutschmiede“ fehlt in data/farbpaletten.json")
		return 1
	var figur := "novize_m+m1"
	# Ohne Hut und Umhang: Umfärben darf am Novizen nichts ändern
	var grund := FigurTeile.bild(figur, "idle", 0).get_image()
	var gefaerbt := FigurTeile.bild(FigurTeile.mit_aussehen(figur, {farben = "glutschmiede"}), "idle", 0).get_image()
	if grund.get_data() != gefaerbt.get_data():
		print("FEHLER: Der Novizen-Körper wurde umgefärbt")
		fehler += 1
	# Mit Umhang: Die festen Töne des Umhangs werden zu den Tönen der Palette
	var umhang := (load("res://assets/teile/ruecken/reiseumhang_hinten_f0.png") as Texture2D).get_image()
	umhang.convert(Image.FORMAT_RGBA8)
	var daten: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/aussehen_teile.json"))
	var neu := FigurTeile.umfaerben(umhang, daten.ruecken.reiseumhang.flaechen, "glutschmiede")
	var sichtbar := 0
	var geaendert := 0
	for y in neu.get_height():
		for x in neu.get_width():
			if umhang.get_pixel(x, y).a > 0.9:
				sichtbar += 1
				if not umhang.get_pixel(x, y).is_equal_approx(neu.get_pixel(x, y)):
					geaendert += 1
	if sichtbar == 0 or geaendert * 2 < sichtbar:
		print("FEHLER: Umhang nicht sauber umgefärbt (%d von %d Punkten)" % [geaendert, sichtbar])
		fehler += 1
	for palette: String in [""] + FigurTeile.paletten_liste().keys():
		var look := FigurTeile.mit_aussehen(figur, {hut = "wanderhut", ruecken = "reiseumhang", farben = palette})
		for anim: String in ["idle", "idle_hinten"]:
			var bild := FigurTeile.bild(look, anim, 0)
			if bild == null:
				print("FEHLER: kein Bild mit Palette %s" % palette)
				fehler += 1
			elif ordner != "":
				bild.get_image().save_png("%s/farben_%s_%s.png" % [ordner, palette if palette != "" else "grund", anim])
	return fehler


## Projekt 13, Schritt 6: Aussehen-Plätze. Wählen über den Befehl „aussehen“, Werte bleiben, Spielstand merkt es sich.
func _plaetze_pruefen() -> int:
	var fehler := 0
	var look := FigurTeile.mit_aussehen("novize_w+w1", {hut = "wanderhut", farben = "glutschmiede", ruecken = "gibtesnicht"})
	if look != "novize_w+w1#hut=wanderhut,farben=glutschmiede":
		print("FEHLER: Aussehen falsch gespeichert: %s" % look)
		fehler += 1
	if FigurTeile.koerper_von(look) != "novize_w" or FigurTeile.aussehen_von(look).hut != "wanderhut":
		print("FEHLER: Aussehen wird falsch gelesen")
		fehler += 1
	if FigurTeile.mit_aussehen(look, {}) != "novize_w+w1":
		print("FEHLER: Ohne Teile muss der Name ohne „#“ bleiben")
		fehler += 1
	if FighterView.einzelbild(look, "idle", 0) == null or FighterView.portrait(look) == null:
		print("FEHLER: Figur mit Aussehen hat kein Bild")
		fehler += 1
	# Befehl in der Welt
	var state := WorldState.new()
	var p := state.add_player("test", "Test", "novize_w+w1", WorldState.start_cell())
	var werte_vorher := JSON.stringify(p.progress.to_dict())
	state.apply_command("test", {type = "aussehen", hut = "wanderhut"})
	state.apply_command("test", {type = "aussehen", ruecken = "reiseumhang", farben = "waldlaeufer"})
	var a := FigurTeile.aussehen_von(p.look)
	if a.hut != "wanderhut" or a.ruecken != "reiseumhang" or a.farben != "waldlaeufer":
		print("FEHLER: Befehl „aussehen“ wirkt nicht: %s" % p.look)
		fehler += 1
	if JSON.stringify(p.progress.to_dict()) != werte_vorher:
		print("FEHLER: Aussehen hat die Werte verändert")
		fehler += 1
	state.apply_command("test", {type = "aussehen", hut = ""})
	if FigurTeile.aussehen_von(p.look).hut != "" or FigurTeile.aussehen_von(p.look).ruecken != "reiseumhang":
		print("FEHLER: Hut ablegen geht nicht: %s" % p.look)
		fehler += 1
	# Figuren ohne Körper und Kopf (z. B. Vega) bekommen kein Aussehen
	var vega := state.add_player("vega", "Vega", "vega", WorldState.start_cell())
	state.apply_command("vega", {type = "aussehen", hut = "wanderhut"})
	if vega.look != "vega":
		print("FEHLER: Vega darf keinen Hut bekommen")
		fehler += 1
	return fehler


## Projekt 13, Schritt 3: Waffe als eigenes Teil. Das Schwert sitzt in jedem Bild mit Griff, nichts wird abgeschnitten.
func _waffe_pruefen(ordner: String) -> int:
	var fehler := 0
	for koerper: String in ["novize_m", "novize_w"]:
		var daten: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FigurTeile.DATEN))[koerper]
		var figur := "%s+%s" % [koerper, FigurTeile.passende_koepfe(koerper)[0]]
		for anim: String in ANIMS:
			var i := 0
			while ResourceLoader.exists(FighterView.sprite_path(koerper, anim, i)):
				var info: Dictionary = daten.get("%s_f%d" % [anim, i], {})
				var mit := FigurTeile.bild(figur, anim, i).get_image()
				mit.clear_mipmaps()
				if anim == "attack" and i == 3 and not info.has("griff"):
					print("FEHLER: %s hat im Treffer-Bild kein Schwert" % koerper)
					fehler += 1
				if anim == "cast" and info.has("griff"):
					print("FEHLER: %s hält beim Wirken ein Schwert" % koerper)
					fehler += 1
				var sichtbar := mit.get_used_rect()
				if sichtbar.position.x <= 0 or sichtbar.position.y <= 0 or sichtbar.end.x >= mit.get_width():
					print("FEHLER: %s %s_f%d: Schwert abgeschnitten (%s in %s)" % [koerper, anim, i, sichtbar, mit.get_size()])
					fehler += 1
				if ordner != "":
					mit.save_png("%s/waffe_%s_%s_f%d.png" % [ordner, koerper, anim, i])
				i += 1
	# Waffen-Aussehen: wählbar, anderes Bild, die Werte bleiben unberührt
	var figur := "novize_m+m1"
	var eigen := FigurTeile.bild(figur, "attack", 3).get_image()
	var krumm := FigurTeile.bild(FigurTeile.mit_aussehen(figur, {waffe = "krummklinge"}), "attack", 3).get_image()
	if eigen.get_data() == krumm.get_data():
		print("FEHLER: Das Waffen-Aussehen ändert das Bild nicht")
		fehler += 1
	var state := WorldState.new()
	var p := state.add_player("test2", "Test", "novize_w+w1", WorldState.start_cell())
	var werte_vorher := JSON.stringify(p.progress.to_dict())
	state.apply_command("test2", {type = "aussehen", waffe = "krummklinge"})
	if FigurTeile.aussehen_von(p.look).waffe != "krummklinge" or JSON.stringify(p.progress.to_dict()) != werte_vorher:
		print("FEHLER: Befehl „aussehen“ wirkt nicht auf die Waffe: %s" % p.look)
		fehler += 1
	return fehler
