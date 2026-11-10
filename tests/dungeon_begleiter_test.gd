extends SceneTree
## Begleiter im Dungeon (A9a, Alpha-Punkt 37): Am Eingang von Pilzhöhle und Vulkanschmiede wählt man, wer mitkommt.
## Die Wahl gilt für alle Kämpfe des Durchgangs (Monster und Bosse). Aufruf: Godot --headless --path . -s tests/dungeon_begleiter_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "novize_w+w1", WorldState.start_cell())
	# Vulkanschmiede: Eingang offen, „Mit Gorm“
	p.progress.quests = {"rivale_kael": "abgegeben"}
	world.change_map(p, "glutoase", Vector2i(22, 3))
	world.start_dialog(p, "eingang_vulkanschmiede")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(str(p.dialog.get("node", "")) == "wer" and world.dialog_view(p).antworten.size() == 5, "Vulkanschmiede: Frage, wer mitkommt (fünf Antworten)")
	world.apply_command("a", {type = "dialog_choose", index = 2})
	_check(p.map == "vulkanschmiede" and p.progress.flags.has("lauf:mit:gorm") and not p.progress.flags.has("lauf:mit:tessa"),
			"Vulkanschmiede: mit Gorm hinab")
	# Pilzhöhle: allein
	world.change_map(p, "waldboden", Vector2i(21, 18))
	world.start_dialog(p, "eingang_pilzhoehle")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.map == "pilzhoehle" and p.progress.flags.has("lauf:begleiter_gewaehlt") and not p.progress.flags.has("lauf:mit:gorm"),
			"Pilzhöhle: allein hinab, die Wahl aus der Vulkanschmiede gilt nicht mehr")
	# Kämpfe: im Dungeon die gewählten, sonst die aus den Kampfdaten
	var boss := GameData.battle("pilz_urbaum")
	BattleRequest.dungeon_begleiter = []
	_check(BattleRequest.begleiter_fuer(boss).is_empty(), "Boss allein")
	BattleRequest.dungeon_begleiter = ["tessa"]
	_check(BattleRequest.begleiter_fuer(boss).map(func(b: Dictionary) -> String: return b.name) == ["Tessa"], "Boss mit Tessa")
	BattleRequest.dungeon_begleiter = null
	_check(BattleRequest.begleiter_fuer(boss).size() == 2, "Ohne Wahl wie bisher: Tessa und Gorm")
	BattleRequest.dungeon_begleiter = ["tessa", "gorm"]
	_check(BattleRequest.begleiter_fuer(GameData.battle("gruppenkampf")) == GameData.battle("gruppenkampf").begleiter, "Außerhalb des Dungeons zählt die Wahl nicht")
	var wild := -1
	var monster := GameData.wild_monsters()
	for i in monster.size():
		if str(monster[i].get("dungeon", "")) == "vulkanschmiede":
			wild = i
			break
	BattleRequest.player_look = "novize_w+w1"
	_check(wild >= 0 and BattleRequest.prepare("wild:%d" % wild, 18) and BattleRequest.setup.helden.size() == 3,
			"Monster in der Vulkanschmiede: zu dritt (%d Helden)" % (BattleRequest.setup.get("helden", []) as Array).size())
	BattleRequest.dungeon_begleiter = null
	BattleRequest.kampf_id = ""
	print("Dungeon-Begleiter: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
