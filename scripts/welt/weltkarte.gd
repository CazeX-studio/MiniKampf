class_name Weltkarte
extends Control
## Große Karte auf Taste M (A11, Alpha-Punkt 42): alle Gegenden als Schilder mit ihrem Namen, verbunden durch die Wege
## (Ausgänge, Seilaufzug, Bergpfad, Dungeon-Eingänge). Wo man war, steht der Name; Gegenden gleich nebenan zeigen „???“,
## der Rest bleibt verborgen. „Du bist hier“ pulsiert, das Ziel der Geschichte trägt einen Stern.
## Lage und Region jeder Karte stehen in data/weltkarte.json.

signal geschlossen

const GROESSE := Vector2(1280, 720)
const SCHILD := Vector2(170, 40)

var state: WorldState
var spieler_id := ""

var _zeit := 0.0
## Karte -> {pos, region, art}
var _karten := {}
## [[a, b], ...] Wege zwischen zwei Karten, jeder nur einmal
var _wege: Array = []
var _knopf: Button


func _ready() -> void:
	size = GROESSE
	mouse_filter = Control.MOUSE_FILTER_STOP
	var daten := GameData.get_file("weltkarte")
	_karten = daten.get("karten", {})
	_knopf = Button.new()
	_knopf.text = "Schließen (M)"
	_knopf.size = Vector2(150, 44)
	_knopf.position = Vector2(GROESSE.x - 170, 14)
	_knopf.add_theme_font_size_override("font_size", 16)
	_knopf.focus_mode = Control.FOCUS_NONE
	_knopf.pressed.connect(schliessen)
	add_child(_knopf)


func oeffnen() -> void:
	_wege = wege_fuer(state, GameData.get_file("weltkarte"))
	visible = true
	queue_redraw()


func schliessen() -> void:
	visible = false
	geschlossen.emit()


func _process(delta: float) -> void:
	if visible:
		_zeit += delta
		queue_redraw()


## Alle Wege zwischen den Karten der Weltkarte (ohne Bedingungen: die Karte zeigt, wo es langgeht, nicht ob es offen ist).
static func wege_fuer(w: WorldState, daten: Dictionary) -> Array:
	var karten: Dictionary = daten.get("karten", {})
	var gesehen := {}
	var liste := []
	var p: PlayerState = null
	for id: String in w.players:
		p = w.players[id]
		break
	var paare: Array = daten.get("zusatz_wege", []).duplicate()
	for id: String in karten:
		if not w.maps.has(id):
			continue
		for link: Array in w._links(p, id, false):
			paare.append([id, str(link[0])])
	for paar: Array in paare:
		var a := str(paar[0])
		var b := str(paar[1])
		var schluessel := "%s|%s" % ([a, b] if a < b else [b, a])
		if a != b and karten.has(a) and karten.has(b) and not gesehen.has(schluessel):
			gesehen[schluessel] = true
			liste.append([a, b])
	return liste


## Was der Spieler von einer Karte weiß: "hier", "besucht", "nachbar" (nebenan, Name unbekannt) oder "" (verborgen).
static func bekannt(p: PlayerState, karte: String, wege: Array) -> String:
	if p.map == karte:
		return "hier"
	if p.progress.flags.get("besucht:" + karte, false) or karte == WorldState.KREUZWEG:
		return "besucht"
	for weg: Array in wege:
		for i in 2:
			var anderer: String = weg[1 - i]
			if weg[i] == karte and (p.map == anderer or p.progress.flags.get("besucht:" + anderer, false) or anderer == WorldState.KREUZWEG):
				return "nachbar"
	return ""


func _pos(karte: String) -> Vector2:
	var p: Array = _karten[karte].pos
	return Vector2(p[0], p[1])


