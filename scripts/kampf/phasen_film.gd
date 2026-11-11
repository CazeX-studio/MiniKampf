class_name PhasenFilm
extends Control
## Kurzer Film, wenn ein Boss in Phase 2 geht (A9b, Alpha-Punkt 38): Kinostreifen, das Feld dunkelt ab, der Boss bebt
## und glüht auf, dann bricht etwas (beim Kettenschmied reißen die drei Ketten, die Glieder fliegen davon), das Bild
## wackelt und der Name der neuen Phase erscheint groß in der Mitte. Rund 3,6 Sekunden, kommt in jedem Kampf nur einmal.
## Motive: "ketten" (Kettenschmied). Weitere Bosse bekommen ihr eigenes Motiv (A9b2, A9b3).

const DAUER := 3.6
## Ab hier bricht es (Sekunden)
const BRUCH := 1.5
const STREIFEN := 74.0
const STREIFEN_UNTEN := 195.0
const GLIED := 22.0
const SCHWERKRAFT := 900.0

var _motiv := "ketten"
var _farbe := Color("ff8a3d")
var _zentrum := Vector2.ZERO
var _zeit := 0.0
var _gebrochen := false
## Ketten: Anfang an der Wand, Ende am Boss
var _ketten: Array[Array] = []
## Fliegende Glieder nach dem Bruch: {pos, vel, dreh, drehung}
var _glieder: Array[Dictionary] = []
var _ansicht: FighterView
var _ansicht_pos := Vector2.ZERO
var _kampf: Control


## Spielt den Film ab; fertig, wenn das Bild wieder hell ist.
static func abspielen(kampf: Control, feld: Control, ansicht: FighterView, motiv: String, titel: String, untertitel: String,
		farbe: Color) -> void:
	var film := PhasenFilm.new()
	film._motiv = motiv
	film._farbe = farbe
	film._kampf = kampf
	film._ansicht = ansicht
	film._zentrum = ansicht.center() if ansicht != null else kampf.size * 0.5
	film.size = kampf.size
	film.mouse_filter = Control.MOUSE_FILTER_IGNORE
	film.z_index = 18
	feld.add_child(film)
	var alte_ebene := 0
	if ansicht != null:
		alte_ebene = ansicht.z_index
		ansicht.z_index = 19
		film._ansicht_pos = ansicht.position
	var schrift := film._schrift(kampf, titel, untertitel)
	Geraeusche.play("zauber", 0.6)
	var tween := film.create_tween()
	tween.tween_property(film, "_zeit", DAUER, DAUER)
	await tween.finished
	if ansicht != null and is_instance_valid(ansicht):
		ansicht.z_index = alte_ebene
		ansicht.position = film._ansicht_pos
	schrift.queue_free()
	film.queue_free()


func _ready() -> void:
	# Drei Ketten zu den Ankern hinter dem Boss: Wand links, Decke, Decke weiter rechts
	_ketten = [[Vector2(-20, _zentrum.y - 60), _zentrum], [Vector2(_zentrum.x - 30, -20), _zentrum],
			[Vector2(_zentrum.x + 320, -20), _zentrum]]


func _process(delta: float) -> void:
	if not _gebrochen and _zeit >= BRUCH:
		_brechen()
	for g in _glieder:
		g.vel.y += SCHWERKRAFT * delta
		g.pos += g.vel * delta
		g.drehung += g.dreh * delta
	# Der Boss bebt immer stärker, bis es bricht
	if _ansicht != null and is_instance_valid(_ansicht):
		var beben := clampf(_zeit / BRUCH, 0.0, 1.0) * 5.0 if _zeit < BRUCH else 0.0
		_ansicht.position = _ansicht_pos + Vector2(randf_range(-beben, beben), randf_range(-beben, beben) * 0.5)
	queue_redraw()


func _brechen() -> void:
	_gebrochen = true
	Geraeusche.play("kritisch", 0.7)
	if _kampf.has_method("_shake"):
		_kampf.call("_shake", 18.0)
	if _ansicht != null and is_instance_valid(_ansicht):
		_ansicht.glow(_farbe.lightened(0.3), 1.4)
	var feld := get_parent() as Control
	Fx.spawn(feld, Fx.Kind.GLOW, _zentrum, _farbe, 420.0, 0.9)
	Fx.spawn(feld, Fx.Kind.RING, _zentrum, _farbe.lightened(0.4), 520.0, 0.8)
	Fx.spawn(feld, Fx.Kind.SPARKS, _zentrum, _farbe.lightened(0.3), 160.0, 0.9)
	match _motiv:
		"ketten":
			# Jedes Glied fliegt vom Riss weg nach außen
			for kette in _ketten:
				var von: Vector2 = kette[0]
				var bis: Vector2 = kette[1]
				var anzahl := int(von.distance_to(bis) / GLIED)
				for i in anzahl:
					var pos := von.lerp(bis, float(i) / anzahl)
					var weg := (pos - _zentrum).normalized()
					_glieder.append({pos = pos, vel = weg * randf_range(180.0, 520.0) + Vector2(0, randf_range(-380.0, -120.0)),
							dreh = randf_range(-9.0, 9.0), drehung = (bis - von).angle()})


