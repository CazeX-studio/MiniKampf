class_name BackdropOrte
## Weitere Kampf-Hintergründe je Gebiet (Endspurt E3d), gezeichnet wie die in backdrop.gd:
## "kreuzwegfelder" (Felder vor Kreuzweg, Ye's Lektionen), "waldweg" (Weg nach Grünwacht),
## "tiefwurzel" (alte Wurzeln und Splitter), "wipfelheim" (Plattform in den Baumkronen),
## "aschensteppe" (Grasland) und "aschensteppe_sand" (Dünen im Süden), "palmenrast" (Oase),
## "sternenduene" (Xavinas Düne, immer Nacht), "glutoase_stadt" (Terrassen), "glutoase_schmiede" (Hadraks Schmiede),
## "glutgrat" (Vulkangrat). Alle Funktionen zeichnen auf den Hintergrund b (bzw. b._lights für das Licht).

const STILE: Array[String] = ["kreuzwegfelder", "waldweg", "tiefwurzel", "wipfelheim", "aschensteppe", "aschensteppe_sand",
		"palmenrast", "sternenduene", "glutoase_stadt", "glutoase_schmiede", "glutgrat"]

## Licht des Ortes auf den Figuren
const LICHT := {
	"kreuzwegfelder": Color(1.0, 0.98, 0.92),
	"waldweg": Color(0.96, 1.0, 0.9),
	"tiefwurzel": Color(0.78, 0.8, 0.9),
	"wipfelheim": Color(0.98, 1.0, 0.9),
	"aschensteppe": Color(1.0, 0.94, 0.84),
	"aschensteppe_sand": Color(1.0, 0.92, 0.8),
	"palmenrast": Color(1.0, 0.97, 0.88),
	"sternenduene": Color(0.74, 0.76, 1.0),
	"glutoase_stadt": Color(1.0, 0.94, 0.84),
	"glutoase_schmiede": Color(1.0, 0.84, 0.72),
	"glutgrat": Color(1.0, 0.8, 0.7),
}

## Schwebende Teilchen: Pollen, Asche, Sand, Glut
const STAUB := {
	"kreuzwegfelder": Color(1, 1, 0.85),
	"waldweg": Color(0.9, 1.0, 0.6),
	"tiefwurzel": Color(0.75, 0.6, 1.0),
	"wipfelheim": Color(0.9, 1.0, 0.6),
	"aschensteppe": Color(0.85, 0.8, 0.75),
	"aschensteppe_sand": Color(1.0, 0.9, 0.7),
	"palmenrast": Color(1, 1, 0.85),
	"sternenduene": Color(0.8, 0.85, 1.0),
	"glutoase_stadt": Color(1.0, 0.9, 0.7),
	"glutoase_schmiede": Color(1.0, 0.6, 0.25),
	"glutgrat": Color(1.0, 0.5, 0.2),
}

## Orte unter freiem Himmel: Dort wird es nachts dunkel (nach der Uhr, wie in der Welt).
const DRAUSSEN: Array[String] = ["wiese", "kreuzwegfelder", "wald", "waldweg", "tiefwurzel", "wipfelheim",
		"aschensteppe", "aschensteppe_sand", "palmenrast", "glutoase_stadt", "glutgrat"]


static func zeichne(b: Backdrop, stil: String) -> void:
	match stil:
		"kreuzwegfelder": _felder(b)
		"waldweg": _waldweg(b)
		"tiefwurzel": _tiefwurzel(b)
		"wipfelheim": _wipfelheim(b)
		"aschensteppe": _steppe(b, false)
		"aschensteppe_sand": _steppe(b, true)
		"palmenrast": _palmenrast(b)
		"sternenduene": _sternenduene(b)
		"glutoase_stadt": _stadt(b)
		"glutoase_schmiede": _schmiede(b)
		"glutgrat": _glutgrat(b)


