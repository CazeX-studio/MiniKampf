class_name UltFilm
extends Control
## Filmische Ult (K.6): Bild dunkelt ab, Kamera rückt an die Figur, Name und Bild der Figur blenden ein, 3 bis 4 Sekunden.
## Beim ersten Mal immer ganz, danach in den Einstellungen auf kurz stellbar (Musik.ult_kurz, Knopf im Menü).
## Die Figur selbst bleibt sichtbar, der Hintergrund jeder Klasse kommt aus BILD.

const LANG := 3.4
const KURZ := 1.0
const ZOOM := 1.16
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
	var tween := film.create_tween().set_parallel()
	tween.tween_property(feld, "scale", Vector2.ONE * ZOOM, ein).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(film, "_zeit", dauer, dauer)
	tween.tween_property(feld, "scale", Vector2.ONE, ein).set_delay(dauer - ein).set_trans(Tween.TRANS_SINE)
	await tween.finished
	feld.scale = Vector2.ONE
	ansicht.z_index = alte_ebene
	oben.queue_free()
	film.queue_free()


## Film beim Wechsel eines Endbosses in Phase 2 (A9b, Alpha-Punkt 38): Das Bild bebt und dunkelt ab, Kino-Streifen,
## die Kamera rückt an den neuen Gegner, sein Bild gleitet herein mit Name und einer Zeile darunter.
## Beim ersten Mal ganz, danach wie die Ult in den Einstellungen auf kurz stellbar.
static func phase_abspielen(kampf: Control, feld: Control, ansicht: FighterView, farbe: Color, motiv: String,
		titel: String, zeile: String) -> void:
	var dauer := Musik.ult_dauer("phase_" + ansicht.fighter.klass, LANG + 0.6, KURZ + 0.4)
	var film := UltFilm.new()
	film._bild = {farbe = farbe, motiv = motiv}
	film._dauer = dauer
	film._zentrum = ansicht.center()
	film.size = kampf.size
	film.mouse_filter = Control.MOUSE_FILTER_IGNORE
	film.z_index = 18
	feld.add_child(film)
	var alte_ebene := ansicht.z_index
	ansicht.z_index = 19
	var oben := film._schrift(kampf, ansicht, titel)
	if zeile != "":
		var unter := Label.new()
		unter.text = zeile
		unter.add_theme_font_size_override("font_size", 22)
		unter.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
		unter.add_theme_color_override("font_outline_color", Color.BLACK)
		unter.add_theme_constant_override("outline_size", 6)
		unter.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		unter.size = Vector2(kampf.size.x - 280, 30)
		unter.position = Vector2(240, kampf.size.y - 72)
		unter.modulate.a = 0.0
		oben.add_child(unter)
		oben.create_tween().tween_property(unter, "modulate:a", 1.0, minf(0.5, dauer * 0.2)).set_delay(minf(0.4, dauer * 0.25))
	# Der neue Gegner wächst aus dem Nichts heran (das Beben macht der Kampf)
	var gross := ansicht.scale
	ansicht.scale = gross * 0.6
	feld.pivot_offset = ansicht.center()
	var ein := minf(0.45, dauer * 0.25)
	var tween := film.create_tween().set_parallel()
	tween.tween_property(feld, "scale", Vector2.ONE * ZOOM, ein).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(ansicht, "scale", gross, dauer * 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(film, "_zeit", dauer, dauer)
	tween.tween_property(feld, "scale", Vector2.ONE, ein).set_delay(dauer - ein).set_trans(Tween.TRANS_SINE)
	await tween.finished
	feld.scale = Vector2.ONE
	ansicht.scale = gross
	ansicht.z_index = alte_ebene
	oben.queue_free()
	film.queue_free()


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
