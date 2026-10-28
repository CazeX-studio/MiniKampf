extends Node2D
## Baukasten-Testfeld: ein kleiner Marktplatz in Rautenansicht, gebaut aus Einzelbildern statt aus Code-Zeichnungen.
## Boden und Gegenstände kommen aus assets/baukasten/, welches Teil wie groß ist und wo es steht, steht in
## data/baukasten_teile.json und data/baukasten_testfeld.json. Neue Bilder einfach mit gleichem Namen austauschen
## (Regeln in data/BAUKASTEN.md). Hier wird nur gelaufen und angeschaut, es gibt noch keine Figuren oder Aufträge.

const TILE_W := 64.0
const TILE_H := 32.0
## Die Bilder haben schon Spielgröße (ein Feld = 64 x 32 Pixel). Ein Teil kann mit "massstab" vergrößert werden
## (die alten Platzhalter sind halb so groß gezeichnet und haben massstab 2).
const MASSSTAB := 1.0
const WALK_SPEED := 5.5
const NIGHT_COLOR := Color(0.45, 0.5, 0.78)
## Fläche, die die Spielfigur in voller Größe auf dem Bildschirm ungefähr bedeckt (über ihrem Fußpunkt)
const PLAYER_RECT := Rect2(-24, -128, 48, 130)
## Größe der Spielfigur im Testfeld (Tasten + und -), um den Maßstab zur Welt auszuprobieren
const FIGUR_GROESSEN: Array[float] = [0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
## Stand der Geschichte (Taste K): Teile mit "nur_stufe" erscheinen nur in diesen Stufen (Splitterkreis, Krater …)
const STUFEN: Array[String] = ["vor dem Fest", "Nacht des Sternenfalls", "Wochen danach"]
## So durchsichtig werden Dinge, hinter denen die Figur steht
const FADE_ALPHA := 0.45
const ASSET_PATH := "res://assets/baukasten/"
## Übergänge zwischen Böden: Der Boden mit mehr "vorrang" (data/baukasten_teile.json) ragt mit einem unregelmäßigen,
## weichen Rand ins Nachbarfeld (Gras wächst über das Pflaster, am Wasser entsteht ein Ufer).
## Kanten (gerade Nachbarn) und Ecken (schräge Nachbarn), in Feldern
const KANTEN: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const ECKEN: Array[Vector2i] = [Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]
## Wie weit der Rand ins Feld ragt (Anteil eines Feldes), wie stark er ausfranst und wie weich er ausläuft
const RAND_WEITE := 0.3
const RAND_FRANSEN := 0.2
const RAND_WEICH := 0.07
## Am Ufer liegt im Wasser ein dunkler Schatten etwas weiter als der Rand
const UFER_WEITE := 0.5
const UFER_SCHATTEN := Color(0.0, 0.03, 0.08, 0.45)

var _teile: Dictionary
var _size := Vector2i.ZERO
var _rows: PackedStringArray
var _blocked := {}
## Gesperrte Felder von Teilen, die es nur in der gerade gezeigten Stufe der Geschichte gibt
var _stufe_blocked := {}
var _stufe := 0
var _start := Vector2i.ZERO
## Ein Eintrag pro Gegenstand: {name, node, rect (Felder), bild (Bildschirm-Fläche), flach}
var _objekte: Array[Dictionary] = []
var _lights: Array[Licht] = []
## Position der Spielfigur in Feldern (Kommazahlen, Mitte eines Feldes = x,5)
var _pos := Vector2.ZERO
var _path: Array[Vector2] = []
var _night := true
var _grid := false
var _figur_stufe := 3
var _hint: Label

var _ground: Node2D
var _flat: Node2D
var _sorted: Node2D
var _grid_node: Node2D
var _holder: Node2D
var _player: WorldCharacter
var _camera: Camera2D
var _modulate: CanvasModulate
var _ground_colors := {}
## Fertige Randbilder für Übergänge: "Bild|Richtung|Weite" -> ImageTexture
var _rand_bilder := {}


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("1b2418"))
	_teile = _load_json("baukasten_teile")
	var feld := _load_json("baukasten_testfeld")
	_rows = PackedStringArray(feld.get("boden", []))
	_size = Vector2i(_rows[0].length() if _rows.size() > 0 else 0, _rows.size())
	var start: Array = feld.get("start", [0, 0])
	_start = Vector2i(start[0], start[1])
	_pos = Vector2(_start) + Vector2(0.5, 0.5)

	_modulate = CanvasModulate.new()
	add_child(_modulate)
	_ground = Node2D.new()
	_ground.z_index = -10
	_ground.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_ground.draw.connect(_draw_ground)
	add_child(_ground)
	# Flache Dinge (Brücke, Blumen, Splitterkreis) liegen auf dem Boden, Figuren laufen darüber
	_flat = Node2D.new()
	_flat.z_index = -5
	add_child(_flat)
	# Alles, was steht, wird nach Tiefe sortiert (wer weiter unten steht, ist vorne)
	_sorted = Node2D.new()
	_sorted.y_sort_enabled = true
	add_child(_sorted)
	for y in _size.y:
		for x in _size.x:
			if not _ground_def(Vector2i(x, y)).get("begehbar", true):
				_blocked[Vector2i(x, y)] = true
	for o: Dictionary in feld.get("objekte", []):
		_add_object(o)
	_check_overlaps()

	_holder = Node2D.new()
	_sorted.add_child(_holder)
	_player = WorldCharacter.new()
	_player.setup(FigurWahl.gewaehlt(), "Du")
	_player.richtungen = true
	_holder.add_child(_player)
	_set_figur(_figur_stufe)

	_grid_node = Node2D.new()
	_grid_node.z_index = 50
	_grid_node.draw.connect(_draw_grid)
	add_child(_grid_node)

	_camera = Camera2D.new()
	_camera.zoom = Vector2(1.25, 1.25)
	_camera.position_smoothing_enabled = true
	add_child(_camera)
	_build_hud()
	_set_figur(_figur_stufe)
	set_stufe(0)
	_set_night(true)
	_update_player()
	_camera.position = cell_to_screen(_pos)
	_camera.reset_smoothing()


