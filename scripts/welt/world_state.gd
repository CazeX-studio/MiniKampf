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
##   {type = "pos", pos = Vector2, karte = "…", facing = 1, walking = true}  beim Zusammenspielen: wo die Figur eines
##                                       Mitspielers gerade ist (Mitspieler laufen bei sich selbst, der Gastgeber übernimmt den Platz)
##   {type = "interact"}                 das Nächste direkt nebenan benutzen (E, Leertaste, Aktions-Knopf)
##   {type = "start"}                    Stadt betreten (zeigt beim ersten Mal die Einleitung)
##   {type = "kampf_ergebnis", kampf = "…", gewonnen = true, traenke_benutzt = 1}  Ergebnis eines Kampfes (vom Kampfbildschirm)
##   {type = "dialog_next"}              im Gespräch weiter (wenn es keine Antworten gibt)
##   {type = "dialog_choose", index = 0} im Gespräch eine Antwort wählen
##   {type = "szene_verlassen"}          eine gemeinsame Szene verlassen (Zusammenspielen)
##   {type = "einlagern", gegenstand = "…"} / {type = "abholen", gegenstand = "…"}  an einer Bankstelle (Bank geöffnet)
##   {type = "guertel_ablegen", gegenstand = "…"} / {type = "guertel_nehmen", platz = 0}  Trank an den Gürtel bzw. zurück
##   {type = "bank_erweitern"}           an einer Bankstelle mehr Bankplätze kaufen
##   {type = "kaufen", gegenstand = "…"} / {type = "verkaufen", gegenstand = "…"} / {type = "laden_zu"}  im geöffneten Laden
##   {type = "wegwerfen", gegenstand = "…"}  alle Stück eines Gegenstands aus der Tasche wegwerfen
##   {type = "beute_nehmen", gegenstand = "…"} / {type = "beute_lassen"}  Beute, die nicht in die Tasche gepasst hat
##   {type = "test_geld", bronze = 75} / {type = "test_tasche"} / {type = "test_beute"}  Testknöpfe (nur im Godot-Editor)
##   {type = "karten_ergebnis", gegner = "marv", gewonnen = true, unentschieden = false}  Ende einer Partie Kreuzweg-Karten
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
## Hängebrücke und Laub (die Baumkronen unter den Plattformen, dort kann man nicht laufen). Höhlen: Höhlenboden und Fels.
enum Tile { GRASS, ROAD, PLAZA, OVERGROWN, FOREST, PLANKS, BRIDGE, CANOPY, CAVE, ROCK }

## Kennung der Stadt Kreuzweg (dort beginnt das Spiel)
const KREUZWEG := "kreuzweg"

const SIZE := Vector2i(44, 44)
const CENTER := Vector2i(22, 22)
## Halbmesser des runden Marktplatzes (in Feldern)
const PLAZA_RADIUS := 7.5
## Felder pro Sekunde
const WALK_SPEED := 5.5
## Beim Zusammenspielen: so weit darf ein Mitspieler zwischen zwei Platz-Meldungen höchstens gelaufen sein (Felder)
const REMOTE_MAX_JUMP := 4.0
## So schnell laufen NPCs, die einen ansprechen (Felder pro Sekunde)
const NPC_WALK_SPEED := 6.0
## So weit entfernt taucht ein NPC auf, der einen ansprechen will (Felder)
const WALK_IN_DISTANCE := 8
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
## Monster laufen um ihren Platz herum (so weit, Felder) und folgen Spielern, die so nah herankommen (Felder)
const MONSTER_RANGE := 2.0
const MONSTER_CHASE := 2.5
## Tempo der Monster (Felder pro Sekunde): beim Herumlaufen und wenn sie jemandem folgen
const MONSTER_SPEED := 1.2
const MONSTER_CHASE_SPEED := 2.4
## So lange bleibt ein besiegtes Monster für den Spieler weg (Sekunden)
const MONSTER_RESPAWN := 60.0
## Spieler, deren Kampf gerade beginnt (bis das Ergebnis kommt oder sie gehen): Kennung -> true
var _fighting := {}
## Gruppenmitglieder, die bei einem fremden Geschichts-Kampf nur mithelfen: Kennung -> Kampf
var _helpers := {}
## Nur für Tests der Szenen-Regeln: gemeinsame Szenen auch außerhalb von Dungeons
var scenes_everywhere := false
## So viel der Erfahrung eines Kampfes bekommt, wer nur mithilft
const HELPER_XP := 0.5
## So nah muss man bei Tilda stehen, um den Monster-Stall zu benutzen (Felder)
const STALL_RANGE := 3.0
## Zufall für Monsterkarten als Beute (Tests setzen einen festen Startwert)
var card_rng := RandomNumberGenerator.new()
## Belohnung wurde schon am Ende des Kampfes gezeigt: Erfahrung, Gold, Karte und Stufe hier ohne Meldung
var _rewards_shown := false
## Karte, die am Kampfende schon gezeigt wurde ("" = keine, "?" = hier selbst auswürfeln)
var _shown_card := "?"

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
	# Eigene Kopie: Die Monster laufen herum (pos, Ziel, Pause), die Daten aus den Karten bleiben unverändert
	monsters = []
	for m: Dictionary in GameData.wild_monsters():
		var wild := m.duplicate()
		wild.merge({pos = Vector2(m.feld), target = Vector2(m.feld), wait = randf_range(0.0, 2.0), moving = false, facing = 1})
		monsters.append(wild)
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
				dialog = d.get("dialog", ""), actions = d.get("aktionen", []), text = d.get("meldung", ""),
				entry = d.get("zutritt_wenn", {}), locked_text = d.get("zutritt_meldung", "")})


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
	# Lichter (Straßenlaternen, Fackeln): werfen einen Schein, siehe Licht
	for d: Dictionary in town.get("lichter", []):
		var cell := Vector2i(int(d.feld[0]), int(d.feld[1]))
		props.append({kind = d.art, cell = cell})
		blocked[cell] = true
	# Grundlicht: tagsüber leicht abgedunkelt, damit Lichter wirken
	maps[KREUZWEG].light = Color(town.get("licht", "ffffff"))

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
	# Dungeon von außen betreten: ein neuer Lauf beginnt (Bosse sind wieder da, die Entscheidung bleibt bestehen)
	if m.dungeon != "" and p.map != map_id:
		for flag: String in p.progress.flags.keys():
			if flag.begins_with("lauf:"):
				p.progress.flags.erase(flag)
	p.map = map_id
	p.cell = cell
	# Wer gerade auf eine Karte kommt, wird nicht sofort von einem Monster angesprungen
	p.safe_time = maxf(p.safe_time, 3.0)
	p.npc_walk = {}
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
	# Läuft gerade ein NPC auf den Spieler zu, wartet der Spieler (nur Stehenbleiben geht)
	if p.awaiting_npc() and cmd.get("type", "") in ["move", "talk", "use", "interact"]:
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
		"pos":
			_remote_position(p, cmd)
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
			var used := mini(int(cmd.get("traenke_benutzt", 0)), p.progress.potion_count("heiltrank"))
			if used > 0:
				# Zuerst vom Gürtel, dann aus der Tasche
				p.progress.use_potions("heiltrank", used)
				progress_changed.emit(p.id)
			_fighting.erase(p.id)
			for monster_id: String in cmd.get("gezaehmt", []):
				_add_to_pack(p, monster_id, true)
			_rewards_shown = bool(cmd.get("belohnung_gezeigt", false))
			_shown_card = str(cmd.get("karte", "")) if cmd.has("karte") else "?"
			if _helpers.get(p.id, "") == str(cmd.get("kampf", "")):
				# Hat nur mitgeholfen: Erfahrung und Gold, aber kein Fortschritt in fremden Aufträgen
				_helper_result(p, str(cmd.get("kampf", "")), bool(cmd.get("gewonnen", false)))
			else:
				_battle_result(p, str(cmd.get("kampf", "")), bool(cmd.get("gewonnen", false)))
			_rewards_shown = false
			_shown_card = "?"
			_back_from_battle(p.id)
		"karten_ergebnis":
			_card_result(p, str(cmd.get("gegner", "")), bool(cmd.get("gewonnen", false)), bool(cmd.get("unentschieden", false)))
		"benutzen":
			_use_item(p, str(cmd.get("gegenstand", "")))
		"test_geld":
			# Testknopf in der Tasche (nur beim Ausprobieren im Godot-Editor, nicht im fertigen Spiel)
			if OS.is_debug_build():
				_give_gold(p, clampi(int(cmd.get("bronze", 0)), 0, 1000000))
				progress_changed.emit(p.id)
		"wegwerfen":
			_discard(p, str(cmd.get("gegenstand", "")))
		"guertel_ablegen":
			_belt_put(p, str(cmd.get("gegenstand", "")))
		"guertel_nehmen":
			_belt_take(p, int(cmd.get("platz", -1)))
		"beute_nehmen":
			_take_loot(p, str(cmd.get("gegenstand", "")))
		"beute_lassen":
			p.progress.loot.clear()
			progress_changed.emit(p.id)
		"test_beute":
			# Testknopf in der Tasche: Beute wie nach einem Sieg (nur im Godot-Editor)
			if OS.is_debug_build():
				give_loot(p, {testruestung = 1})
				progress_changed.emit(p.id)
		"test_tasche":
			# Testknopf in der Tasche: alle freien Kästchen mit Testkieseln füllen (nur im Godot-Editor)
			if OS.is_debug_build():
				var n := 1
				while p.progress.used_slots() < Progress.BAG_SIZE:
					if not p.progress.items.has("testkiesel_%d" % n):
						p.progress.add_item("testkiesel_%d" % n, 1)
					n += 1
				progress_changed.emit(p.id)
		"tasche_tauschen":
			p.progress.move_slot(int(cmd.get("von", -1)), int(cmd.get("nach", -1)))
			progress_changed.emit(p.id)
		"rudel":
			_pack_command(p, cmd)
		"kaufen":
			_buy(p, str(cmd.get("gegenstand", "")))
		"verkaufen":
			_sell(p, str(cmd.get("gegenstand", "")))
		"laden_zu":
			p.shop = ""
		"einlagern":
			_bank_move(p, str(cmd.get("gegenstand", "")), true)
		"abholen":
			_bank_move(p, str(cmd.get("gegenstand", "")), false)
		"bank_erweitern":
			_bank_expand(p)
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
		return Vector2i(Vector2(monsters[int(parts[1])].pos).round())
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
## NPCs, die einen von sich aus ansprechen, sieht man erst, wenn sie herbeilaufen.
func npc_visible(p: PlayerState, npc_id: String) -> bool:
	if not _npc_present(p, npc_id):
		return false
	return npcs[npc_id].approach.is_empty() or p.progress.flags.has("angesprochen:" + npc_id) or p.npc_walk.get("id", "") == npc_id


