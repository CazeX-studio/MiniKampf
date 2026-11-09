class_name BaukastenBoden
extends Node2D
## Malt den Boden einer Baukasten-Karte (Rautenansicht) samt weichen Übergängen und baut einzelne Teile auf.
## Benutzt vom Testfeld und von der Stadt Kreuzweg. Das Regelwerk der Teile steht in data/BAUKASTEN.md.

const TILE_W := 64.0
const TILE_H := 32.0
const MASSSTAB := 1.0
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
## Der Boden wird in Kacheln von KACHEL x KACHEL Feldern gezeichnet. So malt Godot nur, was gerade im Bild ist,
## und jedes Licht trifft nur die Kacheln in seiner Nähe (vorher war der ganze Boden ein einziges Riesenbild).
const KACHEL := 8
## Am Ufer liegt im Wasser ein dunkler Schatten etwas weiter als der Rand
const UFER_WEITE := 0.5
const UFER_SCHATTEN := Color(0.0, 0.03, 0.08, 0.45)

var _teile: Dictionary
var _size := Vector2i.ZERO
var _rows: PackedStringArray
var _ground_colors := {}
## Fertige Randbilder für Übergänge: "Bild|Richtung|Weite" -> ImageTexture
var _rand_bilder := {}


func setup(teile: Dictionary, rows: PackedStringArray) -> void:
	_teile = teile
	_rows = rows
	_size = Vector2i(rows[0].length() if rows.size() > 0 else 0, rows.size())
	z_index = -10
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	# Erst alle Bodenkacheln, darüber alle Übergänge (damit kein Nachbar einen Übergang wieder verdeckt)
	var bereiche: Array[Rect2i] = []
	for ky in range(0, _size.y, KACHEL):
		for kx in range(0, _size.x, KACHEL):
			bereiche.append(Rect2i(kx, ky, mini(KACHEL, _size.x - kx), mini(KACHEL, _size.y - ky)))
	for ebene: Callable in [_zeichne_boden, _zeichne_uebergaenge]:
		for bereich in bereiche:
			var kachel := Node2D.new()
			kachel.draw.connect(ebene.bind(kachel, bereich))
			add_child(kachel)


static func cell_to_screen(c: Vector2) -> Vector2:
	return Vector2((c.x - c.y) * TILE_W * 0.5, (c.x + c.y) * TILE_H * 0.5)


## Grundfläche eines Teils in Feldern.
static func grundflaeche(o: Dictionary, teile: Dictionary) -> Rect2i:
	var flaeche: Array = teile.objekte[o.teil].get("flaeche", [1, 1])
	var rect := Rect2i(Vector2i(o.feld[0], o.feld[1]), Vector2i(flaeche[0], flaeche[1]))
	# Gespiegelt oder um 90°/270° gedreht (flache Teile) steht das Teil quer
	if o.get("gespiegelt", false) != (posmod(int(o.get("drehung", 0)), 180) == 90):
		rect.size = Vector2i(flaeche[1], flaeche[0])
	return rect


## Felder, die ein Teil sperrt (ohne Grafik, gilt auch für den Server).
static func gesperrte_felder(o: Dictionary, teile: Dictionary) -> Array[Vector2i]:
	var d: Dictionary = teile.objekte[o.teil]
	var rect := grundflaeche(o, teile)
	var zellen: Array[Vector2i] = []
	if d.get("begehbar", false) or not d.get("blockiert", true):
		return zellen
	var frei: Array = [] if o.get("geschlossen", false) else d.get("frei", [])
	for y in rect.size.y:
		for x in rect.size.x:
			# Bei gespiegelten Teilen sind die freien Felder ebenfalls getauscht
			var f := [y, x] if o.get("gespiegelt", false) else [x, y]
			if not f in frei and not [float(f[0]), float(f[1])] in frei:
				zellen.append(rect.position + Vector2i(x, y))
	return zellen