static func _load_json(file_name: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/%s.json" % file_name))
	if parsed is Dictionary:
		return parsed
	push_error("Datendatei kaputt oder fehlt: data/%s.json" % file_name)
	return {}


func cell_to_screen(c: Vector2) -> Vector2:
	return Vector2((c.x - c.y) * TILE_W * 0.5, (c.x + c.y) * TILE_H * 0.5)


func screen_to_cell(p: Vector2) -> Vector2i:
	var x := (p.x / (TILE_W * 0.5) + p.y / (TILE_H * 0.5)) * 0.5
	var y := (p.y / (TILE_H * 0.5) - p.x / (TILE_W * 0.5)) * 0.5
	return Vector2i(floori(x), floori(y))


func _ground_def(cell: Vector2i) -> Dictionary:
	if cell.x < 0 or cell.y < 0 or cell.x >= _size.x or cell.y >= _size.y:
		return {}
	return _teile.boden.get(_rows[cell.y][cell.x], {})


func is_walkable(cell: Vector2i) -> bool:
	return not _ground_def(cell).is_empty() and not _blocked.has(cell) and not _stufe_blocked.has(cell)


# --- Aufbau ---------------------------------------------------------------------

func _add_object(o: Dictionary) -> void:
	var teil: String = o.get("teil", "")
	if not _teile.objekte.has(teil):
		push_warning("Baukasten: unbekanntes Teil '%s'" % teil)
		return
	var d: Dictionary = _teile.objekte[teil]
	var flaeche: Array = d.get("flaeche", [1, 1])
	var rect := Rect2i(Vector2i(o.feld[0], o.feld[1]), Vector2i(flaeche[0], flaeche[1]))
	if o.get("gespiegelt", false):
		rect.size = Vector2i(flaeche[1], flaeche[0])
	var tex: Texture2D = load(ASSET_PATH + d.bild)
	if tex == null:
		push_warning("Baukasten: Bild fehlt: %s" % d.bild)
		return
	var flach: bool = d.get("flach", false)
	var node := Node2D.new()
	# Sortierpunkt: die vorderste Ecke der Grundfläche
	node.position = cell_to_screen(Vector2(rect.end))
	var center := cell_to_screen(Vector2(rect.position) + Vector2(rect.size) * 0.5) - node.position
	var massstab: float = d.get("massstab", MASSSTAB)
	var gespiegelt: bool = o.get("gespiegelt", false)
	# Der Fußpunkt (fuss = Pixel im Bild, sonst unten in der Mitte, fuss_y Pixel über dem Rand) steht auf der Mitte der Grundfläche
	var fuss := Vector2(tex.get_width() * 0.5, tex.get_height() - float(d.get("fuss_y", (rect.size.x + rect.size.y) * 8.0 / massstab)))
	if d.has("fuss"):
		fuss = Vector2(d.fuss[0], d.fuss[1])
	if gespiegelt:
		# Gespiegelt steht das Teil quer (Breite und Tiefe tauschen), z. B. ein Tor an einer anderen Straße
		fuss.x = tex.get_width() - fuss.x
	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.centered = false
	sprite.flip_h = gespiegelt
	sprite.scale = Vector2(massstab, massstab)
	# Pixel-Platzhalter bleiben scharf, die gemalten Bilder werden weich verkleinert
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if massstab >= 2.0 else CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.position = center - fuss * massstab
	node.add_child(sprite)
	var lichter: Array = d.get("lichter", []).duplicate()
	if d.has("licht"):
		lichter.append({art = d.licht.art, hoehe = d.licht.get("hoehe", 0)})
	for l: Dictionary in lichter:
		var licht := Licht.erzeugen(l.art)
		if l.has("bild"):
			# Licht an einer Stelle im Bild (z. B. Laterne an der Hauswand)
			var px := Vector2(l.bild[0], l.bild[1])
			if gespiegelt:
				px.x = tex.get_width() - px.x
			licht.position = sprite.position + px * massstab
		else:
			licht.position = center + Vector2(0, -float(l.get("hoehe", 0)))
		node.add_child(licht)
		_lights.append(licht)
	(_flat if flach else _sorted).add_child(node)
	var stufen: Array = o.get("nur_stufe", [])
	var zellen: Array[Vector2i] = []
	if d.get("begehbar", false):
		# Brücke und Ähnliches: darauf kann man laufen, auch wenn darunter Wasser ist
		for y in rect.size.y:
			for x in rect.size.x:
				_blocked.erase(rect.position + Vector2i(x, y))
	elif d.get("blockiert", true):
		var frei: Array = d.get("frei", [])
		for y in rect.size.y:
			for x in rect.size.x:
				# Bei gespiegelten Teilen sind die freien Felder ebenfalls getauscht
				var f := [y, x] if o.get("gespiegelt", false) else [x, y]
				if not f in frei and not [float(f[0]), float(f[1])] in frei:
					zellen.append(rect.position + Vector2i(x, y))
	if stufen.is_empty():
		for cell in zellen:
			_blocked[cell] = true
	_objekte.append({name = teil, node = node, rect = rect, flach = flach, stufen = stufen, zellen = zellen,
			bild = Rect2(node.position + sprite.position, tex.get_size() * massstab)})


## Warnt, wenn zwei stehende Dinge auf demselben Feld stehen oder etwas über den Rand ragt (Fehler in der Datei).
func _check_overlaps() -> void:
	var used := {}
	for o: Dictionary in _objekte:
		if o.flach or not o.stufen.is_empty():
			continue
		var rect: Rect2i = o.rect
		for y in range(rect.position.y, rect.end.y):
			for x in range(rect.position.x, rect.end.x):
				var cell := Vector2i(x, y)
				if _ground_def(cell).is_empty():
					push_warning("Baukasten: %s ragt über den Rand (%d, %d)" % [o.name, x, y])
				elif used.has(cell):
					push_warning("Baukasten: %s und %s stehen beide auf (%d, %d)" % [used[cell], o.name, x, y])
				used[cell] = o.name


func _draw_ground() -> void:
	for y in _size.y:
		for x in _size.x:
			var cell := Vector2i(x, y)
			var d := _ground_def(cell)
			var bilder: Array = d.get("bilder", [])
			if bilder.is_empty():
				continue
			# Abwechslung: jedes Feld nimmt immer dasselbe, aber zufällig wirkende Bild
			var tex: Texture2D = load(ASSET_PATH + bilder[(x * 7 + y * 13 + x * y) % bilder.size()])
			var top := cell_to_screen(Vector2(cell))
			# Darunter eine Raute in der Grundfarbe, damit zwischen den Pixel-Rauten keine Ritzen bleiben
			var diamond := PackedVector2Array([top, top + Vector2(TILE_W * 0.5, TILE_H * 0.5),
					top + Vector2(0, TILE_H), top + Vector2(-TILE_W * 0.5, TILE_H * 0.5)])
			_ground.draw_colored_polygon(diamond, _base_color(tex))
			_ground.draw_texture_rect(tex, Rect2(top - Vector2(TILE_W * 0.5, 0), Vector2(TILE_W, TILE_H)), false)
	# Danach die Übergänge (über allen Bodenfeldern, damit kein Nachbar sie wieder verdeckt)
	for y in _size.y:
		for x in _size.x:
			_draw_uebergaenge(Vector2i(x, y))


## Bild eines Bodenfeldes (jedes Feld nimmt immer dasselbe, aber zufällig wirkende Bild).
func _boden_bild(cell: Vector2i) -> Texture2D:
	var bilder: Array = _ground_def(cell).get("bilder", [])
	if bilder.is_empty():
		return null
	return load(ASSET_PATH + bilder[(cell.x * 7 + cell.y * 13 + cell.x * cell.y) % bilder.size()])


## Ränder der Nachbarn mit mehr Vorrang in dieses Feld malen.
func _draw_uebergaenge(cell: Vector2i) -> void:
	var mein := _ground_def(cell)
	if mein.is_empty():
		return
	var rang: int = mein.get("vorrang", 0)
	var rect := Rect2(cell_to_screen(Vector2(cell)) - Vector2(TILE_W * 0.5, 0), Vector2(TILE_W, TILE_H))
	var wasser: bool = not mein.get("begehbar", true)
	var richtungen: Array[Vector2i] = []
	for d in KANTEN:
		if _ground_def(cell + d).get("vorrang", 0) > rang:
			richtungen.append(d)
	for d in ECKEN:
		# Eine Ecke nur, wenn die beiden Kanten daneben nicht schon denselben Boden zeigen
		var art := _ground_char(cell + d)
		if _ground_def(cell + d).get("vorrang", 0) > rang and _ground_char(cell + Vector2i(d.x, 0)) != art \
				and _ground_char(cell + Vector2i(0, d.y)) != art:
			richtungen.append(d)
	# Erst der Uferschatten im Wasser, dann die Ränder
	if wasser:
		for d in richtungen:
			if _ground_def(cell + d).get("begehbar", true):
				_ground.draw_texture_rect(_rand(_boden_bild(cell + d), d, UFER_WEITE), rect, false, UFER_SCHATTEN)
	for d in richtungen:
		_ground.draw_texture_rect(_rand(_boden_bild(cell + d), d, RAND_WEITE), rect, false)


func _ground_char(cell: Vector2i) -> String:
	if cell.x < 0 or cell.y < 0 or cell.x >= _size.x or cell.y >= _size.y:
		return ""
	return _rows[cell.y][cell.x]


## Randbild: das Bodenbild des Nachbarn, das zur Kante (oder Ecke) d hin sichtbar ist und nach innen unregelmäßig ausläuft.
func _rand(tex: Texture2D, d: Vector2i, weite: float) -> Texture2D:
	var key := "%s|%d,%d|%.2f" % [tex.resource_path, d.x, d.y, weite]
	if _rand_bilder.has(key):
		return _rand_bilder[key]
	var img := tex.get_image()
	img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	for py in h:
		for px in w:
			# Lage im Feld: u entlang x (0 oben links … 1 unten rechts), v entlang y
			var sx := (px + 0.5) / w * TILE_W - TILE_W * 0.5
			var sy := (py + 0.5) / h * TILE_H
			var u := (sx / (TILE_W * 0.5) + sy / (TILE_H * 0.5)) * 0.5
			var v := (sy / (TILE_H * 0.5) - sx / (TILE_W * 0.5)) * 0.5
			var du := 1.0 - u if d.x > 0 else u
			var dv := 1.0 - v if d.y > 0 else v
			var abstand := du if d.y == 0 else (dv if d.x == 0 else Vector2(du, dv).length())
			var fransen := (_rauschen(px, py, d) - 0.5) * RAND_FRANSEN
			var a := clampf((weite + fransen - abstand) / RAND_WEICH, 0.0, 1.0)
			var c := img.get_pixel(px, py)
			c.a *= a
			img.set_pixel(px, py, c)
	var fertig := ImageTexture.create_from_image(img)
	_rand_bilder[key] = fertig
	return fertig


## Weiches, festes Rauschen (gleiches Feld = gleicher Rand), damit die Kante wie Grasbüschel oder Erdbrocken ausfranst.
func _rauschen(px: int, py: int, d: Vector2i) -> float:
	var gx := px / 4.0
	var gy := py / 2.0
	var x0 := floori(gx)
	var y0 := floori(gy)
	var fx := gx - x0
	var fy := gy - y0
	var a := lerpf(_zufall(x0, y0, d), _zufall(x0 + 1, y0, d), fx)
	var b := lerpf(_zufall(x0, y0 + 1, d), _zufall(x0 + 1, y0 + 1, d), fx)
	return lerpf(a, b, fy)


func _zufall(x: int, y: int, d: Vector2i) -> float:
	var n := x * 374761393 + y * 668265263 + (d.x + 2) * 2147483 + (d.y + 2) * 1442695
	n = (n ^ (n >> 13)) * 1274126177
	return float((n ^ (n >> 16)) & 0xffff) / 65535.0


func _base_color(tex: Texture2D) -> Color:
	if not _ground_colors.has(tex):
		var img := tex.get_image()
		_ground_colors[tex] = img.get_pixel(img.get_width() / 2, img.get_height() / 2) if img != null else Color.DIM_GRAY
	return _ground_colors[tex]


## Raster (Taste G): Felder, gesperrte Felder rot, Grundflächen gelb, die Figur grün. Zum Prüfen neuer Teile.
func _draw_grid() -> void:
	if not _grid:
		return
	for y in _size.y:
		for x in _size.x:
			var top := cell_to_screen(Vector2(x, y))
			var diamond := PackedVector2Array([top, top + Vector2(TILE_W * 0.5, TILE_H * 0.5),
					top + Vector2(0, TILE_H), top + Vector2(-TILE_W * 0.5, TILE_H * 0.5), top])
			if _blocked.has(Vector2i(x, y)) or _stufe_blocked.has(Vector2i(x, y)):
				_grid_node.draw_colored_polygon(diamond.slice(0, 4), Color(1, 0.2, 0.2, 0.25))
			_grid_node.draw_polyline(diamond, Color(1, 1, 1, 0.15), 1.0)
	for o: Dictionary in _objekte:
		if not (o.node as Node2D).visible:
			continue
		var r: Rect2i = o.rect
		_grid_node.draw_polyline(PackedVector2Array([cell_to_screen(Vector2(r.position)),
				cell_to_screen(Vector2(r.end.x, r.position.y)), cell_to_screen(Vector2(r.end)),
				cell_to_screen(Vector2(r.position.x, r.end.y)), cell_to_screen(Vector2(r.position))]), Color("ffd34d"), 2.0)
	var c := Vector2(Vector2i(_pos.floor()))
	_grid_node.draw_polyline(PackedVector2Array([cell_to_screen(c), cell_to_screen(c + Vector2(1, 0)),
			cell_to_screen(c + Vector2(1, 1)), cell_to_screen(c + Vector2(0, 1)), cell_to_screen(c)]), Color("6cff8a"), 2.0)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.theme = Combat.make_theme()
	root.size = Vector2(1280, 720)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)
	var hint := Label.new()
	_hint = hint
	hint.add_theme_font_size_override("font_size", 16)
	hint.add_theme_color_override("font_outline_color", Color.BLACK)
	hint.add_theme_constant_override("outline_size", 5)
	hint.position = Vector2(16, 12)
	root.add_child(hint)
	var buttons: Array = [["Tag/Nacht", func() -> void: _set_night(not _night)],
			["Raster", func() -> void: _toggle_grid()], ["Figur +", func() -> void: _set_figur(_figur_stufe + 1)],
			["Figur −", func() -> void: _set_figur(_figur_stufe - 1)], ["Geschichte", func() -> void: set_stufe(_stufe + 1)],
			["Editor", _go_menu]]
	for i in buttons.size():
		var b := Button.new()
		b.text = buttons[i][0]
		b.add_theme_font_size_override("font_size", 16)
		b.size = Vector2(130, 44)
		b.position = Vector2(1280 - 146, 12 + i * 52)
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect(buttons[i][1])
		root.add_child(b)


