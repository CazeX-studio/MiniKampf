class_name PhasenFilm
extends Control
## Kurzer Film, wenn ein Boss in Phase 2 geht (A9b, Alpha-Punkt 38): Kinostreifen, das Feld dunkelt ab, der Boss bebt
## und glüht auf, dann bricht etwas (Glut bzw. Nebel steigt vom Boden) (beim Kettenschmied reißen die drei Ketten, die Glieder fliegen davon), das Bild
## wackelt und der Name der neuen Phase erscheint groß in der Mitte. Rund 3,6 Sekunden, kommt in jedem Kampf nur einmal.
## Motive: "ketten" (Kettenschmied: drei Ketten reißen), "leere" (Vorbote: ein Riss der Leere öffnet sich, schwarze
## Ranken greifen heraus), "sporen" (Sporenkönigin: Sporenwolken quellen auf und platzen), "amboss" (Hammerbrüder:
## zwei Hämmer schlagen zusammen auf den Amboss, Funken stieben).
## Ketten und Riss der Leere sind gemalt (Teil M: fx_kette_glied, fx_kette_reisst, fx_leere; A9c1 und A9c2).
## Sporen und Amboss zeichnet das Spiel selbst.

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
	film.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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
		g.vel.y += SCHWERKRAFT * float(g.get("schwer", 1.0)) * delta
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
		"sporen":
			# Die Wolken platzen: Sporen schweben langsam nach außen
			for i in 70:
				var weg := Vector2.from_angle(randf_range(0.0, TAU))
				_glieder.append({pos = _zentrum + weg * randf_range(10.0, 90.0), vel = weg * randf_range(60.0, 320.0) + Vector2(0, -60.0),
						dreh = 0.0, drehung = 0.0, schwer = 0.06, groesse = randf_range(3.0, 8.0)})
		"amboss":
			# Gemalte Hammerfunken (Teil E) und dazu Funken, die vom Amboss nach oben stieben und wieder fallen
			FxBild.spawn(feld, "hammer_funken", _amboss_ort() + Vector2(0, -20), 0.8, false, 0.0, 1.4).z_index = 20
			for i in 60:
				var weg := Vector2.from_angle(randf_range(PI * 1.1, PI * 1.9))
				_glieder.append({pos = _amboss_ort(), vel = weg * randf_range(200.0, 700.0), dreh = 0.0, drehung = 0.0, schwer = 1.0,
						groesse = randf_range(3.0, 6.0)})
		"ketten":
			# Jede Kette reißt an drei Stellen (gemalt), die Glieder fliegen vom Riss weg nach außen
			for kette in _ketten:
				for anteil: float in [0.3, 0.6, 0.85]:
					FxBild.spawn(feld, "kette_reisst", (kette[0] as Vector2).lerp(kette[1], anteil), 0.7, false, 0.0, 0.55).z_index = 20
			for kette in _ketten:
				var von: Vector2 = kette[0]
				var bis: Vector2 = kette[1]
				var anzahl := int(von.distance_to(bis) / (GLIED * 3.0))
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
		# (Leere: dunkler Nebel statt Glut)
		var boden_farbe := Color(0.06, 0.0, 0.12, 0.7) if _motiv == "leere" else Color(_farbe, 0.35)
		draw_rect(Rect2(0, boden - hoehe, size.x, hoehe), Color(boden_farbe, boden_farbe.a * deckung))
		draw_rect(Rect2(0, boden - hoehe, size.x, 6), Color(_farbe.lightened(0.4), 0.8 * deckung))
	match _motiv:
		"ketten":
			if not _gebrochen:
				# Die Ketten glühen von dunklem Eisen zu weißer Glut auf, spannen sich und zittern kurz vor dem Bruch
				var glut := clampf(_zeit / BRUCH, 0.0, 1.0)
				for kette in _ketten:
					if glut > 0.3:
						draw_line(kette[0], kette[1], Color(_farbe, 0.25 * glut), 14.0)
					KetteBild.zeichnen(self, kette[0], kette[1], mini(int(glut * 4.0), 3), 0.8, glut * glut * 3.0, deckung)
			for g in _glieder:
				_glied(g.pos, g.drehung, deckung)
		"leere":
			_leere(deckung)
		"sporen":
			if not _gebrochen:
				# Sporenwolken quellen rund um die Königin auf
				var auf := clampf(_zeit / BRUCH, 0.0, 1.0)
				for i in 7:
					var ort := _zentrum + Vector2.from_angle(TAU * i / 7.0 + _zeit * 0.6) * (40.0 + 50.0 * auf)
					draw_circle(ort, 20.0 + 45.0 * auf + 6.0 * sin(_zeit * 5.0 + i), Color(_farbe.darkened(0.3), 0.45 * deckung))
					draw_circle(ort, 8.0 + 20.0 * auf, Color(_farbe, 0.5 * deckung))
			for g in _glieder:
				draw_circle(g.pos, g.groesse, Color(_farbe.lightened(0.2), 0.8 * deckung))
		"amboss":
			_amboss(deckung)
			for g in _glieder:
				draw_rect(Rect2(g.pos, Vector2.ONE * g.groesse), Color(_farbe.lightened(0.4), deckung))


