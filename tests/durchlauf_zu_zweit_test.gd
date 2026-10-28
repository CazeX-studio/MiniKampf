extends SceneTree
## Spielt die ganze erste Stunde zu zweit durch (Zusammen spielen, Lernprojekt 4 Schritt 8) – ohne Grafik und ohne Netz,
## aber mit allem, was beim Zusammenspielen passiert: Gruppe, gemeinsame Szenen mit Abstimmung, Zuschauen,
## Gruppenkämpfe (Gruppenkampf bei Ye, Sternenfresser) und Ren, die wartet, bis beide zurück sind.
## Es führt immer der Spieler, der in der Geschichte weiter hinten ist; der andere läuft neben ihm her.
## Aufruf: Godot --headless --path . --script res://tests/durchlauf_zu_zweit_test.gd   (optional: -- <Startwert>)

const MAX_ACTIONS := 8000
const IDS: Array[String] = ["a", "b"]

var world: WorldState
var _rng := RandomNumberGenerator.new()
var _answer_uses := {}
var _talked_round := {}
## Je Spieler: wartender Kampf, wartender Bildschirm, fertig
var _battle := {}
var _scene := {}
var _done := {}
## Fortschritt der Spieler, die schon fertig sind (sie verlassen die Stadt)
var _final := {}
var _group_battles: Array[String] = []
var _solo_battles := 0
var _solo_names: Array[String] = []
var _scenes_seen := {}
var _votes_split := 0
var _failed := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	_rng.seed = int(args[0]) if not args.is_empty() else 5
	world = WorldState.new()
	for i in IDS.size():
		var id: String = IDS[i]
		world.add_player(id, id.to_upper(), "elf_m", WorldState.start_cell() + Vector2i(i, 0))
		_battle[id] = ""
		_scene[id] = ""
	world.group_members = func(_id: String) -> Array: return IDS
	world.group_leader = func(_id: String) -> String: return "a"
	world.battle_requested.connect(func(id: String, kampf: String) -> void: _battle[id] = kampf)
	world.group_battle_requested.connect(func(ids: Array, kampf: String) -> void:
		for id: String in ids:
			_battle[id] = "gruppe:" + kampf)
	world.scene_requested.connect(func(id: String, scene: String) -> void: _scene[id] = scene)
	for id in IDS:
		world.apply_command(id, {type = "start"})

	var started := Time.get_ticks_msec()
	for step in MAX_ACTIONS:
		if _done.size() == IDS.size():
			break
		if OS.has_environment("DUO_DEBUG") and step % 200 == 0:
			print("Schritt %d nach %d s: %s" % [step, (Time.get_ticks_msec() - started) / 1000, _state_text()])
		if await _handle_battles():
			continue
		var busy := false
		for id in IDS:
			if _done.has(id):
				continue
			if _handle_screen(id):
				busy = true
				break
			var p: PlayerState = world.players[id]
			if p.shop != "":
				world.apply_command(id, {type = "laden_zu"})
				busy = true
				break
			if p.in_dialog():
				_answer(id)
				busy = true
				break
		if busy:
			continue
		var leader := _leader()
		_follow(leader)
		_next_goal(leader)
		_walk(leader, 12.0)

	_check(_done.size() == 2, "Beide sehen am Ende den Abspann")
	for id in IDS:
		_check(_final.has(id) and _final[id].flags.has("klasse"), "Spieler %s hat eine Klasse gewählt" % id.to_upper())
	_check(not "gruppenkampf" in _group_battles, "Aufträge macht jeder für sich: Den Gruppenkampf bei Ye kämpft jeder selbst")
	# War einer schon weiter (er schaut bei Marv nur zu), kämpft jeder für sich – das ist richtig so
	_check("sternenfall" in _group_battles or _solo_names.count("sternenfall") == 2,
			"Sternenfresser: gemeinsam, oder jeder für sich, wenn einer in der Geschichte schon weiter war")
	_check(_scenes_seen.is_empty(), "Außerhalb von Dungeons gibt es keine gemeinsamen Szenen (%d gesehen)" % _scenes_seen.size())
	_check(_final.size() == 2 and _final.a.flags.has("ren_getroffen") and _final.b.flags.has("ren_getroffen"), "Beide haben Ren getroffen")
	print("\nGemeinsame Kämpfe: %s · allein: %d · gemeinsame Gespräche: %s · uneinige Abstimmungen: %d" % [
		", ".join(_group_battles), _solo_battles, ", ".join(_scenes_seen.keys()), _votes_split])
	for id: String in _final:
		var progress: Progress = _final[id]
		print("Spieler %s: Stufe %d, %s, Klasse %s" % [id.to_upper(), progress.level, Geld.text(progress.gold), progress.flags.get("klasse", "-")])
	print("Durchlauf zu zweit: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


func _state_text() -> String:
	var parts: PackedStringArray = []
	for id in IDS:
		if not world.players.has(id):
			parts.append("%s fertig" % id)
			continue
		var p: PlayerState = world.players[id]
		parts.append("%s %s/%s Aufträge %d %s" % [id, p.dialog.get("id", "-"), p.dialog.get("node", "-"), p.progress.quests.size(), _battle[id]])
	return " | ".join(parts)


## Wer in der Geschichte weiter hinten ist (weniger abgegebene Aufträge), führt.
func _leader() -> String:
	var best := ""
	var best_count := 1 << 30
	for id in IDS:
		if _done.has(id):
			continue
		var count := 0
		for q: String in world.players[id].progress.quests:
			if world.players[id].progress.quests[q] == "abgegeben":
				count += 1
		if count < best_count:
			best_count = count
			best = id
	return best


## Der andere stellt sich direkt neben den, der führt (so kommt er in gemeinsame Szenen).
func _follow(leader: String) -> void:
	var lp: PlayerState = world.players[leader]
	for id in IDS:
		if id == leader or _done.has(id) or not world.players.has(id):
			continue
		var p: PlayerState = world.players[id]
		if p.in_dialog() or p.shop != "":
			continue
		var cell := world._free_neighbor(lp.cell, lp.cell)
		if cell != Vector2i(-1, -1):
			p.path.clear()
			p.use_target = ""
			p.cell = cell
			p.pos = Vector2(cell)


func _handle_screen(id: String) -> bool:
	var scene: String = _scene[id]
	if scene == "":
		return false
	_scene[id] = ""
	if scene == "abspann":
		_done[id] = true
		_final[id] = world.players[id].progress
		world.remove_player(id)
		return true
	if scene.begins_with("klassenwahl:"):
		var region := scene.get_slice(":", 1)
		var options: Array = GameData.get_file("klassen").reihenfolge.filter(
				func(c: String) -> bool: return Sandbox.CLASSES[c].region == region)
		_battle[id] = "probe:" + str(options[_rng.randi() % options.size()])
		return true
	if scene == "klassenwahl":
		var classes: Array = GameData.get_file("klassen").reihenfolge
		world.players[id].progress.flags["klasse"] = classes[_rng.randi() % classes.size()]
		world.players[id].progress.flags["klasse_gewaehlt"] = "ja"
		return true
	return false


## Kämpfe ausspielen: Gruppenkämpfe einmal für alle Beteiligten, sonst jeder allein.
func _handle_battles() -> bool:
	var group_kampf := ""
	var group_ids: Array[String] = []
	for id in IDS:
		var b: String = _battle[id]
		if b.begins_with("gruppe:"):
			group_kampf = b.substr(7)
			group_ids.append(id)
	if not group_ids.is_empty():
		var members: Array = []
		for id in group_ids:
			var p: PlayerState = world.players[id]
			members.append({name = p.display_name, stufe = p.progress.level, traenke = p.progress.item_count("heiltrank")})
			_battle[id] = ""
		var setup := BattleRequest.build_group(group_kampf, members)
		world.add_battle_group(group_ids)
		var cells := {}
		for id in group_ids:
			cells[id] = world.players[id].cell
		var won := await _fight(setup)
		_group_battles.append(group_kampf)
		# Wie im Spiel: beide verlassen die Stadt, kommen nacheinander zurück
		var saved := {}
		for id in group_ids:
			saved[id] = world.players[id].progress.to_dict()
			world.remove_player(id)
		for id in group_ids:
			var p := world.add_player(id, id.to_upper(), "elf_m", cells[id])
			p.progress.load_dict(saved[id])
			world.apply_command(id, {type = "kampf_ergebnis", kampf = group_kampf, gewonnen = won})
			world.tick(0.05)
		return true
	for id in IDS:
		var b: String = _battle[id]
		if b == "":
			continue
		_battle[id] = ""
		var p: PlayerState = world.players[id]
		for tries in 5:
			BattleRequest.prepare(b, p.progress.level, p.progress.item_count("heiltrank"))
			var won := await _fight(BattleRequest.setup)
			_solo_battles += 1
			_solo_names.append(b)
			world.apply_command(id, {type = "kampf_ergebnis", kampf = b, gewonnen = won})
			if won or GameData.battle(b).get("kein_nochmal", false):
				break
		BattleRequest.kampf_id = ""
		return true
	return false


func _fight(setup: Dictionary) -> bool:
	var harness: GDScript = load("res://tests/neu_kampf.gd")
	var node: Node = harness.new()
	node.start_seed = _rng.randi()
	node.setup = setup
	root.add_child(node)
	var won: bool = node.state.won
	root.remove_child(node)
	node.free()
	return won


## Im Gespräch: weiterblättern oder abstimmen. In gemeinsamen Szenen stimmt jeder für sich ab (mal einig, mal nicht).
func _answer(id: String) -> void:
	var p: PlayerState = world.players[id]
	var view := world.dialog_view(p)
	var scene: Dictionary = view.get("szene", {})
	if not scene.is_empty():
		_scenes_seen[p.dialog.id] = true
		if scene.rolle == "zuschauen":
			# Zuschauer warten; wer spricht, macht weiter
			_answer_speaker()
			return
	if view.antworten.is_empty():
		if scene.is_empty() or scene.rolle == "spricht":
			world.apply_command(id, {type = "dialog_next"})
		else:
			_answer_speaker()
		return
	if not scene.is_empty() and scene.meine >= 0:
		_answer_speaker()
		return
	var choice := _pick_answer(p)
	if not scene.is_empty() and id == "b" and _rng.randf() < 0.3:
		var other: int = (choice + 1) % view.antworten.size()
		if other != choice:
			_votes_split += 1
		choice = other
	world.apply_command(id, {type = "dialog_choose", index = choice})


## Wenn einer wartet, ist der andere dran (Sprecher blättert, wer noch nicht gewählt hat, wählt).
func _answer_speaker() -> void:
	for id in IDS:
		if not world.players.has(id):
			continue
		var view := world.dialog_view(world.players[id])
		var scene: Dictionary = view.get("szene", {})
		if scene.is_empty() or scene.rolle == "zuschauen":
			continue
		if view.antworten.is_empty() and scene.rolle == "spricht":
			world.apply_command(id, {type = "dialog_next"})
			return
		if not view.antworten.is_empty() and scene.meine < 0:
			_answer(id)
			return
	# Niemand kann etwas tun (z. B. Abstimmung läuft noch): Zeit vergeht
	world.tick(1.0)


func _pick_answer(p: PlayerState) -> int:
	var view := world.dialog_view(p)
	var key := "%s/%s" % [p.dialog.id, p.dialog.node]
	var best := 0
	var best_uses := 1 << 30
	for i in view.antworten.size():
		var uses: int = _answer_uses.get("%s/%d" % [key, i], 0)
		if uses < best_uses:
			best_uses = uses
			best = i
	_answer_uses["%s/%d" % [key, best]] = best_uses + 1
	return best


func _next_goal(id: String) -> void:
	var p: PlayerState = world.players[id]
	for mark: String in ["?", "!"]:
		for npc: String in world.npcs:
			if world.npc_marker(p, npc) == mark:
				world.apply_command(id, {type = "talk", npc = npc})
				return
	for q: String in p.progress.quests:
		if p.progress.quests[q] != "aktiv":
			continue
		for goal: Dictionary in GameData.quest(q).get("ziele", []):
			if goal.art == "sammeln" and not world.goal_done(p, goal):
				for i in world.pickups.size():
					if world.can_use(p, "punkt:%d" % i):
						world.apply_command(id, {type = "use", target = "punkt:%d" % i})
						return
	var candidates: Array[String] = []
	for npc: String in world.npcs:
		if world.npc_visible(p, npc) and not _talked_round.has(npc):
			candidates.append(npc)
	if candidates.is_empty():
		_talked_round.clear()
		return
	var pick := candidates[_rng.randi() % candidates.size()]
	_talked_round[pick] = true
	world.apply_command(id, {type = "talk", npc = pick})


func _walk(id: String, max_seconds: float) -> void:
	var p: PlayerState = world.players[id]
	var t := 0.0
	while t < max_seconds:
		world.tick(0.1)
		t += 0.1
		if p.in_dialog() or (not p.is_moving() and p.use_target == ""):
			break


func _check(condition: bool, text: String) -> void:
	if not condition:
		_failed += 1
	print("%s %s" % ["OK    " if condition else "FEHLER", text])
