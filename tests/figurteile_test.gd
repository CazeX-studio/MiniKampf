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
			if FigurTeile.bild("kofi", anim, i) == null:
				print("FEHLER: kein Bild mit neuem Kopf für %s_f%d" % [anim, i])
				fehler += 1
			i += 1
	FigurTeile.art = FigurTeile.Art.GANZ
	if FigurTeile.bild("kofi", "idle", 0) != null:
		print("FEHLER: bei „ganz“ darf nichts zusammengesetzt werden")
		fehler += 1
	print("figurteile_test: %s" % ("OK" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
