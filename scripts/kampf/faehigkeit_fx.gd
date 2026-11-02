class_name FaehigkeitFx
extends RefCounted
## Eigene Bewegungen und Effekte einzelner Fähigkeiten (K.6, nach den Steckbriefen). Skills melden sie mit c.zeige("name", f, ziel).
## "seite" unterscheidet Wiederholungen derselben Bewegung, z. B. Hieb von links und von rechts.

const STERN := Color("c9a6ff")
const SCHILD := Color("8fd3ff")
const GRUEN := Color("7dffa0")
const WALD := Color("8fe86a")
const STAUB := Color("c8b898")
const HIRSCH := "res://assets/figuren/hirsch_idle_anim_f0.png"


static func spielen(k: Control, name: String, f: Fighter, ziel: Fighter, seite: int, farbe := Color.WHITE) -> void:
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
		"schnellschuss":
			_pose(v)
			Geraeusche.play("wurf", 1.7)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				await _pfeil(feld, v.center(), ort, Color("e8ffd0"), 0.14, 3.0)
				Fx.spawn(feld, Fx.Kind.SPARKS, ort, Color("e8ffd0"), 40.0, 0.25)
		"spannen":
			Geraeusche.play("wurf", 0.5)
			v.glow(WALD, 0.7)
			Fx.spawn(feld, Fx.Kind.RING, v.home_feet(), WALD, 70.0, 0.6)
			Fx.spawn(feld, Fx.Kind.GLOW, v.center(), Color(WALD, 0.5), 60.0, 0.6)
			await k.wait(0.5)
		"ladeschuss", "durchschlag":
			_pose(v)
			_rueckstoss(v)
			Geraeusche.play("kritisch", 1.3)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				await _pfeil(feld, v.center(), ort, Color("f4ffe0"), 0.12, 7.0)
				if name == "durchschlag":
					_schneise(feld, v.center(), ort, Color("e8ffc8"))
					Geraeusche.play("parade", 0.5)
				Fx.spawn(feld, Fx.Kind.SPARKS, ort, STAUB, 100.0, 0.5)
				k._shake(10.0)
		"durchschlag_weiter":
			if ziel_ansicht != null:
				_schneise(feld, v.center(), ziel_ansicht.center(), Color("e8ffc8"))
				Fx.spawn(feld, Fx.Kind.SPARKS, ziel_ansicht.center(), STAUB, 70.0, 0.4)
				await k.wait(0.15)
		"hagel_auf":
			# Steil in den Himmel schießen und hinterherschauen
			_pose(v)
			Geraeusche.play("wurf", 1.2)
			for i in 3:
				_pfeil(feld, v.center(), v.center() + Vector2(-40.0 - 30.0 * i, -520.0), Color("e8ffd0"), 0.22, 3.0)
			await k.wait(0.35)
		"hagel_regen":
			if ziel_ansicht != null:
				_regen(k, feld, ziel_ansicht.home_feet())
		"netzpfeil":
			_pose(v)
			Geraeusche.play("wurf", 0.8)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				var mitte := v.center().lerp(ort, 0.5) + Vector2(0, -120)
				await _pfeil(feld, v.center(), mitte, Color.WHITE, 0.14, 3.0)
				await _pfeil(feld, mitte, ort, Color.WHITE, 0.14, 3.0)
				Geraeusche.play("parade", 0.5)
				_netz(feld, ort)
				_zappeln(ziel_ansicht)
		"schnellfeuer":
			# Immer schneller, die Spuren werden heller (seite zählt die Pfeile)
			_pose(v)
			Geraeusche.play("wurf", 1.5 + 0.1 * seite)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				await _pfeil(feld, v.center(), ort, WALD.lightened(0.15 * seite), maxf(0.15 - 0.02 * seite, 0.07), 3.0)
				Fx.spawn(feld, Fx.Kind.SPARKS, ort, Color("e8ffd0"), 34.0, 0.2)
		"schnellfeuer_ende":
			Geraeusche.play("wurf", 2.2)
			_huepfer(v, 10.0, 0.1)
		"schwachstelle":
			v.glow(Color("ff5050"), 0.6)
			await k.wait(0.45)
			_pose(v)
			Geraeusche.play("perfekt", 1.8)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				await _pfeil(feld, v.center(), ort, Color("ff5050"), 0.2, 4.0)
				_fadenkreuz(feld, ort)
		"elementpfeil":
			v.glow(farbe, 0.4)
			await k.wait(0.25)
			_pose(v)
			Geraeusche.play("wurf", 1.1)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				await _pfeil(feld, v.center(), ort, farbe, 0.18, 5.0)
				Fx.spawn(feld, Fx.Kind.RING, ort, farbe, 80.0, 0.3)
				Fx.spawn(feld, Fx.Kind.SPARKS, ort, farbe, 70.0, 0.4)
		"jaegerpfeil":
			# Der Bogen füllt sich mit Waldlicht, der Geist des Silberhirschs läuft neben dem Pfeil
			v.glow(WALD, 1.0)
			Fx.spawn(feld, Fx.Kind.GLOW, v.center(), Color(WALD, 0.6), 110.0, 0.6)
			await k.wait(0.35)
			_pose(v)
			Geraeusche.play("wurf", 0.7)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				_hirschgeist(feld, v.home_feet() + Vector2(0, -60), ort, 0.45)
				await _pfeil(feld, v.center(), ort, WALD.lightened(0.4), 0.45, 8.0)
				Geraeusche.play("kritisch", 0.6)
				k._change_speed(0.3, 0.25)
				k._shake(14.0)
				k.screen_flash(WALD)
				Fx.spawn(feld, Fx.Kind.RING, ort, WALD, 170.0, 0.5)
				Fx.spawn(feld, Fx.Kind.SPARKS, ort, WALD, 170.0, 0.8)
		"schleuder":
			_pose(v)
			Geraeusche.play("wurf")
			if ziel_ansicht != null:
				await _bogenwurf(feld, v.center(), ziel_ansicht.center(), Color("c9b28a"))
		"pfiff":
			# Zwei Pfiffe, der Stab schwenkt
			_pose(v)
			Geraeusche.play("perfekt", 2.0)
			await k.wait(0.14)
			Geraeusche.play("perfekt", 2.3)
			await k.wait(0.14)
		"auftritt":
			# f ist das neue Monster, ziel der Zähmer; seite > 0: Großer Auftritt
			_huepfer(v, 34.0, 0.14)
			if ziel_ansicht != null:
				_schneise(feld, ziel_ansicht.center(), v.center(), Color("fff3b0"))
			await k.wait(0.28)
			Geraeusche.play("treffer", 0.7)
			Fx.spawn(feld, Fx.Kind.SPARKS, v.home_feet(), STAUB, 90.0 + 40.0 * seite, 0.5)
			Fx.spawn(feld, Fx.Kind.RING, v.home_feet(), STAUB, 70.0 + 30.0 * seite, 0.3)
			if seite > 0:
				_kuppel(feld, v.home_feet())
		"anfeuern":
			_huepfer(v, 12.0, 0.1)
			Geraeusche.play("parade", 1.7)
			if ziel_ansicht != null:
				await k.wait(0.15)
				_huepfer(ziel_ansicht, 16.0, 0.1)
				Geraeusche.play("treffer", 0.6)
				ziel_ansicht.glow(Color("ff6060"), 0.7)
				Fx.spawn(feld, Fx.Kind.RING, ziel_ansicht.home_feet(), Color("ff6060"), 80.0, 0.4)
				Fx.spawn(feld, Fx.Kind.SPARKS, ziel_ansicht.center(), Color("ff8080"), 80.0, 0.6)
		"pflege":
			# Kniet sich zum Monster und gibt ihm eine Beere
			var kniend := _kniefall(v)
			await k.wait(0.35)
			kniend.kill()
			v.body.position = v._home
			if ziel_ansicht != null:
				Fx.spawn(feld, Fx.Kind.SPARKS, ziel_ansicht.center(), WALD, 80.0, 0.7)
		"lockfutter":
			_pose(v)
			Geraeusche.play("wurf", 0.7)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				await _bogenwurf(feld, v.center(), ort, Color("e8c890"))
				Fx.spawn(feld, Fx.Kind.SPARKS, ziel_ansicht.home_feet(), Color("e8c890"), 40.0, 0.4)
				_zeichen(feld, ort + Vector2(0, -60), "?", Color("e8c890"))
		"gemeinsam_blitz":
			if ziel_ansicht != null:
				Fx.spawn(feld, Fx.Kind.GLOW, ziel_ansicht.center(), Color(Color.WHITE, 0.7), 120.0, 0.35)
				Fx.spawn(feld, Fx.Kind.RING, ziel_ansicht.center(), Color("fff3b0"), 120.0, 0.35)
			k.screen_flash(Color("fff3b0"))
		"wachstum":
			# Grünes Licht strömt ins Monster, es wächst, der Boden wackelt
			_pose(v)
			if ziel_ansicht != null:
				_schneise(feld, v.center(), ziel_ansicht.center(), WALD)
				Geraeusche.play("kritisch", 0.5)
				k._shake(6.0)
				ziel_ansicht.glow(WALD, 0.7)
				if not ziel_ansicht.has_meta("grund_scale"):
					ziel_ansicht.set_meta("grund_scale", ziel_ansicht.body.scale)
				var gross: Vector2 = ziel_ansicht.get_meta("grund_scale") * 1.5
				await ziel_ansicht.create_tween().tween_property(ziel_ansicht.body, "scale", gross, 0.4).set_trans(Tween.TRANS_BACK).finished
		"wachstum_ende":
			if v.has_meta("grund_scale"):
				v.create_tween().tween_property(v.body, "scale", v.get_meta("grund_scale"), 0.3)
		"bruellen":
			_pose(v)
			var quelle := ziel_ansicht if ziel_ansicht != null else v
			Geraeusche.play("kritisch", 0.5)
			k._shake(6.0)
			for i in 3:
				Fx.spawn(feld, Fx.Kind.RING, quelle.center(), Color("8fb8ff"), 140.0 + 70.0 * i, 0.45)
				await k.wait(0.12)
		"eingeschuechtert":
			if ziel_ansicht != null:
				_taumeln(ziel_ansicht)
				_zeichen(feld, ziel_ansicht.center() + Vector2(0, -60), "▼", Color("8fb8ff"))
		"zweites_leben":
			# Lichtfunken sammeln sich, ein Ton schwillt an, das Monster steht auf
			Geraeusche.play("perfekt", 0.8)
			if ziel_ansicht != null:
				Fx.spawn(feld, Fx.Kind.GLOW, ziel_ansicht.center(), Color("fff3b0"), 110.0, 0.7)
				Fx.spawn(feld, Fx.Kind.SPARKS, ziel_ansicht.center(), Color("fff3b0"), 90.0, 0.7)
				await k.wait(0.4)
				_huepfer(ziel_ansicht, 14.0, 0.12)
		"rudelruf_an":
			_pose(v)
			Geraeusche.play("perfekt", 1.6)
			await k.wait(0.35)
		"rudelruf_ende":
			Geraeusche.play("kritisch", 0.6)
			if ziel_ansicht != null:
				Fx.spawn(feld, Fx.Kind.SPARKS, ziel_ansicht.home_feet(), STAUB, 180.0, 0.8)
				Fx.spawn(feld, Fx.Kind.RING, ziel_ansicht.home_feet(), STAUB, 170.0, 0.5)
			k._change_speed(0.3, 0.25)
			k._shake(14.0)


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


