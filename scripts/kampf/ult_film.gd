class_name UltFilm
extends Control
## Filmische Ult (K.6): Bild dunkelt ab, Kamera rückt an die Figur, Name und Bild der Figur blenden ein, 3 bis 4 Sekunden.
## Beim ersten Mal immer ganz, danach in den Einstellungen auf kurz stellbar (Musik.ult_kurz, Knopf im Menü).
## Die Figur selbst bleibt sichtbar, der Hintergrund jeder Klasse kommt aus BILD.

const LANG := 3.4
const KURZ := 1.0
const ZOOM := 1.28
## P15b (Marco 16.11.): mehr Wucht, Licht und Kamera. Linien wie im Anime ziehen zur Figur, ein Lichthof wächst hinter
## ihr, am Ende ein heller Blitz und ein kurzes Beben, wenn die Ult losgeht.
const LINIEN := 34
const BEBEN := 9.0
const STREIFEN := 74.0
## Der untere Streifen deckt auch die Bedienleiste ab, dort stehen Bild und Name.
const STREIFEN_UNTEN := 195.0
## Klasse -> Farbe und Motiv des Hintergrunds (nach den Steckbriefen)
const BILD := {
	"novize": {farbe = Color("c9a6ff"), motiv = "strahl"},
	"archer": {farbe = Color("cfe6ff"), motiv = "mond"},
	"tamer": {farbe = Color("8fdc7a"), motiv = "ringe"},
	"smith": {farbe = Color("ff9a3c"), motiv = "esse"},
	"blade": {farbe = Color("ff6a3c"), motiv = "feuer"},
	"singer": {farbe = Color("9fc8ff"), motiv = "himmel"},
}
const STANDARD := {farbe = Color("f2c14e"), motiv = "strahl"}

var _bild: Dictionary = STANDARD
var _zentrum := Vector2.ZERO
var _zeit := 0.0
var _dauer := LANG
var _sterne: Array[Vector2] = []


## Spielt den Film ab. Fertig, wenn das Bild wieder hell ist.
static func abspielen(kampf: Control, feld: Control, ansicht: FighterView, klasse: String, titel: String) -> void:
	var dauer := Musik.ult_dauer(klasse, LANG, KURZ)
	var film := UltFilm.new()
	film._bild = BILD.get(klasse, STANDARD)
	film._dauer = dauer
	film._zentrum = ansicht.center()
	film.size = kampf.size
	film.mouse_filter = Control.MOUSE_FILTER_IGNORE
	film.z_index = 18
	feld.add_child(film)
	var alte_ebene := ansicht.z_index
	ansicht.z_index = 19
	var oben := film._schrift(kampf, ansicht, titel)
	feld.pivot_offset = ansicht.center()
	var ein := minf(0.45, dauer * 0.25)
	var feld_pos := feld.position
	var figur_mass := ansicht.scale
	var tween := film.create_tween().set_parallel()
	# Kamera: schnell heran, federt leicht nach (mehr Wucht als ein weiches Heranfahren)
	tween.tween_property(feld, "scale", Vector2.ONE * ZOOM, ein).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(film, "_zeit", dauer, dauer)
	# Die Figur holt Luft: wird kurz größer und sammelt Kraft
	if dauer > KURZ:
		tween.tween_property(ansicht, "scale", figur_mass * 1.12, dauer * 0.45).set_delay(ein).set_trans(Tween.TRANS_SINE)
		tween.tween_property(ansicht, "scale", figur_mass, 0.12).set_delay(dauer - ein - 0.12)
	tween.tween_property(feld, "scale", Vector2.ONE, ein).set_delay(dauer - ein).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	await tween.finished
	feld.scale = Vector2.ONE
	ansicht.scale = figur_mass
	ansicht.z_index = alte_ebene
	oben.queue_free()
	# Die Ult geht los: heller Blitz in der Farbe der Klasse und ein kurzes Beben
	var blitz := film._blitz(kampf, film._bild.farbe)
	await film._beben(feld, feld_pos)
	if blitz.is_running():
		await blitz.finished
	film.queue_free()


