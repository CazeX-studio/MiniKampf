class_name WorldState
extends RefCounted
## Spiellogik der Stadt Kreuzweg – ohne Grafik.
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
##   {type = "kaufen", gegenstand = "…"} / {type = "verkaufen", gegenstand = "…"} / {type = "laden_zu"}  im geöffneten Laden
## So kann später ein Server dieselben Befehle von vielen Spielern annehmen;
## die Anzeige (kreuzweg.gd) liest nur den Zustand und schickt Befehle.
## NPCs, Sammelpunkte, Dialoge und Aufträge kommen aus den Datendateien in res://data.

## Kurze Meldung für einen Spieler („+30 Gold“, „Neuer Auftrag …“)
signal notice(player_id: String, text: String)
## Gold, Tasche, Erfahrung oder Aufträge eines Spielers haben sich geändert (z. B. zum Speichern)
signal progress_changed(player_id: String)
## Ein Spieler beginnt einen Kampf (Kennung aus data/kaempfe.json). Die Anzeige wechselt zum Kampfbildschirm.
signal battle_requested(player_id: String, kampf_id: String)

enum Tile { GRASS, ROAD, PLAZA, OVERGROWN }

const SIZE := Vector2i(22, 22)
const CENTER := Vector2i(11, 11)
## Felder pro Sekunde
const WALK_SPEED := 4.0
## So nah muss man an etwas stehen, um es zu benutzen (in Feldern)
const USE_RANGE := 1.6

## tiles[y][x]
var tiles: Array = []
var blocked := {}
## Häuser: {name, rect (Rect2i), height, color}
var buildings: Array[Dictionary] = []
## Kleinkram: {kind = "tree" / "bush" / "lantern", cell}
var props: Array[Dictionary] = []
var players := {}
## NPCs: id -> {name, cell, look, tint, dialog}
var npcs := {}
## Sammelpunkte: {item, cell}. Jeder Spieler kann jeden Punkt einmal einsammeln.
var pickups: Array[Dictionary] = []

var _astar := AStarGrid2D.new()


func _init() -> void:
	_build_map()
	var town := GameData.get_file("kreuzweg")
	var npc_data: Dictionary = town.get("npcs", {})
	for id: String in npc_data:
		var d: Dictionary = npc_data[id]
		var cell := Vector2i(int(d.feld[0]), int(d.feld[1]))
		npcs[id] = {name = d.name, cell = cell, look = d.aussehen, tint = Color(d.get("farbe", "ffffff")), dialog = d.get("dialog", id),
				cond = d.get("wenn", {}), approach = d.get("anspringen", {})}
		blocked[cell] = true
	for d: Dictionary in town.get("sammelpunkte", []):
		pickups.append({item = d.gegenstand, cell = Vector2i(int(d.feld[0]), int(d.feld[1]))})
	_astar.region = Rect2i(Vector2i.ZERO, SIZE)
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_astar.update()
	for cell: Vector2i in blocked:
		_astar.set_point_solid(cell)


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
			p.shop = ""
			if is_walkable(target) and not p.in_dialog():
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
			_battle_result(p, str(cmd.get("kampf", "")), bool(cmd.get("gewonnen", false)))
		"kaufen":
			_buy(p, str(cmd.get("gegenstand", "")))
		"verkaufen":
			_sell(p, str(cmd.get("gegenstand", "")))
		"laden_zu":
			p.shop = ""
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


## Wo ein Ziel ("npc:ye", "punkt:0") steht.
func target_cell(target: String) -> Vector2i:
	var parts := target.split(":")
	if parts.size() == 2 and parts[0] == "npc" and npcs.has(parts[1]):
		return npcs[parts[1]].cell
	if parts.size() == 2 and parts[0] == "punkt" and int(parts[1]) < pickups.size():
		return pickups[int(parts[1])].cell
	return Vector2i(-1, -1)


## Kann dieser Spieler das Ziel benutzen? (Ein schon eingesammelter Punkt oder ein gerade abwesender NPC nicht.)
func can_use(p: PlayerState, target: String) -> bool:
	if target.begins_with("punkt:"):
		return target_cell(target) != Vector2i(-1, -1) and not p.progress.flags.has("gesammelt:" + target)
	if target.begins_with("npc:") and not npc_visible(p, target.substr(4)):
		return false
	return target_cell(target) != Vector2i(-1, -1)