static func licht(b: Backdrop, stil: String) -> void:
	var glow := Fx.glow_texture()
	var l := b._lights
	var t := b._time
	match stil:
		"kreuzwegfelder", "waldweg", "aschensteppe", "aschensteppe_sand", "palmenrast", "glutoase_stadt":
			# Sonne von links oben, warmes Licht auf dem Kampffeld
			l.draw_texture_rect(glow, Rect2(Vector2(-200, -250), Vector2(700, 600)), false, Color(1.0, 0.9, 0.6, 0.35))
			l.draw_texture_rect(glow, Rect2(Vector2(640, 150), Vector2(640, 430)), false, Color(1.0, 0.85, 0.6, 0.14))
			if stil == "glutoase_stadt":
				for x: float in [180.0, 640.0, 1100.0]:
					var f := 0.85 + 0.15 * sin(t * 6.0 + x)
					l.draw_texture_rect(glow, Rect2(Vector2(x, 150) - Vector2(70, 70) * f, Vector2(140, 140) * f), false, Color(1.0, 0.65, 0.3, 0.3))
		"wipfelheim":
			for i in 4:
				var x := 140.0 + i * 330.0
				var sway := 0.85 + 0.15 * sin(t * 0.8 + i)
				l.draw_texture_rect(glow, Rect2(Vector2(x - 90, -120), Vector2(180, 520)), false, Color(0.9, 1.0, 0.6, 0.15 * sway))
			for x in WIPFEL_LATERNEN:
				var f := 0.85 + 0.15 * sin(t * 5.0 + x)
				l.draw_texture_rect(glow, Rect2(Vector2(x, 120) - Vector2(60, 60) * f, Vector2(120, 120) * f), false, Color(1.0, 0.7, 0.3, 0.35))
		"tiefwurzel":
			for c in TIEF_SPLITTER:
				var p := 0.75 + 0.25 * sin(t * 2.0 + c.x * 0.02)
				l.draw_texture_rect(glow, Rect2(c - Vector2(110, 110) * p, Vector2(220, 220) * p), false, Color(0.6, 0.35, 1.0, 0.32 * p))
			l.draw_texture_rect(glow, Rect2(Vector2(0, 170), Vector2(1280, 410)), false, Color(0.5, 0.6, 0.8, 0.1))
		"sternenduene":
			l.draw_texture_rect(glow, Rect2(Vector2(470, -160), Vector2(340, 340)), false, Color(0.8, 0.85, 1.0, 0.4))
			l.draw_texture_rect(glow, Rect2(Vector2(0, 150), Vector2(1280, 430)), false, Color(0.5, 0.5, 1.0, 0.14))
		"glutoase_schmiede":
			var f := 0.85 + 0.15 * sin(t * 7.0) * sin(t * 4.3)
			l.draw_texture_rect(glow, Rect2(Vector2(640, 120) - Vector2(260, 220) * f, Vector2(520, 440) * f), false, Color(1.0, 0.45, 0.15, 0.4))
			l.draw_texture_rect(glow, Rect2(Vector2(0, 170), Vector2(1280, 410)), false, Color(1.0, 0.65, 0.4, 0.14))
		"glutgrat":
			var p := 0.9 + 0.1 * sin(t * 1.5)
			l.draw_texture_rect(glow, Rect2(Vector2(820, -80) - Vector2(80, 0), Vector2(360, 300) * p), false, Color(1.0, 0.35, 0.1, 0.45))
			l.draw_texture_rect(glow, Rect2(Vector2(-100, 160), Vector2(1480, 300)), false, Color(1.0, 0.3, 0.08, 0.18 * p))


## Nachts (nach der Uhr): Mondlicht statt Sonne (wird über das Licht des Ortes gelegt).
static func mond(b: Backdrop) -> void:
	var glow := Fx.glow_texture()
	b._lights.draw_texture_rect(glow, Rect2(Vector2(960, -40), Vector2(200, 200)), false, Color(0.9, 0.9, 1.0, 0.3 * b.nacht))


## Dunkle Schicht über dem Bild, Sterne und Mond am Himmel (nur Orte mit freiem Himmel).
static func nacht_schicht(b: Backdrop, stil: String) -> void:
	if b.nacht <= 0.0:
		return
	b.draw_rect(Rect2(Vector2.ZERO, b.size), Color(0.04, 0.05, 0.16, 0.55 * b.nacht))
	if stil in ["wald", "tiefwurzel", "wipfelheim"]:
		return
	for s in b._stars:
		var twinkle := 0.5 + 0.5 * sin(b._time * 2.0 + s.x)
		b.draw_rect(Rect2(s, Vector2(2, 2)), Color(1, 1, 0.9, (0.3 + 0.6 * twinkle) * b.nacht))
	b.draw_circle(Vector2(1060, 58), 20, Color(0.96, 0.94, 0.82, b.nacht))


# --- Bausteine ----------------------------------------------------------------

static func _himmel(b: Backdrop, oben: Color, unten: Color, hoehe := 180.0) -> void:
	var streifen := 12
	for i in streifen:
		var t := float(i) / float(streifen - 1)
		b.draw_rect(Rect2(0, i * hoehe / streifen, 1280, hoehe / streifen + 1), oben.lerp(unten, t))


static func _boden(b: Backdrop, fern: Color, nah: Color, y0 := 176.0) -> void:
	var reihen := int(ceil((720.0 - y0) / 16.0))
	for row in reihen:
		var t := float(row) / float(reihen - 1)
		b.draw_rect(Rect2(0, y0 + row * 16.0, 1280, 17), fern.lerp(nah, t))


## Feste Zufallspunkte auf dem Boden (gleich bei jedem Kampf).
static func _punkt(i: int, y0 := 190.0) -> Vector2:
	return Vector2(float((i * 97 + i * i * 13) % 1280), y0 + float((i * 53 + i * i * 7) % 330))


static func _huegel(b: Backdrop, y: float, farbe: Color, abstand := 220.0, radius := 120.0, versatz := -40.0) -> void:
	var n := int(1280.0 / abstand) + 2
	for i in n:
		b.draw_circle(Vector2(i * abstand + versatz, y), radius, farbe)


