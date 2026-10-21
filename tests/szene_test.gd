extends SceneTree
## Prüft gemeinsame Szenen ohne Netz: Gruppenmitglieder in der Nähe erleben ein Gespräch mit, wer an derselben Stelle
## der Geschichte ist, stimmt ab, die anderen schauen zu. Gleichstand, Weiterblättern, Verlassen, Belohnungen.
## Aufruf: Godot --headless --path . --script res://tests/szene_test.gd

var _failed := 0


func _initialize() -> void:
	_test_result_rules()
	_test_scene()
	_test_scene_battle()
	_test_star_night()
	_test_boss_scaling()
	print("Szenen: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


func _test_result_rules() -> void:
	var w := WorldState.new()
	_check(w.scene_result({a = 0, b = 0, c = 1}, "c", "a") == 0, "Mehrheit gewinnt")
	_check(w.scene_result({a = 0, b = 1}, "b", "a") == 1, "Gleichstand: Gruppenführer entscheidet")
	_check(w.scene_result({a = 0, b = 1}, "x", "a") == 0, "Gleichstand ohne Stimme des Gruppenführers: wer spricht")
	_check(w.scene_result({b = 1}, "a", "a") == 1, "Nur eine Stimme abgegeben: die gilt")


func _near(w: WorldState, center: Vector2i, skip: Array) -> Vector2i:
	for r in range(1, 5):
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				var cell := center + Vector2i(dx, dy)
				if w.is_walkable(cell) and not cell in skip:
					return cell
	return center


func _test_scene() -> void:
	var w := WorldState.new()
	var lene: Vector2i = w.npcs["schreiberin"].cell
	var used: Array = []
	var ids := ["a", "b", "c", "fern"]
	for id: String in ids:
		var cell := _near(w, lene, used) if id != "fern" else WorldState.start_cell()
		used.append(cell)
		var p := w.add_player(id, id.to_upper(), "elf_m", cell)
		p.progress.quests["ankunft"] = "aktiv"
	# C ist schon weiter (hat sich schon angemeldet) und schaut deshalb nur zu
	w.players["c"].progress.quests["ankunft"] = "abgegeben"
	w.players["c"].progress.quests["zu_ye"] = "aktiv"
	w.group_members = func(_id: String) -> Array: return ids
	w.group_leader = func(_id: String) -> String: return "b"
	var notices := []
	w.notice.connect(func(id: String, text: String) -> void: notices.append([id, text]))

	w.apply_command("a", {type = "talk", npc = "schreiberin"})
	_tick_until(w, func() -> bool: return w.players["a"].in_dialog())
	var a: PlayerState = w.players["a"]
	var b: PlayerState = w.players["b"]
	var c: PlayerState = w.players["c"]
	_check(b.in_dialog() and c.in_dialog(), "Gruppenmitglieder in der Nähe sind in der Szene")
	_check(not w.players["fern"].in_dialog(), "Wer weit weg steht, wird nicht mitgeholt")
	_check(w.dialog_view(a).szene.rolle == "spricht" and w.dialog_view(b).szene.rolle == "abstimmen", "A spricht, B stimmt ab")
	_check(w.dialog_view(c).szene.rolle == "zuschauen", "C ist woanders in der Geschichte und schaut zu")
	_check(w.dialog_view(c).text == w.dialog_view(a).text, "Alle sehen denselben Text")

	w.apply_command("c", {type = "dialog_choose", index = 0})
	_check(w.dialog_view(a).szene.stimmen == [0, 0], "Zuschauer können nicht abstimmen")
	w.apply_command("a", {type = "dialog_choose", index = 0})
	_check(w.dialog_view(b).szene.stimmen == [1, 0] and w.dialog_view(b).szene.offen == 1, "Stimme von A ist zu sehen, B fehlt noch")
	w.apply_command("b", {type = "dialog_choose", index = 1})
	_check(a.dialog.node == "gilde" and c.dialog.node == "gilde", "Gleichstand: Gruppenführer B entscheidet (Frage nach der Gilde)")

	w.apply_command("b", {type = "dialog_next"})
	_check(a.dialog.node == "gilde", "Nur wer spricht, blättert weiter")
	w.apply_command("a", {type = "dialog_next"})
	_check(b.dialog.node == "anmeldung", "A blättert weiter, alle sind wieder bei der Frage")

	w.apply_command("a", {type = "dialog_choose", index = 0})
	w.apply_command("b", {type = "dialog_choose", index = 0})
	_check(a.dialog.node == "eingetragen", "Beide wählen „Ja, bitte.“")
	_check(a.progress.flags.has("gilde_angemeldet") and b.progress.flags.has("gilde_angemeldet"), "Belohnung und Fortschritt für alle, die abgestimmt haben")
	_check(b.progress.quest_state("zu_ye") == "aktiv", "B hat den nächsten Auftrag")
	_check(not c.progress.flags.has("gilde_angemeldet"), "Zuschauer bekommen nichts (sie haben es schon oder sind woanders)")
	w.apply_command("a", {type = "dialog_next"})
	_check(not a.in_dialog() and not b.in_dialog() and not c.in_dialog() and w.scenes.is_empty(), "Szene ist für alle vorbei")

	# Verlassen: B geht aus der Szene, A spricht weiter; geht auch A, ist sie vorbei
	w.apply_command("a", {type = "talk", npc = "schreiberin"})
	_tick_until(w, func() -> bool: return a.in_dialog())
	_check(b.in_dialog(), "Neue Szene mit B")
	w.apply_command("b", {type = "szene_verlassen"})
	_check(not b.in_dialog() and a.in_dialog(), "B verlässt die Szene, A ist noch drin")
	w.remove_player("a")
	_check(c.in_dialog() and w.dialog_view(c).szene.rolle == "spricht", "A geht (z. B. Kampf): C ist jetzt an derselben Stelle und spricht weiter")
	w.remove_player("c")
	_check(w.scenes.is_empty(), "Niemand mehr zum Abstimmen: Szene vorbei")

	# Zeit läuft ab: die abgegebenen Stimmen zählen
	var w2 := WorldState.new()
	used.clear()
	for id: String in ["x", "y"]:
		var cell := _near(w2, lene, used)
		used.append(cell)
		w2.add_player(id, id, "elf_m", cell).progress.quests["ankunft"] = "aktiv"
	w2.group_members = func(_id: String) -> Array: return ["x", "y"]
	w2.apply_command("x", {type = "talk", npc = "schreiberin"})
	_tick_until(w2, func() -> bool: return w2.players["x"].in_dialog())
	w2.apply_command("x", {type = "dialog_choose", index = 1})
	w2.tick(WorldState.VOTE_SECONDS + 0.1)
	_check(w2.players["y"].dialog.get("node", "") == "gilde", "Zeit abgelaufen: die abgegebene Stimme zählt")

	# Allein (keine Gruppe): ganz normales Gespräch
	var w3 := WorldState.new()
	var solo := w3.add_player("s", "S", "elf_m", _near(w3, lene, []))
	solo.progress.quests["ankunft"] = "aktiv"
	w3.apply_command("s", {type = "talk", npc = "schreiberin"})
	_tick_until(w3, func() -> bool: return solo.in_dialog())
	_check(not solo.dialog.has("szene") and not w3.dialog_view(solo).has("szene"), "Allein: normales Gespräch ohne Abstimmung")


## Ein Kampf aus einer Szene: mit mehreren Abstimmenden ein Gruppenkampf, sonst wie bisher einzeln.
func _test_scene_battle() -> void:
	var w := WorldState.new()
	w.add_player("a", "A", "elf_m", WorldState.start_cell())
	w.add_player("b", "B", "elf_m", WorldState.start_cell() + Vector2i(1, 0))
	var group_battles := []
	var solo_battles := []
	w.group_battle_requested.connect(func(ids: Array, kampf: String) -> void: group_battles.append([ids, kampf]))
	w.battle_requested.connect(func(id: String, kampf: String) -> void: solo_battles.append([id, kampf]))
	w._scene_actions({voters = ["a", "b"], watchers = []}, [{auftrag_starten = "erster_gruppenkampf"}, {kampf = "gruppenkampf"}])
	_check(group_battles == [[["a", "b"], "gruppenkampf"]] and solo_battles.is_empty(), "Kampf aus einer Szene mit zwei Abstimmenden: Gruppenkampf für beide")
	_check(w.players["b"].progress.quest_state("erster_gruppenkampf") == "aktiv", "Die anderen Aktionen gelten trotzdem für alle")
	w._scene_actions({voters = ["a"], watchers = ["b"]}, [{kampf = "gruppenkampf"}])
	_check(solo_battles == [["a", "gruppenkampf"]] and group_battles.size() == 1, "Nur einer stimmt ab: normaler Kampf allein")


## Nacht des Sternenfalls zusammen: Marv holt die Gruppe auf dem Fest, alle sehen den Sternenfall,
## nach dem Kampf wartet Ren, bis alle zurück sind, und spricht dann alle zusammen an.
func _test_star_night() -> void:
	var w := WorldState.new()
	var marv: Vector2i = w.npcs["marv_fest"].cell
	var used: Array = []
	for id: String in ["a", "b", "z"]:
		var cell := _near(w, marv, used) if id != "z" else WorldState.start_cell()
		used.append(cell)
		var p := w.add_player(id, id.to_upper(), "elf_m", cell)
		if id != "z":
			p.progress.flags["nacht"] = true
			p.progress.quests["fest"] = "aktiv"
	w.group_members = func(_id: String) -> Array: return ["a", "b"]
	w.group_leader = func(_id: String) -> String: return "a"
	var effects := {}
	w.effect_requested.connect(func(id: String, effect: String) -> void: effects[id] = effects.get(id, []) + [effect])
	var battles := []
	w.group_battle_requested.connect(func(ids: Array, kampf: String) -> void: battles.append([ids, kampf]))
	w.tick(0.05)
	var a: PlayerState = w.players["a"]
	var b: PlayerState = w.players["b"]
	_check(a.in_dialog() and b.in_dialog() and a.dialog.has("szene"), "Marv spricht die Gruppe auf dem Fest gemeinsam an")
	_check(b.progress.flags.has("angesprochen:marv_fest"), "Marv spricht danach niemanden aus der Gruppe noch einmal an")
	# Durch das Gespräch: Antworten wählen und weiterblättern, bis der Kampf beginnt
	for i in 12:
		if not a.in_dialog():
			break
		if w.dialog_view(a).antworten.is_empty():
			w.apply_command("a", {type = "dialog_next"})
		else:
			w.apply_command("a", {type = "dialog_choose", index = 0})
			w.apply_command("b", {type = "dialog_choose", index = 0})
	_check(effects.get("a", []) == ["sternenfall"] and effects.get("b", []) == ["sternenfall"], "Sternenfall: einmal für jeden in der Szene")
	_check(effects.get("z", []) == ["sternenfall"], "… und auch für alle anderen in der Stadt sichtbar")
	_check(battles == [[["a", "b"], "sternenfall"]], "Beide kämpfen zusammen gegen den Sternenfresser")

	# Kampf: beide verlassen die Stadt. A kommt zuerst zurück und wartet, bis B auch da ist.
	w.add_battle_group(["a", "b"])
	var b_cell := b.cell
	w.remove_player("b")
	w.apply_command("a", {type = "kampf_ergebnis", kampf = "sternenfall", gewonnen = true})
	for i in 10:
		w.tick(0.05)
	_check(not a.in_dialog() and w.waiting_for_group("a"), "Ren wartet, solange noch jemand aus der Gruppe kämpft")
	var b2 := w.add_player("b", "B", "elf_m", b_cell)
	b2.progress.load_dict(b.progress.to_dict())
	w.apply_command("b", {type = "kampf_ergebnis", kampf = "sternenfall", gewonnen = true})
	w.tick(0.05)
	_check(a.in_dialog() and b2.in_dialog() and a.dialog.get("id", "") == "ren", "Alle zurück: Ren spricht beide zusammen an")
	_check(w.dialog_view(b2).get("szene", {}).get("rolle", "") in ["spricht", "abstimmen"], "Beide stimmen in der Szene mit Ren ab")
	_check(a.progress.flags.has("erfolg:schild_hoch") and b2.progress.flags.has("erfolg:schild_hoch"), "Beide haben den Erfolg „Schild hoch, Schild runter“")


## Der Sternenfresser hat mehr Leben, je mehr Spieler mitkämpfen.
func _test_boss_scaling() -> void:
	var one := BattleRequest.build_group("sternenfall", [{name = "A", stufe = 8}])
	var two := BattleRequest.build_group("sternenfall", [{name = "A", stufe = 8}, {name = "B", stufe = 8}])
	_check(is_equal_approx(float(two.gegner_leben), 1.25) and is_equal_approx(float(one.gegner_leben), 1.0), "Zwei Spieler: Sternenfresser mit 25 % mehr Leben")
	_check(not BattleRequest.build_group("gruppenkampf", [{name = "A", stufe = 3}, {name = "B", stufe = 3}]).has("gegner_leben"), "Andere Kämpfe bleiben gleich stark")
	var hp := []
	for setup: Dictionary in [one, two]:
		var battle := BattleState.new(null, [] as Array[String], "", 1)
		battle.setup = setup
		battle._create_heroes()
		battle.waves = setup.wellen
		battle._spawn_wave(0)
		hp.append(battle.enemies[0].hp)
		battle.cleanup()
	_check(hp[1] > hp[0], "Im Kampf: %d statt %d Leben" % [hp[1], hp[0]])


func _tick_until(w: WorldState, done: Callable) -> void:
	for i in 300:
		if done.call():
			return
		w.tick(0.05)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failed += 1
	print("%s %s" % ["OK    " if ok else "FEHLER", what])