## Ist der NPC für diesen Spieler gerade da? (z. B. Ye erst in der Gilde, später am Stadttor)
func npc_visible(p: PlayerState, npc_id: String) -> bool:
	return npcs.has(npc_id) and check(p, npcs[npc_id].cond)


## Das Nächste, das der Spieler direkt nebenan benutzen kann ("" = nichts).
func usable_near(p: PlayerState) -> String:
	var best := ""
	var best_dist := USE_RANGE
	var targets: Array[String] = []
	for id: String in npcs:
		targets.append("npc:" + id)
	for i in pickups.size():
		targets.append("punkt:%d" % i)
	for target in targets:
		if not can_use(p, target):
			continue
		var dist := (Vector2(target_cell(target)) - p.pos).length()
		if dist < best_dist:
			best = target
			best_dist = dist
	return best


## Hinlaufen und benutzen (NPC: auf ein freies Nachbarfeld, Sammelpunkt: drauf).
func _go_use(p: PlayerState, target: String) -> void:
	if p.in_dialog() or not can_use(p, target):
		return
	var cell := target_cell(target)
	var spot := cell if target.begins_with("punkt:") and is_walkable(cell) else _free_neighbor(cell, p.cell)
	if spot == Vector2i(-1, -1):
		return
	p.use_target = target
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


## Freies Nachbarfeld, das am nächsten am Spieler liegt.
func _free_neighbor(npc_cell: Vector2i, from: Vector2i) -> Vector2i:
	var best := Vector2i(-1, -1)
	for dir: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
			Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
		var cell := npc_cell + dir
		if is_walkable(cell) and (best == Vector2i(-1, -1) or (cell - from).length() < (best - from).length()):
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
		if is_walkable(cell):
			p.pos = next
			p.cell = cell
			break
	var screen_x := p.steer.x - p.steer.y
	if absf(screen_x) > 0.01:
		p.facing = 1 if screen_x > 0 else -1


## Spielt die Welt um "delta" Sekunden weiter (Laufen, Benutzen nach der Ankunft).
func tick(delta: float) -> void:
	for p: PlayerState in players.values():
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
		_check_approach(p)
		if not p.is_moving() and p.use_target != "":
			var target := p.use_target
			p.use_target = ""
			if (Vector2(target_cell(target)) - p.pos).length() < USE_RANGE:
				_use(p, target)


func _use(p: PlayerState, target: String) -> void:
	if not can_use(p, target):
		return
	if target.begins_with("npc:"):
		var npc_id := target.substr(4)
		p.progress.flags["geredet:" + npc_id] = true
		_update_quests(p)
		start_dialog(p, npcs[npc_id].dialog)
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
func dialog_view(p: PlayerState) -> Dictionary:
	if not p.in_dialog():
		return {}
	var node := _current_node(p)
	var answers: Array[String] = []
	for a in _visible_answers(p, node):
		answers.append(a.text)
	return {wer = node.get("wer", ""), text = node.get("text", ""), antworten = answers}


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


# --- Bedingungen und Aktionen (aus den Datendateien) --------------------------

## Prüft eine Bedingung aus den Dialog-Daten. Leere Bedingung = immer erfüllt.
func check(p: PlayerState, cond: Dictionary) -> bool:
	if cond.has("auftrag") and p.progress.quest_state(cond.auftrag) != cond.get("stand", "aktiv"):
		return false
	if cond.has("gemerkt") and not p.progress.flags.has(cond.gemerkt):
		return false
	if cond.has("nicht_gemerkt") and p.progress.flags.has(cond.nicht_gemerkt):
		return false
	if cond.has("stufe_ab") and p.progress.level < int(cond.stufe_ab):
		return false
	return true


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
		if action.has("kampf"):
			battle_requested.emit(p.id, action.kampf)
	_update_quests(p)
	progress_changed.emit(p.id)


# --- Aufträge, Gold, Gegenstände, Erfahrung -----------------------------------

