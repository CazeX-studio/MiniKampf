class_name WorldState
extends RefCounted
## Spiellogik der Welt – ohne Grafik. Die Welt besteht aus mehreren Karten (Kreuzweg, der Weg nach Grünwacht,
## Waldboden, Wipfelheim …); jeder Spieler steht auf genau einer (PlayerState.map). Kreuzweg wird hier gebaut,
## die anderen Karten kommen aus data/karten.json (siehe WorldMap).
## Alles, was Spieler tun, kommt als Befehl (Dictionary) mit Spieler-Kennung herein:
##   {type = "move", cell = Vector2i}    laufen
##   {type = "talk", npc = "ye"}         zu einem NPC laufen und mit ihm reden
##   {type = "use", target = "punkt:0"}  zu etwas hinlaufen und es benutzen ("npc:ye" oder "punkt:Nummer")
##   {type = "steer", dir = Vector2}     frei laufen in eine Bildschirm-Richtung (Tasten, Steuerknopf), ZERO = stehen bleiben
##   {type = "interact"}                 das Nächste direkt nebenan benutzen (E, Leertaste, Aktions-Knopf)
##   {type = "start"}                    Stadt betreten (zeigt beim ersten Mal die Einleitung)
##   {type = "kampf_ergebnis", kampf = "…", gewonnen = true, traenke_benutzt = 1}  Ergebnis eines Kampfes (vom Kampfbildschirm)
##   {type = "dialog_next"}              im Gespräch weiter (wenn es keine Antworten gibt)
##   {type = "dialog_choose", index = 0} im Gespräch eine Antwort wählen
##   {type = "szene_verlassen"}          eine gemeinsame Szene verlassen (Zusammenspielen)
##   {type = "kaufen", gegenstand = "…"} / {type = "verkaufen", gegenstand = "…"} / {type = "laden_zu"}  im geöffneten Laden
## Auf eine andere Karte kommt man über Ausgänge am Rand (hineinlaufen) oder über Orte mit der Aktion "reisen" (Seilaufzug).
## Monster in der Wildnis ("monster:<Nummer>", aus data/karten.json): hineinlaufen oder antippen startet den Kampf.
## So kann später ein Server dieselben Befehle von vielen Spielern annehmen;
## die Anzeige (kreuzweg.gd) liest nur den Zustand und schickt Befehle.
## NPCs, Sammelpunkte, Dialoge und Aufträge kommen aus den Datendateien in res://data.

## Kurze Meldung für einen Spieler („+30 Gold“, „Neuer Auftrag …“)
signal notice(player_id: String, text: String)
## Gold, Tasche, Erfahrung oder Aufträge eines Spielers haben sich geändert (z. B. zum Speichern)
signal progress_changed(player_id: String)
## Ein Spieler beginnt einen Kampf (Kennung aus data/kaempfe.json). Die Anzeige wechselt zum Kampfbildschirm.
signal battle_requested(player_id: String, kampf_id: String)
## Mehrere Spieler einer gemeinsamen Szene kämpfen zusammen (Zusammenspielen). Netz startet den Gruppenkampf.
signal group_battle_requested(player_ids: Array, kampf_id: String)
## Ein besonderer Effekt für einen Spieler (z. B. "sternenfall": greller Lichtblitz). Nur Anzeige.
signal effect_requested(player_id: String, effect: String)
## Wechsel zu einem anderen Bildschirm (z. B. "klassenwahl", "abspann"). Nur Anzeige.
signal scene_requested(player_id: String, scene: String)

## Böden. Kreuzweg: Wiese, Straße, Platz, Gestrüpp. Grünwacht: Waldboden, Planken (Plattformen in den Baumkronen),
## Hängebrücke und Laub (die Baumkronen unter den Plattformen, dort kann man nicht laufen).
enum Tile { GRASS, ROAD, PLAZA, OVERGROWN, FOREST, PLANKS, BRIDGE, CANOPY }

## Kennung der Stadt Kreuzweg (dort beginnt das Spiel)
const KREUZWEG := "kreuzweg"

const SIZE := Vector2i(44, 44)
const CENTER := Vector2i(22, 22)
## Halbmesser des runden Marktplatzes (in Feldern)
const PLAZA_RADIUS := 7.5
## Felder pro Sekunde
const WALK_SPEED := 5.5
## So nah muss man an etwas stehen, um es zu benutzen (in Feldern)
const USE_RANGE := 1.6

## Alle Karten: Kennung -> WorldMap
var maps := {}
## Kreuzweg (tiles, blocked, buildings und props zeigen auf dieselben Daten wie maps["kreuzweg"])
## tiles[y][x]
var tiles: Array = []
var blocked := {}
## Häuser: {name, rect (Rect2i), height, color, art ("haus" mit Dach oder "statue"), roof}
var buildings: Array[Dictionary] = []
## Kleinkram: {kind = "tree" / "bush" / "lantern" / "well" / "flowers" / "stand", cell} (Stand: auch color, text)
var props: Array[Dictionary] = []
var players := {}
## NPCs aller Karten: id -> {name, cell, map, look, tint, dialog}
var npcs := {}
## Sammelpunkte: {item, cell, map}. Jeder Spieler kann jeden Punkt einmal einsammeln.
var pickups: Array[Dictionary] = []
## Orte, die man benutzen kann (Kater, Laternenhaken, Seilaufzug …), nur solange ihre Bedingung stimmt
var places: Array[Dictionary] = []
## Schmuck, der nur zu bestimmten Zeiten da ist (Festlaternen, Krater, Wegweiser): {art, cell, map, cond, text}
var decorations: Array[Dictionary] = []
## Monster in der Wildnis: {karte, feld, gegner, stufe} (GameData.wild_monsters). Wer eines besiegt, sieht es eine
## Weile nicht mehr (MONSTER_RESPAWN), die anderen Spieler schon.
var monsters: Array[Dictionary] = []
## So nah muss man einem Monster kommen, damit der Kampf beginnt (Felder)
const MONSTER_TOUCH := 0.6
## So lange bleibt ein besiegtes Monster für den Spieler weg (Sekunden)
const MONSTER_RESPAWN := 60.0
## Spieler, deren Kampf gerade beginnt (bis das Ergebnis kommt oder sie gehen): Kennung -> true
var _fighting := {}

## --- Gemeinsame Szenen (Zusammenspielen, Lernprojekt 4 Schritt 5) ---
## Spricht ein Gruppenmitglied eine Figur an, erleben Mitglieder in der Nähe das Gespräch mit. Bei Antworten stimmen alle
## ab, die in der Geschichte an derselben Stelle sind; wer woanders steht (z. B. die Szene schon erlebt hat), schaut zu.
## Bei Gleichstand entscheidet der Gruppenführer. Netz setzt hier ein, wer mit wem in einer Gruppe ist.
var group_members: Callable = func(_id: String) -> Array: return []
var group_leader: Callable = func(_id: String) -> String: return ""
## So nah müssen Gruppenmitglieder stehen, um mitgeholt zu werden (Felder)
const SCENE_RANGE := 8.0
## So lange wird auf Stimmen gewartet (Sekunden); danach zählen die abgegebenen
const VOTE_SECONDS := 30.0
## Laufende Szenen: Nummer -> {dialog, node, speaker, voters, watchers, votes = {Spieler: Antwort}, time_left}
var scenes := {}
var _next_scene := 1
## Effekte, die alle in der Stadt sehen (design.md: Der Sternenfall ist für alle in Kreuzweg sichtbar)
const GLOBAL_EFFECTS := ["sternenfall"]
## Gruppenkämpfe, aus denen noch nicht alle zurück sind: [{ids, back = {Spieler: true}, time}].
## Solange spricht niemand aus der Gruppe von sich aus an (z. B. Ren wartet, bis alle wieder da sind).
var battle_groups: Array[Dictionary] = []
## So lange wird höchstens auf die anderen gewartet (Sekunden)
const BATTLE_WAIT_MAX := 600.0
## Laufende Zeit der Welt (Sekunden)
var _time := 0.0
var _effect_time := {}