static func _duenen(b: Backdrop, y: float, hoehe: float, farbe: Color, wellen: float, phase: float) -> void:
	var pts := PackedVector2Array()
	pts.append(Vector2(0, 720))
	for i in 33:
		var x := i * 40.0
		pts.append(Vector2(x, y - hoehe * (0.5 + 0.5 * sin(x / 1280.0 * TAU * wellen + phase))))
	pts.append(Vector2(1280, 720))
	b.draw_colored_polygon(pts, farbe)


static func _palme(b: Backdrop, fuss: Vector2, hoehe: float, neigung: float, t: float) -> void:
	var stamm := Color("7a5a3a")
	var oben := fuss + Vector2(neigung, -hoehe)
	for i in 8:
		var a := fuss.lerp(oben, i / 8.0) + Vector2(sin(i * 0.5) * neigung * 0.1, 0)
		var c := fuss.lerp(oben, (i + 1) / 8.0)
		b.draw_line(a, c, stamm if i % 2 == 0 else stamm.darkened(0.2), 9.0 - i * 0.5)
	var wind := sin(t * 1.3 + fuss.x) * 4.0
	for k in 7:
		var w := -PI * 0.95 + k * PI * 0.32
		var spitze := oben + Vector2(cos(w) * 62.0, sin(w) * 26.0 + 22.0 + wind)
		var mitte := oben + Vector2(cos(w) * 34.0, sin(w) * 20.0 - 4.0)
		b.draw_polyline(PackedVector2Array([oben, mitte, spitze]), Color("3f7a32") if k % 2 else Color("2f6428"), 7.0)
	b.draw_circle(oben + Vector2(0, 4), 6.0, Color("6a4a2a"))


static func _kaktus(b: Backdrop, fuss: Vector2, h: float) -> void:
	var gruen := Color("4f7a3a")
	b.draw_rect(Rect2(fuss.x - 7, fuss.y - h, 14, h), gruen)
	b.draw_rect(Rect2(fuss.x - 22, fuss.y - h * 0.65, 8, h * 0.3), gruen)
	b.draw_rect(Rect2(fuss.x - 22, fuss.y - h * 0.4, 18, 7), gruen)
	b.draw_rect(Rect2(fuss.x + 14, fuss.y - h * 0.8, 8, h * 0.35), gruen)
	b.draw_rect(Rect2(fuss.x + 4, fuss.y - h * 0.5, 18, 7), gruen)
	b.draw_rect(Rect2(fuss.x - 7, fuss.y - h, 4, h), gruen.darkened(0.2))


# --- Orte ---------------------------------------------------------------------

## Kreuzwegfelder: Felder in Streifen, Zaun, Windmühle, Vogelscheuche, Kreuzweg rechts in der Ferne.
static func _felder(b: Backdrop) -> void:
	var t := b._time
	_himmel(b, Color("72a9dc"), Color("f4dcae"))
	_huegel(b, 196, Color("7aa266"), 260.0, 110.0)
	# Stadtmauer von Kreuzweg klein in der Ferne
	var mauer := Color("a89e8a")
	b.draw_rect(Rect2(960, 130, 320, 46), mauer)
	for x in range(960, 1280, 24):
		b.draw_rect(Rect2(x, 123, 14, 9), mauer)
	b.draw_rect(Rect2(1080, 104, 30, 72), mauer.darkened(0.1))
	b.draw_rect(Rect2(1100, 146, 50, 30), Color("4a3626"))
	# Felder auf dem Hang: Weizen, Kohl, Brache
	var feld_farben: Array[Color] = [Color("d9b94a"), Color("8cb048"), Color("b08a52"), Color("e2c860")]
	for i in 6:
		var x := i * 170.0 - 20.0
		var farbe := feld_farben[i % feld_farben.size()]
		b.draw_colored_polygon(PackedVector2Array([Vector2(x, 176), Vector2(x + 30, 150), Vector2(x + 190, 150), Vector2(x + 170, 176)]), farbe)
		for r in 4:
			b.draw_line(Vector2(x + 8 + r * 4, 170 - r * 5), Vector2(x + 172 + r * 4, 170 - r * 5), farbe.darkened(0.15), 2.0)
	# Windmühle links
	var m := Vector2(230, 118)
	b.draw_colored_polygon(PackedVector2Array([m + Vector2(-22, 58), m + Vector2(-14, -10), m + Vector2(14, -10), m + Vector2(22, 58)]), Color("d8cdb6"))
	b.draw_colored_polygon(PackedVector2Array([m + Vector2(-18, -10), m + Vector2(0, -28), m + Vector2(18, -10)]), Color("8a4a32"))
	for k in 4:
		var w := t * 0.8 + k * PI * 0.5
		var ende := m + Vector2(cos(w), sin(w)) * 52.0
		b.draw_line(m, ende, Color("6a5040"), 3.0)
		var quer := Vector2(-sin(w), cos(w)) * 9.0
		b.draw_colored_polygon(PackedVector2Array([m.lerp(ende, 0.3), ende, ende + quer, m.lerp(ende, 0.3) + quer]), Color("efe6d2"))
	b.draw_circle(m, 4.0, Color("4a3626"))
	# Wiese vorne
	_boden(b, Color("6aa04e"), Color("86c260"))
	# Zaun hinter den Kämpfern
	for x in range(0, 1290, 64):
		b.draw_rect(Rect2(x, 186, 6, 30), Color("7a5a3a"))
	b.draw_rect(Rect2(0, 192, 1280, 4), Color("8a6a46"))
	b.draw_rect(Rect2(0, 204, 1280, 4), Color("8a6a46"))
	# Vogelscheuche
	var v := Vector2(620, 200)
	b.draw_rect(Rect2(v.x - 3, v.y - 60, 6, 64), Color("6a4a2a"))
	b.draw_rect(Rect2(v.x - 26, v.y - 46, 52, 5), Color("6a4a2a"))
	b.draw_rect(Rect2(v.x - 14, v.y - 46, 28, 30), Color("a0503a"))
	b.draw_circle(v + Vector2(0, -56), 9.0, Color("e2c88a"))
	b.draw_colored_polygon(PackedVector2Array([v + Vector2(-16, -62), v + Vector2(0, -78), v + Vector2(16, -62)]), Color("c8a040"))
	# Grasbüschel und Blumen
	for i in b._floor_pick.size():
		var p := _punkt(i, 222.0)
		if p.y > 520:
			continue
		b.draw_rect(Rect2(p.x, p.y, 4, 8), Color("4f8a3c"))
		b.draw_rect(Rect2(p.x + 5, p.y + 2, 4, 6), Color("4f8a3c"))
		if i % 8 == 0:
			b.draw_rect(Rect2(p.x + 2, p.y - 4, 4, 4), Color("ffe680") if i % 2 == 0 else Color("f2a0c8"))