## Ist der NPC für diesen Spieler in der Geschichte gerade da (auch wenn er erst noch herbeiläuft)?
func _npc_present(p: PlayerState, npc_id: String) -> bool:
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
	elif p.pos != Vector2(p.cell) and route.size() < 2:
		# Zwischen zwei Feldern stehen geblieben und das Ziel ist genau dieses Feld: noch das kleine Stück hin.
		# (Sonst geht es direkt zum nächsten Feld des Weges – nicht erst zurück, das sah aus wie ein Zurückspringen.)
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
	_move_monsters(delta)
	for p: PlayerState in players.values():
		p.safe_time = maxf(p.safe_time - delta, 0.0)
		# Mitspieler laufen bei sich selbst und melden ihren Platz ("pos"), der Gastgeber bewegt sie nicht noch einmal
		if not p.remote_driven:
			move_player(p, delta)
		_check_exits(p)
		_check_monsters(p)
		_move_npc_walk(p, delta)
		_check_approach(p)
		if not p.is_moving() and p.use_target != "":
			var target := p.use_target
			p.use_target = ""
			if (Vector2(target_cell(target)) - p.pos).length() < USE_RANGE:
				_use(p, target)


## Platz eines Mitspielers übernehmen. Unmögliche Sprünge (zu weit, in ein Haus, andere Karte) werden nicht übernommen –
## dann setzt der Mitspieler seine Figur selbst wieder dorthin, wo der Gastgeber sie kennt.
func _remote_position(p: PlayerState, cmd: Dictionary) -> void:
	p.remote_driven = true
	var pos: Variant = cmd.get("pos")
	if pos is Vector2 and str(cmd.get("karte", p.map)) == p.map and not p.awaiting_npc():
		var cell := Vector2i((pos as Vector2).round())
		if is_walkable(cell, p.map) and (pos as Vector2).distance_to(p.pos) <= REMOTE_MAX_JUMP:
			p.pos = pos
			p.cell = cell
	p.facing = 1 if int(cmd.get("facing", p.facing)) >= 0 else -1
	p.remote_walking = bool(cmd.get("walking", false))
	if not p.remote_walking:
		# Stehen geblieben: Ein angeklickter Weg ist zu Ende, jetzt wird benutzt, was angeklickt war
		p.path.clear()


## Nur das Laufen eines Spielers (frei gesteuert oder einen Weg entlang), ohne Reden und Benutzen.
## Beim Zusammenspielen bewegt ein Mitspieler damit seine eigene Figur sofort, ohne auf den Gastgeber zu warten.
func move_player(p: PlayerState, delta: float) -> void:
	if p.awaiting_npc():
		p.steer = Vector2.ZERO
		p.path.clear()
		return
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
		# Manche Orte sieht man immer, betreten kann man sie aber erst später (z. B. die Pilzhöhle nach dem Auftrag)
		if not check(p, place.entry):
			_say(p, place.locked_text)
			return
		if place.text != "":
			_say(p, place.text)
		if place.dialog != "":
			start_dialog(p, place.dialog)
		run_actions(p, place.actions)
		progress_changed.emit(p.id)
	else:
		var pickup: Dictionary = pickups[int(target.substr(6))]
		if not p.progress.has_room(pickup.item):
			_say(p, GameData.text("tasche_voll", [GameData.item_name(pickup.item)]))
			return
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
	var visible := _visible_answers(p, node)
	for a in visible:
		answers.append(a.text)
	return {wer = node.get("wer", ""), text = fill_text(p, node.get("text", "")), antworten = answers,
			zeichen = answer_markers(p, p.dialog.id, p.dialog.node, visible)}


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