func _init() -> void:
	var town_map := WorldMap.new(KREUZWEG, SIZE, Tile.GRASS)
	town_map.title = "Kreuzweg"
	tiles = town_map.tiles
	blocked = town_map.blocked
	buildings = town_map.buildings
	props = town_map.props
	maps[KREUZWEG] = town_map
	_build_map()
	var town := GameData.get_file("kreuzweg")
	town_map.start = start_cell()
	for d: Dictionary in town.get("ausgaenge", []):
		town_map.add_exit(d)
	town_map.finish()
	_add_things(KREUZWEG, town)
	monsters = GameData.wild_monsters()
	var all_maps := GameData.get_file("karten")
	var legend: Dictionary = all_maps.get("zeichen", {})
	for id: String in all_maps:
		if all_maps[id] is Dictionary and all_maps[id].has("raster"):
			maps[id] = WorldMap.from_data(id, all_maps[id], legend)
			_add_things(id, all_maps[id])
	# Wer irgendwo hintippt, läuft um Monster herum statt mitten hindurch (nur wer sie antippt, läuft hin)
	for m: Dictionary in monsters:
		var astar: AStarGrid2D = get_map(m.karte).astar
		if astar.region.has_point(m.feld) and not astar.is_point_solid(m.feld):
			astar.set_point_weight_scale(m.feld, 40.0)


## NPCs, Sammelpunkte, Orte und Schmuck einer Karte aus ihren Daten.
func _add_things(map_id: String, data: Dictionary) -> void:
	var m: WorldMap = maps[map_id]
	var npc_data: Dictionary = data.get("npcs", {})
	for id: String in npc_data:
		var d: Dictionary = npc_data[id]
		var cell := Vector2i(int(d.feld[0]), int(d.feld[1]))
		npcs[id] = {name = d.name, cell = cell, map = map_id, look = d.aussehen, tint = Color(d.get("farbe", "ffffff")),
				dialog = d.get("dialog", id), cond = d.get("wenn", {}), approach = d.get("anspringen", {})}
		m.block(cell)
	for d: Dictionary in data.get("deko", []):
		decorations.append({art = d.art, cell = Vector2i(int(d.feld[0]), int(d.feld[1])), map = map_id, cond = d.get("wenn", {}),
				text = d.get("text", "")})
	for d: Dictionary in data.get("sammelpunkte", []):
		pickups.append({item = d.gegenstand, cell = Vector2i(int(d.feld[0]), int(d.feld[1])), map = map_id, cond = d.get("wenn", {})})
	for d: Dictionary in data.get("orte", []):
		places.append({art = d.art, cell = Vector2i(int(d.feld[0]), int(d.feld[1])), map = map_id, cond = d.get("wenn", {}),
				dialog = d.get("dialog", ""), actions = d.get("aktionen", []), text = d.get("meldung", "")})


# --- Karte ----------------------------------------------------------------------

## Kreuzweg: Marktplatz mit der Statue der Fünf in der Mitte, sechs Straßen nach draußen.
## Die sechste (nach Südosten) ist zugewachsen und endet in Gestrüpp.
func _build_map() -> void:
	var town := GameData.get_file("kreuzweg")

	# Marktplatz (rund)
	for y in SIZE.y:
		for x in SIZE.x:
			if (Vector2(x, y) - Vector2(CENTER)).length() <= PLAZA_RADIUS:
				tiles[y][x] = Tile.PLAZA
	# Fünf benutzte Straßen, drei Felder breit (Norden, Süden, Osten, Westen, Nordwesten)
	for i in SIZE.x:
		for w in [-1, 0, 1]:
			_road(Vector2i(CENTER.x + w, i))
			_road(Vector2i(i, CENTER.y + w))
	for k in range(0, CENTER.x):
		_road(Vector2i(k, k))
		_road(Vector2i(k + 1, k))
		_road(Vector2i(k, k + 1))
	# Die sechste Straße nach Südosten: zugewachsen, in der Mitte versperrt Gestrüpp den Weg
	for k in range(CENTER.x + 6, SIZE.x):
		_set_tile(Vector2i(k, k), Tile.OVERGROWN)
		_set_tile(Vector2i(k, k - 1), Tile.OVERGROWN)
		_set_tile(Vector2i(k - 1, k), Tile.OVERGROWN)
	for cell: Vector2i in [Vector2i(34, 34), Vector2i(34, 33), Vector2i(33, 34), Vector2i(35, 35), Vector2i(35, 34),
			Vector2i(34, 35), Vector2i(36, 35), Vector2i(35, 36), Vector2i(33, 32), Vector2i(32, 33)]:
		props.append({kind = "bush", cell = cell})
		blocked[cell] = true

	# Statue der Fünf in der Mitte
	_building("Statue der Fünf", Rect2i(21, 21, 2, 2), 46.0, Color("b8b0a0"), "statue")
	# Wichtige Häuser
	_building("Abenteurergilde", Rect2i(27, 9, 6, 4), 64.0, Color("8a5a3c"), "haus", Color("7a2f2a"))
	_building("Bingos Laden", Rect2i(8, 28, 4, 4), 48.0, Color("a07a3a"), "haus", Color("3f6a8a"))
	_building("Schmiede", Rect2i(33, 25, 4, 3), 42.0, Color("6a5048"), "haus", Color("3c3c44"))
	_building("Wohnhaus", Rect2i(14, 8, 4, 3), 40.0, Color("7a6a5a"), "haus", Color("8a4a2a"))
	_building("Gasthaus Wegrast", Rect2i(6, 17, 4, 3), 46.0, Color("8a6a48"), "haus", Color("5a6a3a"))
	# Weitere Wohnhäuser ohne Namen
	var houses := [
		[Rect2i(14, 4, 3, 3), Color("8a7a62"), Color("6a3a2a")], [Rect2i(35, 8, 4, 3), Color("75685a"), Color("4a5a3a")],
		[Rect2i(37, 13, 3, 3), Color("8c7458"), Color("7a2f2a")], [Rect2i(3, 14, 3, 3), Color("80705e"), Color("3f5a6a")],
		[Rect2i(13, 35, 4, 3), Color("7c6c58"), Color("8a4a2a")], [Rect2i(4, 36, 3, 3), Color("8a7a62"), Color("5a3a4a")],
		[Rect2i(27, 37, 3, 3), Color("75685a"), Color("6a3a2a")], [Rect2i(38, 30, 3, 3), Color("8c7458"), Color("3f5a6a")],
		[Rect2i(13, 28, 3, 3), Color("80705e"), Color("7a2f2a")], [Rect2i(27, 2, 3, 3), Color("7c6c58"), Color("4a5a3a")],
	]
	for h: Array in houses:
		_building("", h[0], 34.0, h[1], "haus", h[2])
	props.append({kind = "lantern", cell = Vector2i(28, 13)})
	# Brunnen und Blumen
	props.append({kind = "well", cell = Vector2i(25, 19)})
	blocked[Vector2i(25, 19)] = true
	for b: Dictionary in buildings:
		if b.art == "haus":
			var spot := Vector2i(b.rect.position.x - 1, b.rect.end.y - 1)
			if tile_at(spot) == Tile.GRASS:
				props.append({kind = "flowers", cell = spot})

	# Stände der Gesandten an ihren Straßen
	for d: Dictionary in town.get("staende", []):
		var cell := Vector2i(int(d.feld[0]), int(d.feld[1]))
		props.append({kind = "stand", cell = cell, color = Color(d.get("farbe", "ffffff")), text = d.get("text", "")})
		blocked[cell] = true

	# Bäume auf freiem Gras am Rand, nicht direkt neben Figuren, Ständen oder Sammelpunkten
	var reserved: Array[Vector2i] = []
	for id: String in town.get("npcs", {}):
		var f: Array = town.npcs[id].feld
		reserved.append(Vector2i(int(f[0]), int(f[1])))
	for d: Dictionary in town.get("sammelpunkte", []) + town.get("deko", []) + town.get("orte", []):
		reserved.append(Vector2i(int(d.feld[0]), int(d.feld[1])))
	var rng := RandomNumberGenerator.new()
	rng.seed = 6
	for i in 160:
		var cell := Vector2i(rng.randi_range(0, SIZE.x - 1), rng.randi_range(0, SIZE.y - 1))
		if tiles[cell.y][cell.x] != Tile.GRASS or blocked.has(cell) or (cell - CENTER).length() < 10.0:
			continue
		if reserved.any(func(r: Vector2i) -> bool: return (r - cell).length() < 2.5):
			continue
		props.append({kind = "tree", cell = cell})
		blocked[cell] = true