## Weg nach Grünwacht: lichter Waldrand, Himmel zwischen den Bäumen, ein Erdweg quer durchs Bild.
static func _waldweg(b: Backdrop) -> void:
	_himmel(b, Color("8cc0d8"), Color("dcecc0"), 190.0)
	_huegel(b, 200, Color("4c7a44"), 240.0, 100.0, 0.0)
	# Bäume einzeln, mit Kronen
	for i in 8:
		var x := float((i * 173 + 40) % 1300) - 20.0
		var h := 150.0 + float((i * 31) % 50)
		var breite := 22.0 + float(i % 3) * 8.0
		b.draw_rect(Rect2(x, 196 - h * 0.6, breite, h * 0.6 + 4), Color("5a4030"))
		var krone := Color("3f6e34") if i % 2 == 0 else Color("4a7c3a")
		b.draw_circle(Vector2(x + breite * 0.5, 196 - h * 0.62), 48.0, krone)
		b.draw_circle(Vector2(x + breite * 0.5 - 30, 196 - h * 0.5), 34.0, krone.darkened(0.1))
		b.draw_circle(Vector2(x + breite * 0.5 + 30, 196 - h * 0.5), 34.0, krone.lightened(0.05))
	_boden(b, Color("4f7a3a"), Color("6e9e4c"), 196.0)
	# Erdweg schräg durchs Bild
	b.draw_colored_polygon(PackedVector2Array([Vector2(0, 250), Vector2(1280, 214), Vector2(1280, 290), Vector2(0, 360)]), Color("a08058"))
	b.draw_colored_polygon(PackedVector2Array([Vector2(0, 262), Vector2(1280, 222), Vector2(1280, 228), Vector2(0, 270)]), Color("8a6c48"))
	# Wegweiser
	b.draw_rect(Rect2(1180, 170, 6, 56), Color("6a4a2a"))
	b.draw_colored_polygon(PackedVector2Array([Vector2(1150, 176), Vector2(1214, 176), Vector2(1226, 186), Vector2(1214, 196), Vector2(1150, 196)]), Color("8a6a46"))
	# Büsche, Blumen, Steine
	for i in b._floor_pick.size():
		var p := _punkt(i, 210.0)
		if i % 13 == 0:
			b.draw_circle(p, 14.0, Color("3c6a30"))
			b.draw_circle(p + Vector2(12, 4), 11.0, Color("467a36"))
		elif i % 9 == 0:
			b.draw_rect(Rect2(p.x, p.y - 4, 4, 4), Color("f2e070") if i % 2 == 0 else Color("e8a0d0"))
		elif i % 7 == 0:
			b.draw_circle(p, 5.0, Color("8a8478"))
		else:
			b.draw_rect(Rect2(p.x, p.y, 4, 6), Color("4a7a36"))


## Tiefwurzel: uralter Wald, riesige Wurzelbögen, Moos, lila leuchtende Splitter im Boden.
const TIEF_SPLITTER: Array[Vector2] = [Vector2(140, 210), Vector2(470, 196), Vector2(860, 204), Vector2(1150, 214), Vector2(300, 600), Vector2(1020, 620)]


