class_name WorldState
extends RefCounted
## Spiellogik der Stadt Kreuzweg – ohne Grafik.
## Alles, was Spieler tun, kommt als Befehl (Dictionary) mit Spieler-Kennung herein:
##   {type = "move", cell = Vector2i}   laufen
##   {type = "talk", npc = "ye"}        zu einem NPC laufen und mit ihm reden
## So kann später ein Server dieselben Befehle von vielen Spielern annehmen;
## die Anzeige (kreuzweg.gd) liest nur den Zustand und schickt Befehle.

signal dialog_started(player_id: String, npc_id: String, lines: Array)

enum Tile { GRASS, ROAD, PLAZA, OVERGROWN }

const SIZE := Vector2i(22, 22)
const CENTER := Vector2i(11, 11)
## Felder pro Sekunde
const WALK_SPEED := 4.0

## tiles[y][x]
var tiles: Array = []
var blocked := {}
## Häuser: {name, rect (Rect2i), height, color}
var buildings: Array[Dictionary] = []
## Kleinkram: {kind = "tree" / "bush" / "lantern", cell}
var props: Array[Dictionary] = []
var players := {}
## NPCs: id -> {name, cell, look, tint}
var npcs := {}

var _astar := AStarGrid2D.new()


func _init() -> void:
	_build_map()
	_astar.region = Rect2i(Vector2i.ZERO, SIZE)
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_astar.update()
	for cell: Vector2i in blocked:
		_astar.set_point_solid(cell)
	npcs["ye"] = {name = "Ausbilder Ye", cell = Vector2i(13, 9), look = "wizzard_m", tint = Color(0.8, 0.86, 0.95)}
	blocked[npcs.ye.cell] = true
	_astar.set_point_solid(npcs.ye.cell)


# --- Karte ----------------------------------------------------------------------

## Kreuzweg: Marktplatz mit der Statue der Fünf in der Mitte, sechs Straßen nach draußen.
## Die sechste (nach Südosten) ist zugewachsen und endet in Gestrüpp.
func _build_map() -> void:
	for y in SIZE.y:
		var row: Array = []
		for x in SIZE.x:
			row.append(Tile.GRASS)
		tiles.append(row)

	# Marktplatz
	for y in SIZE.y:
		for x in SIZE.x:
			if absi(x - CENTER.x) + absi(y - CENTER.y) <= 4:
				tiles[y][x] = Tile.PLAZA
	# Fünf benutzte Straßen (Norden, Süden, Osten, Westen, Nordwesten)
	for i in SIZE.x:
		_road(Vector2i(CENTER.x, i))
		_road(Vector2i(i, CENTER.y))
	for k in range(0, CENTER.x):
		_road(Vector2i(k, k))
		_road(Vector2i(k + 1, k))
	# Die sechste Straße nach Südosten: zugewachsen, am Ende Gestrüpp
	for k in range(CENTER.x + 3, SIZE.x):
		_set_tile(Vector2i(k, k), Tile.OVERGROWN)
		_set_tile(Vector2i(k, k - 1), Tile.OVERGROWN)
	for cell: Vector2i in [Vector2i(17, 17), Vector2i(17, 16), Vector2i(18, 17), Vector2i(16, 17)]:
		props.append({kind = "bush", cell = cell})
		blocked[cell] = true

	# Statue der Fünf in der Mitte
	_building("Statue der Fünf", Rect2i(10, 10, 2, 2), 46.0, Color("b8b0a0"))
	# Häuser
	_building("Abenteurergilde", Rect2i(14, 5, 4, 3), 70.0, Color("8a5a3c"))
	_building("Bingos Laden", Rect2i(4, 13, 3, 3), 54.0, Color("a07a3a"))
	_building("Wohnhaus", Rect2i(4, 5, 3, 3), 50.0, Color("7a6a5a"))
	_building("Schmiede", Rect2i(15, 13, 3, 2), 46.0, Color("6a5048"))
	props.append({kind = "lantern", cell = Vector2i(14, 8)})

	# Bäume auf freiem Gras am Rand
	var rng := RandomNumberGenerator.new()
	rng.seed = 6
	for i in 40:
		var cell := Vector2i(rng.randi_range(0, SIZE.x - 1), rng.randi_range(0, SIZE.y - 1))
		if tiles[cell.y][cell.x] == Tile.GRASS and not blocked.has(cell) \
				and (cell - CENTER).length() > 6.5:
			props.append({kind = "tree", cell = cell})
			blocked[cell] = true