## Schuss-Haltung, wenn die Figur eine hat.
static func _pose(v: FighterView) -> void:
	if v.has_anim("attack"):
		v.play("attack", 0.3)


## Rückstoß beim Schuss, weg vom Ziel.
static func _rueckstoss(v: FighterView) -> void:
	var weg := 1.0 if v.fighter.is_ally() else -1.0
	var x := v.position.x
	var tween := v.create_tween()
	tween.tween_property(v, "position:x", x + 14.0 * weg, 0.06)
	tween.tween_property(v, "position:x", x, 0.25).set_trans(Tween.TRANS_SINE)


## Dünne, helle Spur eines Pfeils. Kann auch ohne await laufen (mehrere Pfeile gleichzeitig).
static func _pfeil(feld: Control, von: Vector2, nach: Vector2, farbe: Color, sekunden: float, breite: float) -> void:
	var spur := Line2D.new()
	spur.width = breite
	spur.default_color = farbe
	spur.z_index = 8
	spur.material = Fx.add_material()
	spur.add_point(von)
	spur.add_point(von)
	feld.add_child(spur)
	var tween := spur.create_tween()
	tween.tween_method(func(t: float) -> void:
		spur.set_point_position(0, von.lerp(nach, maxf(t - 0.3, 0.0)))
		spur.set_point_position(1, von.lerp(nach, t)), 0.0, 1.0, sekunden)
	await tween.finished
	spur.queue_free()