func _road(cell: Vector2i) -> void:
	if tile_at(cell) == Tile.GRASS:
		_set_tile(cell, Tile.ROAD)


func _set_tile(cell: Vector2i, tile: Tile) -> void:
	if in_bounds(cell):
		tiles[cell.y][cell.x] = tile


func _building(p_name: String, rect: Rect2i, height: float, color: Color, art := "haus", roof := Color("6a3a2a")) -> void:
	maps[KREUZWEG].add_building(p_name, rect, height, color, art, roof)


## Die Karte mit dieser Kennung (unbekannte Kennung: Kreuzweg).
func get_map(map_id: String) -> WorldMap:
	return maps.get(map_id, maps[KREUZWEG])


func in_bounds(cell: Vector2i, map_id := KREUZWEG) -> bool:
	return get_map(map_id).in_bounds(cell)


func tile_at(cell: Vector2i, map_id := KREUZWEG) -> int:
	return get_map(map_id).tile_at(cell)


func is_walkable(cell: Vector2i, map_id := KREUZWEG) -> bool:
	return get_map(map_id).is_walkable(cell)


## Nach dem Laden eines Spielstands: Gibt es die Karte nicht (mehr) oder ist das Feld belegt, geht es an den Start.
func fix_position(p: PlayerState) -> void:
	if not maps.has(p.map):
		p.map = KREUZWEG
		p.cell = start_cell()
	if not is_walkable(p.cell, p.map):
		p.cell = get_map(p.map).start
	p.pos = Vector2(p.cell)


## Auf welcher Karte ein Ziel ("npc:ye", "punkt:0", "ort:0") liegt ("" = unbekannt).
func target_map(target: String) -> String:
	var parts := target.split(":")
	if parts.size() != 2:
		return ""
	if parts[0] == "npc" and npcs.has(parts[1]):
		return npcs[parts[1]].map
	if parts[0] == "punkt" and int(parts[1]) < pickups.size():
		return pickups[int(parts[1])].map
	if parts[0] == "ort" and int(parts[1]) < places.size():
		return places[int(parts[1])].map
	if parts[0] == "monster" and int(parts[1]) < monsters.size():
		return monsters[int(parts[1])].karte
	return ""


## Bringt einen Spieler auf eine andere Karte (Ausgang am Rand, Seilaufzug). Ein laufendes Gespräch oder ein
## offener Laden endet. Steht das Zielfeld nicht frei, kommt er am Start der Karte an.
func change_map(p: PlayerState, map_id: String, cell: Vector2i) -> void:
	if not maps.has(map_id):
		return
	_leave_scene(p)
	p.dialog = {}
	p.shop = ""
	p.path.clear()
	p.use_target = ""
	var m: WorldMap = maps[map_id]
	if not m.is_walkable(cell):
		cell = m.start
	p.map = map_id
	p.cell = cell
	p.pos = Vector2(cell)
	_say(p, GameData.text("karte_betreten", [m.title]))
	# Für Aufträge wie „Reise nach Wipfelheim“
	p.progress.flags["besucht:" + map_id] = true
	_update_quests(p)
	progress_changed.emit(p.id)


## Steht der Spieler in einem Ausgang seiner Karte, kommt er auf die nächste.
func _check_exits(p: PlayerState) -> void:
	if p.in_dialog():
		return
	for e: Dictionary in get_map(p.map).exits:
		if e.rect.has_point(p.cell) and check(p, e.cond):
			change_map(p, e.karte, e.feld)
			return


# --- Spieler --------------------------------------------------------------------

func add_player(id: String, p_name: String, look: String, cell: Vector2i) -> PlayerState:
	var p := PlayerState.new(id, p_name, look, cell)
	players[id] = p
	return p


func remove_player(id: String) -> void:
	if players.has(id):
		_leave_scene(players[id])
	players.erase(id)
	_fighting.erase(id)


## Nimmt einen Befehl eines Spielers an.
func apply_command(player_id: String, cmd: Dictionary) -> void:
	var p: PlayerState = players.get(player_id)
	if p == null:
		return
	match cmd.get("type", ""):
		"move":
			var target: Vector2i = cmd.cell
			p.shop = ""
			if is_walkable(target, p.map) and not p.in_dialog():
				p.use_target = ""
				_walk_to(p, target)
		"talk":
			_go_use(p, "npc:" + str(cmd.npc))
		"use":
			_go_use(p, str(cmd.target))
		"steer":
			var dir: Vector2 = cmd.dir
			p.steer = screen_dir_to_cells(dir.limit_length(1.0)) if not p.in_dialog() else Vector2.ZERO
			if p.steer != Vector2.ZERO:
				# Freies Laufen ersetzt einen angeklickten Weg und schließt den Laden
				p.shop = ""
				p.path.clear()
				p.use_target = ""
		"interact":
			if p.in_dialog():
				return
			var target := usable_near(p)
			if target != "":
				p.path.clear()
				p.use_target = target
		"start":
			# Beim Betreten der Stadt: Einleitung, solange sie noch nicht gesehen wurde
			var start: Dictionary = GameData.get_file("kreuzweg").get("start", {})
			var flag: String = start.get("nur_wenn_nicht_gemerkt", "")
			if start.has("dialog") and (flag == "" or not p.progress.flags.has(flag)):
				start_dialog(p, start.dialog)
		"kampf_ergebnis":
			# Im Kampf getrunkene Heiltränke sind weg (auch bei einer Niederlage)
			var used := mini(int(cmd.get("traenke_benutzt", 0)), p.progress.item_count("heiltrank"))
			if used > 0:
				_give_item(p, "heiltrank", -used)
			_fighting.erase(p.id)
			for monster_id: String in cmd.get("gezaehmt", []):
				_add_to_pack(p, monster_id, true)
			_battle_result(p, str(cmd.get("kampf", "")), bool(cmd.get("gewonnen", false)))
			_back_from_battle(p.id)
		"benutzen":
			_use_item(p, str(cmd.get("gegenstand", "")))
		"kaufen":
			_buy(p, str(cmd.get("gegenstand", "")))
		"verkaufen":
			_sell(p, str(cmd.get("gegenstand", "")))
		"laden_zu":
			p.shop = ""
		"szene_verlassen":
			_leave_scene(p)
		"dialog_next":
			_dialog_next(p)
		"dialog_choose":
			_dialog_choose(p, int(cmd.get("index", -1)))


## Wandelt eine Richtung auf dem Bildschirm (rechts = +x, unten = +y) in Feld-Koordinaten um.
## Die Länge bleibt gleich, damit man in alle Richtungen gleich schnell läuft.
static func screen_dir_to_cells(dir: Vector2) -> Vector2:
	if dir == Vector2.ZERO:
		return Vector2.ZERO
	# Bildschirm: x = Feld.x - Feld.y, y = (Feld.x + Feld.y) / 2 (Felder sind doppelt so breit wie hoch)
	var cells := Vector2(dir.x + 2.0 * dir.y, 2.0 * dir.y - dir.x)
	return cells.normalized() * dir.length()


## Wo ein Ziel ("npc:ye", "punkt:0", "ort:0") steht.
func target_cell(target: String) -> Vector2i:
	var parts := target.split(":")
	if parts.size() == 2 and parts[0] == "npc" and npcs.has(parts[1]):
		return npcs[parts[1]].cell
	if parts.size() == 2 and parts[0] == "punkt" and int(parts[1]) < pickups.size():
		return pickups[int(parts[1])].cell
	if parts.size() == 2 and parts[0] == "ort" and int(parts[1]) < places.size():
		return places[int(parts[1])].cell
	if parts.size() == 2 and parts[0] == "monster" and int(parts[1]) < monsters.size():
		return monsters[int(parts[1])].feld
	return Vector2i(-1, -1)


## Kann dieser Spieler das Ziel benutzen? (Ein schon eingesammelter Punkt oder ein gerade abwesender NPC nicht.)
func can_use(p: PlayerState, target: String) -> bool:
	if target_map(target) != p.map:
		return false
	if target.begins_with("punkt:"):
		return target_cell(target) != Vector2i(-1, -1) and not p.progress.flags.has("gesammelt:" + target) \
				and check(p, pickups[int(target.substr(6))].cond)
	if target.begins_with("ort:"):
		return target_cell(target) != Vector2i(-1, -1) and check(p, places[int(target.substr(4))].cond)
	if target.begins_with("monster:"):
		return target_cell(target) != Vector2i(-1, -1) and monster_here(p, int(target.substr(8)))
	if target.begins_with("npc:") and not npc_visible(p, target.substr(4)):
		return false
	return target_cell(target) != Vector2i(-1, -1)


