extends SceneTree
## Schneidet die UI-Teile aus den beiden Asterfall-UI-Bögen (tools/vorlagen/ui/), entfernt den
## Magenta-Hintergrund und verkleinert sie auf Spielgröße. Ergebnis: assets/ui/*.png.
## Aufruf: Godot --headless --path . --script res://tools/ui_zuschneiden.gd

const QUELLE := "res://tools/vorlagen/ui/%s.png"
const ZIEL := "res://assets/ui/%s.png"
const RAND_DUNKEL := Color(0.04, 0.05, 0.08, 0.0)

## Name: [Bogen, Rechteck im Bogen, Verkleinerung]
const TEILE := {
	# Zweiter Bogen: schlichte Rahmen, Knöpfe in vier Zuständen, Symbole ohne Kästchen.
	fenster = ["asterfall_ui_extras", Rect2i(67, 462, 913, 460), 1.0 / 3.0],
	fenster_klein = ["asterfall_ui_extras", Rect2i(1039, 482, 430, 403), 1.0 / 3.0],
	knopf = ["asterfall_ui_extras", Rect2i(75, 279, 306, 107), 1.0 / 3.0],
	knopf_hover = ["asterfall_ui_extras", Rect2i(437, 279, 304, 108), 1.0 / 3.0],
	knopf_gedrueckt = ["asterfall_ui_extras", Rect2i(797, 279, 306, 108), 1.0 / 3.0],
	knopf_aus = ["asterfall_ui_extras", Rect2i(1158, 279, 305, 108), 1.0 / 3.0],
	# Erster Bogen: Pergament, Felder, Balken, Reiter, Häkchen, Meldungen, Schmuck.
	pergament = ["asterfall_ui_kit", Rect2i(1125, 37, 397, 339), 0.5],
	feld = ["asterfall_ui_kit", Rect2i(708, 418, 121, 123), 0.5],
	feld_aktiv = ["asterfall_ui_kit", Rect2i(842, 418, 123, 123), 0.5],
	balken = ["asterfall_ui_kit", Rect2i(990, 419, 263, 43), 0.5],
	fuellung_rot = ["asterfall_ui_kit", Rect2i(1279, 419, 221, 30), 0.5],
	fuellung_blau = ["asterfall_ui_kit", Rect2i(1279, 464, 221, 30), 0.5],
	fuellung_gruen = ["asterfall_ui_kit", Rect2i(1279, 510, 222, 30), 0.5],
	knopf_rot = ["asterfall_ui_kit", Rect2i(359, 466, 148, 74), 0.5],
	knopf_gold = ["asterfall_ui_kit", Rect2i(194, 466, 149, 74), 0.5],
	reiter_aktiv = ["asterfall_ui_kit", Rect2i(25, 568, 254, 80), 0.5],
	reiter = ["asterfall_ui_kit", Rect2i(295, 568, 254, 79), 0.5],
	regler_griff = ["asterfall_ui_kit", Rect2i(1050, 575, 42, 57), 0.5],
	kaestchen = ["asterfall_ui_kit", Rect2i(1182, 578, 61, 59), 0.5],
	kaestchen_an = ["asterfall_ui_kit", Rect2i(1262, 578, 61, 59), 0.5],
	meldung_gruen = ["asterfall_ui_kit", Rect2i(586, 657, 319, 104), 0.5],
	meldung_gold = ["asterfall_ui_kit", Rect2i(586, 766, 318, 102), 0.5],
	meldung_lila = ["asterfall_ui_kit", Rect2i(586, 874, 319, 104), 0.5],
	banner = ["asterfall_ui_kit", Rect2i(21, 682, 135, 233), 0.5],
	ranke_gross = ["asterfall_ui_kit", Rect2i(164, 682, 185, 229), 0.5],
}

## Symbole: alle mittig in ein gleich großes Feld (120 x 120 im Bogen, 40 x 40 im Spiel).
const SYMBOLE := {
	gold = Rect2i(62, 99, 96, 97),
	kristall = Rect2i(182, 93, 80, 112),
	trank = Rect2i(285, 93, 83, 112),
	schwert = Rect2i(399, 94, 105, 111),
	schild = Rect2i(539, 93, 95, 112),
	wirbel = Rect2i(672, 98, 100, 101),
	tasche = Rect2i(801, 99, 116, 104),
	schluessel = Rect2i(932, 98, 94, 107),
	zahnrad = Rect2i(1052, 93, 109, 112),
	ausrufe = Rect2i(1199, 88, 45, 117),
	frage = Rect2i(1283, 88, 78, 117),
	pfeil = Rect2i(1385, 100, 94, 93),
}
const SYMBOL_FELD := 120
const SYMBOL_GROESSE := 40