## Zeichen vor den Antworten: "!" = beginnt einen Hauptauftrag, "?" = bringt die Hauptgeschichte weiter, "" = nichts.
## Markiert wird nur die Antwort (bzw. die Antworten), die am direktesten weiterführt; Nebenaufträge nicht.
func answer_markers(p: PlayerState, dialog_id: String, node_id: String, answers: Array[Dictionary]) -> Array[String]:
	var values: Array[Dictionary] = []
	var best := 0
	for a in answers:
		var v := _answer_value(p, dialog_id, a, {node_id: true}, 0)
		values.append(v)
		best = maxi(best, v.wert)
	var result: Array[String] = []
	for v in values:
		result.append(v.zeichen if best > 0 and v.wert == best else "")
	return result


## Wie sehr eine Antwort die Hauptgeschichte weiterbringt: {wert, zeichen}. Weiterbringen zählt mehr als nur einen
## Auftrag annehmen, und je früher im Gespräch es passiert, desto besser (Umwege über Fragen zählen weniger).
func _answer_value(p: PlayerState, dialog_id: String, a: Dictionary, visited: Dictionary, depth: int) -> Dictionary:
	var v := _actions_value(p, a.get("aktionen", []), depth)
	if a.has("weiter"):
		v = _better_value(v, _node_value(p, dialog_id, str(a.weiter), visited, depth + 1))
	return v


func _node_value(p: PlayerState, dialog_id: String, node_id: String, visited: Dictionary, depth: int) -> Dictionary:
	if depth > 6 or visited.has(node_id):
		return {wert = 0, zeichen = ""}
	var seen := visited.duplicate()
	seen[node_id] = true
	var node: Dictionary = GameData.dialog(dialog_id).get("knoten", {}).get(node_id, {})
	var v := _actions_value(p, node.get("aktionen", []), depth)
	for a in _visible_answers(p, node):
		v = _better_value(v, _answer_value(p, dialog_id, a, seen, depth))
	if node.has("weiter"):
		v = _better_value(v, _node_value(p, dialog_id, str(node.weiter), seen, depth + 1))
	return v


func _actions_value(p: PlayerState, actions: Array, depth: int) -> Dictionary:
	var starts := false
	var advances := false
	for action: Dictionary in actions:
		if action.has("auftrag_starten") and is_main_quest(str(action.auftrag_starten)) and p.progress.quest_state(action.auftrag_starten) == "neu":
			starts = true
		if action.has("auftrag_abgeben") and is_main_quest(str(action.auftrag_abgeben)) and p.progress.quest_state(action.auftrag_abgeben) in ["aktiv", "fertig"]:
			advances = true
		if action.has("kampf") and not _is_side_battle(str(action.kampf)):
			advances = true
		if action.has("szene"):
			advances = true
		if action.has("merken") and _is_open_goal_flag(p, str(action.merken)):
			advances = true
	if not starts and not advances:
		return {wert = 0, zeichen = ""}
	return {wert = (20 if advances else 10) - depth, zeichen = "!" if starts else "?"}


func _better_value(a: Dictionary, b: Dictionary) -> Dictionary:
	return b if b.wert > a.wert else a


## Hauptaufträge sind alle, die nicht als "neben" markiert sind.
func is_main_quest(id: String) -> bool:
	var q := GameData.quest(id)
	return not q.is_empty() and not q.get("neben", false)


## Gehört dieser Kampf zu einem Nebenauftrag? (Dann bekommt die Antwort kein Zeichen.)
func _is_side_battle(kampf_id: String) -> bool:
	var all_quests := GameData.get_file("auftraege")
	for id: String in all_quests:
		var q = all_quests[id]
		if not q is Dictionary or not q.get("neben", false):
			continue
		for goal: Dictionary in q.get("ziele", []):
			if goal.get("kampf", "") == kampf_id:
				return true
	return false


## Ist "flag" ein noch offenes Ziel eines aktiven Hauptauftrags?
func _is_open_goal_flag(p: PlayerState, flag: String) -> bool:
	for id: String in p.progress.quests:
		if p.progress.quests[id] != "aktiv" or not is_main_quest(id):
			continue
		for goal: Dictionary in GameData.quest(id).get("ziele", []):
			if goal.get("art", "") == "gemerkt" and goal.get("merken", "") == flag and not p.progress.flags.has(flag):
				return true
	return false


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
	# Gemeinsame Szenen gibt es nur im Dungeon; sonst macht jeder seine Aufträge für sich (Playtest 25.10.)
	var shared := get_map(p.map).dungeon != "" or scenes_everywhere
	for id: String in group_members.call(p.id) if shared else []:
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
		if _npc_present(other, npc_id) and _entry_node(other, dialog_id) == entry:
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
	var visible := _visible_answers(speaker, node)
	for a in visible:
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
			zeichen = answer_markers(speaker, speaker.dialog.id, speaker.dialog.node, visible),
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
	# {"hat": "sternentafel"}: diesen Gegenstand in der Tasche ({"nicht_hat": …} = nicht)
	if cond.has("hat") and p.progress.item_count(cond.hat) <= 0:
		return false
	if cond.has("nicht_hat") and p.progress.item_count(cond.nicht_hat) > 0:
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
		# {"wenn": {…}, …}: diese Aktion nur, wenn die Bedingung stimmt (z. B. nur für eine Klasse)
		if action.has("wenn") and not check(p, action.wenn):
			continue
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
			_start_story_battle(p, str(action.kampf))
		if action.has("ruf"):
			# {"ruf": "jaeger", "wert": 10}: Ruf bei einer Gruppe (Jäger, Zähmer …), sichtbar unter „Werte“
			change_reputation(p, str(action.ruf), int(action.get("wert", 0)))
		if action.has("kartenspiel"):
			# {"kartenspiel": "marv"}: eine Partie Kreuzweg-Karten gegen diese Figur (eigener Bildschirm)
			_ensure_starter_cards(p)
			scene_requested.emit(p.id, "kartenspiel:" + str(action.kartenspiel))
		if action.has("karte"):
			add_card(p, str(action.karte))
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
			"besitzen":
				if p.progress.item_count(goal.gegenstand) < int(goal.get("anzahl", 1)):
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
		"besitzen":
			return p.progress.item_count(goal.gegenstand) >= int(goal.get("anzahl", 1))
		"kampf":
			return p.progress.flags.has("kampf_gewonnen:" + str(goal.kampf))
	return true


## Wartet ein laufender Auftrag nur (alle offenen Ziele gelten gerade nicht, z. B. „Beim Lehrmeister lernen“, während
## Fenns Prüfung läuft)? Dann zeigen „Ziel:“ und Wegweiser zum nächsten Auftrag.
func _quest_waiting(p: PlayerState, id: String) -> bool:
	if p.progress.quest_state(id) != "aktiv":
		return false
	for goal: Dictionary in GameData.quest(id).get("ziele", []):
		if not goal_done(p, goal) and goal_shown(p, goal) and check(p, goal.get("wenn", {})):
			return false
	return true