static func _tiefwurzel(b: Backdrop) -> void:
	var t := b._time
	_himmel(b, Color("0a140e"), Color("22301e"), 190.0)
	# Riesige Stämme hinten
	for i in 5:
		var x := float((i * 283 + 60) % 1320) - 40.0
		b.draw_rect(Rect2(x, 0, 90, 200), Color("1e1a14"))
		b.draw_rect(Rect2(x, 0, 24, 200), Color("16130e"))
	# Wurzelbögen über dem Boden
	for i in 6:
		var x := -60.0 + i * 240.0
		var pts := PackedVector2Array()
		for k in 13:
			var a := PI * k / 12.0
			pts.append(Vector2(x + 110 - cos(a) * 110.0, 206 - sin(a) * (70.0 + float(i % 3) * 18.0)))
		b.draw_polyline(pts, Color("3a2c1e"), 16.0)
		b.draw_polyline(pts, Color("4a3826"), 6.0)
	_boden(b, Color("1c2618"), Color("2e3c24"), 200.0)
	# Moos, Farn und kleine Splitter
	for i in b._floor_pick.size():
		var p := _punkt(i, 214.0)
		if i % 10 == 0:
			b.draw_colored_polygon(PackedVector2Array([p, p + Vector2(10, -16), p + Vector2(20, 0)]), Color("2e5a2a"))
		elif i % 7 == 0:
			b.draw_circle(p, 9.0, Color("2a4a24"))
		else:
			b.draw_rect(Rect2(p.x, p.y, 4, 4), Color("26361e"))
	for c in TIEF_SPLITTER:
		var p := 0.75 + 0.25 * sin(t * 2.0 + c.x * 0.02)
		var farbe := Color(0.62, 0.4, 0.95).lightened(0.25 * p)
		b.draw_colored_polygon(PackedVector2Array([c + Vector2(-10, 0), c + Vector2(-3, -34), c + Vector2(4, 0)]), farbe)
		b.draw_colored_polygon(PackedVector2Array([c + Vector2(2, 0), c + Vector2(12, -22), c + Vector2(16, 0)]), farbe.darkened(0.15))
	# Nebel über dem Boden
	for i in 5:
		var x := fmod(i * 300.0 + t * 8.0, 1600.0) - 300.0
		b.draw_rect(Rect2(x, 230 + i * 18.0, 360, 14), Color(0.7, 0.75, 0.85, 0.06))


## Wipfelheim: Holzplattform in den Baumkronen, Geländer mit Seilen, Hängebrücke und Laternen im Hintergrund.
const WIPFEL_LATERNEN: Array[float] = [200.0, 620.0, 1050.0]


static func _wipfelheim(b: Backdrop) -> void:
	var t := b._time
	_himmel(b, Color("7cb4c8"), Color("c8e0b0"), 200.0)
	# Blätterwolken und Stämme dahinter
	for i in 7:
		var x := float((i * 197) % 1340) - 30.0
		b.draw_rect(Rect2(x, 40, 60, 160), Color("4a3828"))
	for i in 22:
		var x := float((i * 61) % 1320)
		b.draw_circle(Vector2(x, float((i * 29) % 60) + 10.0), 50.0 + float(i % 3) * 8.0, Color("2f5a2a") if i % 2 == 0 else Color("3a6a30"))
	# Hängebrücke zwischen zwei Plattformen in der Ferne
	b.draw_rect(Rect2(60, 128, 140, 10), Color("6a4c30"))
	b.draw_rect(Rect2(1080, 120, 160, 10), Color("6a4c30"))
	var bruecke := PackedVector2Array()
	for k in 21:
		var x := 200.0 + k * 44.0
		bruecke.append(Vector2(x, 132 + sin(PI * k / 20.0) * 26.0 - k * 0.4))
	b.draw_polyline(bruecke, Color("7a5a3a"), 5.0)
	for k in 21:
		b.draw_line(bruecke[k], bruecke[k] - Vector2(0, 16), Color("8a6a46"), 2.0)
	# Laternen an Seilen
	for x in WIPFEL_LATERNEN:
		var sway := sin(t * 1.4 + x) * 3.0
		b.draw_line(Vector2(x, 0), Vector2(x + sway, 112), Color("3a2c1e"), 2.0)
		b.draw_rect(Rect2(x + sway - 8, 112, 16, 20), Color("ffcc70"))
		b.draw_rect(Rect2(x + sway - 10, 108, 20, 5), Color("5a3a22"))
	# Plankenboden
	for row in 33:
		var y := 186.0 + row * 16.0
		var farbe := Color("6e5034").lerp(Color("9a7450"), float(row) / 32.0)
		b.draw_rect(Rect2(0, y, 1280, 17), farbe)
		b.draw_rect(Rect2(0, y + 15, 1280, 2), farbe.darkened(0.3))
		var versatz := float((row * 137) % 160)
		for x in range(0, 1440, 160):
			b.draw_rect(Rect2(x - versatz, y, 2, 16), farbe.darkened(0.3))
	# Geländer hinten mit Seil
	for x in range(20, 1290, 120):
		b.draw_rect(Rect2(x, 150, 8, 40), Color("5a3e26"))
	b.draw_rect(Rect2(0, 156, 1280, 5), Color("7a5a3a"))
	b.draw_line(Vector2(0, 174), Vector2(1280, 174), Color("c8b080"), 2.0)