var _boegen := {}


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/ui"))
	for name: String in TEILE:
		var teil: Array = TEILE[name]
		var bild := _ausschneiden(teil[0], teil[1])
		_speichern(name, bild, teil[2])
	for name: String in SYMBOLE:
		var stueck := _ausschneiden("asterfall_ui_extras", SYMBOLE[name])
		var feld := Image.create_empty(SYMBOL_FELD, SYMBOL_FELD, false, Image.FORMAT_RGBA8)
		feld.fill(RAND_DUNKEL)
		var pos := (Vector2i(SYMBOL_FELD, SYMBOL_FELD) - stueck.get_size()) / 2
		feld.blit_rect(stueck, Rect2i(Vector2i.ZERO, stueck.get_size()), pos)
		_speichern("symbol_" + name, feld, float(SYMBOL_GROESSE) / SYMBOL_FELD)
	quit()


func _bogen(name: String) -> Image:
	if not _boegen.has(name):
		var img := Image.load_from_file(ProjectSettings.globalize_path(QUELLE % name))
		img.convert(Image.FORMAT_RGBA8)
		_boegen[name] = img
	return _boegen[name]


## Ist das (fast) der Magenta-Hintergrund? Der Bogen ist nicht ganz reines Magenta.
func _ist_hintergrund(c: Color) -> bool:
	return c.r > 0.75 and c.b > 0.75 and c.g < 0.3


## Wie stark ist ein Randpixel mit Magenta vermischt (0 = gar nicht, 1 = ganz)?
func _magenta_anteil(c: Color) -> float:
	return clampf((minf(c.r, c.b) - c.g) * 1.4 - 0.15, 0.0, 1.0)


func _ausschneiden(bogen: String, rect: Rect2i) -> Image:
	var quelle := _bogen(bogen)
	var bild := quelle.get_region(rect.grow(2).intersection(Rect2i(Vector2i.ZERO, quelle.get_size())))
	var w := bild.get_width()
	var h := bild.get_height()
	var hintergrund := PackedByteArray()
	hintergrund.resize(w * h)
	for y in h:
		for x in w:
			if _ist_hintergrund(bild.get_pixel(x, y)):
				hintergrund[y * w + x] = 1
				bild.set_pixel(x, y, RAND_DUNKEL)
	# Randpixel neben dem Hintergrund: Magenta-Schimmer herausrechnen statt rosa Saum.
	for y in h:
		for x in w:
			if hintergrund[y * w + x] or not _am_rand(hintergrund, w, h, x, y):
				continue
			var c := bild.get_pixel(x, y)
			var anteil := _magenta_anteil(c)
			if anteil <= 0.0:
				continue
			var rest := Color(
				(c.r - anteil * 0.98) / maxf(1.0 - anteil, 0.05),
				(c.g - anteil * 0.01) / maxf(1.0 - anteil, 0.05),
				(c.b - anteil * 0.99) / maxf(1.0 - anteil, 0.05),
				1.0 - anteil
			).clamp()
			bild.set_pixel(x, y, rest)
	return bild


func _am_rand(maske: PackedByteArray, w: int, h: int, x: int, y: int) -> bool:
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			var nx := x + dx
			var ny := y + dy
			if nx >= 0 and ny >= 0 and nx < w and ny < h and maske[ny * w + nx]:
				return true
	return false


func _speichern(name: String, bild: Image, faktor: float) -> void:
	var groesse := Vector2i((Vector2(bild.get_size()) * faktor).round())
	bild.premultiply_alpha()
	bild.resize(groesse.x, groesse.y, Image.INTERPOLATE_LANCZOS)
	_entmultiplizieren(bild)
	bild.save_png(ProjectSettings.globalize_path(ZIEL % name))
	print("%s: %s" % [name, groesse])


func _entmultiplizieren(bild: Image) -> void:
	for y in bild.get_height():
		for x in bild.get_width():
			var c := bild.get_pixel(x, y)
			if c.a > 0.004:
				bild.set_pixel(x, y, Color(c.r / c.a, c.g / c.a, c.b / c.a, c.a).clamp())
			else:
				bild.set_pixel(x, y, RAND_DUNKEL)