## Gilt dieses Ziel für den Spieler? "nur_wenn" blendet ein Ziel ganz aus (z. B. nur für Bogenschützen),
## "wenn" gibt nur an, wann Ziel-Anzeige und Wegweiser dorthin zeigen.
func goal_shown(p: PlayerState, goal: Dictionary) -> bool:
	return check(p, goal.get("nur_wenn", {}))


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
		"gemerkt", "kampf", "besitzen":
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
				if not goal_done(p, goal) and goal_shown(p, goal) and check(p, goal.get("wenn", {})):
					return prefix + goal_text(p, goal)
	return ""


## Wohin der Spieler für die Hauptgeschichte als Nächstes muss, als Feld auf seiner eigenen Karte – oder (-1, -1).
## Liegt das Ziel auf einer anderen Karte, zeigt der Wegweiser zum Ausgang, der dorthin führt. Für den Wegweiser.
func objective_cell(p: PlayerState) -> Vector2i:
	var goal := objective_place(p)
	if goal.is_empty():
		return Vector2i(-1, -1)
	if goal.karte == p.map:
		return goal.feld
	var exit := _exit_towards(p, str(goal.karte))
	return exit


## Ziel der Hauptgeschichte: {karte, feld} oder leer.
func objective_place(p: PlayerState) -> Dictionary:
	for id: String in p.progress.quests:
		var q := GameData.quest(id)
		var quest_state: String = p.progress.quests[id]
		if q.is_empty() or quest_state == "abgegeben" or not is_main_quest(id) or _quest_waiting(p, id):
			continue
		return _quest_place(p, id)
	# Kein Hauptauftrag offen: zum nächsten gelben „!“ auf dieser Karte
	var best := {}
	for id: String in npcs:
		if npc_marker(p, id) == "!" and not npc_marker_side(p, id) \
				and (best.is_empty() or (Vector2(npcs[id].cell) - p.pos).length() < (Vector2(best.feld) - p.pos).length()):
			best = {karte = npcs[id].map, feld = npcs[id].cell}
	return best


## Wohin man für diesen (laufenden) Auftrag als Nächstes muss: {karte, feld} oder leer.
func _quest_place(p: PlayerState, id: String) -> Dictionary:
	var q := GameData.quest(id)
	if p.progress.quest_state(id) == "fertig":
		return _npc_goal(p, [q.get("abgeben_bei", "")])
	for goal: Dictionary in q.get("ziele", []):
		if goal_done(p, goal) or not goal_shown(p, goal) or not check(p, goal.get("wenn", {})):
			continue
		if goal.art == "sammeln":
			var herb := _nearest_pickup(p, str(goal.gegenstand))
			if not herb.is_empty():
				return herb
		if goal.has("bei"):
			return _npc_goal(p, [goal.bei])
		if goal.has("wegweiser"):
			return _npc_goal(p, goal.wegweiser)
		if goal.art == "gemerkt":
			# Ein Ort, der das Ziel erfüllt (z. B. ein Laternenhaken)
			for place: Dictionary in places:
				if check(p, place.cond) and place.actions.any(func(a: Dictionary) -> bool: return a.get("merken", "") == goal.merken):
					return {karte = place.map, feld = place.cell}
	return {}


## Wegweiser der Nebenaufträge: [{nummer, feld}] auf der eigenen Karte (oder der Ausgang dorthin).
## Die Nummer ist die Reihenfolge, in der man die laufenden Nebenaufträge angenommen hat (wie im Auftragsbuch).
func side_objectives(p: PlayerState) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var number := 0
	for id: String in p.progress.quests:
		var quest_state: String = p.progress.quests[id]
		if is_main_quest(id) or GameData.quest(id).is_empty() or not quest_state in ["aktiv", "fertig"]:
			continue
		number += 1
		var goal := _quest_place(p, id)
		if goal.is_empty():
			continue
		var cell: Vector2i = goal.feld if goal.karte == p.map else _exit_towards(p, str(goal.karte))
		if cell != Vector2i(-1, -1):
			result.append({nummer = number, feld = cell})
	return result


## Nummer eines laufenden Nebenauftrags (wie bei den Wegweisern), 0 = keiner.
func side_number(p: PlayerState, quest_id: String) -> int:
	var number := 0
	for id: String in p.progress.quests:
		if is_main_quest(id) or GameData.quest(id).is_empty() or not p.progress.quests[id] in ["aktiv", "fertig"]:
			continue
		number += 1
		if id == quest_id:
			return number
	return 0


## Der nächste der genannten NPCs, der für den Spieler gerade da ist (auch einer, der erst herbeiläuft).
func _npc_goal(p: PlayerState, ids: Array) -> Dictionary:
	var best := {}
	for id: String in ids:
		if not npcs.has(id) or not check(p, npcs[id].cond):
			continue
		var cell: Vector2i = npcs[id].cell
		if p.npc_walk.get("id", "") == id:
			cell = Vector2i(Vector2(p.npc_walk.pos).round())
		var here: bool = npcs[id].map == p.map
		if best.is_empty() or (here and (best.karte != p.map or (Vector2(cell) - p.pos).length() < (Vector2(best.feld) - p.pos).length())):
			best = {karte = npcs[id].map, feld = cell}
	return best


## Der nächste Sammelpunkt dieses Gegenstands, den der Spieler noch nicht eingesammelt hat (lieber auf der eigenen Karte).
func _nearest_pickup(p: PlayerState, item: String) -> Dictionary:
	var best := {}
	for i in pickups.size():
		var pick: Dictionary = pickups[i]
		if pick.item != item or p.progress.flags.has("gesammelt:punkt:%d" % i) or not check(p, pick.get("cond", {})):
			continue
		var here: bool = pick.map == p.map
		if best.is_empty() or (here and (best.karte != p.map or (Vector2(pick.cell) - p.pos).length() < (Vector2(best.feld) - p.pos).length())):
			best = {karte = pick.map, feld = pick.cell}
	return best


## Ausgang der eigenen Karte, über den man (auch über mehrere Karten hinweg) zur Zielkarte kommt, oder (-1, -1).
func _exit_towards(p: PlayerState, target_map: String) -> Vector2i:
	# Breitensuche über die Ausgänge aller Karten; gemerkt wird, über welchen Ausgang der eigenen Karte man losging
	var first := {}
	var queue: Array[String] = []
	for e: Dictionary in get_map(p.map).exits:
		if check(p, e.cond) and not first.has(e.karte) and e.karte != p.map:
			first[e.karte] = e.rect.get_center()
			queue.append(e.karte)
	while not queue.is_empty():
		var map_id: String = queue.pop_front()
		if map_id == target_map:
			var c: Vector2 = first[map_id]
			return Vector2i(c.round())
		if not maps.has(map_id):
			continue
		for e: Dictionary in get_map(map_id).exits:
			if not first.has(e.karte) and e.karte != p.map:
				first[e.karte] = first[map_id]
				queue.append(e.karte)
	return Vector2i(-1, -1)


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
					if goal.get("bei", "") == npc_id and not goal_done(p, goal) and goal_shown(p, goal) and check(p, goal.get("wenn", {})):
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
	if not _rewards_shown:
		_say(p, GameData.text("gold", [Geld.text(amount)]))


func _give_xp(p: PlayerState, amount: int) -> void:
	var reached := p.progress.add_xp(amount)
	if not _rewards_shown:
		_say(p, GameData.text("erfahrung", [amount]))
	for level in reached:
		if not _rewards_shown:
			_say(p, GameData.text("stufe", [level, Grundwerte.growth_text()]))
		if level == 2:
			_say(p, GameData.text("werte_tipp"))