## Aschensteppe: dunstiger Himmel, Tafelberge, trockenes Gras (Norden) oder Dünen mit Kakteen und Ruine (Süden).
static func _steppe(b: Backdrop, sand: bool) -> void:
	_himmel(b, Color("c8a888"), Color("f0d0a0"))
	# Tafelberge in der Ferne
	for i in 4:
		var x := 60.0 + i * 340.0
		var h := 40.0 + float((i * 23) % 30)
		b.draw_colored_polygon(PackedVector2Array([Vector2(x - 40, 182), Vector2(x, 182 - h), Vector2(x + 140, 182 - h), Vector2(x + 190, 182)]), Color("a07a5e"))
		b.draw_rect(Rect2(x, 182 - h, 140, 6), Color("8a6248"))
	if sand:
		_duenen(b, 200, 34, Color("d8b07a"), 2.0, 0.6)
		_duenen(b, 230, 20, Color("e4c08a"), 3.0, 1.9)
		# Ruine: zwei Säulen und ein Bogenrest
		for x: float in [880.0, 960.0]:
			b.draw_rect(Rect2(x, 120, 26, 92), Color("c8a47a"))
			b.draw_rect(Rect2(x - 4, 116, 34, 8), Color("b08c64"))
		b.draw_rect(Rect2(876, 110, 114, 10), Color("b08c64"))
		b.draw_rect(Rect2(1020, 190, 30, 22), Color("b08c64"))
		_kaktus(b, Vector2(180, 222), 62.0)
		_kaktus(b, Vector2(1180, 232), 48.0)
		_boden(b, Color("e0bc86"), Color("f0d4a0"), 240.0)
		for i in b._floor_pick.size():
			var p := _punkt(i, 250.0)
			if i % 3 == 0:
				b.draw_line(p, p + Vector2(34, 0), Color("d4ae78"), 2.0)
			elif i % 17 == 0:
				b.draw_circle(p, 6.0, Color("a8906e"))
		return
	_boden(b, Color("a89a5a"), Color("c4b070"))
	# Ascheflecken, Felsen und Steppengras
	for i in b._floor_pick.size():
		var p := _punkt(i, 196.0)
		if i % 11 == 0:
			b.draw_circle(p, 14.0, Color("8a8070"))
			b.draw_circle(p + Vector2(-4, -4), 9.0, Color("9e9482"))
		elif i % 6 == 0:
			b.draw_rect(Rect2(p.x, p.y, 30, 4), Color(0.45, 0.42, 0.4, 0.5))
		else:
			b.draw_line(p, p + Vector2(-3, -10), Color("8a7c3e"), 2.0)
			b.draw_line(p + Vector2(4, 0), p + Vector2(6, -12), Color("9a8a46"), 2.0)
	_kaktus(b, Vector2(1100, 200), 44.0)


## Palmenrast: Oase mit Wasser, Palmen und grünen Flecken, Sand vorne.
static func _palmenrast(b: Backdrop) -> void:
	var t := b._time
	_himmel(b, Color("5ea0d8"), Color("f2dcae"))
	_duenen(b, 180, 30, Color("d8b480"), 1.5, 2.2)
	_boden(b, Color("dcb882"), Color("f0d29e"), 196.0)
	# Oasen-Teich hinter den Kämpfern
	b.draw_set_transform(Vector2(640, 214), 0.0, Vector2(1.0, 0.18))
	b.draw_circle(Vector2.ZERO, 300.0, Color("6aa84a"))
	b.draw_circle(Vector2.ZERO, 250.0, Color("3a8ab8"))
	b.draw_set_transform_matrix(Transform2D.IDENTITY)
	for i in 9:
		var x := 430.0 + fmod(i * 53.0 + t * 12.0, 420.0)
		b.draw_rect(Rect2(x, 206 + (i % 3) * 7.0, 22, 2), Color(0.85, 0.95, 1.0, 0.7))
	for p: Vector2 in [Vector2(330, 214), Vector2(410, 206), Vector2(900, 210), Vector2(980, 218)]:
		_palme(b, p, 120.0 + fmod(p.x, 30.0), 18.0 if p.x < 640 else -18.0, t)
	for p: Vector2 in [Vector2(90, 230), Vector2(1190, 236)]:
		_palme(b, p, 160.0, 24.0 if p.x < 640 else -24.0, t)
	for i in b._floor_pick.size():
		var p := _punkt(i, 250.0)
		if i % 9 == 0:
			b.draw_rect(Rect2(p.x, p.y, 4, 8), Color("6a9a40"))
			b.draw_rect(Rect2(p.x + 5, p.y + 2, 4, 6), Color("6a9a40"))
		elif i % 4 == 0:
			b.draw_line(p, p + Vector2(28, 0), Color("dab27c"), 2.0)