## Leuchtende Schneise, die kurz stehen bleibt.
static func _schneise(feld: Control, von: Vector2, nach: Vector2, farbe: Color) -> void:
	var spur := Line2D.new()
	spur.width = 12.0
	spur.default_color = farbe
	spur.z_index = 8
	spur.material = Fx.add_material()
	spur.add_point(von)
	spur.add_point(nach)
	feld.add_child(spur)
	var tween := spur.create_tween()
	tween.tween_property(spur, "width", 0.0, 0.6).set_delay(0.2)
	tween.tween_callback(spur.queue_free)


## Pfeile regnen nacheinander herab, ihre Schatten erscheinen vorher am Boden.
static func _regen(k: Control, feld: Control, fuss: Vector2) -> void:
	for i in 3:
		var ort := fuss + Vector2(randf_range(-46, 46), randf_range(-10, 10))
		var schatten := Polygon2D.new()
		var punkte := PackedVector2Array()
		for winkel in 12:
			punkte.append(Vector2.from_angle(TAU * winkel / 12.0) * Vector2(16, 6))
		schatten.polygon = punkte
		schatten.color = Color(0, 0, 0, 0.5)
		schatten.position = ort
		schatten.z_index = 1
		feld.add_child(schatten)
		await k.wait(0.1)
		_pfeil(feld, ort + Vector2(30, -420), ort, Color("e8ffd0"), 0.14, 3.0)
		await k.wait(0.14)
		schatten.queue_free()
		Geraeusche.play("treffer", 1.6)
		Fx.spawn(feld, Fx.Kind.SPARKS, ort, STAUB, 30.0, 0.25)


