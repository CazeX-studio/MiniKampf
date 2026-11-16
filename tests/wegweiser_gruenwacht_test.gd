extends SceneTree
## P1 (Playtest 16.11.2026): Bei jedem Schritt von Grünwacht Teil 2 zeigt ein Wegweiser, wohin es geht –
## auch nach Kaels Gespräch zum Eingang der Pilzhöhle.
## Aufruf: Godot --headless --path . -s tests/wegweiser_gruenwacht_test.gd

const AUFTRAEGE := ["rueckkehr_gruenwacht", "veraenderte_tiere", "das_leere_grab", "der_urbaum", "die_wahrheit"]
const KARTEN := ["wipfelheim", "waldboden"]

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _pruefen(world: WorldState, p: PlayerState, name: String) -> void:
	for karte: String in KARTEN:
		world.change_map(p, karte, world.get_map(karte).start)
		_check(world.objective_cell(p) != Vector2i(-1, -1), "%s: Wegweiser in %s (Ziel: %s)" % [name, karte, world.objective(p)])


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	for klasse: String in ["blade", "archer"]:
		var weg := SpielstandEditor.weg(klasse)
		for id: String in AUFTRAEGE:
			var world := SpielstandEditor.bauen(klasse, "novize_w+w1", weg.find(id), 22, 500, {})
			var p: PlayerState = world.players["spieler"]
			var titel := "%s, %s" % [klasse, GameData.quest(id).titel]
			if not p.progress.quests.has(id):
				_pruefen(world, p, titel + " (annehmen)")
				p.progress.quests[id] = "aktiv"
			# Ziel für Ziel abhaken, vor jedem muss ein Wegweiser da sein
			for goal: Dictionary in GameData.quest(id).ziele:
				if not world.goal_shown(p, goal) or world.goal_done(p, goal):
					continue
				# In der Pilzhöhle selbst kämpft man sich durch, das Herz des Urbaums liegt an ihrem Ende
				if str(goal.merken) != "urbaum_entschieden":
					_pruefen(world, p, "%s (%s)" % [titel, goal.text])
				p.progress.flags[str(goal.merken)] = true
			world._update_quests(p)
			_check(p.progress.quest_state(id) == "fertig", titel + ": alle Ziele erledigt")
			_pruefen(world, p, titel + " (abgeben)")

	# Genau Marcos Stelle: nach Kaels Gespräch zeigt der Wegweiser im Waldboden auf den Eingang der Pilzhöhle
	var w := SpielstandEditor.bauen("blade", "novize_w+w1", SpielstandEditor.weg("blade").find("das_leere_grab"), 22, 500, {})
	var s: PlayerState = w.players["spieler"]
	s.progress.quests["das_leere_grab"] = "aktiv"
	s.progress.flags["kael_getroffen"] = true
	s.progress.flags["erinnerung_rowan"] = true
	w._update_quests(s)
	w.change_map(s, "wipfelheim", w.npcs.kael.cell + Vector2i(0, 1))
	w.start_dialog(s, "kael")
	for i in 60:
		if not s.in_dialog():
			break
		if w.dialog_view(s).antworten.is_empty():
			w.apply_command(s.id, {type = "dialog_next"})
		else:
			w.apply_command(s.id, {type = "dialog_choose", index = 0})
	_check(s.progress.quest_state("der_urbaum") == "aktiv", "Nach Kaels Gespräch läuft „Der Splitter im Urbaum“")
	_check(w.objective_cell(s) != Vector2i(-1, -1), "Wipfelheim: Wegweiser zeigt zum Seilaufzug hinunter")
	w.change_map(s, "waldboden", w.get_map("waldboden").start)
	_check(w.objective_cell(s) == Vector2i(17, 27), "Waldboden: Wegweiser zeigt auf den Eingang der Pilzhöhle (%s)" % w.objective_cell(s))
	_check(w.objective_place(s).get("karte", "") == "pilzhoehle", "Das Ziel liegt in der Pilzhöhle")

	# P16: Beide Dungeon-Eingänge sind bekannt und stehen mit Boss-Symbol auf der kleinen Karte
	_check(w.dungeon_eingaenge("waldboden").size() == 1 and w.dungeon_eingaenge("waldboden")[0] == Vector2i(17, 27), "Eingang der Pilzhöhle erkannt (%s)" % [w.dungeon_eingaenge("waldboden")])
	_check(w.dungeon_eingaenge("glutoase").size() == 1, "Eingang der Vulkanschmiede erkannt (%s)" % [w.dungeon_eingaenge("glutoase")])
	_check(w.dungeon_eingaenge("wipfelheim").is_empty(), "Wipfelheim hat keinen Dungeon-Eingang")
	var zeichen := Minikarte.zeichen_fuer(w, s)
	_check(zeichen.any(func(z: Dictionary) -> bool: return z.art == "boss" and Vector2i(z.feld) == Vector2i(17, 27)), "Boss-Symbol auf der kleinen Karte")

	print("\n%s" % ("ALLES OK" if _failed == 0 else "%d FEHLER" % _failed))
	quit(1 if _failed > 0 else 0)
