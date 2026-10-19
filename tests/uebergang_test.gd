extends SceneTree
## Prüft den echten Wechsel Stadt -> Kampfbildschirm -> Stadt (mit Anzeige, ohne Fenster).
## Aufruf: Godot --headless --path . --script res://tests/uebergang_test.gd

var _failed := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	# Spielstand: erster Auftrag erledigt, Ye wartet am Stadttor
	var p := PlayerState.new("spieler", "Du", "elf_m", Vector2i(11, 18))
	p.progress.quests = {ankunft = "abgegeben", zu_ye = "abgegeben", erster_auftrag = "abgegeben"}
	p.progress.flags = {angekommen = true, gilde_angemeldet = true, ausbildung_morgen = true}
	p.progress.xp = 100
	p.progress.level = 2
	SaveGame.save(p)

	change_scene_to_file("res://scenes/kreuzweg.tscn")
	await _frames(5)
	var town: Node = current_scene
	var local: PlayerState = town.local_player()
	_check(town.state.npc_visible(local, "ye_tor"), "Ye steht am Stadttor")
	town.state.apply_command("spieler", {type = "talk", npc = "ye_tor"})
	await _frames(120)
	_check(local.in_dialog(), "Gespräch mit Ye am Tor beginnt")
	town.state.apply_command("spieler", {type = "dialog_choose", index = 0})
	town.state.apply_command("spieler", {type = "dialog_choose", index = 0})
	await _frames(5)
	_check(current_scene is Combat, "Wechsel zum Kampfbildschirm")
	var combat: Combat = current_scene
	_check(combat.state.setup.get("name", "") == "Lektion 1: Die Tempo-Leiste", "Lektion 1 läuft")
	_check(combat.state.heroes[0].display_name == "Du" and combat.state.heroes[0].max_hp == 100, "Novize mit Stufe 2 (100 Leben)")
	combat._back_to_world(true)
	await _frames(5)
	town = current_scene
	_check(town.has_method("local_player"), "Zurück in der Stadt")
	local = town.local_player()
	_check(local.progress.flags.has("kampf_gewonnen:lektion_tempo"), "Lektion 1 zählt als bestanden")
	_check(local.progress.xp == 175, "75 Erfahrung für den ersten Sieg")
	_check(local.cell == Vector2i(12, 18) or (Vector2(local.cell) - Vector2(12, 19)).length() < 2.0, "Spieler steht noch bei Ye")
	SaveGame.delete()
	print("Übergang Stadt/Kampf: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _check(condition: bool, text: String) -> void:
	if not condition:
		_failed += 1
		print("FEHLER: " + text)