## Baut ein Teil als Grafik: {node, rect, bild (Bildschirm-Fläche), flach, lichter}. Null-Wörterbuch, wenn das Bild fehlt.
static func teil_bauen(o: Dictionary, teile: Dictionary) -> Dictionary:
	var teil: String = o.get("teil", "")
	if not teile.objekte.has(teil):
		push_warning("Baukasten: unbekanntes Teil '%s'" % teil)
		return {}
	var d: Dictionary = teile.objekte[teil]
	var rect := grundflaeche(o, teile)
	# Ansicht von hinten (Stadt-Editor „Drehen“), wenn es für das Teil ein Bild von hinten gibt
	var hinten: bool = o.get("hinten", false) and d.has("bild_hinten")
	var bild_datei: String = d.bild_hinten if hinten else d.bild
	var tex: Texture2D = load(ASSET_PATH + bild_datei)
	if tex == null:
		push_warning("Baukasten: Bild fehlt: %s" % bild_datei)
		return {}
	var node := Node2D.new()
	# Sortierpunkt: die vorderste Ecke der Grundfläche
	node.position = cell_to_screen(Vector2(rect.end))
	var center := cell_to_screen(Vector2(rect.position) + Vector2(rect.size) * 0.5) - node.position
	var massstab: float = d.get("massstab", MASSSTAB)
	var gespiegelt: bool = o.get("gespiegelt", false)
	# Der Fußpunkt (fuss = Pixel im Bild, sonst unten in der Mitte, fuss_y Pixel über dem Rand) steht auf der Mitte der Grundfläche
	var fuss := Vector2(tex.get_width() * 0.5, tex.get_height() - float(d.get("fuss_y", (rect.size.x + rect.size.y) * 8.0 / massstab)))
	if hinten and d.has("fuss_hinten"):
		fuss = Vector2(d.fuss_hinten[0], d.fuss_hinten[1])
	elif d.has("fuss") and not hinten:
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
	var drehung := float(posmod(int(o.get("drehung", 0)), 360)) if d.get("flach", false) and d.get("drehbar", true) else 0.0
	var bild_rect := Rect2(node.position + sprite.position, tex.get_size() * massstab)
	if drehung != 0.0:
		# Flache Teile drehen auf dem Boden: in der Rautenansicht ist der Boden halb so hoch wie breit,
		# also erst strecken, drehen, wieder stauchen (so bleibt eine Raute eine Raute)
		var dreh := Node2D.new()
		var w := deg_to_rad(drehung)
		dreh.transform = Transform2D(Vector2(cos(w), 0.5 * sin(w)), Vector2(-2.0 * sin(w), cos(w)), center)
		sprite.position -= center
		dreh.add_child(sprite)
		node.add_child(dreh)
		var ecken: Array[Vector2] = []
		for e: Vector2 in [Vector2.ZERO, Vector2(tex.get_width(), 0), Vector2(0, tex.get_height()), Vector2(tex.get_size())]:
			ecken.append(node.position + dreh.transform * (sprite.position + e * massstab))
		bild_rect = Rect2(ecken[0], Vector2.ZERO)
		for e in ecken:
			bild_rect = bild_rect.expand(e)
	else:
		node.add_child(sprite)
	var lichter: Array = d.get("lichter", []).duplicate()
	if d.has("licht"):
		lichter.append({art = d.licht.art, hoehe = d.licht.get("hoehe", 0)})
	var neue_lichter: Array[Licht] = []
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
		neue_lichter.append(licht)
	return {name = teil, node = node, rect = rect, flach = d.get("flach", false), lichter = neue_lichter,
			oben = node.position + sprite.position + Vector2(tex.get_width() * massstab * 0.5, 0),
			bild = bild_rect}


func _ground_def(cell: Vector2i) -> Dictionary:
	if cell.x < 0 or cell.y < 0 or cell.x >= _size.x or cell.y >= _size.y:
		return {}
	return _teile.boden.get(_rows[cell.y][cell.x], {})


func _zeichne_boden(kachel: Node2D, bereich: Rect2i) -> void:
	# Erst alle Grundflächen, dann die Bilder nach Bild geordnet: So kann die Grafikkarte viele Felder
	# auf einmal malen. Die Rauten überlappen sich nicht, deshalb sieht es genauso aus wie Feld für Feld.
	var nach_bild := {}
	for y in range(bereich.position.y, bereich.end.y):
		for x in range(bereich.position.x, bereich.end.x):
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
			kachel.draw_colored_polygon(diamond, _base_color(tex))
			if not nach_bild.has(tex):
				nach_bild[tex] = []
			nach_bild[tex].append(Rect2(top - Vector2(TILE_W * 0.5, 0), Vector2(TILE_W, TILE_H)))
	for tex: Texture2D in nach_bild:
		for r: Rect2 in nach_bild[tex]:
			kachel.draw_texture_rect(tex, r, false)


## Die Übergänge einer Kachel (liegen über allen Bodenkacheln).
func _zeichne_uebergaenge(kachel: Node2D, bereich: Rect2i) -> void:
	for y in range(bereich.position.y, bereich.end.y):
		for x in range(bereich.position.x, bereich.end.x):
			_draw_uebergaenge(kachel, Vector2i(x, y))


## Bild eines Bodenfeldes (jedes Feld nimmt immer dasselbe, aber zufällig wirkende Bild).
func _boden_bild(cell: Vector2i) -> Texture2D:
	var bilder: Array = _ground_def(cell).get("bilder", [])
	if bilder.is_empty():
		return null
	return load(ASSET_PATH + bilder[(cell.x * 7 + cell.y * 13 + cell.x * cell.y) % bilder.size()])


## Ränder der Nachbarn mit mehr Vorrang in dieses Feld malen.
func _draw_uebergaenge(kachel: Node2D, cell: Vector2i) -> void:
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
				kachel.draw_texture_rect(_rand(_boden_bild(cell + d), d, UFER_WEITE), rect, false, UFER_SCHATTEN)
	for d in richtungen:
		kachel.draw_texture_rect(_rand(_boden_bild(cell + d), d, RAND_WEITE), rect, false)


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
