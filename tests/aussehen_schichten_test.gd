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
	# Mit Umhang: Die Töne des Umhangs werden zu den Tönen der Palette
	var umhang := (load("res://assets/teile/ruecken/reiseumhang_hinten.png") as Texture2D).get_image()
	umhang.convert(Image.FORMAT_RGBA8)
	var flaechen: Dictionary = {"hauptfarbe": ["#a03e34", "#802c28", "#602020", "#441618"]}
	var neu := FigurTeile.umfaerben(umhang, flaechen, "glutschmiede")
	var ziel := Color.html("#b02a1c")
	var quelle := Color.html("#802c28")
	var alt_gefunden := 0
	var neu_gefunden := 0
	for y in neu.get_height():
		for x in neu.get_width():
			if umhang.get_pixel(x, y).is_equal_approx(quelle):
				alt_gefunden += 1
				if neu.get_pixel(x, y).is_equal_approx(ziel):
					neu_gefunden += 1
	if alt_gefunden == 0 or neu_gefunden != alt_gefunden:
		print("FEHLER: Umhang nicht sauber umgefärbt (%d von %d Punkten)" % [neu_gefunden, alt_gefunden])
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