## Sternendüne (Xavinas Prüfung): Nachthimmel voller Sterne, silberblaue Dünen.
static func _sternenduene(b: Backdrop) -> void:
	var t := b._time
	_himmel(b, Color("080a24"), Color("2c2858"), 220.0)
	for i in b._stars.size():
		var s: Vector2 = b._stars[i]
		var twinkle := 0.5 + 0.5 * sin(t * 2.0 + s.x)
		b.draw_rect(Rect2(s, Vector2(2, 2)), Color(1, 1, 0.9, 0.4 + 0.6 * twinkle))
		b.draw_rect(Rect2(Vector2(fmod(s.x * 1.7, 1280.0), s.y * 0.6 + 20.0), Vector2(2, 2)), Color(0.8, 0.85, 1.0, 0.3 + 0.5 * twinkle))
	# Sternbild über der Düne
	var bild: Array[Vector2] = [Vector2(520, 50), Vector2(580, 30), Vector2(640, 60), Vector2(700, 36), Vector2(760, 64)]
	for k in bild.size() - 1:
		b.draw_line(bild[k], bild[k + 1], Color(0.8, 0.85, 1.0, 0.35), 1.0)
	for p in bild:
		b.draw_circle(p, 3.0, Color(1, 1, 0.95))
	_duenen(b, 200, 50, Color("3a3c6a"), 1.5, 0.3)
	_duenen(b, 236, 26, Color("4a4e80"), 2.5, 1.4)
	_boden(b, Color("4a4e80"), Color("6a6ea0"), 246.0)
	for i in b._floor_pick.size():
		var p := _punkt(i, 256.0)
		if i % 3 == 0:
			b.draw_line(p, p + Vector2(30, 0), Color("5a5e90"), 2.0)
		elif i % 19 == 0:
			b.draw_rect(Rect2(p.x, p.y, 3, 3), Color(0.9, 0.9, 1.0, 0.5 + 0.5 * sin(t * 3.0 + i)))


## Glutoase (Stadt): Terrassen aus Sandstein mit bunten Sonnensegeln, Palmen, Pflaster aus hellen Platten.
static func _stadt(b: Backdrop) -> void:
	var t := b._time
	_himmel(b, Color("6aa4d4"), Color("f6d6a0"))
	var stein: Array[Color] = [Color("d8b48a"), Color("c8a07a"), Color("e2c296")]
	var segel: Array[Color] = [Color("c84a3a"), Color("e09a3a"), Color("3a9a9a"), Color("b85a8a")]
	# Drei Terrassen übereinander, die oberste am weitesten hinten
	for stufe in 3:
		var y := 80.0 + stufe * 40.0
		for i in 8:
			var x := float(i) * 170.0 - 40.0 + stufe * 50.0
			var h := 44.0 + float((i * 13 + stufe * 7) % 18)
			var farbe := stein[(i + stufe) % stein.size()].darkened(0.18 - stufe * 0.06)
			b.draw_rect(Rect2(x, y - h + 40, 130, h), farbe)
			b.draw_rect(Rect2(x, y - h + 36, 130, 6), farbe.lightened(0.12))
			b.draw_rect(Rect2(x + 22, y - h + 54, 16, 22), Color("5a3a2a"))
			b.draw_rect(Rect2(x + 84, y - h + 54, 16, 16), Color("5a3a2a"))
			if (i + stufe) % 2 == 0:
				var s := segel[(i + stufe) % segel.size()]
				b.draw_colored_polygon(PackedVector2Array([Vector2(x + 10, y - h + 44), Vector2(x + 120, y - h + 44), Vector2(x + 110, y - h + 56), Vector2(x + 20, y - h + 56)]), s)
	_palme(b, Vector2(120, 196), 130.0, 16.0, t)
	_palme(b, Vector2(1160, 196), 140.0, -16.0, t)
	# Pflaster aus hellen Platten
	for row in 33:
		var y := 186.0 + row * 16.0
		var farbe := Color("b89a74").lerp(Color("dcc29a"), float(row) / 32.0)
		b.draw_rect(Rect2(0, y, 1280, 17), farbe)
		var versatz := 0.0 if row % 2 == 0 else 32.0
		for x in range(0, 1320, 64):
			b.draw_rect(Rect2(x + versatz, y, 2, 16), farbe.darkened(0.18))
	# Laternen an Pfosten
	for x: float in [180.0, 640.0, 1100.0]:
		b.draw_rect(Rect2(x - 3, 150, 6, 40), Color("4a3426"))
		b.draw_rect(Rect2(x - 8, 136, 16, 16), Color("ffc070"))


