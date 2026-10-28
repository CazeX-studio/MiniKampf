extends SceneTree
## Spielt die ganze erste Stunde der Kreuzweg-Demo am Stück durch – ohne Grafik, aber mit echten Kämpfen.
## Ein Computer-Spieler folgt den Zeichen (! und ?), dem Ziel-Hinweis und redet sonst mit allen.
## Gibt eine Übersicht aus: wann welcher Auftrag fertig war, Stufe, Geld, Kämpfe und eine geschätzte Spielzeit.
## Aufruf: Godot --headless --path . --script res://tests/durchlauf_test.gd   (optional: -- <Startwert>)

const MAX_ACTIONS := 4000
## Geschätzte Spielzeit: Sekunden pro gelesener Dialogzeile und pro Kampfzug des Spielers
const SECONDS_PER_LINE := 4.0
const SECONDS_PER_TURN := 6.0

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
var _failed := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	_rng.seed = int(args[0]) if not args.is_empty() else 7
	world = WorldState.new()
	p = world.add_player("spieler", "Du", "elf_m", WorldState.start_cell())
	world.battle_requested.connect(func(_id: String, kampf: String) -> void: _pending_battle = kampf)
	world.scene_requested.connect(func(_id: String, scene: String) -> void: _pending_scene = scene)
	world.apply_command("spieler", {type = "start"})

	var done_quests := {}
	var finished := false
	for step in MAX_ACTIONS:
		# Fertige Aufträge mitschreiben
		for id: String in p.progress.quests:
			if p.progress.quests[id] == "abgegeben" and not done_quests.has(id):
				done_quests[id] = true
				print("%5.1f min  Auftrag „%s“ fertig  –  Stufe %d (%d Erfahrung), %s" % [
					_seconds / 60.0, GameData.quest(id).get("titel", id), p.progress.level, p.progress.xp, Geld.text(p.progress.gold)])
		if _pending_battle != "":
			await _play_battle(_pending_battle)
			_pending_battle = ""
			continue
		if _pending_scene == "abspann":
			finished = true
			break
		# Beim Gesandten: Klassen der Region ansehen und eine davon in der Probestunde ausprobieren
		if _pending_scene.begins_with("klassenwahl:"):
			var region := _pending_scene.get_slice(":", 1)
			_pending_scene = ""
			var options: Array = GameData.get_file("klassen").reihenfolge.filter(
					func(id: String) -> bool: return Sandbox.CLASSES[id].region == region)
			_pending_battle = "probe:" + str(options[_rng.randi() % options.size()])
			_seconds += 30.0
			continue
		if _pending_scene == "klassenwahl":
			_pending_scene = ""
			var classes: Array = GameData.get_file("klassen").reihenfolge
			p.progress.flags["klasse"] = classes[_rng.randi() % classes.size()]
			p.progress.flags["klasse_gewaehlt"] = "ja"
			_seconds += 60.0
			continue
		if p.shop != "":
			world.apply_command("spieler", {type = "laden_zu"})
			continue
		if p.in_dialog():
			_answer()
			continue
		_next_goal()
		_walk(12.0)

	_check(finished, "Die erste Stunde endet mit dem Abspann")
	_check(p.progress.flags.has("klasse"), "Eine Klasse wurde gewählt")
	for id: String in GameData.get_file("auftraege"):
		# Nur die Nebenaufträge der ersten Stunde (Grünwacht-Aufträge haben ein eigenes Gebiet)
		if GameData.quest(id).get("neben", false) and not GameData.quest(id).has("gebiet"):
			_check(p.progress.quest_state(id) == "abgegeben", "Nebenauftrag „%s“ abgeschlossen" % GameData.quest(id).titel)
	print("\nKämpfe:")
	for line in _battle_log:
		print("  " + line)
	print("\nEnde: Stufe %d, %d Erfahrung, %s, Tasche %s" % [p.progress.level, p.progress.xp, Geld.text(p.progress.gold), p.progress.items])
	print("Geschätzte Spielzeit: %d Minuten (%d Dialogzeilen, %d eigene Kampfzüge, Laufwege)" % [
		int(_seconds / 60.0), _lines, _battle_turns])
	print("Durchlauf: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


## Im Gespräch: weiterblättern oder eine Antwort wählen (am wenigsten benutzte zuerst, bei Gleichstand eine mit Aktion).
func _answer() -> void:
	_lines += 1
	_seconds += SECONDS_PER_LINE
	var view := world.dialog_view(p)
	if view.antworten.is_empty():
		world.apply_command("spieler", {type = "dialog_next"})
		return
	var node := "%s/%s" % [p.dialog.id, p.dialog.node]
	var raw: Array = GameData.dialog(p.dialog.id).knoten[p.dialog.node].get("antworten", [])
	var visible: Array = raw.filter(func(a: Dictionary) -> bool: return world.check(p, a.get("wenn", {})))
	var best := 0
	var best_score := 1e9
	for i in visible.size():
		var uses: int = _answer_uses.get("%s/%d" % [node, i], 0)
		var score := uses * 10.0 + (0.0 if visible[i].has("aktionen") else 1.0) + i * 0.01
		if score < best_score:
			best_score = score
			best = i
	_answer_uses["%s/%d" % [node, best]] = _answer_uses.get("%s/%d" % [node, best], 0) + 1
	world.apply_command("spieler", {type = "dialog_choose", index = best})


## Nächstes Ziel: NPC mit ? oder !, sonst Sammelpunkt für ein Sammel-Ziel, sonst ein Ort (Kater, Laterne)
## oder ein Gegenstand zum Benutzen (Bürste), sonst reihum alle NPCs.
func _next_goal() -> void:
	for mark: String in ["?", "!"]:
		for id: String in world.npcs:
			if world.npc_marker(p, id) == mark:
				world.apply_command("spieler", {type = "talk", npc = id})
				return
	for id: String in p.progress.quests:
		if p.progress.quests[id] != "aktiv":
			continue
		for goal: Dictionary in GameData.quest(id).get("ziele", []):
			if goal.art == "sammeln" and not world.goal_done(p, goal):
				for i in world.pickups.size():
					if world.can_use(p, "punkt:%d" % i) and world.pickups[i].item == goal.gegenstand:
						world.apply_command("spieler", {type = "use", target = "punkt:%d" % i})
						return
	for i in world.places.size():
		if world.can_use(p, "ort:%d" % i):
			world.apply_command("spieler", {type = "use", target = "ort:%d" % i})
			return
	for item_id: String in p.progress.items:
		var use: Dictionary = GameData.item(item_id).get("benutzen", {})
		var entries: Array = GameData.dialog(use.get("dialog", "")).get("einstieg", [])
		if entries.size() > 1 and world.check(p, entries[0].get("wenn", {})):
			var spot := Vector2(float(use.feld[0]), float(use.feld[1]))
			if (spot - p.pos).length() <= float(use.radius):
				world.apply_command("spieler", {type = "benutzen", gegenstand = item_id})
			else:
				world.apply_command("spieler", {type = "move", cell = world._free_neighbor(Vector2i(spot.round()), p.cell)})
			return
	var candidates: Array[String] = []
	for id: String in world.npcs:
		if world.npc_visible(p, id) and not _talked_round.has(id):
			candidates.append(id)
	if candidates.is_empty():
		_talked_round.clear()
		return
	var pick := candidates[_rng.randi() % candidates.size()]
	_talked_round[pick] = true
	world.apply_command("spieler", {type = "talk", npc = pick})


## Laufen, bis der Spieler angekommen ist oder ein Gespräch beginnt.
func _walk(max_seconds: float) -> void:
	var t := 0.0
	while t < max_seconds:
		world.tick(0.1)
		t += 0.1
		if p.in_dialog() or (not p.is_moving() and p.use_target == ""):
			break
	_seconds += t


## Einen Kampf wirklich ausspielen (Computer-Spieler), bei Niederlage bis zu viermal nochmal.
func _play_battle(kampf_id: String) -> void:
	var harness: GDScript = load("res://tests/neu_kampf.gd")
	var tries := 0
	while true:
		tries += 1
		BattleRequest.prepare(kampf_id, p.progress.level, p.progress.item_count("heiltrank"))
		var node: Node = harness.new()
		node.start_seed = _rng.randi()
		node.setup = BattleRequest.setup
		root.add_child(node)
		var won: bool = node.state.won
		var turns := 0
		for h in node.state.heroes:
			if not node.state.computer.has(h):
				turns = h.stat_ults
		var player_turns := int(node.state.turns / maxf(1.0, node.state.heroes.size() + 1.0))
		_battle_turns += player_turns
		_seconds += player_turns * SECONDS_PER_TURN + 20.0
		var potions := 0
		var hero: Fighter = node.state.heroes[0]
		if hero.wares.has("heiltrank"):
			potions = int(BattleRequest.setup.helden[0].get("traenke", 0)) - int(hero.wares.heiltrank)
		root.remove_child(node)
		node.free()
		world.apply_command("spieler", {type = "kampf_ergebnis", kampf = kampf_id, gewonnen = won, traenke_benutzt = potions})
		_battle_log.append("%-40s Stufe %d: %s (Versuch %d)" % [GameData.battle(kampf_id).get("name", kampf_id), p.progress.level,
			"Sieg" if won else "Niederlage", tries])
		if won or GameData.battle(kampf_id).get("kein_nochmal", false) or tries >= 5:
			break
	BattleRequest.kampf_id = ""


func _check(condition: bool, text: String) -> void:
	if not condition:
		_failed += 1
		print("FEHLER: " + text)
