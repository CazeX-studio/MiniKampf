extends SceneTree
## P22: Beim letzten Gespräch mit Ysolde (Ende von Grünwacht) läuft Kael dazu, steht beim Gespräch dabei und geht
## danach wieder. Aufruf: Godot --headless --path . -s tests/kael_abschluss_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _tick(world: WorldState, seconds: float) -> void:
	var t := 0.0
	while t < seconds:
		world.tick(0.1)
		t += 0.1


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	var weg := SpielstandEditor.weg("archer")
	var world := SpielstandEditor.bauen("archer", "novize_w+w1", weg.find("die_wahrheit"), 24, 500, {})
	var p: PlayerState = world.players["spieler"]
	p.progress.quests["die_wahrheit"] = "aktiv"
	p.progress.flags["angesprochen:kael"] = true
	var ysolde: Vector2i = world.npcs.ysolde.cell
	world.change_map(p, "wipfelheim", world._free_neighbor(ysolde, ysolde + Vector2i(2, 2), "wipfelheim"))
	world.start_dialog(p, "ysolde")
	_check(p.dialog.get("node", "") == "konfrontation", "Ysoldes Abschluss-Gespräch beginnt")
	_check(p.npc_walk.get("id", "") == "kael", "Kael läuft dazu")
	_tick(world, 8.0)
	_check(p.npc_walk.get("phase", "") == "reden" and p.in_dialog(), "Kael steht beim Gespräch dabei")
	var nah := Vector2(p.npc_walk.get("pos", Vector2(-99, -99))).distance_to(p.pos) < 2.5
	_check(nah, "Kael steht neben dir (%s, du bei %s)" % [p.npc_walk.get("pos"), p.pos])
	# Durchs Gespräch: Die Wahrheit aussprechen (danach gilt Kael in der Geschichte als fertig)
	var gesehen_nach_entscheidung := false
	for i in 40:
		if not p.in_dialog():
			break
		if world.dialog_view(p).antworten.is_empty():
			world.apply_command(p.id, {type = "dialog_next"})
		else:
			world.apply_command(p.id, {type = "dialog_choose", index = 0})
		if p.progress.flags.has("wahrheit_entschieden") and p.in_dialog():
			gesehen_nach_entscheidung = gesehen_nach_entscheidung or world.npc_visible(p, "kael")
	_check(gesehen_nach_entscheidung, "Nach der Entscheidung bleibt Kael bis zum Ende des Gesprächs da")
	_check(p.progress.quest_state("die_wahrheit") == "abgegeben", "Auftrag „Die Wahrheit über Rowan“ abgegeben")
	_tick(world, 30.0)
	_check(p.npc_walk.is_empty(), "Kael ist wieder gegangen")
	_check(not world.npc_visible(p, "kael"), "Danach ist Kael nicht mehr da")
	print("\nKael beim Abschluss: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
