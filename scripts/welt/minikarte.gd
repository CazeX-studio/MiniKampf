class_name Minikarte
extends Control
## Kleine Karte oben rechts (A11, Alpha-Punkt 41): die Karte, auf der man gerade ist, von oben. Wege hell, Wald und
## Häuser dunkel, Ausgänge gold. Darauf: du (weißer Punkt), andere Spieler (blau), Leute mit Auftrag („!“ gold,
## „?“ hell, Nebenaufträge blau) und das Ziel des Wegweisers (pulsierende Raute). Einklappbar mit dem Knopf darüber,
## Antippen der Karte öffnet die große Karte (Taste M).

signal grosse_karte_gewuenscht

const BREITE := 200.0
const HOEHE := 112.0
const KOPF := 26.0
## So oft (Sekunden) werden die Zeichen neu gesucht; die Punkte selbst laufen jedes Bild mit
const NEU_SUCHEN := 0.5

## Farben je Boden (WorldState.Tile)
const BODEN := {
	WorldState.Tile.GRASS: Color("5f8f45"),
	WorldState.Tile.ROAD: Color("c8ad7a"),
	WorldState.Tile.PLAZA: Color("bdb3a0"),
	WorldState.Tile.OVERGROWN: Color("4a7a3a"),
	WorldState.Tile.FOREST: Color("2f5a2c"),
	WorldState.Tile.PLANKS: Color("9a6a3e"),
	WorldState.Tile.BRIDGE: Color("a5774a"),
	WorldState.Tile.CANOPY: Color("6b7f3a"),
	WorldState.Tile.CAVE: Color("5a5066"),
	WorldState.Tile.ROCK: Color("7a6f66"),
}

var state: WorldState
var spieler_id := ""
## Ziel des Wegweisers auf dieser Karte (-1, -1 = keins)
var ziel := Vector2i(-1, -1)
var offen := true

var _karte_id := ""
var _bild: ImageTexture
var _zeichen: Array[Dictionary] = []
var _seit := 99.0
var _zeit := 0.0
var _knopf: Button