func _start_quest(p: PlayerState, id: String) -> void:
	var q := GameData.quest(id)
	if q.is_empty() or p.progress.quest_state(id) != "neu":
		return
	p.progress.quests[id] = "aktiv"
	_say(p, GameData.text("auftrag_neu", [q.titel]))


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
func objective(p: PlayerState) -> String:
	for id: String in p.progress.quests:
		var q := GameData.quest(id)
		var quest_state: String = p.progress.quests[id]
		if q.is_empty() or quest_state == "abgegeben":
			continue
		if quest_state == "fertig":
			var giver: Dictionary = npcs.get(q.get("abgeben_bei", ""), {name = "Auftraggeber"})
			return "Zurück zu %s" % giver.name
		for goal: Dictionary in q.get("ziele", []):
			if not goal_done(p, goal):
				return goal_text(p, goal)
	return ""


## Zeichen über einem NPC: "!" = neuer Auftrag, "?" = hier etwas erledigen oder abgeben, "" = nichts.
func npc_marker(p: PlayerState, npc_id: String) -> String:
	if not npc_visible(p, npc_id):
		return ""
	var all_quests := GameData.get_file("auftraege")
	for id: String in all_quests:
		var q: Dictionary = all_quests[id]
		var quest_state := p.progress.quest_state(id)
		if quest_state == "fertig" and q.get("abgeben_bei", "") == npc_id:
			return "?"
		if quest_state == "aktiv":
			for goal: Dictionary in q.get("ziele", []):
				if goal.get("bei", "") == npc_id and not goal_done(p, goal):
					return "?"
	for id: String in all_quests:
		var q: Dictionary = all_quests[id]
		if q.get("start_bei", "") == npc_id and p.progress.quest_state(id) == "neu" \
				and (not q.has("voraussetzung") or p.progress.quest_state(q.voraussetzung) == "abgegeben"):
			return "!"
	return ""


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


func _give_gold(p: PlayerState, amount: int) -> void:
	p.progress.gold += amount
	_say(p, GameData.text("gold", [amount]))


func _give_xp(p: PlayerState, amount: int) -> void:
	var reached := p.progress.add_xp(amount)
	_say(p, GameData.text("erfahrung", [amount]))
	for level in reached:
		_say(p, GameData.text("stufe", [level]))


func _give_item(p: PlayerState, item_id: String, count: int) -> void:
	p.progress.add_item(item_id, count)
	if count > 0:
		_say(p, GameData.text("gegenstand", [count, GameData.item_name(item_id)]))
	else:
		_say(p, GameData.text("gegenstand_weg", [-count, GameData.item_name(item_id)]))


# --- NPCs, die einen ansprechen ------------------------------------------------

## Manche NPCs (z. B. Marv) sprechen dich von sich aus an, sobald du nah genug bist – einmal.
func _check_approach(p: PlayerState) -> void:
	if p.in_dialog() or p.shop != "":
		return
	for id: String in npcs:
		var approach: Dictionary = npcs[id].approach
		if approach.is_empty() or p.progress.flags.has("angesprochen:" + id) or not npc_visible(p, id):
			continue
		if (Vector2(npcs[id].cell) - p.pos).length() <= float(approach.get("radius", 3)):
			p.progress.flags["angesprochen:" + id] = true
			p.use_target = ""
			start_dialog(p, npcs[id].dialog)
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
	var battle: Dictionary = GameData.get_file("kaempfe").get(kampf_id, {})
	if battle.is_empty():
		return
	if not won:
		_say(p, GameData.text("kampf_verloren"))
		return
	_say(p, GameData.text("kampf_gewonnen", [battle.get("name", kampf_id)]))
	var flag := "kampf_gewonnen:" + kampf_id
	if not p.progress.flags.has(flag):
		p.progress.flags[flag] = true
		if battle.has("erfahrung"):
			_give_xp(p, int(battle.erfahrung))
	_update_quests(p)
	progress_changed.emit(p.id)


func _say(p: PlayerState, text: String) -> void:
	notice.emit(p.id, text)


## Wo neue Spieler die Stadt betreten (aus data/kreuzweg.json).
static func start_cell() -> Vector2i:
	var cell: Array = GameData.get_file("kreuzweg").get("start", {}).get("feld", [11, 19])
	return Vector2i(int(cell[0]), int(cell[1]))