## Gegenstände aus Aufträgen und Gesprächen kommen auch bei voller Tasche hinein (in ein Extra-Kästchen),
## damit die Geschichte nie hängen bleibt. Sammeln und Kaufen prüfen vorher selbst, ob Platz ist.
func _give_item(p: PlayerState, item_id: String, count: int) -> void:
	var room := p.progress.has_room(item_id)
	p.progress.add_item(item_id, count)
	if count > 0:
		_say(p, GameData.text("gegenstand", [count, GameData.item_name(item_id)]))
		if not room:
			_say(p, GameData.text("tasche_uebervoll"))
	else:
		_say(p, GameData.text("gegenstand_weg", [-count, GameData.item_name(item_id)]))


## Beute nach einem Sieg: Was in die Tasche passt, kommt hinein. Der Rest wartet im Beute-Fenster
## (Progress.loot), bis man Platz gemacht hat oder ihn liegen lässt. So geht kein Fund verloren, ohne dass man es merkt.
func give_loot(p: PlayerState, items: Dictionary) -> void:
	var waiting := false
	for item_id: String in items:
		var count := int(items[item_id])
		if count <= 0:
			continue
		if p.progress.has_room(item_id) and not p.progress.loot.has(item_id):
			_give_item(p, item_id, count)
		else:
			p.progress.loot[item_id] = int(p.progress.loot.get(item_id, 0)) + count
			waiting = true
	if waiting:
		_say(p, GameData.text("beute_kein_platz"))


func _take_loot(p: PlayerState, item_id: String) -> void:
	if not p.progress.loot.has(item_id):
		return
	if not p.progress.has_room(item_id):
		_say(p, GameData.text("tasche_voll", [GameData.item_name(item_id)]))
		return
	_give_item(p, item_id, int(p.progress.loot[item_id]))
	p.progress.loot.erase(item_id)
	progress_changed.emit(p.id)


## Darf man das wegwerfen? Nicht: Gegenstände der Geschichte (ohne Preis, z. B. Bürste, Sternensplitter)
## und was ein laufender Auftrag noch braucht (sonst bliebe der Auftrag hängen).
func can_discard(p: PlayerState, item_id: String) -> bool:
	if p.progress.item_count(item_id) <= 0 or int(GameData.item(item_id).get("preis", 0)) <= 0:
		return false
	for quest_id: String in p.progress.quests:
		if p.progress.quest_state(quest_id) == "abgegeben":
			continue
		for goal: Dictionary in GameData.quest(quest_id).get("ziele", []):
			if goal.get("art", "") == "sammeln" and goal.get("gegenstand", "") == item_id:
				return false
	return true


func _discard(p: PlayerState, item_id: String) -> void:
	if not can_discard(p, item_id):
		return
	var count := p.progress.item_count(item_id)
	p.progress.add_item(item_id, -count)
	_say(p, GameData.text("weggeworfen", [count, GameData.item_name(item_id)]))
	progress_changed.emit(p.id)


# --- Ruf ------------------------------------------------------------------------------

## Ruf liegt zwischen -100 und 100 (0 = neutral). Gruppen und ihre Namen stehen in data/texte.json („ruf_jaeger“ …).
const REPUTATION_MAX := 100


func reputation(p: PlayerState, group: String) -> int:
	return int(p.progress.flags.get("ruf:" + group, 0))


func change_reputation(p: PlayerState, group: String, amount: int) -> void:
	if amount == 0:
		return
	p.progress.flags["ruf:" + group] = clampi(reputation(p, group) + amount, -REPUTATION_MAX, REPUTATION_MAX)
	_say(p, GameData.text("ruf_aenderung", [GameData.text("ruf_" + group), "+%d" % amount if amount > 0 else str(amount)]))


# --- Rudel des Zähmers -------------------------------------------------------------

## Ein Monster kommt ins Rudel (Start-Monster von Esche oder in der Wildnis gezähmt). Mitnehmen kann man höchstens
## Sandbox.MAX_MONSTERS; ist das Gepäck voll, geht es automatisch in den Stall bei Tilda (man kann es gleich tauschen).
func _add_to_pack(p: PlayerState, monster_id: String, tamed := false) -> void:
	if not Sandbox.MONSTERS.has(monster_id) and not Sandbox.ENEMIES.has(monster_id):
		return
	var pack: Array = p.progress.flags.get("monster", []).duplicate()
	var name: String = monster_name(monster_id)
	if tamed:
		p.progress.flags["erstes_zaehmen"] = true
	if pack.size() >= Sandbox.MAX_MONSTERS:
		var stall: Array = p.progress.flags.get("stall", []).duplicate()
		stall.append(monster_id)
		p.progress.flags["stall"] = stall
		# Merken, damit die Stadt gleich anbietet, es gegen eins aus dem Gepäck zu tauschen
		p.progress.flags["stall_neu"] = stall.size() - 1
		_say(p, GameData.text("rudel_stall", [name]))
		_update_quests(p)
		progress_changed.emit(p.id)
		return
	pack.append(monster_id)
	p.progress.flags["monster"] = pack
	_say(p, GameData.text("rudel_neu", [name]))
	_update_quests(p)
	progress_changed.emit(p.id)


static func monster_name(monster_id: String) -> String:
	return str(Sandbox.MONSTERS.get(monster_id, Sandbox.ENEMIES.get(monster_id, {name = monster_id})).name)


## Steht der Spieler bei Tilda? (Nur dort kann man Monster in den Stall bringen oder holen.)
func at_stall(p: PlayerState) -> bool:
	return npcs.has("tilda") and npcs.tilda.map == p.map and (Vector2(npcs.tilda.cell) - p.pos).length() <= STALL_RANGE


## Rudel ordnen und den Stall benutzen:
##   {type = "rudel", aktion = "hoch", index}       Monster im Gepäck eins nach vorne (Platz 1 kämpft, 2 und 3 unterstützen)
##   {type = "rudel", aktion = "ablegen", index}    Monster aus dem Gepäck in den Stall (nur bei Tilda, eins bleibt immer)
##   {type = "rudel", aktion = "holen", index}      Monster aus dem Stall mitnehmen (nur bei Tilda, wenn Platz ist)
##   {type = "rudel", aktion = "tauschen", index}   das eben gezähmte Monster aus dem Stall gegen dieses im Gepäck tauschen (überall)
##   {type = "rudel", aktion = "behalten"}          das eben gezähmte Monster bleibt im Stall
func _pack_command(p: PlayerState, cmd: Dictionary) -> void:
	var pack: Array = p.progress.flags.get("monster", []).duplicate()
	var stall: Array = p.progress.flags.get("stall", []).duplicate()
	var index := int(cmd.get("index", -1))
	match str(cmd.get("aktion", "")):
		"hoch":
			if index > 0 and index < pack.size():
				var moved: String = pack[index]
				pack[index] = pack[index - 1]
				pack[index - 1] = moved
		"ablegen":
			if at_stall(p) and index >= 0 and index < pack.size() and pack.size() > 1:
				stall.append(pack[index])
				pack.remove_at(index)
		"holen":
			if at_stall(p) and index >= 0 and index < stall.size() and pack.size() < Sandbox.MAX_MONSTERS:
				pack.append(stall[index])
				stall.remove_at(index)
		"tauschen":
			var fresh := int(p.progress.flags.get("stall_neu", -1))
			if fresh >= 0 and fresh < stall.size() and index >= 0 and index < pack.size():
				var out: String = pack[index]
				pack[index] = stall[fresh]
				stall[fresh] = out
				_say(p, GameData.text("rudel_getauscht", [monster_name(pack[index]), monster_name(out)]))
			p.progress.flags.erase("stall_neu")
		"behalten":
			p.progress.flags.erase("stall_neu")
	p.progress.flags["monster"] = pack
	p.progress.flags["stall"] = stall
	progress_changed.emit(p.id)