## Hadraks Schmiede: Holzbalken, Steinwand mit Werkzeug, große Esse in der Mitte, Amboss und Wassertrog.
static func _schmiede(b: Backdrop) -> void:
	var t := b._time
	_himmel(b, Color("140c08"), Color("3a2418"), 190.0)
	for row in 4:
		for i in 14:
			var x := float(i) * 96.0 - (48.0 if row % 2 else 0.0)
			b.draw_rect(Rect2(x + 2, 20 + row * 42.0, 92, 38), Color("4a3226") if (i + row) % 3 else Color("54382a"))
	# Balken
	b.draw_rect(Rect2(0, 0, 1280, 16), Color("3a2618"))
	for x in range(80, 1280, 300):
		b.draw_rect(Rect2(x, 0, 18, 190), Color("3a2618"))
	# Werkzeug an der Wand
	for i in 6:
		var x := 200.0 + i * 36.0 + (i / 3) * 600.0
		b.draw_line(Vector2(x, 70), Vector2(x, 120), Color("6a4c34"), 4.0)
		if i % 2 == 0:
			b.draw_rect(Rect2(x - 10, 64, 20, 10), Color("6a6a70"))
		else:
			b.draw_rect(Rect2(x - 3, 116, 6, 14), Color("7a7a80"))
	# Große Esse in der Mitte
	var glut := 0.8 + 0.2 * sin(t * 3.0)
	b.draw_rect(Rect2(540, 40, 200, 150), Color("4a3a32"))
	b.draw_rect(Rect2(600, 0, 80, 44), Color("3a2c26"))
	b.draw_rect(Rect2(570, 110, 140, 64), Color(1.0, 0.45, 0.12).lerp(Color(1.0, 0.85, 0.4), 0.35 * glut))
	b.draw_rect(Rect2(570, 100, 140, 10), Color("1a100c"))
	# Boden aus Stein
	_boden(b, Color("2e2018"), Color("4e3a2c"), 190.0)
	for i in b._floor_pick.size():
		var p := _punkt(i, 204.0)
		if i % 5 == 0:
			b.draw_rect(Rect2(p.x, p.y, 12, 6), Color("3a2a20"))
	# Amboss und Wassertrog hinter den Kämpfern
	var a := Vector2(360, 206)
	b.draw_rect(Rect2(a.x - 12, a.y - 24, 24, 24), Color("3a3a40"))
	b.draw_colored_polygon(PackedVector2Array([a + Vector2(-42, -36), a + Vector2(34, -36), a + Vector2(52, -28), a + Vector2(30, -22), a + Vector2(-30, -22)]), Color("55555e"))
	b.draw_rect(Rect2(880, 180, 90, 32), Color("5a4030"))
	b.draw_rect(Rect2(886, 184, 78, 8), Color("3a6a8a"))


## Glutgrat: rauchiger Himmel, Vulkan mit glühendem Krater, schwarze Felszacken, Basaltboden mit Glutrissen.
static func _glutgrat(b: Backdrop) -> void:
	var t := b._time
	_himmel(b, Color("2a1418"), Color("8a4a32"))
	# Vulkan rechts hinten mit Lavastreifen
	b.draw_colored_polygon(PackedVector2Array([Vector2(700, 186), Vector2(900, 50), Vector2(980, 50), Vector2(1200, 186)]), Color("3a2422"))
	b.draw_rect(Rect2(900, 44, 80, 10), Color(1.0, 0.5, 0.15))
	b.draw_polyline(PackedVector2Array([Vector2(930, 54), Vector2(920, 100), Vector2(950, 140), Vector2(935, 186)]), Color(1.0, 0.45, 0.12, 0.9), 5.0)
	# Rauchwolken steigen aus dem Krater
	for i in 6:
		var steigt := fposmod(t * 10.0 + i * 20.0, 120.0)
		b.draw_circle(Vector2(940 + sin(t * 0.5 + i) * 14.0 + steigt * 0.4, 40 - steigt), 18.0 + steigt * 0.2, Color(0.25, 0.2, 0.2, 0.4 * (1.0 - steigt / 120.0)))
	# Felszacken
	for i in 9:
		var x := float((i * 151) % 1320) - 40.0
		var h := 50.0 + float((i * 37) % 60)
		b.draw_colored_polygon(PackedVector2Array([Vector2(x, 196), Vector2(x + 24, 196 - h), Vector2(x + 40, 196 - h * 0.7), Vector2(x + 70, 196)]), Color("1e1416") if i % 2 == 0 else Color("2a1c1c"))
	_boden(b, Color("2a1e1c"), Color("463230"), 196.0)
	for i in b._floor_pick.size():
		var p := _punkt(i, 210.0)
		if i % 6 == 0:
			b.draw_line(p, p + Vector2(28, 7), Color(1.0, 0.4, 0.1, 0.5 + 0.3 * sin(t * 2.0 + i)), 2.0)
		elif i % 4 == 0:
			b.draw_colored_polygon(PackedVector2Array([p, p + Vector2(8, -10), p + Vector2(16, 0)]), Color("1a1012"))