## Ist der NPC für diesen Spieler gerade da? (z. B. Ye erst in der Gilde, später am Stadttor; nur auf der eigenen Karte)
func npc_visible(p: PlayerState, npc_id: String) -> bool:
	return npcs.has(npc_id) and npcs[npc_id].map == p.map and check(p, npcs[npc_id].cond)


## Das Nächste, das der Spieler direkt nebenan benutzen kann ("" = nichts).
func usable_near(p: PlayerState) -> String:
	var best := ""
	var best_dist := USE_RANGE
	var targets: Array[String] = []
	for id: String in npcs:
		targets.append("npc:" + id)
	for i in pickups.size():
		targets.append("punkt:%d" % i)
	for i in places.size():
		targets.append("ort:%d" % i)
	for i in monsters.size():
		targets.append("monster:%d" % i)
	for target in targets:
		if not can_use(p, target):
			continue
		var dist := (Vector2(target_cell(target)) - p.pos).length()
		if dist < best_dist:
			best = target
			best_dist = dist
	return best


## Hinlaufen und benutzen (NPC: auf ein freies Nachbarfeld, Sammelpunkt und Ort: drauf).
func _go_use(p: PlayerState, target: String) -> void:
	if p.in_dialog() or not can_use(p, target):
		return
	var cell := target_cell(target)
	var spot := cell if not target.begins_with("npc:") and is_walkable(cell, p.map) else _free_neighbor(cell, p.cell, p.map)
	if spot == Vector2i(-1, -1):
		return
	p.use_target = target
	_walk_to(p, spot)


func _walk_to(p: PlayerState, target: Vector2i) -> void:
	# Läuft der Spieler gerade, geht es vom nächsten Feld aus weiter
	var start := p.path[0] if p.is_moving() else p.cell
	var route := get_map(p.map).astar.get_id_path(start, target)
	var path: Array[Vector2i] = []
	if p.is_moving():
		path.append(start)
	elif p.pos != Vector2(p.cell):
		# Zwischen zwei Feldern stehen geblieben (z. B. weil jemand dich angesprochen hat): erst zurück aufs Feld
		path.append(p.cell)
	for i in range(1, route.size()):
		path.append(route[i])
	p.path = path


## Freies Nachbarfeld, das am nächsten am Spieler liegt.
func _free_neighbor(npc_cell: Vector2i, from: Vector2i, map_id := KREUZWEG) -> Vector2i:
	var best := Vector2i(-1, -1)
	for dir: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
			Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
		var cell := npc_cell + dir
		if is_walkable(cell, map_id) and (best == Vector2i(-1, -1) or (cell - from).length() < (best - from).length()):
			best = cell
	return best


## Freies Laufen: Schritt in Steuer-Richtung. Vor Häusern, Bäumen und NPCs wird an der Wand entlang gerutscht.
func _steer(p: PlayerState, delta: float) -> void:
	var move := p.steer * WALK_SPEED * delta
	for attempt: Vector2 in [move, Vector2(move.x, 0), Vector2(0, move.y)]:
		if attempt == Vector2.ZERO:
			continue
		var next := p.pos + attempt
		var cell := Vector2i(next.round())
		if is_walkable(cell, p.map):
			p.pos = next
			p.cell = cell
			break
	var screen_x := p.steer.x - p.steer.y
	if absf(screen_x) > 0.01:
		p.facing = 1 if screen_x > 0 else -1


## Spielt die Welt um "delta" Sekunden weiter (Laufen, Benutzen nach der Ankunft).
func tick(delta: float) -> void:
	_time += delta
	_tick_scenes(delta)
	for p: PlayerState in players.values():
		move_player(p, delta)
		_check_exits(p)
		_check_monsters(p)
		_check_approach(p)
		if not p.is_moving() and p.use_target != "":
			var target := p.use_target
			p.use_target = ""
			if (Vector2(target_cell(target)) - p.pos).length() < USE_RANGE:
				_use(p, target)


## Nur das Laufen eines Spielers (frei gesteuert oder einen Weg entlang), ohne Reden und Benutzen.
## Beim Zusammenspielen bewegt ein Mitspieler damit seine eigene Figur sofort, ohne auf den Gastgeber zu warten.
func move_player(p: PlayerState, delta: float) -> void:
	if p.steer != Vector2.ZERO:
		_steer(p, delta)
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


func _use(p: PlayerState, target: String) -> void:
	if not can_use(p, target):
		return
	if target.begins_with("monster:"):
		_start_wild(p, int(target.substr(8)))
		return
	if target.begins_with("npc:"):
		var npc_id := target.substr(4)
		p.progress.flags["geredet:" + npc_id] = true
		_update_quests(p)
		_start_talk(p, npc_id)
	elif target.begins_with("ort:"):
		var place: Dictionary = places[int(target.substr(4))]
		if place.text != "":
			_say(p, place.text)
		if place.dialog != "":
			start_dialog(p, place.dialog)
		run_actions(p, place.actions)
		progress_changed.emit(p.id)
	else:
		var pickup: Dictionary = pickups[int(target.substr(6))]
		p.progress.flags["gesammelt:" + target] = true
		_give_item(p, pickup.item, 1)
		_update_quests(p)
		progress_changed.emit(p.id)


# --- Dialoge ------------------------------------------------------------------

## Beginnt ein Gespräch: Der erste Einstieg, dessen Bedingung passt, gilt.
func start_dialog(p: PlayerState, dialog_id: String) -> void:
	var d := GameData.dialog(dialog_id)
	for entry: Dictionary in d.get("einstieg", []):
		if check(p, entry.get("wenn", {})):
			p.path.clear()
			p.steer = Vector2.ZERO
			_enter_node(p, dialog_id, entry.knoten)
			return


func _enter_node(p: PlayerState, dialog_id: String, node_id: String) -> void:
	var node: Dictionary = GameData.dialog(dialog_id).get("knoten", {}).get(node_id, {})
	if node.is_empty():
		p.dialog = {}
		return
	p.dialog = {id = dialog_id, node = node_id}
	run_actions(p, node.get("aktionen", []))


## Was der Spieler gerade im Gespräch sieht: {wer, text, antworten (nur die erlaubten)}. Leer = kein Gespräch.
## In einer gemeinsamen Szene kommt "szene" dazu: {rolle, sprecher, stimmen, meine, offen, zeit, teilnehmer}.
func dialog_view(p: PlayerState) -> Dictionary:
	if not p.in_dialog():
		return {}
	# Mitspieler: Die Ansicht der Szene hat der Gastgeber schon berechnet
	if p.dialog.has("ansicht"):
		return p.dialog.ansicht
	if p.dialog.has("szene") and scenes.has(p.dialog.szene):
		return _scene_view(p, scenes[p.dialog.szene])
	var node := _current_node(p)
	var answers: Array[String] = []
	for a in _visible_answers(p, node):
		answers.append(a.text)
	return {wer = node.get("wer", ""), text = fill_text(p, node.get("text", "")), antworten = answers}


## Gesprächszustand zum Verschicken an einen Mitspieler (in einer Szene mit fertiger Ansicht, weil das Spiegelbild
## die Szene selbst nicht kennt).
func dialog_for_sync(p: PlayerState) -> Dictionary:
	if not p.dialog.has("szene"):
		return p.dialog
	var d := p.dialog.duplicate()
	d["ansicht"] = dialog_view(p)
	return d


func _current_node(p: PlayerState) -> Dictionary:
	return GameData.dialog(p.dialog.id).get("knoten", {}).get(p.dialog.node, {})