func _set_figur(stufe: int) -> void:
	_figur_stufe = clampi(stufe, 0, FIGUR_GROESSEN.size() - 1)
	var g := FIGUR_GROESSEN[_figur_stufe]
	_player.scale = Vector2(g, g)
	_update_hint()


func _update_hint() -> void:
	if _hint != null:
		_hint.text = ("Baukasten-Testfeld · Laufen: WASD, Pfeiltasten oder Klicken/Antippen\nN: Tag/Nacht · G: Raster · "
				+ "+/−: Figurgröße (jetzt %d %%) · K: Geschichte (jetzt: %s) · Esc: Editor") % [
				roundi(FIGUR_GROESSEN[_figur_stufe] * 100.0), STUFEN[_stufe]]


## Stand der Geschichte zeigen: Splitterkreis vor dem Fest, frischer Krater in der Festnacht (immer Nacht), später der umzäunte Krater.
func set_stufe(stufe: int) -> void:
	_stufe = posmod(stufe, STUFEN.size())
	_stufe_blocked.clear()
	for o: Dictionary in _objekte:
		if o.stufen.is_empty():
			continue
		var da: bool = _stufe in o.stufen or float(_stufe) in o.stufen
		(o.node as Node2D).visible = da
		if da:
			for cell: Vector2i in o.zellen:
				_stufe_blocked[cell] = true
	if _stufe == 1:
		_set_night(true)
	# Steht die Figur jetzt in etwas drin, geht sie zum Start
	if not is_walkable(Vector2i(_pos.floor())):
		place_player(_start)
	_update_hint()
	if _grid_node != null:
		_grid_node.queue_redraw()


