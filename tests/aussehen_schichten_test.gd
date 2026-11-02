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
					FigurTeile.hut = ""
					FigurTeile.ruecken = ""
					var ohne := FigurTeile.bild(figur, anim, i)
					FigurTeile.hut = "wanderhut"
					FigurTeile.ruecken = "reiseumhang"
					var mit := FigurTeile.bild(figur, anim, i)
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
	FigurTeile.hut = ""
	FigurTeile.ruecken = ""
	print("aussehen_schichten_test: %s" % ("OK" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
