extends SceneTree
## Spielt Grünwacht am Stück durch (Grünwacht Schritt 11): vom Abschied bei Ye über den Weg nach Wipfelheim bis zum
## Abspann „Ende von Grünwacht“ – ohne Grafik, aber mit echten Kämpfen. Ein Computer-Spieler folgt den Zeichen (! und ?)
## auf allen Karten, geht zu den Orten der Aufträge, reist zwischen den Karten und kämpft gegen Monster, wenn er für einen
## Kampf zu schwach war. Einmal je Klasse: Bogenschütze, Zähmer und eine Klasse aus einer anderen Region.
## Gibt eine Übersicht aus: wann welcher Auftrag fertig war, Stufe, Gold, Kämpfe und eine geschätzte Spielzeit.
## Aufruf: Godot --headless --path . --script res://tests/durchlauf_gruenwacht_test.gd   (optional: -- <Klasse>)

const MAX_ACTIONS := 6000
## Geschätzte Spielzeit: Sekunden pro gelesener Dialogzeile und pro Kampfzug des Spielers
const SECONDS_PER_LINE := 4.0
const SECONDS_PER_TURN := 6.0
## Stand am Ende von Akt 1 (aus tests/durchlauf_test.gd)
const START_LEVEL := 10
const START_XP := 3030
const START_GOLD := 190
const CLASSES := ["archer", "tamer", "blade"]

