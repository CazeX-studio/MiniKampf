class_name WorldMap
extends RefCounted
## Eine Karte der Welt (Kreuzweg, der Weg nach Grünwacht, Waldboden, Wipfelheim …) – nur Daten, keine Grafik.
## Kreuzweg baut WorldState selbst. Alle anderen Karten stehen in data/karten.json als Bild aus Buchstaben
## ("raster", eine Zeile pro Reihe, ein Zeichen pro Feld); was die Zeichen bedeuten, steht dort unter "zeichen".

var id: String
## Name, der beim Betreten erscheint („Wipfelheim“)
var title: String
var size: Vector2i
## tiles[y][x] (WorldState.Tile)
var tiles: Array = []
var blocked := {}
## Häuser: {name, rect (Rect2i), height, color, art, roof}
var buildings: Array[Dictionary] = []
## Kleinkram: {kind, cell, …} (siehe WorldState.props)
var props: Array[Dictionary] = []
## Wo man ankommt, wenn nichts anderes gilt
var start := Vector2i.ZERO
## Übergänge am Rand: Läuft man hinein, kommt man auf eine andere Karte. {rect (Rect2i), karte, feld (Vector2i), cond}
var exits: Array[Dictionary] = []
## Grundfarbe des Lichts (z. B. etwas grünlich-dunkel im Wald)
var light := Color.WHITE
## Welches Musikstück läuft (Platzhalter, bis es eigene Musik gibt)
var music := "stadt"
## Dungeon-Regeln für Kämpfe auf dieser Karte ("pilzhoehle") oder "" (normale Karte)
var dungeon := ""

var astar := AStarGrid2D.new()


func _init(p_id: String, p_size: Vector2i, fill: int) -> void:
	id = p_id
	title = p_id
	size = p_size
	for y in size.y:
		var row: Array = []
		for x in size.x:
			row.append(fill)
		tiles.append(row)


## Baut eine Karte aus ihrem Eintrag in data/karten.json.
static func from_data(p_id: String, data: Dictionary, legend: Dictionary) -> WorldMap:
	var raster: Array = data.get("raster", [])
	var width := 0
	for line: String in raster:
		width = maxi(width, line.length())
	# Boden für alle Zeichen, die keinen eigenen nennen (z. B. Bäume im Wald stehen auf Waldboden)
	var ground: String = data.get("grund", "waldboden")
	var m := WorldMap.new(p_id, Vector2i(width, raster.size()), _tile_of(ground))
	m.title = data.get("name", p_id)
	m.light = Color(data.get("licht", "ffffff"))
	m.music = data.get("musik", "stadt")
	m.dungeon = data.get("dungeon", "")
	var start: Array = data.get("start", [1, 1])
	m.start = Vector2i(int(start[0]), int(start[1]))
	for y in raster.size():
		var line: String = raster[y]
		for x in line.length():
			var sign_def: Dictionary = legend.get(line[x], {})
			if sign_def.is_empty():
				continue
			var cell := Vector2i(x, y)
			m.tiles[y][x] = _tile_of(sign_def.get("boden", ground))
			if sign_def.get("gesperrt", false):
				m.blocked[cell] = true
			if sign_def.has("ding"):
				m.props.append({kind = sign_def.ding, cell = cell})
	for d: Dictionary in data.get("haeuser", []):
		var r: Array = d.feld
		m.add_building(d.get("name", ""), Rect2i(int(r[0]), int(r[1]), int(r[2]), int(r[3])), float(d.get("hoehe", 40)),
				Color(d.get("farbe", "7a6a5a")), d.get("art", "haus"), Color(d.get("dach", "6a3a2a")))
	for d: Dictionary in data.get("staende", []):
		var cell := Vector2i(int(d.feld[0]), int(d.feld[1]))
		m.props.append({kind = "stand", cell = cell, color = Color(d.get("farbe", "ffffff")), text = d.get("text", "")})
		m.blocked[cell] = true
	for d: Dictionary in data.get("ausgaenge", []):
		m.add_exit(d)
	m.finish()
	return m


static func _tile_of(boden: String) -> int:
	match boden:
		"wiese":
			return WorldState.Tile.GRASS
		"weg":
			return WorldState.Tile.ROAD
		"platz":
			return WorldState.Tile.PLAZA
		"gestruepp":
			return WorldState.Tile.OVERGROWN
		"planken":
			return WorldState.Tile.PLANKS
		"bruecke":
			return WorldState.Tile.BRIDGE
		"laub":
			return WorldState.Tile.CANOPY
		"hoehle":
			return WorldState.Tile.CAVE
		"fels":
			return WorldState.Tile.ROCK
	return WorldState.Tile.FOREST


## Ein Übergang aus den Daten: {"bereich": [x, y, Breite, Höhe], "karte": "…", "feld": [x, y], "wenn": {…}}
func add_exit(d: Dictionary) -> void:
	var r: Array = d.bereich
	exits.append({rect = Rect2i(int(r[0]), int(r[1]), int(r[2]), int(r[3])), karte = d.karte,
			feld = Vector2i(int(d.feld[0]), int(d.feld[1])), cond = d.get("wenn", {})})


func add_building(p_name: String, rect: Rect2i, height: float, color: Color, art := "haus", roof := Color("6a3a2a")) -> void:
	buildings.append({name = p_name, rect = rect, height = height, color = color, art = art, roof = roof})
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			blocked[Vector2i(x, y)] = true


## Wegsuche vorbereiten (nach dem Bauen und nachdem NPCs ihre Felder belegt haben).
func finish() -> void:
	astar.region = Rect2i(Vector2i.ZERO, size)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.update()
	for cell: Vector2i in blocked:
		if in_bounds(cell):
			astar.set_point_solid(cell)


func block(cell: Vector2i) -> void:
	blocked[cell] = true
	if in_bounds(cell) and astar.region.has_point(cell):
		astar.set_point_solid(cell)


func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < size.x and cell.y < size.y


func tile_at(cell: Vector2i) -> int:
	return tiles[cell.y][cell.x] if in_bounds(cell) else -1


func set_tile(cell: Vector2i, tile: int) -> void:
	if in_bounds(cell):
		tiles[cell.y][cell.x] = tile


func is_walkable(cell: Vector2i) -> bool:
	return in_bounds(cell) and not blocked.has(cell)