func _set_night(on: bool) -> void:
	_night = on
	_modulate.color = NIGHT_COLOR if on else Color.WHITE
	for licht in _lights:
		licht.visible = on


func _toggle_grid() -> void:
	_grid = not _grid
	_grid_node.queue_redraw()


func _go_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/editor.tscn")


# --- Laufen ---------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_N:
				_set_night(not _night)
			KEY_G:
				_toggle_grid()
			KEY_K:
				set_stufe(_stufe + 1)
			KEY_ESCAPE:
				_go_menu()
			KEY_EQUAL, KEY_PLUS, KEY_KP_ADD:
				_set_figur(_figur_stufe + 1)
			KEY_MINUS, KEY_KP_SUBTRACT:
				_set_figur(_figur_stufe - 1)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		walk_to(screen_to_cell(get_global_mouse_position()))


## Kürzesten Weg zu einem Feld suchen und hinlaufen (Klicken oder Antippen).
func walk_to(target: Vector2i) -> void:
	var from := Vector2i(_pos.floor())
	if not is_walkable(target) or target == from:
		return
	var came := {from: from}
	var queue: Array[Vector2i] = [from]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_front()
		if cell == target:
			break
		for step: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next := cell + step
			if not came.has(next) and is_walkable(next):
				came[next] = cell
				queue.append(next)
	if not came.has(target):
		return
	_path.clear()
	var cell := target
	while cell != from:
		_path.push_front(Vector2(cell) + Vector2(0.5, 0.5))
		cell = came[cell]


