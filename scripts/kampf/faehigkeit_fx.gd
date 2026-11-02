class_name FaehigkeitFx
extends RefCounted
## Eigene Bewegungen und Effekte einzelner Fähigkeiten (K.6, nach den Steckbriefen). Skills melden sie mit c.zeige("name", f, ziel).
## "seite" unterscheidet Wiederholungen derselben Bewegung, z. B. Hieb von links und von rechts.

const STERN := Color("c9a6ff")
const SCHILD := Color("8fd3ff")
const GRUEN := Color("7dffa0")


static func spielen(k: Control, name: String, f: Fighter, ziel: Fighter, seite: int) -> void:
	if not k.has_view(f):
		return
	var v: FighterView = k.view(f)
	var ziel_ansicht: FighterView = k.view(ziel) if ziel != null and k.has_view(ziel) else null
	var feld: Control = k._field
	match name:
		"schildstoss_anlauf":
			# Zwei schnelle Schritte nach vorn
			v.play("run", 0.4)
			_huepfer(v, 8.0, 0.1)
			await k.wait(0.2)
			_huepfer(v, 8.0, 0.1)
			await k.wait(0.2)
		"schildstoss_treffer":
			Geraeusche.play("treffer", 0.55)
			if ziel_ansicht != null:
				Fx.spawn(feld, Fx.Kind.RING, ziel_ansicht.center(), Color("e0b070"), 70.0, 0.25)
				_taumeln(ziel_ansicht)
		"hieb":
			# Schnitt-Spur von links oder rechts
			_huepfer(v, 12.0, 0.1)
			Geraeusche.play("parade", 1.25 + 0.15 * seite)
			if ziel_ansicht != null:
				var spur := Fx.spawn(feld, Fx.Kind.SLASH, ziel_ansicht.center(), Color("fff4d6"), 58.0, 0.28)
				spur.rotation = -0.8 if seite == 0 else 0.8
		"erste_hilfe":
			# Kniet kurz und legt den Verband an
			v.play("cast", 0.6)
			var tiefe := _kniefall(v)
			Geraeusche.play("wurf", 0.6)
			await k.wait(0.45)
			tiefe.kill()
			v.body.position = v._home
			var ort := ziel_ansicht.center() if ziel_ansicht != null else v.center()
			Fx.spawn(feld, Fx.Kind.SPARKS, ort, GRUEN, 70.0, 0.6)
			_pflaster(feld, ort)
		"deckung":
			_huepfer(v, 20.0, 0.16)
			Geraeusche.play("parade", 0.7)
			if ziel_ansicht != null:
				_kuppel(feld, ziel_ansicht.home_feet())
			await k.wait(0.35)
		"deckung_funke":
			Geraeusche.play("parade", 0.7)
			Fx.spawn(feld, Fx.Kind.SPARKS, v.center(), SCHILD.lightened(0.4), 80.0, 0.35)
		"sternenmut_an":
			# Das Schwert leuchtet lila wie ein Splitter, ein heller Glockenton
			Geraeusche.play("perfekt", 1.5)
			v.glow(STERN, 1.0)
			Fx.spawn(feld, Fx.Kind.GLOW, v.center(), STERN, 120.0, 0.6)
			await k.wait(0.4)
		"sternenmut_schlag":
			Geraeusche.play("kritisch", 0.9)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				Fx.spawn(feld, Fx.Kind.SLASH, ort, STERN, 110.0, 0.4)
				Fx.spawn(feld, Fx.Kind.SPARKS, ort, STERN.lightened(0.4), 130.0, 0.7)
				Fx.spawn(feld, Fx.Kind.RING, ort, STERN, 170.0, 0.5)
			k.screen_flash(STERN)


## Kleiner Sprung. Bewegt die ganze Ansicht, damit er neben einem laufenden Angriff funktioniert.
static func _huepfer(v: FighterView, hoehe: float, sekunden: float) -> void:
	var y := v.position.y
	var tween := v.create_tween()
	tween.tween_property(v, "position:y", y - hoehe, sekunden).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(v, "position:y", y, sekunden).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


static func _kniefall(v: FighterView) -> Tween:
	var tween := v.create_tween()
	tween.tween_property(v.body, "position", v._home + Vector2(0, 12), 0.12)
	return tween


## Das Ziel taumelt ein Stück zurück, weiter als bei einem normalen Treffer.
static func _taumeln(v: FighterView) -> void:
	var weg := 1.0 if v.fighter.is_ally() else -1.0
	var x := v.position.x
	var tween := v.create_tween()
	tween.tween_property(v, "position:x", x + 30.0 * weg, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(v, "position:x", x, 0.35).set_trans(Tween.TRANS_SINE)


## Kleines Pflaster-Zeichen, das aufsteigt und verblasst.
static func _pflaster(feld: Control, ort: Vector2) -> void:
	var zeichen := Node2D.new()
	zeichen.position = ort + Vector2(0, -20)
	zeichen.rotation = -0.3
	zeichen.z_index = 9
	for teil: Rect2 in [Rect2(-14, -5, 28, 10), Rect2(-5, -14, 10, 28)]:
		var balken := ColorRect.new()
		balken.position = teil.position
		balken.size = teil.size
		balken.color = Color("f4e6c8")
		zeichen.add_child(balken)
	feld.add_child(zeichen)
	var tween := zeichen.create_tween().set_parallel()
	tween.tween_property(zeichen, "position:y", ort.y - 70.0, 0.7)
	tween.tween_property(zeichen, "modulate:a", 0.0, 0.3).set_delay(0.4)
	tween.chain().tween_callback(zeichen.queue_free)


## Kurze Schild-Kuppel über dem Gedeckten.
static func _kuppel(feld: Control, fuss: Vector2) -> void:
	var bogen := Line2D.new()
	bogen.position = fuss
	bogen.width = 5.0
	bogen.default_color = SCHILD
	bogen.z_index = 8
	for i in 25:
		bogen.add_point(Vector2.from_angle(PI + PI * i / 24.0) * Vector2(70, 110))
	feld.add_child(bogen)
	Fx.spawn(feld, Fx.Kind.GLOW, fuss + Vector2(0, -50), Color(SCHILD, 0.3), 90.0, 0.7)
	var tween := bogen.create_tween()
	tween.tween_property(bogen, "modulate:a", 0.0, 0.3).set_delay(0.45)
	tween.tween_callback(bogen.queue_free)