var world: WorldState
var p: PlayerState
var _rng := RandomNumberGenerator.new()
var _answer_uses := {}
var _talked_round := {}
var _seconds := 0.0
var _lines := 0
var _battle_turns := 0
var _battle_log: PackedStringArray = []
var _pending_battle := ""
var _pending_scene := ""
## Unter dieser Stufe wird erst gegen Monster gekämpft (steigt, wenn ein Geschichtskampf zu schwer war)
var _min_level := 0
var _failed := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var classes: Array = [args[0]] if not args.is_empty() else CLASSES
	for klasse: String in classes:
		await _play_region(klasse)
	print("Durchlauf Grünwacht: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


func _play_region(klasse: String) -> void:
	print("\n=== %s ===" % klasse)
	_rng.seed = 11
	_answer_uses.clear()
	_talked_round.clear()
	_seconds = 0.0
	_lines = 0
	_battle_turns = 0
	_battle_log.clear()
	_pending_battle = ""
	_pending_scene = ""
	_min_level = 0
	world = WorldState.new()
	p = world.add_player("spieler", "Du", "elf_m", Vector2i(10, 31))
	world.battle_requested.connect(func(_id: String, kampf: String) -> void: _pending_battle = kampf)
	world.scene_requested.connect(func(_id: String, scene: String) -> void: _pending_scene = scene)
	# Stand am Ende von Akt 1: alle Aufträge davor erledigt, Klasse gewählt, Abschied bei Ye
	for id: String in GameData.get_file("auftraege"):
		if id == "nach_gruenwacht":
			break
		p.progress.quests[id] = "abgegeben"
	p.progress.quests["abreise"] = "aktiv"
	p.progress.flags["klasse"] = klasse
	p.progress.flags["klasse_gewaehlt"] = true
	p.progress.flags["klasse_bestaetigt"] = true
	p.progress.level = START_LEVEL
	p.progress.xp = START_XP
	p.progress.gold = START_GOLD
	world.start_dialog(p, "ye_tor")
	while p.in_dialog():
		_answer()
	_pending_scene = ""
	_check(p.map == "weg_gruenwacht", "%s: Nach dem Abschied auf dem Weg nach Grünwacht" % klasse)

	# Aufträge aus Akt 1 nicht noch einmal melden
	var done_quests := {}
	for id: String in p.progress.quests:
		if p.progress.quests[id] == "abgegeben":
			done_quests[id] = true
	var finished := false
	for step in MAX_ACTIONS:
		for id: String in p.progress.quests:
			if p.progress.quests[id] == "abgegeben" and not done_quests.has(id):
				done_quests[id] = true
				print("%5.1f min  Auftrag „%s“ fertig  –  Stufe %d, %d Gold" % [
					_seconds / 60.0, GameData.quest(id).get("titel", id), p.progress.level, p.progress.gold])
		if _pending_battle != "":
			var kampf := _pending_battle
			_pending_battle = ""
			await _play_battle(kampf)
			continue
		if _pending_scene != "":
			var scene := _pending_scene
			_pending_scene = ""
			if scene == "abspann:gruenwacht":
				finished = true
				break
			if scene.begins_with("kartenspiel:"):
				world.apply_command("spieler", {type = "karten_ergebnis", gegner = scene.get_slice(":", 1), gewonnen = _rng.randf() < 0.5})
			_seconds += 60.0
			continue
		if p.shop != "":
			world.apply_command("spieler", {type = "laden_zu"})
			continue
		if p.in_dialog():
			_answer()
			continue
		if world.waiting_for_group(p.id):
			world.tick(0.5)
			continue
		_next_goal()
		_walk(12.0)

	_check(finished, "%s: Grünwacht endet mit dem Abspann" % klasse)
	for id: String in ["nach_gruenwacht", "veraenderte_tiere", "das_leere_grab", "der_urbaum", "die_wahrheit"]:
		_check(p.progress.quest_state(id) == "abgegeben", "%s: Auftrag „%s“ abgeschlossen" % [klasse, GameData.quest(id).titel])
	# Region 15–20 (Entscheidung 21.10.): Am Ende ist man fast auf der Höchststufe, auch ohne Nebenaufträge
	_check(p.progress.level >= 18, "%s: Am Ende Stufe 18 oder mehr (%d)" % [klasse, p.progress.level])
	if klasse == "archer":
		_check(p.progress.quest_state("fenns_pruefung") == "abgegeben", "Bogenschütze: Fenns Prüfung abgeschlossen")
	if klasse == "tamer":
		_check(p.progress.quest_state("tildas_unterricht") == "abgegeben", "Zähmer: Tildas Unterricht abgeschlossen")
	print("Kämpfe (ohne Monster der Wildnis):")
	for line in _battle_log:
		print("  " + line)
	print("Ende: Stufe %d, %d Gold, Tasche %s" % [p.progress.level, p.progress.gold, p.progress.items])
	print("Geschätzte Spielzeit: %d Minuten (%d Dialogzeilen, %d eigene Kampfzüge, Laufwege)" % [
		int(_seconds / 60.0), _lines, _battle_turns])


## Im Gespräch: weiterblättern oder eine Antwort wählen (am wenigsten benutzte zuerst, „Später“ am Ende zuletzt).
func _answer() -> void:
	_lines += 1
	_seconds += SECONDS_PER_LINE
	var view := world.dialog_view(p)
	if view.antworten.is_empty():
		world.apply_command("spieler", {type = "dialog_next"})
		return
	var node := "%s/%s" % [p.dialog.id, p.dialog.node]
	var count: int = view.antworten.size()
	var best := 0
	var best_score := 1e9
	for i in count:
		var uses: int = _answer_uses.get("%s/%d" % [node, i], 0)
		# Die letzte Antwort ist meistens „Später“ – nur nehmen, wenn alle anderen schon dran waren
		var score := uses * 10.0 + (1.0 if i == count - 1 and count > 1 else 0.0) + i * 0.01
		if score < best_score:
			best_score = score
			best = i
	_answer_uses["%s/%d" % [node, best]] = _answer_uses.get("%s/%d" % [node, best], 0) + 1
	world.apply_command("spieler", {type = "dialog_choose", index = best})


## Nächstes Ziel: erst Stufe aufholen, dann Hauptaufträge, dann Nebenaufträge hier, sonst reihum mit allen reden
## oder Monster bekämpfen.
func _next_goal() -> void:
	if p.progress.level < _min_level:
		_grind()
		return
	# Hauptaufträge: erst abgeben (?), dann Orte für laufende Aufträge (z. B. Silberhirsch vor dem nächsten Kapitel),
	# dann Zähmen für Tilda, dann neue Aufträge (!). Danach Nebenaufträge auf dieser Karte.
	if _talk_marked("?", false) or _talk_marked("!", false, _class_teachers()):
		return
	for here: bool in [true, false]:
		for i in world.places.size():
			if (world.places[i].map == p.map) == here and _place_wanted(i):
				_go(world.places[i].map, "ort:%d" % i)
				return
	if p.progress.quest_state("tildas_unterricht") == "aktiv":
		_grind()
		return
	# Figuren ohne Zeichen, die erst herbeilaufen, wenn man nah ist (z. B. Kael): dem Wegweiser folgen
	var place := world.objective_place(p)
	if not place.is_empty():
		if str(place.karte) != p.map:
			_travel(str(place.karte))
			return
		var cell := Vector2i(place.feld)
		if Vector2(cell).distance_to(p.pos) > 3.0:
			world.apply_command("spieler", {type = "move", cell = world._free_neighbor(cell, p.cell, p.map)})
			return
	if _talk_marked("!", false) or _talk_marked("?", true) or _talk_marked("!", true):
		return
	var candidates: Array[String] = []
	for id: String in world.npcs:
		if world.npc_visible(p, id) and not _talked_round.has(id):
			candidates.append(id)
	if candidates.is_empty():
		_talked_round.clear()
		_grind()
		return
	var pick := candidates[_rng.randi() % candidates.size()]
	_talked_round[pick] = true
	world.apply_command("spieler", {type = "talk", npc = pick})


## Zu einer Figur mit diesem Zeichen gehen (Hauptaufträge auf allen Karten, Nebenaufträge nur hier).
## only: nur diese Figuren (leer = alle)
func _talk_marked(mark: String, side: bool, only: Array = []) -> bool:
	for id: String in world.npcs:
		if not only.is_empty() and not id in only:
			continue
		var map_id: String = world.npcs[id].map
		if side and map_id != p.map:
			continue
		if _marker_on(id, map_id) == [mark, side]:
			_go(map_id, "npc:" + id)
			return true
	return false


## Lehrmeister der eigenen Klasse (geben Aufträge nur für eine Klasse): Die nimmt man zuerst, wie Ysolde es sagt.
func _class_teachers() -> Array:
	var result := []
	var quests := GameData.get_file("auftraege")
	for id: String in quests:
		if quests[id].get("start_wenn", {}).has("klasse") and not quests[id].get("neben", false):
			result.append(quests[id].get("start_bei", ""))
	return result


## Zeichen einer Figur, auch auf einer anderen Karte: [Zeichen, Nebenauftrag?]
func _marker_on(npc_id: String, map_id: String) -> Array:
	var here := p.map
	p.map = map_id
	var result := [world.npc_marker(p, npc_id), world.npc_marker_side(p, npc_id)]
	p.map = here
	return result


## Lohnt sich dieser Ort gerade für einen Auftrag? (Ort mit eigener Bedingung, Dialog-Einstieg für einen laufenden
## Auftrag oder der Eingang zur Pilzhöhle, solange „Der Urbaum“ läuft)
func _place_wanted(index: int) -> bool:
	var place: Dictionary = world.places[index]
	var here := p.map
	p.map = place.map
	var usable := world.can_use(p, "ort:%d" % index)
	p.map = here
	# Nur Orte auf Karten, die man gerade erreichen kann (die Pilzhöhle erst, wenn der Eingang offen ist)
	if not usable or (place.map != p.map and _next_hop(p.map, place.map).is_empty()):
		return false
	if place.dialog == "":
		for action: Dictionary in place.actions:
			if action.has("reisen") and world.get_map(str(action.reisen)).dungeon != "":
				return p.progress.quest_state("der_urbaum") == "aktiv" and not p.progress.flags.has("pilzhoehle_abgeschlossen")
		return false
	if not place.cond.is_empty():
		return true
	# Sonst nur, wenn der passende Einstieg zu einem laufenden Auftrag gehört (z. B. Rowans Grab, Bienenstock)
	for entry: Dictionary in GameData.dialog(place.dialog).get("einstieg", []):
		if world.check(p, entry.get("wenn", {})):
			return entry.get("wenn", {}).get("stand", "") == "aktiv"
	return false


## Zu einem Ziel auf irgendeiner Karte: erst hinreisen, dann benutzen bzw. ansprechen.
func _go(map_id: String, target: String) -> void:
	if map_id != p.map:
		_travel(map_id)
		return
	world.apply_command("spieler", {type = "use", target = target})


## Einen Schritt Richtung Zielkarte: zum Ausgang laufen oder den Seilaufzug bzw. Höhleneingang benutzen.
func _travel(map_id: String) -> void:
	var hop := _next_hop(p.map, map_id)
	if hop.is_empty():
		return
	if hop.has("ort"):
		world.apply_command("spieler", {type = "use", target = hop.ort})
	else:
		world.apply_command("spieler", {type = "move", cell = hop.feld})


## Wege zwischen den Karten (Breitensuche): {ort} oder {feld} für den ersten Schritt.
func _next_hop(from: String, to: String) -> Dictionary:
	var first := {from: {}}
	var queue: Array[String] = [from]
	while not queue.is_empty():
		var current: String = queue.pop_front()
		if current == to:
			return first[current]
		for edge: Array in _edges(current):
			var next: String = edge[0]
			if not first.has(next):
				first[next] = first[current] if current != from else edge[1]
				queue.append(next)
	return {}


## Verbindungen einer Karte: [Zielkarte, {feld} oder {ort}]
func _edges(map_id: String) -> Array:
	var result := []
	var m := world.get_map(map_id)
	if m == null:
		return result
	for e: Dictionary in m.exits:
		if world.check(p, e.get("cond", {})):
			var rect: Rect2i = e.rect
			result.append([e.karte, {feld = rect.position + rect.size / 2}])
	for i in world.places.size():
		var place: Dictionary = world.places[i]
		# Verschlossene Eingänge (z. B. die Pilzhöhle vor dem Auftrag) zählen nicht als Weg
		if place.map != map_id or not world.check(p, place.cond) or not world.check(p, place.entry):
			continue
		for action: Dictionary in place.actions:
			if action.has("reisen"):
				result.append([str(action.reisen), {ort = "ort:%d" % i}])
	return result


## Gegen ein Monster kämpfen, dessen Stufe am besten passt (nicht im Dungeon). Ist hier keins, zum Waldboden reisen.
func _grind() -> void:
	var best := -1
	var best_score := 1e9
	for i in world.monsters.size():
		var m: Dictionary = world.monsters[i]
		if m.dungeon != "" or m.karte != p.map or not world.can_use(p, "monster:%d" % i):
			continue
		var score := absf(float(m.stufe) - float(p.progress.level) + 1.0) + (Vector2(m.feld) - p.pos).length() * 0.05
		if score < best_score:
			best_score = score
			best = i
	if best < 0:
		_travel("waldboden" if p.map != "waldboden" else "weg_gruenwacht")
		return
	world.apply_command("spieler", {type = "use", target = "monster:%d" % best})


## Laufen, bis der Spieler angekommen ist oder ein Gespräch oder Kampf beginnt.
func _walk(max_seconds: float) -> void:
	var t := 0.0
	var map := p.map
	while t < max_seconds:
		world.tick(0.1)
		t += 0.1
		if p.in_dialog() or _pending_battle != "" or _pending_scene != "" or p.map != map \
				or (not p.is_moving() and p.use_target == ""):
			break
	_seconds += t


## Einen Kampf wirklich ausspielen (Computer-Spieler). Geschichtskämpfe bei Niederlage bis zu dreimal nochmal,
## danach erst Monster bekämpfen (eine Stufe mehr).
func _play_battle(kampf_id: String) -> void:
	var harness: GDScript = load("res://tests/neu_kampf.gd")
	var wild := kampf_id.begins_with("wild:")
	var tries := 0
	while true:
		tries += 1
		var flags := p.progress.flags
		BattleRequest.prepare(kampf_id, p.progress.level, p.progress.item_count("heiltrank"), str(flags.get("klasse", "")),
				flags.get("monster", []))
		var node: Node = harness.new()
		node.start_seed = _rng.randi()
		node.setup = BattleRequest.setup
		root.add_child(node)
		var won: bool = node.state.won
		var player_turns := int(node.state.turns / maxf(1.0, node.state.heroes.size() + 1.0))
		_battle_turns += player_turns
		_seconds += player_turns * SECONDS_PER_TURN + 20.0
		var tamed: Array = []
		var hero: Fighter = node.state.heroes[0]
		for m in hero.monsters:
			if m.has_meta("neu_gezaehmt"):
				tamed.append(m.klass)
		# Der Computer-Spieler zähmt nicht von selbst: Für Tildas Auftrag das erste zähmbare Monster nehmen
		if won and wild and tamed.is_empty() and p.progress.quest_state("tildas_unterricht") == "aktiv":
			for enemy: String in world.monsters[int(kampf_id.substr(5))].gegner:
				if Sandbox.ENEMIES.get(enemy, {}).has("tame"):
					tamed.append(enemy)
					break
		root.remove_child(node)
		node.free()
		world.apply_command("spieler", {type = "kampf_ergebnis", kampf = kampf_id, gewonnen = won, gezaehmt = tamed})
		if wild:
			break
		_battle_log.append("%-40s Stufe %d: %s (Versuch %d)" % [GameData.battle(kampf_id).get("name", kampf_id), p.progress.level,
			"Sieg" if won else "Niederlage", tries])
		if won or GameData.battle(kampf_id).get("kein_nochmal", false) or GameData.battle(kampf_id).has("merken_immer"):
			break
		if tries >= 3:
			_min_level = p.progress.level + 1
			break
	BattleRequest.kampf_id = ""


func _check(condition: bool, text: String) -> void:
	if not condition:
		_failed += 1
		print("FEHLER: " + text)