## 0 bis 1: wie stark der Film gerade da ist (ein- und ausblenden)
func _deckung() -> float:
	return clampf(minf(_zeit, DAUER - _zeit) / 0.4, 0.0, 1.0)


func _draw() -> void:
	var deckung := _deckung()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.03, 0.01, 0.0, 0.72 * deckung))
	var boden := size.y - STREIFEN_UNTEN
	# Greller Blitz beim Bruch (eigener, damit die Schrift darüber klar bleibt)
	var blitz := clampf(1.0 - (_zeit - BRUCH) / 0.35, 0.0, 1.0) if _gebrochen else 0.0
	if blitz > 0.0:
		draw_rect(Rect2(Vector2.ZERO, size), Color(_farbe.lightened(0.6), 0.45 * blitz))
	if _gebrochen:
		# Glut steigt vom Boden auf
		var hoehe := clampf((_zeit - BRUCH) / 0.8, 0.0, 1.0) * 120.0
		draw_rect(Rect2(0, boden - hoehe, size.x, hoehe), Color(_farbe, 0.35 * deckung))
		draw_rect(Rect2(0, boden - hoehe, size.x, 6), Color(_farbe.lightened(0.4), 0.8 * deckung))
	match _motiv:
		"ketten":
			if not _gebrochen:
				# Die Ketten glühen von dunklem Eisen zu heller Glut auf
				var glut := clampf(_zeit / BRUCH, 0.0, 1.0)
				var farbe := Color("3a3330").lerp(_farbe.lightened(0.2), glut)
				for kette in _ketten:
					_kette(kette[0], kette[1], farbe, glut)
			for g in _glieder:
				_glied(g.pos, g.drehung, Color(_farbe.lightened(0.2), deckung))


func _kette(von: Vector2, bis: Vector2, farbe: Color, glut: float) -> void:
	var anzahl := int(von.distance_to(bis) / GLIED)
	var winkel := (bis - von).angle()
	# Die Kette spannt sich und zittert kurz vor dem Bruch
	var zittern := glut * glut * 3.0
	for i in anzahl:
		var pos := von.lerp(bis, float(i) / anzahl) + Vector2(randf_range(-zittern, zittern), randf_range(-zittern, zittern))
		_glied(pos, winkel + (PI * 0.5 if i % 2 == 1 else 0.0), farbe)
	if glut > 0.3:
		draw_line(von, bis, Color(_farbe, 0.25 * glut), 10.0)


func _glied(pos: Vector2, winkel: float, farbe: Color) -> void:
	draw_set_transform(pos, winkel)
	draw_rect(Rect2(-GLIED * 0.55, -6, GLIED * 1.1, 12), farbe, false, 4.0)
	draw_set_transform(Vector2.ZERO, 0.0)


## Kinostreifen oben und unten, Titel und Untertitel in der Mitte (über allem, ohne Wackeln)
func _schrift(kampf: Control, titel: String, untertitel: String) -> Control:
	var ebene := Control.new()
	ebene.size = kampf.size
	ebene.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ebene.z_index = 23
	kampf.add_child(ebene)
	var oben := ColorRect.new()
	oben.color = Color.BLACK
	oben.size = Vector2(kampf.size.x, STREIFEN)
	oben.position.y = -STREIFEN
	ebene.add_child(oben)
	var unten := oben.duplicate() as ColorRect
	unten.size.y = STREIFEN_UNTEN
	unten.position.y = kampf.size.y
	ebene.add_child(unten)
	var gross := _label(titel, 72, _farbe.lightened(0.35))
	gross.size = Vector2(kampf.size.x, 100)
	gross.position = Vector2(0, kampf.size.y * 0.3)
	gross.pivot_offset = gross.size * 0.5
	gross.modulate.a = 0.0
	gross.scale = Vector2.ONE * 1.5
	ebene.add_child(gross)
	var klein := _label(untertitel, 30, Color("f4e6d0"))
	klein.size = Vector2(kampf.size.x, 44)
	klein.position = Vector2(0, kampf.size.y * 0.3 + 96)
	klein.modulate.a = 0.0
	ebene.add_child(klein)
	var tween := ebene.create_tween().set_parallel()
	tween.tween_property(oben, "position:y", 0.0, 0.4)
	tween.tween_property(unten, "position:y", kampf.size.y - STREIFEN_UNTEN, 0.4)
	tween.tween_property(gross, "modulate:a", 1.0, 0.25).set_delay(BRUCH + 0.05)
	tween.tween_property(gross, "scale", Vector2.ONE, 0.35).set_delay(BRUCH + 0.05).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(klein, "modulate:a", 1.0, 0.4).set_delay(BRUCH + 0.4)
	tween.tween_property(ebene, "modulate:a", 0.0, 0.4).set_delay(DAUER - 0.4)
	return ebene


func _label(text: String, groesse: int, farbe: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", groesse)
	label.add_theme_color_override("font_color", farbe)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 10)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label
