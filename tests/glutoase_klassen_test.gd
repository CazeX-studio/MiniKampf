extends SceneTree
## D26: Klassen lernen in der Glutoase. Novizen der Glutoase-Klassen reisen nach der Klassenwahl in die Glutoase,
## melden sich bei Hadrak und bestehen die Prüfung ihres Lehrmeisters (Brakkus, Samira, Xavina).
## Aufruf: Godot --headless --path . -s tests/glutoase_klassen_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _abreise(world: WorldState, id: String, klasse: String) -> PlayerState:
	var p := world.add_player(id, "Test", "novize_w+w1", Vector2i(29, 60))
	p.progress.quests["abreise"] = "aktiv"
	p.progress.flags["klasse"] = klasse
	p.progress.flags["klasse_gewaehlt"] = true
	world.start_dialog(p, "ye_tor")
	world.apply_command(id, {type = "dialog_choose", index = 0})
	world.apply_command(id, {type = "dialog_choose", index = 0})
	world.apply_command(id, {type = "dialog_next"})
	# Kein Versetzen (E3i): zur Torwache, dann selbst durchs Tor (West- oder Südtor)
	var glutoase := klasse in ["smith", "blade", "singer"]
	world.start_dialog(p, "torwache_glutoase" if glutoase else "torwache_gruenwacht")
	world.apply_command(id, {type = "dialog_choose", index = 0})
	world.apply_command(id, {type = "move", cell = Vector2i(31, 65) if glutoase else Vector2i(0, 31)})
	for i in 1200:
		world.tick(0.05)
		if p.map != "kreuzweg":
			break
	return p


func _reden(world: WorldState, p: PlayerState, dialog: String, antworten: Array = []) -> void:
	world.start_dialog(p, dialog)
	for i in 12:
		if not p.in_dialog():
			break
		if world.dialog_view(p).antworten.is_empty():
			world.apply_command(p.id, {type = "dialog_next"})
		else:
			world.apply_command(p.id, {type = "dialog_choose", index = antworten.pop_front() if not antworten.is_empty() else 0})


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	var world := WorldState.new()
	for npc: String in ["hadrak", "brakkus", "samira", "xavina"]:
		_check(world.npcs.has(npc) and ResourceLoader.exists(FighterView.sprite_path(npc, "idle_vorn", 0)), "%s steht da, mit eigenen Bildern" % npc)
		_check(WorldState.portraet({wer = world.npcs[npc].name.split(" ")[-1] if npc != "hadrak" else "Hadrak"}) != "", "Porträt von %s" % npc)

	# Bogenschütze: wie bisher nach Grünwacht
	var a := _abreise(world, "a", "archer")
	_check(a.map == "weg_gruenwacht" and a.progress.quest_state("nach_gruenwacht") == "aktiv"
			and a.progress.quest_state("nach_glutoase") == "neu", "Bogenschütze reist nach Grünwacht")

	# Klingentänzerin: in die Glutoase
	var b := _abreise(world, "b", "blade")
	_check(b.map == "aschensteppe", "Klingentänzerin läuft durchs Südtor in die Aschensteppe")
	_check(b.progress.quest_state("nach_glutoase") == "aktiv" and b.progress.quest_state("nach_gruenwacht") == "neu"
			and b.progress.quest_state("klasse_lernen") == "aktiv", "Auftrag „Der Weg in die Glutoase“ läuft")
	world.change_map(b, "glutoase", Vector2i(26, 3))
	world.tick(0.1)
	world.apply_command("b", {type = "talk", npc = "hadrak"})
	for i in 100:
		world.tick(0.05)
		if b.in_dialog():
			break
	for i in 8:
		if not b.in_dialog():
			break
		if world.dialog_view(b).antworten.is_empty():
			world.apply_command("b", {type = "dialog_next"})
		else:
			world.apply_command("b", {type = "dialog_choose", index = 1})
	_check(b.progress.quest_state("nach_glutoase") == "abgegeben", "Bei Hadrak angekommen")
	_check(b.progress.battle_class() != "blade", "Noch kämpft man als Novize")
	_reden(world, b, "samira")
	world.apply_command("b", {type = "kampf_ergebnis", kampf = "samiras_pruefung", gewonnen = true})
	_check(b.progress.flags.has("samira_geprueft"), "Samiras Schrittfolge bestanden")
	_reden(world, b, "samira")
	_check(b.progress.flags.has("klasse_gelernt") and b.progress.battle_class() == "blade", "Jetzt Klingentänzerin")
	_check(b.progress.quest_state("klasse_lernen") == "abgegeben", "Auftrag „Beim Lehrmeister lernen“ erledigt")

	# Die anderen beiden Prüfungen gibt es als Kampf mit der eigenen Klasse
	for kampf: String in ["brakkus_pruefung", "samiras_pruefung", "xavinas_pruefung"]:
		var k := GameData.battle(kampf)
		_check(not k.is_empty() and k.get("eigene_klasse", false), "%s ist ein Kampf mit der eigenen Klasse" % kampf)
	_check(GameData.battle("xavinas_pruefung").hintergrund == "sternenduene", "Bei Xavina ist es immer Nacht (Sternendüne)")
	Tageszeit.feste_stunde = -1.0
	print("Glutoase-Klassen: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