## Heller Blitz über allem, der schnell verblasst.
func _blitz(kampf: Control, farbe: Color) -> Tween:
	var blitz := ColorRect.new()
	blitz.color = Color(farbe.lightened(0.6), 0.75)
	blitz.size = kampf.size
	blitz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	blitz.z_index = 24
	kampf.add_child(blitz)
	var t := blitz.create_tween()
	t.tween_property(blitz, "color:a", 0.0, 0.25).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.tween_callback(func() -> void:
		kampf.remove_child(blitz)
		blitz.queue_free())
	return t


## Kurzes Beben des Kampffelds, danach genau wieder an seinem Platz.
func _beben(feld: Control, ruhe: Vector2) -> void:
	var zufall := RandomNumberGenerator.new()
	zufall.seed = 3
	var t := create_tween()
	for i in 6:
		var staerke := BEBEN * (1.0 - i / 6.0)
		t.tween_property(feld, "position", ruhe + Vector2(zufall.randf_range(-1, 1), zufall.randf_range(-1, 1)) * staerke, 0.04)
	t.tween_property(feld, "position", ruhe, 0.04)
	await t.finished
	feld.position = ruhe


func _ready() -> void:
	var zufall := RandomNumberGenerator.new()
	zufall.seed = 7
	for i in 60:
		_sterne.append(Vector2(zufall.randf_range(0, size.x), zufall.randf_range(0, size.y * 0.7)))


func _process(_delta: float) -> void:
	queue_redraw()


## 0 bis 1: Wie stark ist der Film gerade da (ein- und ausblenden)?
func _deckung() -> float:
	var rand := minf(0.4, _dauer * 0.25)
	return clampf(minf(_zeit, _dauer - _zeit) / rand, 0.0, 1.0)


func _draw() -> void:
	var deckung := _deckung()
	var farbe: Color = _bild.farbe
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.02, 0.05, 0.8 * deckung))
	var fortschritt := _zeit / _dauer
	_lichthof(farbe, deckung, fortschritt)
	_linien(farbe, deckung)
	match str(_bild.motiv):
		"strahl":
			_strahl(farbe, deckung)
		"mond":
			draw_circle(Vector2(size.x * 0.72, 150), 90, Color(farbe, 0.5 * deckung))
			draw_circle(Vector2(size.x * 0.72, 150), 74, Color(1, 1, 1, 0.6 * deckung))
			_kreise(farbe, deckung, fortschritt)
		"ringe":
			_kreise(farbe, deckung, fortschritt)
		"esse":
			_glut(farbe, deckung, fortschritt, 1.0)
		"feuer":
			_glut(farbe, deckung, fortschritt, 2.2)
		"himmel":
			for i in range(0, _sterne.size(), 6):
				draw_line(_sterne[i], _sterne[(i + 13) % _sterne.size()], Color(farbe, 0.25 * deckung * fortschritt), 2.0)
	for stern in _sterne:
		if str(_bild.motiv) in ["strahl", "mond", "himmel"]:
			var funkeln := 0.5 + 0.5 * sin(_zeit * 4.0 + stern.x)
			draw_rect(Rect2(stern, Vector2(3, 3)), Color(1, 1, 1, 0.7 * funkeln * deckung))


## Lichthof hinter der Figur: wächst mit dem Film und wird zum Ende hin heller.
func _lichthof(farbe: Color, deckung: float, fortschritt: float) -> void:
	var gross := 90.0 + 200.0 * ease(fortschritt, 0.6)
	for i in 6:
		var anteil := 1.0 - i / 6.0
		draw_circle(_zentrum, gross * anteil, Color(farbe.lightened(0.2 * i), (0.07 + 0.05 * fortschritt) * deckung))
	draw_circle(_zentrum, 34.0 + 18.0 * fortschritt, Color(1, 1, 1, 0.18 * deckung))