func _visible_answers(p: PlayerState, node: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for a: Dictionary in node.get("antworten", []):
		if check(p, a.get("wenn", {})):
			result.append(a)
	return result


func _dialog_next(p: PlayerState) -> void:
	if not p.in_dialog():
		return
	if p.dialog.has("szene"):
		_scene_next(p)
		return
	var node := _current_node(p)
	if not _visible_answers(p, node).is_empty():
		return
	if node.has("weiter"):
		_enter_node(p, p.dialog.id, node.weiter)
	else:
		p.dialog = {}


func _dialog_choose(p: PlayerState, index: int) -> void:
	if not p.in_dialog():
		return
	if p.dialog.has("szene"):
		_scene_vote(p, index)
		return
	var answers := _visible_answers(p, _current_node(p))
	if index < 0 or index >= answers.size():
		return
	var answer := answers[index]
	var dialog_id: String = p.dialog.id
	run_actions(p, answer.get("aktionen", []))
	if answer.has("weiter"):
		_enter_node(p, dialog_id, answer.weiter)
	else:
		p.dialog = {}


# --- Gemeinsame Szenen ----------------------------------------------------------

## Ein Effekt für einen Spieler – oder für alle in der Stadt (Sternenfall), dann nur einmal, auch wenn mehrere ihn auslösen.
func _effect(p: PlayerState, effect: String) -> void:
	if not effect in GLOBAL_EFFECTS:
		effect_requested.emit(p.id, effect)
		return
	if _time - float(_effect_time.get(effect, -INF)) < 3.0:
		return
	_effect_time[effect] = _time
	for id: String in players:
		if players[id].map == p.map:
			effect_requested.emit(id, effect)


## Ein Gruppenkampf beginnt (Netz): Danach warten alle Beteiligten aufeinander, bevor sie jemand anspricht.
func add_battle_group(ids: Array) -> void:
	battle_groups.append({ids = ids.duplicate(), back = {}, time = _time})


## Ein Spieler ist aus dem Kampf zurück. Sind alle da, ist die Gruppe nicht mehr gesperrt.
func _back_from_battle(id: String) -> void:
	for g: Dictionary in battle_groups.duplicate():
		if id in g.ids:
			g.back[id] = true
			if g.back.size() >= g.ids.size():
				battle_groups.erase(g)


## Ein Spieler hat das Spiel verlassen: Auf ihn wird nicht mehr gewartet.
func battle_member_gone(id: String) -> void:
	for g: Dictionary in battle_groups.duplicate():
		g.ids.erase(id)
		g.back.erase(id)
		if g.ids.is_empty() or g.back.size() >= g.ids.size():
			battle_groups.erase(g)


## Wartet dieser Spieler noch auf Mitspieler aus einem gemeinsamen Kampf?
func waiting_for_group(id: String) -> bool:
	for g: Dictionary in battle_groups:
		if id in g.ids and _time - float(g.time) < BATTLE_WAIT_MAX:
			return true
	return false


## Ein Spieler spricht eine Figur an: allein wie immer, in einer Gruppe mit Mitgliedern in der Nähe als gemeinsame Szene.
## approach_flag: Spricht die Figur von sich aus an (Marv, Ren), gilt das für alle, die mit abstimmen.
func _start_talk(p: PlayerState, npc_id: String, approach_flag := "") -> void:
	var dialog_id: String = npcs[npc_id].dialog
	var entry := _entry_node(p, dialog_id)
	var partners: Array[PlayerState] = []
	for id: String in group_members.call(p.id):
		var other: PlayerState = players.get(id)
		if other != null and other != p and not other.in_dialog() and other.shop == "" and other.map == p.map \
				and other.pos.distance_to(p.pos) <= SCENE_RANGE:
			partners.append(other)
	if partners.is_empty() or entry == "":
		start_dialog(p, dialog_id)
		return
	var voters: Array[String] = [p.id]
	var watchers: Array[String] = []
	for other in partners:
		# Abstimmen darf, wer in der Geschichte an derselben Stelle ist (gleicher Einstieg ins Gespräch)
		var flag := "geredet:" + npc_id
		var had_flag := other.progress.flags.has(flag)
		other.progress.flags[flag] = true
		if npc_visible(other, npc_id) and _entry_node(other, dialog_id) == entry:
			voters.append(other.id)
			if approach_flag != "":
				other.progress.flags[approach_flag] = true
			_update_quests(other)
		else:
			if not had_flag:
				other.progress.flags.erase(flag)
			watchers.append(other.id)
		other.path.clear()
		other.steer = Vector2.ZERO
		other.use_target = ""
	p.path.clear()
	p.steer = Vector2.ZERO
	var sid := _next_scene
	_next_scene += 1
	scenes[sid] = {dialog = dialog_id, node = "", speaker = p.id, voters = voters, watchers = watchers, votes = {}, time_left = VOTE_SECONDS}
	for id: String in voters + watchers:
		if id != p.id:
			notice.emit(id, "Gemeinsame Szene: %s spricht mit %s." % [p.display_name, npcs[npc_id].name])
	_scene_enter(sid, entry)


## Erster passender Einstieg eines Gesprächs für diesen Spieler ("" = keiner).
func _entry_node(p: PlayerState, dialog_id: String) -> String:
	for entry: Dictionary in GameData.dialog(dialog_id).get("einstieg", []):
		if check(p, entry.get("wenn", {})):
			return entry.knoten
	return ""


func _scene_members(scene: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for id: String in scene.voters + scene.watchers:
		if players.has(id):
			result.append(id)
	return result


## Alle in der Szene gehen zum nächsten Knoten. Aktionen (Aufträge, Belohnungen …) gelten für alle, die abstimmen.
func _scene_enter(sid: int, node_id: String) -> void:
	var scene: Dictionary = scenes[sid]
	var node: Dictionary = GameData.dialog(scene.dialog).get("knoten", {}).get(node_id, {})
	if node.is_empty():
		_end_scene(sid)
		return
	scene.node = node_id
	scene.votes = {}
	scene.time_left = VOTE_SECONDS
	for id in _scene_members(scene):
		players[id].dialog = {id = scene.dialog, node = node_id, szene = sid}
	_scene_actions(scene, node.get("aktionen", []))


## Aktionen einer Szene für alle, die abstimmen. Ein Kampf wird zum Gruppenkampf, wenn mehrere dabei sind.
func _scene_actions(scene: Dictionary, actions: Array) -> void:
	var voters: Array[String] = []
	for id: String in scene.voters:
		if players.has(id):
			voters.append(id)
	var kampf := ""
	var rest: Array = []
	for action: Dictionary in actions:
		if action.has("kampf") and voters.size() > 1:
			kampf = action.kampf
			var other := action.duplicate()
			other.erase("kampf")
			if not other.is_empty():
				rest.append(other)
		else:
			rest.append(action)
	for id in voters:
		if players.has(id):
			run_actions(players[id], rest)
	if kampf != "":
		group_battle_requested.emit(voters, kampf)


func _end_scene(sid: int) -> void:
	var scene: Dictionary = scenes.get(sid, {})
	for id in _scene_members(scene):
		if players[id].dialog.get("szene", -1) == sid:
			players[id].dialog = {}
	scenes.erase(sid)


func _scene_speaker(scene: Dictionary) -> PlayerState:
	return players.get(scene.speaker)


## Weiterblättern (ohne Antworten): nur wer spricht.
func _scene_next(p: PlayerState) -> void:
	var sid: int = p.dialog.szene
	var scene: Dictionary = scenes.get(sid, {})
	if scene.is_empty() or scene.speaker != p.id:
		return
	var node := _current_node(p)
	if not _visible_answers(p, node).is_empty():
		return
	if node.has("weiter"):
		_scene_enter(sid, node.weiter)
	else:
		_end_scene(sid)


## Stimme abgeben. Haben alle gewählt, wird entschieden.
func _scene_vote(p: PlayerState, index: int) -> void:
	var sid: int = p.dialog.szene
	var scene: Dictionary = scenes.get(sid, {})
	if scene.is_empty() or not p.id in scene.voters:
		return
	var speaker := _scene_speaker(scene)
	var answers := _visible_answers(speaker, _current_node(speaker))
	if index < 0 or index >= answers.size():
		return
	scene.votes[p.id] = index
	var open := 0
	for id: String in scene.voters:
		if players.has(id) and not scene.votes.has(id):
			open += 1
	if open == 0:
		_scene_decide(sid)


## Die Antwort mit den meisten Stimmen gilt. Bei Gleichstand entscheidet der Gruppenführer
## (hat er nicht mit abgestimmt: wer spricht, sonst die erste der gleichauf liegenden Antworten).
func scene_result(votes: Dictionary, leader: String, speaker: String) -> int:
	var counts := {}
	for id: String in votes:
		counts[votes[id]] = counts.get(votes[id], 0) + 1
	var best := 0
	for c: int in counts.values():
		best = maxi(best, c)
	var tied: Array[int] = []
	for index: int in counts:
		if counts[index] == best:
			tied.append(index)
	tied.sort()
	if tied.size() > 1:
		if votes.has(leader) and votes[leader] in tied:
			return votes[leader]
		if votes.has(speaker) and votes[speaker] in tied:
			return votes[speaker]
	return tied[0] if not tied.is_empty() else -1


func _scene_decide(sid: int) -> void:
	var scene: Dictionary = scenes[sid]
	var speaker := _scene_speaker(scene)
	var answers := _visible_answers(speaker, _current_node(speaker))
	var index := scene_result(scene.votes, group_leader.call(speaker.id), speaker.id)
	if index < 0 or index >= answers.size():
		return
	var answer := answers[index]
	if scene.votes.size() > 1:
		for id in _scene_members(scene):
			notice.emit(id, "Die Gruppe hat gewählt: „%s“" % answer.text)
	_scene_actions(scene, answer.get("aktionen", []))
	if not scenes.has(sid):
		return
	if answer.has("weiter"):
		_scene_enter(sid, answer.weiter)
	else:
		_end_scene(sid)


## Ein Spieler verlässt die Szene (Knopf, Kampf oder Spiel verlassen). Wer spricht, wird ersetzt;
## ist niemand mehr da, der abstimmen darf, ist die Szene vorbei.
func _leave_scene(p: PlayerState) -> void:
	if not p.dialog.has("szene"):
		return
	var sid: int = p.dialog.szene
	p.dialog = {}
	var scene: Dictionary = scenes.get(sid, {})
	if scene.is_empty():
		return
	scene.voters.erase(p.id)
	scene.watchers.erase(p.id)
	scene.votes.erase(p.id)
	var voters: Array[String] = []
	for id: String in scene.voters:
		if players.has(id):
			voters.append(id)
	if voters.is_empty():
		_end_scene(sid)
		return
	if scene.speaker == p.id:
		scene.speaker = voters[0]
	if scene.votes.size() >= voters.size() and not scene.votes.is_empty():
		_scene_decide(sid)


## Läuft die Zeit für eine Abstimmung ab, zählen die abgegebenen Stimmen.
func _tick_scenes(delta: float) -> void:
	for sid: int in scenes.keys():
		var scene: Dictionary = scenes.get(sid, {})
		if scene.is_empty():
			continue
		scene.time_left -= delta
		if scene.time_left <= 0.0:
			scene.time_left = VOTE_SECONDS
			if not scene.votes.is_empty():
				_scene_decide(sid)


func _scene_view(p: PlayerState, scene: Dictionary) -> Dictionary:
	var speaker := _scene_speaker(scene)
	if speaker == null:
		return {}
	var node := _current_node(speaker)
	var answers: Array[String] = []
	var votes: Array[int] = []
	for a in _visible_answers(speaker, node):
		answers.append(a.text)
		votes.append(0)
	for id: String in scene.votes:
		if scene.votes[id] < votes.size():
			votes[scene.votes[id]] += 1
	var open := 0
	for id: String in scene.voters:
		if players.has(id) and not scene.votes.has(id):
			open += 1
	var role := "spricht" if p.id == speaker.id else ("abstimmen" if p.id in scene.voters else "zuschauen")
	return {wer = node.get("wer", ""), text = fill_text(p, node.get("text", "")), antworten = answers,
			szene = {rolle = role, sprecher = speaker.display_name, stimmen = votes, meine = scene.votes.get(p.id, -1),
				offen = open, zeit = ceili(scene.time_left), teilnehmer = _scene_members(scene).size()}}


# --- Bedingungen und Aktionen (aus den Datendateien) --------------------------

## Prüft eine Bedingung aus den Dialog-Daten. Leere Bedingung = immer erfüllt.
func check(p: PlayerState, cond: Dictionary) -> bool:
	# {"und": [Bedingung, Bedingung, …]}: alle müssen stimmen (z. B. zwei Aufträge gleichzeitig)
	for part: Dictionary in cond.get("und", []):
		if not check(p, part):
			return false
	# {"oder": [Bedingung, Bedingung, …]}: eine reicht
	if cond.has("oder") and not cond.oder.any(func(part: Dictionary) -> bool: return check(p, part)):
		return false
	if cond.has("auftrag") and p.progress.quest_state(cond.auftrag) != cond.get("stand", "aktiv"):
		return false
	if cond.has("gemerkt") and not p.progress.flags.has(cond.gemerkt):
		return false
	if cond.has("nicht_gemerkt") and p.progress.flags.has(cond.nicht_gemerkt):
		return false
	if cond.has("stufe_ab") and p.progress.level < int(cond.stufe_ab):
		return false
	# {"region": "Grünwacht"}: Die gewählte Klasse gehört in diese Region ({"nicht_region": …} = gerade nicht)
	if cond.has("region") and _class_region(p) != cond.region:
		return false
	if cond.has("nicht_region") and _class_region(p) == cond.nicht_region:
		return false
	# {"klasse": "archer"}: genau diese Klasse gewählt
	if cond.has("klasse") and str(p.progress.flags.get("klasse", "")) != cond.klasse:
		return false
	return true


func _class_region(p: PlayerState) -> String:
	return str(Sandbox.CLASSES.get(str(p.progress.flags.get("klasse", "")), {}).get("region", ""))


func run_actions(p: PlayerState, actions: Array) -> void:
	if actions.is_empty():
		return
	for action: Dictionary in actions:
		if action.has("auftrag_starten"):
			_start_quest(p, action.auftrag_starten)
		if action.has("auftrag_abgeben"):
			_turn_in_quest(p, action.auftrag_abgeben)
		if action.has("gold"):
			_give_gold(p, int(action.gold))
		if action.has("erfahrung"):
			_give_xp(p, int(action.erfahrung))
		if action.has("gegenstand"):
			_give_item(p, action.gegenstand, int(action.get("anzahl", 1)))
		if action.has("merken"):
			p.progress.flags[action.merken] = true
		if action.has("laden"):
			p.shop = action.laden
		if action.has("vergessen"):
			p.progress.flags.erase(action.vergessen)
		if action.has("szene"):
			scene_requested.emit(p.id, action.szene)
		if action.has("effekt"):
			_effect(p, action.effekt)
		if action.has("erfolg"):
			_unlock(p, action.erfolg)
		if action.has("kampf"):
			battle_requested.emit(p.id, action.kampf)
		if action.has("monster_geben"):
			_add_to_pack(p, action.monster_geben)
		if action.has("reisen"):
			# {"reisen": "wipfelheim", "feld": [x, y]}: auf eine andere Karte (z. B. mit dem Seilaufzug)
			var to: Array = action.get("feld", [-1, -1])
			change_map(p, action.reisen, Vector2i(int(to[0]), int(to[1])))
	_update_quests(p)
	progress_changed.emit(p.id)


# --- Aufträge, Gold, Gegenstände, Erfahrung -----------------------------------

func _start_quest(p: PlayerState, id: String) -> void:
	var q := GameData.quest(id)
	if q.is_empty() or p.progress.quest_state(id) != "neu":
		return
	p.progress.quests[id] = "aktiv"
	_say(p, GameData.text("nebenauftrag_neu" if q.get("neben", false) else "auftrag_neu", [q.titel]))


## Sind alle Ziele eines Auftrags erfüllt?
func quest_goals_met(p: PlayerState, id: String) -> bool:
	for goal: Dictionary in GameData.quest(id).get("ziele", []):
		match goal.art:
			"sammeln":
				if p.progress.item_count(goal.gegenstand) < int(goal.anzahl):
					return false
			"reden":
				if not p.progress.flags.has("geredet:" + str(goal.npc)):
					return false
			"gemerkt":
				if not p.progress.flags.has(goal.merken):
					return false
			"kampf":
				if not p.progress.flags.has("kampf_gewonnen:" + str(goal.kampf)):
					return false
	return true


## Ist dieses eine Ziel erfüllt?
func goal_done(p: PlayerState, goal: Dictionary) -> bool:
	match goal.art:
		"sammeln":
			return p.progress.item_count(goal.gegenstand) >= int(goal.anzahl)
		"reden":
			return p.progress.flags.has("geredet:" + str(goal.npc))
		"gemerkt":
			return p.progress.flags.has(goal.merken)
		"kampf":
			return p.progress.flags.has("kampf_gewonnen:" + str(goal.kampf))
	return true


## Fortschritt eines Ziels als Text, z. B. "Silberkraut 2 / 3".
func goal_text(p: PlayerState, goal: Dictionary) -> String:
	match goal.art:
		"sammeln":
			var have := mini(p.progress.item_count(goal.gegenstand), int(goal.anzahl))
			return "%s %d / %d" % [GameData.item_name(goal.gegenstand), have, int(goal.anzahl)]
		"reden":
			var npc: Dictionary = npcs.get(goal.npc, {name = goal.npc})
			var done := p.progress.flags.has("geredet:" + str(goal.npc))
			return "Mit %s reden%s" % [npc.name, " (erledigt)" if done else ""]
		"gemerkt", "kampf":
			return "%s%s" % [goal.get("text", goal.get("merken", goal.get("kampf", ""))), " (erledigt)" if goal_done(p, goal) else ""]
	return ""


## Was der Spieler als Nächstes tun soll (für den Hinweis „Ziel: …“). "" = nichts offen.
## Hauptaufträge gehen vor, Nebenaufträge stehen nur da, wenn in der Geschichte gerade nichts offen ist.
func objective(p: PlayerState) -> String:
	for side: bool in [false, true]:
		for id: String in p.progress.quests:
			var q := GameData.quest(id)
			var quest_state: String = p.progress.quests[id]
			if q.is_empty() or quest_state == "abgegeben" or bool(q.get("neben", false)) != side:
				continue
			var prefix := GameData.text("nebenauftrag_ziel") if side else ""
			if quest_state == "fertig":
				var giver: Dictionary = npcs.get(q.get("abgeben_bei", ""), {name = "Auftraggeber"})
				return prefix + "Zurück zu %s" % giver.name
			for goal: Dictionary in q.get("ziele", []):
				if not goal_done(p, goal):
					return prefix + goal_text(p, goal)
	return ""


## Zeichen über einem NPC: "!" = neuer Auftrag, "?" = hier etwas erledigen oder abgeben, "" = nichts.
func npc_marker(p: PlayerState, npc_id: String) -> String:
	return _marker(p, npc_id)[0]


## Gehört das Zeichen über dem NPC zu einem Nebenauftrag? (Dann ist es blau statt gelb.)
func npc_marker_side(p: PlayerState, npc_id: String) -> bool:
	return _marker(p, npc_id)[1]


## [Zeichen, Nebenauftrag?]. Hauptaufträge gehen vor: erst „?“ und „!“ der Geschichte, dann die der Nebenaufträge.
func _marker(p: PlayerState, npc_id: String) -> Array:
	if not npc_visible(p, npc_id):
		return ["", false]
	var all_quests := GameData.get_file("auftraege")
	for side: bool in [false, true]:
		for id: String in all_quests:
			var q: Dictionary = all_quests[id]
			if bool(q.get("neben", false)) != side:
				continue
			var quest_state := p.progress.quest_state(id)
			if quest_state == "fertig" and q.get("abgeben_bei", "") == npc_id:
				return ["?", side]
			if quest_state == "aktiv":
				for goal: Dictionary in q.get("ziele", []):
					if goal.get("bei", "") == npc_id and not goal_done(p, goal) and check(p, goal.get("wenn", {})):
						return ["?", side]
		for id: String in all_quests:
			var q: Dictionary = all_quests[id]
			# start_wenn: nur für manche Spieler (z. B. Fenns Prüfung nur für Bogenschützen)
			if bool(q.get("neben", false)) == side and q.get("start_bei", "") == npc_id and p.progress.quest_state(id) == "neu" \
					and (not q.has("voraussetzung") or p.progress.quest_state(q.voraussetzung) == "abgegeben") \
					and check(p, q.get("start_wenn", {})):
				return ["!", side]
	return ["", false]


## Aktive Aufträge werden "fertig", sobald alle Ziele erfüllt sind (und wieder "aktiv", falls nicht mehr).
func _update_quests(p: PlayerState) -> void:
	for id: String in p.progress.quests.keys():
		if GameData.quest(id).is_empty():
			# Auftrag gibt es in den Daten nicht mehr (alter Spielstand)
			continue
		var state: String = p.progress.quests[id]
		var met := quest_goals_met(p, id)
		if state == "aktiv" and met:
			p.progress.quests[id] = "fertig"
			_say(p, GameData.text("auftrag_fertig", [GameData.quest(id).titel]))
		elif state == "fertig" and not met:
			p.progress.quests[id] = "aktiv"


func _turn_in_quest(p: PlayerState, id: String) -> void:
	# Wurde das letzte Ziel gerade eben erfüllt (z. B. im selben Gespräch), gilt der Auftrag ohne Extra-Meldung als fertig
	if p.progress.quest_state(id) == "aktiv" and quest_goals_met(p, id):
		p.progress.quests[id] = "fertig"
	if p.progress.quest_state(id) != "fertig":
		return
	var q := GameData.quest(id)
	for goal: Dictionary in q.get("ziele", []):
		if goal.art == "sammeln":
			_give_item(p, goal.gegenstand, -int(goal.anzahl))
	p.progress.quests[id] = "abgegeben"
	_say(p, GameData.text("auftrag_abgegeben", [q.titel]))
	var reward: Dictionary = q.get("belohnung", {})
	if reward.has("gold"):
		_give_gold(p, int(reward.gold))
	if reward.has("erfahrung"):
		_give_xp(p, int(reward.erfahrung))
	var reward_items: Dictionary = reward.get("gegenstaende", {})
	for item_id: String in reward_items:
		_give_item(p, item_id, int(reward_items[item_id]))


## Gegenstand aus der Tasche benutzen (z. B. die Bürste an der Statue). Wo und was dann passiert, steht in
## data/gegenstaende.json unter "benutzen": {"feld": [x, y], "radius": 3, "dialog": "…", "sonst": "Meldung"}.
func _use_item(p: PlayerState, item_id: String) -> void:
	var use: Dictionary = GameData.item(item_id).get("benutzen", {})
	if use.is_empty() or p.in_dialog() or p.progress.item_count(item_id) <= 0:
		return
	var spot := Vector2(float(use.feld[0]), float(use.feld[1]))
	if use.get("karte", KREUZWEG) != p.map or (spot - p.pos).length() > float(use.get("radius", 2.0)):
		_say(p, use.get("sonst", GameData.text("benutzen_nicht_hier", [GameData.item_name(item_id)])))
		return
	p.path.clear()
	p.use_target = ""
	start_dialog(p, use.dialog)
	progress_changed.emit(p.id)


func _give_gold(p: PlayerState, amount: int) -> void:
	p.progress.gold += amount
	_say(p, GameData.text("gold", [amount]))


func _give_xp(p: PlayerState, amount: int) -> void:
	var reached := p.progress.add_xp(amount)
	_say(p, GameData.text("erfahrung", [amount]))
	for level in reached:
		_say(p, GameData.text("stufe", [level, Grundwerte.growth_text()]))
		if level == 2:
			_say(p, GameData.text("werte_tipp"))


func _give_item(p: PlayerState, item_id: String, count: int) -> void:
	p.progress.add_item(item_id, count)
	if count > 0:
		_say(p, GameData.text("gegenstand", [count, GameData.item_name(item_id)]))
	else:
		_say(p, GameData.text("gegenstand_weg", [-count, GameData.item_name(item_id)]))


# --- Rudel des Zähmers -------------------------------------------------------------

## Ein Monster kommt ins Rudel (Start-Monster von Esche oder in der Wildnis gezähmt). Höchstens Sandbox.MAX_MONSTERS.
func _add_to_pack(p: PlayerState, monster_id: String, tamed := false) -> void:
	if not Sandbox.MONSTERS.has(monster_id) and not Sandbox.ENEMIES.has(monster_id):
		return
	var pack: Array = p.progress.flags.get("monster", []).duplicate()
	var name: String = Sandbox.MONSTERS.get(monster_id, Sandbox.ENEMIES.get(monster_id, {})).name
	if pack.size() >= Sandbox.MAX_MONSTERS:
		_say(p, GameData.text("rudel_voll", [name]))
		return
	pack.append(monster_id)
	p.progress.flags["monster"] = pack
	if tamed:
		p.progress.flags["erstes_zaehmen"] = true
	_say(p, GameData.text("rudel_neu", [name]))
	_update_quests(p)
	progress_changed.emit(p.id)


# --- Monster in der Wildnis ------------------------------------------------------

## Steht das Monster für diesen Spieler gerade da? (Nach einem Sieg ist es eine Weile weg.)
func monster_here(p: PlayerState, index: int) -> bool:
	var beaten := float(p.progress.flags.get("besiegt:monster:%d" % index, -INF))
	return Time.get_unix_time_from_system() - beaten >= MONSTER_RESPAWN


## Läuft der Spieler in ein Monster hinein, beginnt der Kampf.
func _check_monsters(p: PlayerState) -> void:
	if p.in_dialog() or p.shop != "" or _fighting.has(p.id) or waiting_for_group(p.id):
		return
	for i in monsters.size():
		var m: Dictionary = monsters[i]
		if m.karte == p.map and (Vector2(m.feld) - p.pos).length() < MONSTER_TOUCH and monster_here(p, i):
			_start_wild(p, i)
			return


## Kampf gegen ein Monster: allein oder mit den Gruppenmitgliedern in der Nähe (wie bei gemeinsamen Szenen).
func _start_wild(p: PlayerState, index: int) -> void:
	if _fighting.has(p.id) or p.in_dialog():
		return
	var ids: Array[String] = [p.id]
	for id: String in group_members.call(p.id):
		var other: PlayerState = players.get(id)
		if other != null and other != p and other.map == p.map and not other.in_dialog() and other.shop == "" \
				and not _fighting.has(id) and other.pos.distance_to(p.pos) <= SCENE_RANGE:
			ids.append(id)
	for id in ids:
		_fighting[id] = true
		players[id].path.clear()
		players[id].steer = Vector2.ZERO
		players[id].use_target = ""
	var kampf := "wild:%d" % index
	if ids.size() > 1:
		for id in ids:
			if id != p.id:
				notice.emit(id, GameData.text("wild_gruppe", [p.display_name]))
		group_battle_requested.emit(ids, kampf)
	else:
		battle_requested.emit(p.id, kampf)


# --- NPCs, die einen ansprechen ------------------------------------------------

## Manche NPCs (z. B. Marv) sprechen dich von sich aus an, sobald du nah genug bist – einmal.
func _check_approach(p: PlayerState) -> void:
	if p.in_dialog() or p.shop != "" or waiting_for_group(p.id):
		return
	for id: String in npcs:
		var approach: Dictionary = npcs[id].approach
		if approach.is_empty() or p.progress.flags.has("angesprochen:" + id) or not npc_visible(p, id) \
				or not check(p, approach.get("wenn", {})):
			continue
		if (Vector2(npcs[id].cell) - p.pos).length() <= float(approach.get("radius", 3)):
			p.progress.flags["angesprochen:" + id] = true
			p.use_target = ""
			# Gruppenmitglieder in der Nähe erleben das mit (z. B. Marv auf dem Fest, Ren nach dem Sternenfresser)
			_start_talk(p, id, "angesprochen:" + id)
			return


# --- Laden ----------------------------------------------------------------------

## Waren eines Ladens: [{gegenstand, preis}] (Preise aus data/gegenstaende.json).
func shop_wares(shop_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item_id: String in GameData.get_file("laeden").get(shop_id, {}).get("waren", []):
		result.append({gegenstand = item_id, preis = int(GameData.item(item_id).get("preis", 0))})
	return result


## Was der Laden für einen Gegenstand zahlt (0 = kauft er nicht an).
func sell_price(shop_id: String, item_id: String) -> int:
	var factor: float = GameData.get_file("laeden").get(shop_id, {}).get("ankauf", 0.5)
	return int(floor(int(GameData.item(item_id).get("preis", 0)) * factor))


func _buy(p: PlayerState, item_id: String) -> void:
	if p.shop == "":
		return
	for ware in shop_wares(p.shop):
		if ware.gegenstand != item_id:
			continue
		if p.progress.gold < ware.preis:
			_say(p, GameData.text("zu_wenig_gold", [GameData.item_name(item_id), ware.preis]))
			return
		p.progress.gold -= ware.preis
		_say(p, GameData.text("gold_weg", [ware.preis]))
		_give_item(p, item_id, 1)
		_update_quests(p)
		progress_changed.emit(p.id)
		return


func _sell(p: PlayerState, item_id: String) -> void:
	if p.shop == "" or p.progress.item_count(item_id) <= 0:
		return
	var price := sell_price(p.shop, item_id)
	if price <= 0:
		return
	_give_item(p, item_id, -1)
	_give_gold(p, price)
	_update_quests(p)
	progress_changed.emit(p.id)


## Ergebnis eines Kampfes: Beim ersten Sieg gibt es die Erfahrung aus data/kaempfe.json, Aufträge zählen mit.
func _battle_result(p: PlayerState, kampf_id: String, won: bool) -> void:
	var battle: Dictionary = GameData.battle(kampf_id)
	if battle.is_empty():
		return
	if battle.get("wild", false):
		_wild_result(p, kampf_id, battle, won)
		return
	# Manche Kämpfe gehen die Geschichte in jedem Fall weiter (Sternenfall: Ren rettet oder klaut)
	if battle.has("merken_immer"):
		p.progress.flags[battle.merken_immer] = true
	if not won:
		_say(p, battle.get("verloren_text", GameData.text("kampf_verloren")))
		_update_quests(p)
		progress_changed.emit(p.id)
		return
	_say(p, GameData.text("kampf_gewonnen", [battle.get("name", kampf_id)]))
	if battle.has("merken"):
		p.progress.flags[battle.merken] = true
	if battle.has("erfolg"):
		_unlock(p, battle.erfolg)
	var flag := "kampf_gewonnen:" + kampf_id
	if not p.progress.flags.has(flag):
		p.progress.flags[flag] = true
		if battle.has("erfahrung"):
			_give_xp(p, int(battle.erfahrung))
	_update_quests(p)
	progress_changed.emit(p.id)


## Monster in der Wildnis: Jeder Sieg bringt Erfahrung und etwas Gold, das Monster ist dann eine Weile weg.
## Bei einer Niederlage wacht man am Start der Karte wieder auf.
func _wild_result(p: PlayerState, kampf_id: String, battle: Dictionary, won: bool) -> void:
	if won:
		_say(p, GameData.text("kampf_gewonnen", [battle.get("name", kampf_id)]))
		p.progress.flags["besiegt:monster:%d" % int(kampf_id.substr(5))] = Time.get_unix_time_from_system()
		_give_gold(p, int(battle.get("gold", 0)))
		_give_xp(p, int(battle.get("erfahrung", 0)))
	else:
		_say(p, GameData.text("wild_verloren"))
		var start := get_map(p.map).start
		p.path.clear()
		p.cell = start
		p.pos = Vector2(start)
	_update_quests(p)
	progress_changed.emit(p.id)


## Ein Erfolg (data/erfolge.json) wird freigeschaltet – jeder nur einmal.
func _unlock(p: PlayerState, id: String) -> void:
	if p.progress.flags.has("erfolg:" + id):
		return
	p.progress.flags["erfolg:" + id] = true
	var data: Dictionary = GameData.get_file("erfolge").get(id, {name = id})
	_say(p, GameData.text("erfolg", [data.name]))


func _say(p: PlayerState, text: String) -> void:
	notice.emit(p.id, text)


## Wo neue Spieler die Stadt betreten (aus data/kreuzweg.json).
static func start_cell() -> Vector2i:
	var cell: Array = GameData.get_file("kreuzweg").get("start", {}).get("feld", [11, 19])
	return Vector2i(int(cell[0]), int(cell[1]))


## Platzhalter in Dialogtexten: {klasse}, {region}, {wohin} („ins Arkanum“), {lehrmeister} (aus der gewählten Klasse).
func fill_text(p: PlayerState, text: String) -> String:
	if not text.contains("{"):
		return text
	var klasse: String = str(p.progress.flags.get("klasse", ""))
	var data: Dictionary = Sandbox.CLASSES.get(klasse, {title = "Novize", region = "?"})
	var extra: Dictionary = GameData.get_file("klassen").get(klasse, {})
	var wohin: String = GameData.get_file("klassen").get("wohin", {}).get(data.region, "nach " + data.region)
	return text.replace("{klasse}", data.title).replace("{region}", data.region).replace("{wohin}", wohin) \
			.replace("{lehrmeister}", extra.get("lehrmeister", "?"))