func _road(cell: Vector2i) -> void:
	if tile_at(cell) == Tile.GRASS:
		_set_tile(cell, Tile.ROAD)


func _set_tile(cell: Vector2i, tile: Tile) -> void:
	if in_bounds(cell):
		tiles[cell.y][cell.x] = tile


func _building(p_name: String, rect: Rect2i, height: float, color: Color) -> void:
	buildings.append({name = p_name, rect = rect, height = height, color = color})
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			blocked[Vector2i(x, y)] = true


func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < SIZE.x and cell.y < SIZE.y


func tile_at(cell: Vector2i) -> int:
	return tiles[cell.y][cell.x] if in_bounds(cell) else -1


func is_walkable(cell: Vector2i) -> bool:
	return in_bounds(cell) and not blocked.has(cell)


# --- Spieler --------------------------------------------------------------------

func add_player(id: String, p_name: String, look: String, cell: Vector2i) -> PlayerState:
	var p := PlayerState.new(id, p_name, look, cell)
	players[id] = p
	return p


func remove_player(id: String) -> void:
	players.erase(id)


## Nimmt einen Befehl eines Spielers an.
func apply_command(player_id: String, cmd: Dictionary) -> void:
	var p: PlayerState = players.get(player_id)
	if p == null:
		return
	match cmd.get("type", ""):
		"move":
			var target: Vector2i = cmd.cell
			if is_walkable(target):
				p.talk_target = ""
				_walk_to(p, target)
		"talk":
			var npc: Dictionary = npcs.get(cmd.npc, {})
			if npc.is_empty():
				return
			var spot := _free_neighbor(npc.cell, p.cell)
			if spot == Vector2i(-1, -1):
				return
			p.talk_target = cmd.npc
			_walk_to(p, spot)


func _walk_to(p: PlayerState, target: Vector2i) -> void:
	# Läuft der Spieler gerade, geht es vom nächsten Feld aus weiter
	var start := p.path[0] if p.is_moving() else p.cell
	var route := _astar.get_id_path(start, target)
	var path: Array[Vector2i] = []
	if p.is_moving():
		path.append(start)
	for i in range(1, route.size()):
		path.append(route[i])
	p.path = path


## Freies Nachbarfeld eines NPCs, das am nächsten am Spieler liegt.
func _free_neighbor(npc_cell: Vector2i, from: Vector2i) -> Vector2i:
	var best := Vector2i(-1, -1)
	for dir: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
			Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
		var cell := npc_cell + dir
		if is_walkable(cell) and (best == Vector2i(-1, -1) or (cell - from).length() < (best - from).length()):
			best = cell
	return best


## Spielt die Welt um "delta" Sekunden weiter (Laufen, Gespräche beginnen).
func tick(delta: float) -> void:
	for p: PlayerState in players.values():
		var step := WALK_SPEED * delta
		while step > 0.0 and p.is_moving():
			var next := Vector2(p.path[0])
			var to_next := next - p.pos
			if absf(to_next.x - to_next.y) > 0.01:
				# Bildschirm-Richtung: x - y wird größer = nach rechts
				p.facing = 1 if to_next.x - to_next.y > 0 else -1
			if to_next.length() <= step:
				step -= to_next.length()
				p.pos = next
				p.cell = p.path.pop_front()
			else:
				p.pos += to_next.normalized() * step
				step = 0.0
		if not p.is_moving() and p.talk_target != "":
			var npc_id := p.talk_target
			p.talk_target = ""
			var npc: Dictionary = npcs[npc_id]
			if (npc.cell - p.cell).length() < 1.5:
				var first := not p.talked.has(npc_id)
				p.talked[npc_id] = true
				dialog_started.emit(p.id, npc_id, Dialogs.lines_for(npc_id, first))