## Linien wie im Anime: ziehen von den Rändern schnell zur Figur hin (zeigt die Kraft, die sie sammelt).
func _linien(farbe: Color, deckung: float) -> void:
	var weit := size.length()
	for i in LINIEN:
		var winkel := TAU * i / LINIEN + sin(i * 12.9) * 0.08
		var richtung := Vector2.from_angle(winkel)
		var lauf := fposmod(_zeit * 1.8 + i * 0.37, 1.0)
		var aussen := weit * (0.55 - 0.35 * lauf)
		var innen := aussen - 90.0 - 80.0 * fposmod(i * 0.61, 1.0)
		if innen < 110.0:
			continue
		var c := Color(farbe.lightened(0.6), 0.6 * deckung * (1.0 - lauf * 0.4))
		draw_line(_zentrum + richtung * innen, _zentrum + richtung * aussen, c, 2.5 + fposmod(i * 0.29, 1.0) * 3.0)


func _strahl(farbe: Color, deckung: float) -> void:
	var breit := 70.0
	draw_colored_polygon(PackedVector2Array([Vector2(_zentrum.x - breit * 0.4, 0), Vector2(_zentrum.x + breit * 0.4, 0),
			Vector2(_zentrum.x + breit, _zentrum.y + 120), Vector2(_zentrum.x - breit, _zentrum.y + 120)]), Color(farbe, 0.4 * deckung))


func _kreise(farbe: Color, deckung: float, fortschritt: float) -> void:
	for i in 3:
		var groesse := fmod(fortschritt * 2.0 + i / 3.0, 1.0)
		draw_arc(_zentrum, 60.0 + 260.0 * groesse, 0.0, TAU, 48, Color(farbe, (1.0 - groesse) * 0.7 * deckung), 4.0)


func _glut(farbe: Color, deckung: float, fortschritt: float, tempo: float) -> void:
	var boden := size.y - STREIFEN_UNTEN
	draw_rect(Rect2(0, boden - 90, size.x, 90), Color(farbe, 0.28 * deckung))
	for i in 40:
		var x := fposmod(_sterne[i % _sterne.size()].x + i * 37.0, size.x)
		var y := boden - fposmod(fortschritt * 900.0 * tempo + i * 53.0, 420.0)
		draw_rect(Rect2(x + sin(y * 0.03) * 12.0, y, 4, 4), Color(farbe.lightened(0.3), deckung))


## Name der Ult und Bild der Figur, über allem und ohne Kamerafahrt. Beide gleiten von den Seiten herein.
func _schrift(kampf: Control, ansicht: FighterView, titel: String) -> Control:
	var ebene := Control.new()
	ebene.size = kampf.size
	ebene.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ebene.z_index = 23
	kampf.add_child(ebene)
	# Breite Streifen oben und unten wie im Kino
	var oben := ColorRect.new()
	oben.color = Color.BLACK
	oben.size = Vector2(kampf.size.x, STREIFEN)
	oben.position.y = -STREIFEN
	ebene.add_child(oben)
	var unten := oben.duplicate() as ColorRect
	unten.size.y = STREIFEN_UNTEN
	unten.position.y = kampf.size.y
	ebene.add_child(unten)
	var figur := TextureRect.new()
	figur.texture = ansicht.ult_bild()
	figur.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	figur.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	figur.texture_filter = FighterView.filter_fuer(figur.texture)
	figur.size = Vector2(220, 240)
	figur.position = Vector2(-260, kampf.size.y - 300)
	ebene.add_child(figur)
	var name_schrift := Label.new()
	name_schrift.text = titel
	name_schrift.add_theme_font_size_override("font_size", 46)
	name_schrift.add_theme_color_override("font_color", (_bild.farbe as Color).lightened(0.35))
	name_schrift.add_theme_color_override("font_outline_color", Color.BLACK)
	name_schrift.add_theme_constant_override("outline_size", 8)
	name_schrift.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	name_schrift.size = Vector2(kampf.size.x - 280, 60)
	name_schrift.position = Vector2(kampf.size.x, kampf.size.y - 130)
	ebene.add_child(name_schrift)
	var rein := minf(0.4, _dauer * 0.25)
	var tween := ebene.create_tween().set_parallel()
	tween.tween_property(oben, "position:y", 0.0, rein)
	tween.tween_property(unten, "position:y", kampf.size.y - STREIFEN_UNTEN, rein)
	tween.tween_property(figur, "position:x", 30.0, rein).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(name_schrift, "position:x", 240.0, rein).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(ebene, "modulate:a", 0.0, rein).set_delay(_dauer - rein)
	return ebene