## Netz, das sich um den Gegner legt.
static func _netz(feld: Control, ort: Vector2) -> void:
	var netz := Node2D.new()
	netz.position = ort
	netz.z_index = 8
	for i in range(-3, 4):
		for richtung: float in [1.0, -1.0]:
			var faden := Line2D.new()
			faden.width = 2.0
			faden.default_color = Color("f0ece0")
			faden.add_point(Vector2(i * 16.0 - 44.0 * richtung, -44))
			faden.add_point(Vector2(i * 16.0 + 44.0 * richtung, 44))
			netz.add_child(faden)
	netz.scale = Vector2(1.5, 1.5)
	feld.add_child(netz)
	var tween := netz.create_tween()
	tween.tween_property(netz, "scale", Vector2.ONE, 0.15)
	tween.tween_interval(0.5)
	tween.tween_property(netz, "modulate:a", 0.0, 0.25)
	tween.tween_callback(netz.queue_free)


## Der Gegner zappelt im Netz.
static func _zappeln(v: FighterView) -> void:
	var x := v.position.x
	var tween := v.create_tween()
	for i in 3:
		tween.tween_property(v, "position:x", x - 5.0, 0.05)
		tween.tween_property(v, "position:x", x + 5.0, 0.05)
	tween.tween_property(v, "position:x", x, 0.05)


## Rotes Fadenkreuz über dem Ziel.
static func _fadenkreuz(feld: Control, ort: Vector2) -> void:
	var kreuz := Node2D.new()
	kreuz.position = ort
	kreuz.z_index = 8
	var ring := Line2D.new()
	ring.width = 3.0
	ring.default_color = Color("ff5050")
	for i in 33:
		ring.add_point(Vector2.from_angle(TAU * i / 32.0) * 42.0)
	kreuz.add_child(ring)
	for richtung: Vector2 in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		var strich := Line2D.new()
		strich.width = 3.0
		strich.default_color = Color("ff5050")
		strich.add_point(richtung * 28.0)
		strich.add_point(richtung * 56.0)
		kreuz.add_child(strich)
	feld.add_child(kreuz)
	var tween := kreuz.create_tween()
	tween.tween_property(kreuz, "modulate:a", 0.0, 0.4).set_delay(0.9)
	tween.tween_callback(kreuz.queue_free)


## Leuchtender Geist des Silberhirschs, läuft neben dem Pfeil her.
static func _hirschgeist(feld: Control, von: Vector2, nach: Vector2, sekunden: float) -> void:
	var geist := Sprite2D.new()
	geist.texture = load(HIRSCH)
	geist.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	geist.scale = Vector2.ONE * 140.0 / geist.texture.get_height()
	geist.flip_h = nach.x < von.x
	geist.modulate = Color(0.8, 0.95, 1.0, 0.85)
	geist.material = Fx.add_material()
	geist.position = von
	geist.z_index = 8
	feld.add_child(geist)
	var tween := geist.create_tween()
	tween.tween_property(geist, "position", nach, sekunden).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(geist, "modulate:a", 0.0, 0.2)
	tween.tween_callback(geist.queue_free)


## Etwas fliegt im Bogen zum Ziel (Stein, Futter).
static func _bogenwurf(feld: Control, von: Vector2, nach: Vector2, farbe: Color) -> void:
	var mitte := von.lerp(nach, 0.5) + Vector2(0, -90)
	await _pfeil(feld, von, mitte, farbe, 0.12, 5.0)
	await _pfeil(feld, mitte, nach, farbe, 0.12, 5.0)


## Kleines Zeichen, das über einer Figur aufsteigt und verblasst.
static func _zeichen(feld: Control, ort: Vector2, text: String, farbe: Color) -> void:
	var schrift := Label.new()
	schrift.text = text
	schrift.add_theme_font_size_override("font_size", 34)
	schrift.add_theme_color_override("font_color", farbe)
	schrift.add_theme_color_override("font_outline_color", Color.BLACK)
	schrift.add_theme_constant_override("outline_size", 5)
	schrift.position = ort - Vector2(10, 20)
	schrift.z_index = 9
	feld.add_child(schrift)
	var tween := schrift.create_tween().set_parallel()
	tween.tween_property(schrift, "position:y", ort.y - 60.0, 0.8)
	tween.tween_property(schrift, "modulate:a", 0.0, 0.3).set_delay(0.5)
	tween.chain().tween_callback(schrift.queue_free)