func _ready() -> void:
	size = Vector2(BREITE, KOPF + HOEHE + 8.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_knopf = Button.new()
	_knopf.size = Vector2(BREITE, KOPF)
	_knopf.add_theme_font_size_override("font_size", 13)
	_knopf.clip_text = true
	_knopf.focus_mode = Control.FOCUS_NONE
	_knopf.tooltip_text = "Kleine Karte ein- und ausklappen"
	_knopf.pressed.connect(func() -> void:
		offen = not offen
		_beschriften()
		queue_redraw())
	add_child(_knopf)
	_beschriften()


func _beschriften() -> void:
	var titel := state.get_map(_karte_id).title if state != null and _karte_id != "" else "Karte"
	_knopf.text = ("▾ " if offen else "▸ ") + titel


## Bereich der eigentlichen Karte (im eigenen Koordinatensystem)
func _feld() -> Rect2:
	return Rect2(0, KOPF + 4.0, BREITE, HOEHE)


func _gui_input(event: InputEvent) -> void:
	# Antippen der Karte öffnet die große Karte
	var tipp: bool = (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
			or (event is InputEventScreenTouch and event.pressed)
	if tipp and offen and _feld().has_point(event.position):
		grosse_karte_gewuenscht.emit()
		accept_event()


func _has_point(punkt: Vector2) -> bool:
	# Nur die Karte selbst fängt Klicks ab (sonst liefe man beim Tippen darauf los); eingeklappt nur der Knopf
	return offen and _feld().has_point(punkt)


func _process(delta: float) -> void:
	if state == null:
		return
	var p: PlayerState = state.players.get(spieler_id)
	if p == null:
		return
	_zeit += delta
	if p.map != _karte_id:
		_karte_id = p.map
		_bild = bild_fuer(state.get_map(_karte_id))
		_seit = 99.0
		_beschriften()
	_seit += delta
	if _seit >= NEU_SUCHEN:
		_seit = 0.0
		_zeichen = zeichen_fuer(state, p)
	if offen:
		queue_redraw()


## Mittlere Farbe je Baukasten-Boden (aus seinem ersten Bild), einmal ausgerechnet
static var _baukasten_farben := {}


static func _baukasten_farbe(zeichen: String) -> Variant:
	if not _baukasten_farben.has(zeichen):
		var def: Dictionary = GameData.get_file("baukasten_teile").get("boden", {}).get(zeichen, {})
		var bilder: Array = def.get("bilder", [])
		var farbe: Variant = null
		var pfad := "res://assets/baukasten/" + str(bilder[0]) if not bilder.is_empty() else ""
		if pfad != "" and ResourceLoader.exists(pfad):
			var img := (load(pfad) as Texture2D).get_image()
			if img != null:
				if img.is_compressed():
					img.decompress()
				img.resize(1, 1, Image.INTERPOLATE_BILINEAR)
				var c := img.get_pixel(0, 0)
				farbe = Color(c.r, c.g, c.b)
		_baukasten_farben[zeichen] = farbe
	return _baukasten_farben[zeichen]


## Die Karte von oben als kleines Bild: ein Bildpunkt je Feld. Karten aus dem Baukasten nehmen die Farbe ihres
## gemalten Bodens, die anderen eine Farbe je Bodenart.
static func bild_fuer(m: WorldMap) -> ImageTexture:
	var img := Image.create(m.size.x, m.size.y, false, Image.FORMAT_RGBA8)
	var zeilen: Array = m.baukasten.get("boden", [])
	for y in m.size.y:
		for x in m.size.x:
			var feld := Vector2i(x, y)
			var farbe: Color = BODEN.get(m.tile_at(feld), Color("5f8f45"))
			if y < zeilen.size() and x < str(zeilen[y]).length():
				var bk: Variant = _baukasten_farbe(str(zeilen[y])[x])
				if bk != null:
					farbe = bk
			if not m.is_walkable(feld):
				farbe = farbe.darkened(0.55)
			img.set_pixel(x, y, farbe)
	for e: Dictionary in m.exits:
		var r: Rect2i = e.rect
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				if m.in_bounds(Vector2i(x, y)):
					img.set_pixel(x, y, Color("f2c14e"))
	return ImageTexture.create_from_image(img)


## Zeichen auf der Karte: Leute mit Auftrag und andere Spieler. [{feld, farbe, art}]
static func zeichen_fuer(w: WorldState, p: PlayerState) -> Array[Dictionary]:
	var liste: Array[Dictionary] = []
	for id: String in w.npcs:
		var npc: Dictionary = w.npcs[id]
		if npc.map != p.map:
			continue
		var info: Array = w.npc_marker_info(p, id)
		if str(info[0]) == "":
			continue
		var farbe := Color("7fc8ff") if info[1] else (Color("f2c14e") if info[0] == "!" else Color("fff3b0"))
		liste.append({feld = Vector2(npc.cell), farbe = farbe, art = str(info[0])})
	for id: String in w.players:
		var anderer: PlayerState = w.players[id]
		if anderer != p and anderer.map == p.map:
			liste.append({feld = anderer.pos, farbe = Color("6aa8ff"), art = "spieler"})
	return liste


func _draw() -> void:
	if not offen or _bild == null:
		return
	var feld := _feld()
	draw_rect(feld.grow(3.0), Color(0.05, 0.04, 0.03, 0.85))
	# Die Karte als Raute wie die Welt (schräg von oben, BaukastenBoden.cell_to_screen), passend in das Feld
	var m := state.get_map(_karte_id)
	var summe := float(m.size.x + m.size.y)
	var mass := minf(feld.size.x / summe, feld.size.y * 2.0 / summe)
	var ecke := feld.position + Vector2((feld.size.x - summe * mass) * 0.5 + m.size.y * mass,
			(feld.size.y - summe * mass * 0.5) * 0.5)
	var schraeg := Transform2D(Vector2(mass, mass * 0.5), Vector2(-mass, mass * 0.5), ecke)
	draw_set_transform_matrix(schraeg)
	draw_texture_rect(_bild, Rect2(Vector2.ZERO, Vector2(m.size)), false)
	draw_rect(Rect2(Vector2.ZERO, Vector2(m.size)), Color("6b5a3a"), false, 1.0 / mass)
	draw_set_transform_matrix(Transform2D.IDENTITY)
	var ort := func(zelle: Vector2) -> Vector2: return schraeg * (zelle + Vector2(0.5, 0.5))
	for z in _zeichen:
		var punkt: Vector2 = ort.call(z.feld)
		if z.art == "spieler":
			draw_circle(punkt, 3.5, z.farbe)
		else:
			draw_circle(punkt, 4.5, Color.BLACK)
			draw_circle(punkt, 3.5, z.farbe)
	# Ziel des Wegweisers
	if ziel != Vector2i(-1, -1):
		var punkt: Vector2 = ort.call(Vector2(ziel))
		var r := 6.0 + 1.5 * sin(_zeit * 5.0)
		var raute := PackedVector2Array([punkt + Vector2(0, -r), punkt + Vector2(r, 0), punkt + Vector2(0, r), punkt + Vector2(-r, 0)])
		draw_colored_polygon(raute, Color("ff7a3d"))
		draw_polyline(raute + PackedVector2Array([raute[0]]), Color.BLACK, 1.5)
	# Du
	var p: PlayerState = state.players.get(spieler_id)
	if p != null:
		var ich: Vector2 = ort.call(p.pos)
		draw_circle(ich, 5.0, Color.BLACK)
		draw_circle(ich, 3.8, Color.WHITE)