# --- Monster in der Wildnis ------------------------------------------------------

## Steht das Monster für diesen Spieler gerade da? (Nach einem Sieg ist es eine Weile weg.)
func monster_here(p: PlayerState, index: int) -> bool:
	# Im Dungeon kommen besiegte Monster in diesem Durchgang nicht wieder
	if get_map(monsters[index].karte).dungeon != "" and p.progress.flags.has("lauf:besiegt:monster:%d" % index):
		return false
	var beaten := float(p.progress.flags.get("besiegt:monster:%d" % index, -INF))
	return Time.get_unix_time_from_system() - beaten >= MONSTER_RESPAWN


## Kann dieser Spieler gerade in einen Kampf mit einem Monster geraten?
func _can_meet_monster(p: PlayerState) -> bool:
	return not p.in_dialog() and not p.awaiting_npc() and p.shop == "" and not _fighting.has(p.id) \
			and not waiting_for_group(p.id) and p.safe_time <= 0.0


## Monster laufen ein Stück um ihren Platz herum und folgen Spielern, die nah herankommen (und sie sehen).
func _move_monsters(delta: float) -> void:
	for i in monsters.size():
		var m: Dictionary = monsters[i]
		var speed := MONSTER_SPEED
		var chasing := false
		for p: PlayerState in players.values():
			if p.map == m.karte and monster_here(p, i) and _can_meet_monster(p) and p.pos.distance_to(m.pos) < MONSTER_CHASE \
					and p.pos.distance_to(Vector2(m.feld)) < MONSTER_RANGE + 2.0:
				m.target = p.pos
				speed = MONSTER_CHASE_SPEED
				chasing = true
				break
		if not chasing and m.wait > 0.0:
			m.wait -= delta
			m.moving = false
			continue
		var to: Vector2 = m.target - m.pos
		if to.length() < 0.05:
			m.wait = randf_range(1.0, 3.0)
			m.target = _monster_spot(m)
			m.moving = false
			continue
		var next: Vector2 = m.pos + to.normalized() * minf(speed * delta, to.length())
		if is_walkable(Vector2i(next.round()), m.karte):
			m.pos = next
			m.moving = true
			if absf(to.x - to.y) > 0.01:
				m.facing = 1 if to.x - to.y > 0 else -1
		else:
			m.target = m.pos


## Ein zufälliges freies Feld in der Nähe des Monster-Platzes.
func _monster_spot(m: Dictionary) -> Vector2:
	var r := int(MONSTER_RANGE)
	for i in 10:
		var cell: Vector2i = m.feld + Vector2i(randi_range(-r, r), randi_range(-r, r))
		if is_walkable(cell, m.karte):
			return Vector2(cell)
	return Vector2(m.feld)


## Läuft der Spieler in ein Monster hinein (oder das Monster in ihn), beginnt der Kampf.
func _check_monsters(p: PlayerState) -> void:
	if not _can_meet_monster(p):
		return
	for i in monsters.size():
		var m: Dictionary = monsters[i]
		if m.karte == p.map and (m.pos - p.pos).length() < MONSTER_TOUCH and monster_here(p, i):
			_start_wild(p, i)
			return


## Kampf aus einem Gespräch (Auftrag). Kämpfe mit "gruppe": true (z. B. das veränderte Tier) können
## Gruppenmitglieder in der Nähe mitmachen; sie helfen nur mit und bekommen keinen Auftrags-Fortschritt.
func _start_story_battle(p: PlayerState, kampf_id: String) -> void:
	if not GameData.battle(kampf_id).get("gruppe", false):
		battle_requested.emit(p.id, kampf_id)
		return
	var ids: Array[String] = [p.id]
	for id: String in group_members.call(p.id):
		var other: PlayerState = players.get(id)
		if other != null and other != p and other.map == p.map and not other.in_dialog() and other.shop == "" \
				and not _fighting.has(id) and other.pos.distance_to(p.pos) <= SCENE_RANGE:
			ids.append(id)
	if ids.size() == 1:
		battle_requested.emit(p.id, kampf_id)
		return
	for id in ids:
		_fighting[id] = true
		players[id].path.clear()
		players[id].steer = Vector2.ZERO
		players[id].use_target = ""
		if id != p.id:
			# Im Dungeon ist es ein gemeinsamer Durchgang: Dort zählt der Sieg für alle wie ihr eigener
			if get_map(p.map).dungeon == "":
				_helpers[id] = kampf_id
			notice.emit(id, GameData.text("geschichte_gruppe", [p.display_name]))
	group_battle_requested.emit(ids, kampf_id)


## Ergebnis für jemanden, der bei einem fremden Geschichts-Kampf nur mitgeholfen hat.
func _helper_result(p: PlayerState, kampf_id: String, won: bool) -> void:
	_helpers.erase(p.id)
	var battle: Dictionary = GameData.battle(kampf_id)
	if won:
		if not _rewards_shown:
			_say(p, GameData.text("kampf_gewonnen", [battle.get("name", kampf_id)]))
		_give_xp(p, roundi(int(battle.get("erfahrung", 0)) * HELPER_XP))
	else:
		_say(p, GameData.text("geholfen_verloren"))
	progress_changed.emit(p.id)


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
		players[id].safe_time = 3.0
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

## Manche NPCs (z. B. Marv) sprechen dich von sich aus an, sobald du nah genug an ihrem Platz bist – einmal.
## Sie kommen von etwas weiter weg angelaufen, reden mit dir und gehen danach an ihren Platz.
func _check_approach(p: PlayerState) -> void:
	if p.in_dialog() or p.shop != "" or waiting_for_group(p.id) or not p.npc_walk.is_empty():
		return
	for id: String in npcs:
		var approach: Dictionary = npcs[id].approach
		if approach.is_empty() or p.progress.flags.has("angesprochen:" + id) or not _npc_present(p, id) or not check(p, approach.get("wenn", {})):
			continue
		if (Vector2(npcs[id].cell) - p.pos).length() <= float(approach.get("radius", 3)):
			p.progress.flags["angesprochen:" + id] = true
			p.use_target = ""
			p.path.clear()
			p.steer = Vector2.ZERO
			_start_walk_in(p, id)
			return