func _amboss_ort() -> Vector2:
	# Vor den Brüdern, zur Mitte des Feldes hin
	return _zentrum + Vector2(190, 40)


## Ein glühender Amboss unter den Brüdern, zwei Hämmer holen von links und rechts aus und treffen beim Bruch zusammen.
func _amboss(deckung: float) -> void:
	var ort := _amboss_ort()
	var glut := clampf(_zeit / BRUCH, 0.0, 1.0)
	var eisen := Color("2e2a28").lerp(_farbe, glut * 0.6)
	draw_rect(Rect2(ort + Vector2(-70, 0), Vector2(140, 26)), Color(eisen, deckung))
	draw_rect(Rect2(ort + Vector2(-34, 26), Vector2(68, 34)), Color(eisen.darkened(0.3), deckung))
	draw_rect(Rect2(ort + Vector2(-70, 0), Vector2(140, 5)), Color(_farbe.lightened(0.3), glut * deckung))
	if _gebrochen and _zeit > BRUCH + 0.6:
		return
	# Hämmer: weit ausgeholt, dann schnell zusammen (kurz vor dem Bruch)
	var schwung := clampf((_zeit - BRUCH * 0.55) / (BRUCH * 0.45), 0.0, 1.0)
	schwung = schwung * schwung
	for seite: float in [-1.0, 1.0]:
		var kopf := ort + Vector2(seite * lerpf(200.0, 34.0, schwung), lerpf(-170.0, -24.0, schwung))
		var griff := kopf + Vector2(seite * 80.0, -70.0)
		draw_line(griff, kopf, Color("5a3b22", deckung), 10.0)
		draw_rect(Rect2(kopf - Vector2(30, 22), Vector2(60, 44)), Color("3a3533", deckung))
		draw_rect(Rect2(kopf - Vector2(30, 22), Vector2(60, 44)), Color(_farbe, 0.7 * glut * deckung), false, 4.0)


## Der gemalte Riss der Leere (Teil M, fx_leere, A9c2) öffnet sich bis zum Bruch immer weiter; danach greifen die
## Ranken heraus und wabern, zum Ende schließt er sich wieder zu einem schmalen Spalt.
func _leere(deckung: float) -> void:
	var bilder := FxBild.bilder("leere")
	if bilder.size() < 6:
		return
	var auf := clampf(_zeit / BRUCH, 0.0, 1.0)
	var nummer := mini(int(auf * 3.0), 2)
	if _gebrochen:
		nummer = 3 + int((_zeit - BRUCH) * 5.0) % 2
		if _zeit > DAUER - 0.5:
			nummer = 5
	# Violetter Schein um den Riss
	draw_circle(_zentrum, 60.0 + 140.0 * auf, Color(_farbe, 0.18 * deckung))
	var tex: Texture2D = bilder[nummer]
	var groesse := tex.get_size() * (2.4 + 1.6 * auf)
	draw_texture_rect(tex, Rect2(_zentrum - groesse * 0.5, groesse), false, Color(1, 1, 1, deckung))


## Ein abgerissenes, glühendes Glied (erstes Bild von fx_kette_reisst)
func _glied(pos: Vector2, winkel: float, deckung: float) -> void:
	var bilder := FxBild.bilder("kette_reisst")
	if bilder.is_empty():
		return
	draw_set_transform(pos, winkel, Vector2.ONE * 0.7)
	draw_texture(bilder[0], -bilder[0].get_size() * 0.5, Color(1, 1, 1, deckung))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


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