func _process(delta: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		dir.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		dir.x += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		dir.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		dir.y += 1.0
	var move := Vector2.ZERO
	if dir != Vector2.ZERO:
		_path.clear()
		move = WorldState.screen_dir_to_cells(dir.normalized()) * WALK_SPEED * delta
	elif not _path.is_empty():
		var to_target := _path[0] - _pos
		var step := WALK_SPEED * delta
		if to_target.length() <= step:
			_pos = _path.pop_front()
			move = Vector2.ZERO
			_face(to_target)
		else:
			move = to_target.normalized() * step
	step_by(move)
	_player.moving = move != Vector2.ZERO or not _path.is_empty()
	_update_player()
	_camera.position = cell_to_screen(_pos)
	if _grid:
		_grid_node.queue_redraw()


## Ein Stück laufen; an Hindernissen entlang rutschen statt hängen zu bleiben.
func step_by(move: Vector2) -> void:
	if move == Vector2.ZERO:
		return
	_face(move)
	for attempt: Vector2 in [move, Vector2(move.x, 0), Vector2(0, move.y)]:
		if attempt == Vector2.ZERO:
			continue
		var next := _pos + attempt
		# Etwas Abstand nach vorne, damit die Figur nicht halb in einer Wand steht
		if is_walkable(Vector2i(next.floor())) and is_walkable(Vector2i((next + attempt.normalized() * 0.3).floor())):
			_pos = next
			return


func _face(move: Vector2) -> void:
	var screen_x := move.x - move.y
	if absf(screen_x) > 0.001:
		_player.facing = 1 if screen_x > 0 else -1
	# Nach oben auf dem Bildschirm = vom Betrachter weg (Bilder von hinten)
	var screen_y := move.x + move.y
	if absf(screen_y) > 0.001:
		_player.hinten = screen_y < 0


## Figur richtig einsortieren: Steht sie vor einem Ding, wird sie danach gemalt, sonst davor.
## Bei großen Dingen (Haus) reicht die Bildschirmhöhe allein nicht, deshalb zählen die Felder.
## Dinge, hinter denen sie steht und die sie verdecken, werden durchsichtig.
func _update_player() -> void:
	var screen := cell_to_screen(_pos)
	var g := FIGUR_GROESSEN[_figur_stufe]
	var area := Rect2(screen + PLAYER_RECT.position * g, PLAYER_RECT.size * g)
	var low := -INF
	var high := INF
	for o: Dictionary in _objekte:
		if o.flach:
			continue
		var node: Node2D = o.node
		if not node.visible:
			continue
		var behind := false
		if (o.bild as Rect2).intersects(area):
			var rect: Rect2i = o.rect
			if _pos.x >= rect.end.x or _pos.y >= rect.end.y:
				low = maxf(low, node.position.y + 1.0)
			else:
				high = minf(high, node.position.y - 1.0)
				behind = true
		node.modulate.a = move_toward(node.modulate.a, FADE_ALPHA if behind else 1.0, get_process_delta_time() * 4.0)
	var key := screen.y
	if low <= high:
		key = clampf(key, low, high)
	elif low > -INF:
		key = low
	_holder.position = Vector2(screen.x, key)
	_player.position = Vector2(0, screen.y - key)


## Für Prüfungen: Figur auf ein Feld stellen.
func place_player(cell: Vector2i) -> void:
	_pos = Vector2(cell) + Vector2(0.5, 0.5)
	_path.clear()
	_update_player()
	_camera.position = cell_to_screen(_pos)
	_camera.reset_smoothing()