## Der NPC taucht ein Stück entfernt auf (auf der Seite seines Platzes) und läuft neben den Spieler.
func _start_walk_in(p: PlayerState, npc_id: String) -> void:
	var home: Vector2i = npcs[npc_id].cell
	var dir := (Vector2(home) - p.pos).normalized()
	if dir == Vector2.ZERO:
		dir = Vector2(1, 0)
	var start := _nearest_walkable(Vector2i((p.pos + dir * WALK_IN_DISTANCE).round()), p.map)
	var goal := _free_neighbor(p.cell, start, p.map) if start != Vector2i(-1, -1) else Vector2i(-1, -1)
	var route: Array[Vector2i] = []
	if goal != Vector2i(-1, -1):
		route = get_map(p.map).astar.get_id_path(start, goal)
	if route.is_empty():
		# Kein Weg: gleich reden (Gruppenmitglieder in der Nähe erleben das mit)
		_start_talk(p, npc_id, "angesprochen:" + npc_id)
		return
	route.pop_front()
	p.npc_walk = {id = npc_id, pos = Vector2(start), path = route, facing = 1, phase = "hin"}
	# Im Dungeon holt der NPC Gruppenmitglieder in der Nähe gleich mit ins Gespräch (sie lösen ihn nicht noch einmal aus)
	for id: String in group_members.call(p.id) if get_map(p.map).dungeon != "" or scenes_everywhere else []:
		var other: PlayerState = players.get(id)
		if other != null and other != p and other.map == p.map and other.pos.distance_to(p.pos) <= SCENE_RANGE:
			other.progress.flags["angesprochen:" + npc_id] = true


## Freies Feld möglichst nah an "cell" (oder (-1, -1), wenn in der Nähe keins ist).
func _nearest_walkable(cell: Vector2i, map_id: String) -> Vector2i:
	for r in 4:
		for y in range(-r, r + 1):
			for x in range(-r, r + 1):
				var c := cell + Vector2i(x, y)
				if (absi(x) == r or absi(y) == r) and is_walkable(c, map_id):
					return c
	return Vector2i(-1, -1)


## Bewegt einen herbeilaufenden NPC: hin, reden, zurück an seinen Platz.
func _move_npc_walk(p: PlayerState, delta: float) -> void:
	if p.npc_walk.is_empty():
		return
	var w := p.npc_walk
	var npc: Dictionary = npcs.get(w.id, {})
	if npc.is_empty() or npc.map != p.map:
		p.npc_walk = {}
		return
	match w.phase:
		"hin":
			if _walk_along(w, delta):
				w.phase = "reden"
				w.facing = 1 if (p.pos.x - p.pos.y) > (w.pos.x - w.pos.y) else -1
				# Gruppenmitglieder in der Nähe erleben das mit (z. B. Marv auf dem Fest, Ren nach dem Sternenfresser).
				# Ist schon ein Gespräch im Gang (jemand aus der Gruppe war schneller), redet der NPC dort mit.
				if not p.in_dialog():
					_start_talk(p, w.id, "angesprochen:" + w.id)
		"reden":
			if not p.in_dialog():
				# Zurück an den eigenen Platz (der Platz selbst ist besetzt, also erst daneben, dann drauf)
				var from := Vector2i(Vector2(w.pos).round())
				var beside := _free_neighbor(npc.cell, from, p.map)
				var route: Array[Vector2i] = []
				if beside != Vector2i(-1, -1) and is_walkable(from, p.map):
					route = get_map(p.map).astar.get_id_path(from, beside)
				if not route.is_empty():
					route.pop_front()
				route.append(npc.cell)
				w.path = route
				w.phase = "zurueck"
		"zurueck":
			if _walk_along(w, delta):
				p.npc_walk = {}


## Läuft den Weg eines NPCs weiter. true = angekommen.
func _walk_along(w: Dictionary, delta: float) -> bool:
	var step := NPC_WALK_SPEED * delta
	var path: Array = w.path
	while step > 0.0 and not path.is_empty():
		var next := Vector2(path[0])
		var to_next: Vector2 = next - w.pos
		if absf(to_next.x - to_next.y) > 0.01:
			w.facing = 1 if to_next.x - to_next.y > 0 else -1
		if to_next.length() <= step:
			step -= to_next.length()
			w.pos = next
			path.pop_front()
		else:
			w.pos += to_next.normalized() * step
			step = 0.0
	return path.is_empty()


# --- Laden ----------------------------------------------------------------------