func _draw() -> void:
	var p: PlayerState = state.players.get(spieler_id) if state != null else null
	if p == null:
		return
	# Pergament mit dunklem Rand
	draw_rect(Rect2(Vector2.ZERO, GROESSE), Color(0.02, 0.02, 0.03, 0.75))
	draw_rect(Rect2(Vector2.ZERO, Vector2(GROESSE.x, 66)), Color(0.04, 0.03, 0.03, 0.97))
	var blatt := Rect2(Vector2(30, 70), GROESSE - Vector2(60, 90))
	draw_rect(blatt, Color("d9c49a"))
	draw_rect(blatt, Color("6b4a2a"), false, 6.0)
	draw_rect(blatt.grow(-10), Color("a4875a"), false, 2.0)
	var schrift := ThemeDB.fallback_font
	draw_string(schrift, Vector2(50, 52), "Karte von Asterfall", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("f2c14e"))
	draw_string(schrift, Vector2(330, 52), "Wege zwischen den Gegenden · ??? = noch nicht betreten", HORIZONTAL_ALIGNMENT_LEFT, -1, 15,
			Color("d8d0c0"))
	# Regionen als große, blasse Namen im Hintergrund
	var regionen: Dictionary = GameData.get_file("weltkarte").get("regionen", {})
	for name: String in regionen:
		var r: Dictionary = regionen[name]
		draw_string(schrift, Vector2(r.pos[0], r.pos[1]) - Vector2(150, 0), name, HORIZONTAL_ALIGNMENT_CENTER, 300, 46,
				Color(Color(str(r.farbe)).darkened(0.35), 0.35))
	var stand := {}
	for karte: String in _karten:
		stand[karte] = bekannt(p, karte, _wege)
	# Wege: gestrichelte Linien, zu Verborgenem gar nicht
	for weg: Array in _wege:
		if stand[weg[0]] == "" or stand[weg[1]] == "":
			continue
		var unbekannt: bool = stand[weg[0]] == "nachbar" or stand[weg[1]] == "nachbar"
		_strichlinie(_pos(weg[0]), _pos(weg[1]), Color("6b4a2a", 0.45 if unbekannt else 0.9), 4.0)
	# Ziel der Geschichte
	var ziel_karte := str(state.objective_place(p).get("karte", ""))
	for karte: String in _karten:
		if stand[karte] != "":
			_schild(karte, stand[karte], karte == ziel_karte)


func _strichlinie(von: Vector2, nach: Vector2, farbe: Color, dicke: float) -> void:
	var laenge := von.distance_to(nach)
	var richtung := (nach - von) / laenge
	var t := 0.0
	while t < laenge:
		draw_line(von + richtung * t, von + richtung * minf(t + 14.0, laenge), farbe, dicke)
		t += 24.0


func _schild(karte: String, wissen: String, ist_ziel: bool) -> void:
	var mitte := _pos(karte)
	var info: Dictionary = _karten[karte]
	var region: Dictionary = GameData.get_file("weltkarte").get("regionen", {}).get(str(info.region), {})
	var farbe := Color(str(region.get("farbe", "c8b080")))
	var art := str(info.get("art", "gebiet"))
	var schrift := ThemeDB.fallback_font
	var titel := state.get_map(karte).title if state.maps.has(karte) else karte
	# Breit genug für lange Namen („Waldboden unter Wipfelheim“), nur bekannte Namen zählen
	var breite := SCHILD.x
	if wissen != "nachbar":
		breite = maxf(breite, schrift.get_string_size(titel, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x + 24.0)
	var rahmen := Rect2(mitte - Vector2(breite, SCHILD.y) * 0.5, Vector2(breite, SCHILD.y))
	if art == "stadt":
		rahmen = rahmen.grow_individual(10, 4, 10, 4)
	if wissen == "nachbar":
		draw_rect(rahmen, Color("bfa982"))
		draw_rect(rahmen, Color("6b4a2a", 0.6), false, 2.0)
		draw_string(schrift, rahmen.position + Vector2(0, 27), "???", HORIZONTAL_ALIGNMENT_CENTER, rahmen.size.x, 18, Color("6b4a2a"))
		return
	var grund := Color("2a2018") if art == "dungeon" else farbe.darkened(0.55)
	draw_rect(rahmen, grund)
	draw_rect(rahmen, farbe, false, 3.0 if art == "stadt" else 2.0)
	var groesse := 16
	draw_string(schrift, rahmen.position + Vector2(0, rahmen.size.y * 0.5 + groesse * 0.35), titel, HORIZONTAL_ALIGNMENT_CENTER,
			rahmen.size.x, groesse, Color("fff3d8"))
	if art == "dungeon":
		draw_string(schrift, rahmen.position + Vector2(0, -6), "Dungeon", HORIZONTAL_ALIGNMENT_CENTER, rahmen.size.x, 12, Color("5a3a2a"))
	if ist_ziel:
		_stern(rahmen.position + Vector2(rahmen.size.x, 0), 14.0 + 2.0 * sin(_zeit * 4.0))
	if wissen == "hier":
		var puls := 0.5 + 0.5 * sin(_zeit * 4.0)
		draw_rect(rahmen.grow(4.0 + 4.0 * puls), Color(1, 1, 1, 0.9 - 0.5 * puls), false, 3.0)
		draw_string(schrift, rahmen.position + Vector2(0, rahmen.size.y + 20), "Du bist hier", HORIZONTAL_ALIGNMENT_CENTER,
				rahmen.size.x, 15, Color("3a2a18"))


func _stern(mitte: Vector2, r: float) -> void:
	var punkte := PackedVector2Array()
	for i in 10:
		punkte.append(mitte + Vector2.from_angle(-PI * 0.5 + i * PI / 5.0) * (r if i % 2 == 0 else r * 0.45))
	draw_colored_polygon(punkte, Color("ff7a3d"))
	draw_polyline(punkte + PackedVector2Array([punkte[0]]), Color("3a1a08"), 2.0)