## Waren eines Ladens: [{gegenstand, preis}] (Preise aus data/gegenstaende.json).
func shop_wares(shop_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	# Ein Laden kann eigene Preise haben ("preise"), sonst gilt der Preis aus gegenstaende.json
	var shop: Dictionary = GameData.get_file("laeden").get(shop_id, {})
	for item_id: String in shop.get("waren", []):
		result.append({gegenstand = item_id, preis = int(shop.get("preise", {}).get(item_id, GameData.item(item_id).get("preis", 0)))})
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
			_say(p, GameData.text("zu_wenig_gold", [GameData.item_name(item_id), Geld.text(ware.preis)]))
			return
		if not p.progress.has_room(item_id):
			_say(p, GameData.text("tasche_voll", [GameData.item_name(item_id)]))
			return
		p.progress.gold -= ware.preis
		_say(p, GameData.text("gold_weg", [Geld.text(ware.preis)]))
		_give_item(p, item_id, 1)
		_update_quests(p)
		progress_changed.emit(p.id)
		return


## Gürtel (Projekt 5): nur außerhalb des Kampfes; Kämpfe laufen auf eigenem Bildschirm, die Welt nimmt dann keine
## Befehle der Tasche an. Im Gespräch oder Laden geht es auch nicht, damit nichts durcheinanderkommt.
func _belt_put(p: PlayerState, item_id: String) -> void:
	if p.in_dialog() or item_id == "" or not Progress.belt_allowed(item_id):
		return
	var moved := p.progress.belt_put(item_id)
	if moved <= 0:
		if p.progress.item_count(item_id) > 0:
			_say(p, GameData.text("guertel_voll", [GameData.item_name(item_id)]))
		return
	_say(p, GameData.text("guertel_angehaengt", [moved, GameData.item_name(item_id)]))
	progress_changed.emit(p.id)


func _belt_take(p: PlayerState, slot: int) -> void:
	if p.in_dialog() or slot < 0 or slot >= p.progress.belt.size() or p.progress.belt[slot].is_empty():
		return
	var id: String = p.progress.belt[slot].id
	if p.progress.belt_take(slot) <= 0:
		_say(p, GameData.text("guertel_zurueck_voll", [GameData.item_name(id)]))
		return
	progress_changed.emit(p.id)


## Ist gerade eine Bank geöffnet (Laden mit "bank": true in data/laeden.json)?
func bank_open(p: PlayerState) -> bool:
	return p.shop != "" and GameData.get_file("laeden").get(p.shop, {}).get("bank", false)


## Ganzen Stapel einlagern (to_bank) oder abholen. Alle Bankstellen teilen sich dieselbe Bank (Progress.bank).
func _bank_move(p: PlayerState, item_id: String, to_bank: bool) -> void:
	if not bank_open(p) or item_id == "":
		return
	var name := GameData.item_name(item_id)
	if to_bank:
		var count := p.progress.deposit(item_id)
		if count <= 0:
			if p.progress.item_count(item_id) > 0:
				_say(p, GameData.text("bank_voll", [name]))
			return
		_say(p, GameData.text("bank_eingelagert", [count, name]))
	else:
		var count := p.progress.withdraw(item_id)
		if count <= 0:
			if int(p.progress.bank.get(item_id, 0)) > 0:
				_say(p, GameData.text("tasche_voll", [name]))
			return
		_say(p, GameData.text("bank_abgeholt", [count, name]))
	_update_quests(p)
	progress_changed.emit(p.id)


## Nächste Bank-Erweiterung: {plaetze, preis}; leer = voll ausgebaut. Preise und Plätze in data/laeden.json ("bank").
func bank_expansion(p: PlayerState) -> Dictionary:
	var info: Dictionary = GameData.get_file("laeden").get("bank", {}).get("erweiterung", {})
	var prices: Array = info.get("preise", [])
	var step := int(info.get("plaetze", 10))
	var done := (p.progress.bank_size - Progress.BANK_START) / maxi(step, 1)
	if done >= prices.size():
		return {}
	return {plaetze = step, preis = int(prices[done])}


func _bank_expand(p: PlayerState) -> void:
	if not bank_open(p):
		return
	var next := bank_expansion(p)
	if next.is_empty():
		_say(p, GameData.text("bank_ausgebaut"))
		return
	if p.progress.gold < next.preis:
		_say(p, GameData.text("zu_wenig_gold", [GameData.text("bank_erweitern", [next.plaetze]), Geld.text(next.preis)]))
		return
	p.progress.gold -= next.preis
	p.progress.bank_size += next.plaetze
	_say(p, GameData.text("gold_weg", [Geld.text(next.preis)]))
	_say(p, GameData.text("bank_erweitert", [p.progress.bank_size]))
	progress_changed.emit(p.id)


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
		# Dungeon-Bosse: Wer verliert, wacht am Eingang wieder auf
		if battle.get("zurueck_zum_start", false):
			p.path.clear()
			p.cell = get_map(p.map).start
			p.pos = Vector2(p.cell)
		_update_quests(p)
		progress_changed.emit(p.id)
		return
	if not _rewards_shown:
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


## Kreuzweg-Karten: Sammlung im Spielstand (Gemerktes "karten": Kennung -> Anzahl).
func add_card(p: PlayerState, card_id: String) -> void:
	if not GameData.get_file("kartenspiel").get("karten", {}).has(card_id):
		return
	var cards: Dictionary = p.progress.flags.get("karten", {}).duplicate()
	cards[card_id] = int(cards.get(card_id, 0)) + 1
	p.progress.flags["karten"] = cards
	if not (_rewards_shown and _shown_card != "?"):
		_say(p, GameData.text("karte_neu", [KartenSpiel.card(card_id).name]))


## Mit der Sternentafel kommen die Startkarten (beim ersten Spiel).
func _ensure_starter_cards(p: PlayerState) -> void:
	if not p.progress.flags.get("karten", {}).is_empty():
		return
	var cards := {}
	for id: String in GameData.get_file("kartenspiel").get("startkarten", []):
		cards[id] = int(cards.get(id, 0)) + 1
	p.progress.flags["karten"] = cards
	_say(p, GameData.text("startkarten", [cards.size()]))


## Ende einer Partie: gemerkt wird, gegen wen man gespielt hat; ein Sieg bringt die Belohnung des Gegners
## (Gold jedes Mal, eine besondere Karte nur beim ersten Sieg).
func _card_result(p: PlayerState, opponent: String, won: bool, draw: bool) -> void:
	var data: Dictionary = GameData.get_file("kartenspiel").get("gegner", {}).get(opponent, {})
	if data.is_empty():
		return
	p.progress.flags["gespielt:" + opponent] = true
	if won:
		_say(p, GameData.text("karten_sieg", [data.get("name", opponent)]))
		var reward: Dictionary = data.get("belohnung", {})
		if reward.has("gold"):
			_give_gold(p, int(reward.gold))
		if reward.has("karte") and not p.progress.flags.has("karten_sieg:" + opponent):
			add_card(p, str(reward.karte))
		p.progress.flags["karten_sieg:" + opponent] = true
	else:
		_say(p, GameData.text("karten_unentschieden" if draw else "karten_verloren", [data.get("name", opponent)]))
	_update_quests(p)
	progress_changed.emit(p.id)


## Monster in der Wildnis: Jeder Sieg bringt Erfahrung und etwas Gold, das Monster ist dann eine Weile weg.
## Bei einer Niederlage wacht man am Start der Karte wieder auf.
## Was ein Sieg in diesem Kampf bringt, für die Anzeige am Kampfende: {erfahrung, gold, karte, stufen}.
## roll_card: die Monsterkarte schon jetzt auswürfeln (nur wer die Welt selbst führt, also allein oder als Gastgeber).
func battle_reward(p: PlayerState, kampf_id: String, roll_card: bool) -> Dictionary:
	var battle: Dictionary = GameData.battle(kampf_id)
	var reward := {erfahrung = 0, gold = 0, karte = "", stufen = []}
	if battle.is_empty():
		return reward
	if battle.get("wild", false):
		reward.erfahrung = int(battle.get("erfahrung", 0))
		reward.gold = int(battle.get("gold", 0))
		var drop: Array = GameData.wild_monsters()[int(kampf_id.substr(5))].gegner
		if roll_card and p.progress.item_count("sternentafel") > 0 \
				and card_rng.randf() < float(GameData.get_file("kartenspiel").get("beute", 0.0)):
			reward.karte = str(drop[card_rng.randi() % drop.size()])
	elif _helpers.get(p.id, "") == kampf_id:
		reward.erfahrung = roundi(int(battle.get("erfahrung", 0)) * HELPER_XP)
	elif not p.progress.flags.has("kampf_gewonnen:" + kampf_id):
		reward.erfahrung = int(battle.get("erfahrung", 0))
	# Welche Stufen damit erreicht werden
	var table := GameData.level_xp()
	var level := p.progress.level
	var xp: int = p.progress.xp + int(reward.erfahrung)
	while level < table.size() and xp >= int(table[level]):
		level += 1
		reward.stufen.append(level)
	return reward


func _wild_result(p: PlayerState, kampf_id: String, battle: Dictionary, won: bool) -> void:
	if won:
		if not _rewards_shown:
			_say(p, GameData.text("kampf_gewonnen", [battle.get("name", kampf_id)]))
		p.progress.flags["besiegt:monster:%d" % int(kampf_id.substr(5))] = Time.get_unix_time_from_system()
		if get_map(monsters[int(kampf_id.substr(5))].karte).dungeon != "":
			p.progress.flags["lauf:besiegt:monster:%d" % int(kampf_id.substr(5))] = true
		_give_gold(p, int(battle.get("gold", 0)))
		_give_xp(p, int(battle.get("erfahrung", 0)))
		# Mit etwas Glück eine Monsterkarte (nur wer schon eine Sternentafel hat, sammelt Karten)
		var drop: Array = GameData.wild_monsters()[int(kampf_id.substr(5))].gegner
		if _shown_card != "?":
			if _shown_card != "":
				add_card(p, _shown_card)
		elif p.progress.item_count("sternentafel") > 0 and card_rng.randf() < float(GameData.get_file("kartenspiel").get("beute", 0.0)):
			add_card(p, str(drop[card_rng.randi() % drop.size()]))
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
