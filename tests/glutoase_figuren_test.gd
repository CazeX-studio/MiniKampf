extends SceneTree
## D27: Glutoase-Figuren nach Steckbrief (NPC.md), Volk aus dem Baukasten und der Rastplatz-Händler.
## Aufruf: Godot --headless --path . -s tests/glutoase_figuren_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "novize_m+m1", Vector2i(23, 2))
	world.change_map(p, "glutoase", Vector2i(23, 2))
	world.nacht = false
	for id: String in world.npcs:
		var npc: Dictionary = world.npcs[id]
		if npc.map != "glutoase" and id != "rastplatz_haendler":
			continue
		var bild: Texture2D = FighterView.einzelbild(npc.look, "idle_vorn", 0)
		_check(bild != null, "%s lässt sich zeichnen (%s)" % [id, npc.look])
	for wer: String in ["Nadia", "Zaid", "Rashid", "Tarek", "Layla", "Mira"]:
		_check(WorldState.portraet({wer = wer}) != "", "Porträt von %s" % wer)
	_check(world.npcs.mira_glutoase.liegt, "Mira liegt krank im Krankenzelt")
	_check(world.npcs.bank_glutoase.zeichen == "truhe" and world.npcs.tarek.zeichen == "muenze" and world.npcs.rastplatz_haendler.zeichen == "muenze",
			"Zeichen über Bank, Tarek und dem Rastplatz-Händler")
	_check(GameData.get_file("laeden").has("tarek") and GameData.get_file("laeden").tarek.waren.has("breitschwert"), "Tarek verkauft Grundwaffen")
	_check(GameData.get_file("laeden").has("rastplatz") and world.npcs.rastplatz_haendler.map == "aschensteppe"
			and world.get_map("aschensteppe").sicher.has_point(world.npcs.rastplatz_haendler.cell), "Rastplatz-Händler am Rastplatz der Aschensteppe")
	for id: String in ["basar_1", "basar_2", "schmied_1", "karawane_1", "aufzugwaerter"]:
		_check(world._npc_present(p, id), "Tags da: %s" % id)
	for id: String in ["taenzer_1", "taenzer_2", "gast_go_2"]:
		_check(not world._npc_present(p, id), "Tags nicht da: %s" % id)
	world.nacht = true
	for id: String in ["taenzer_1", "taenzer_2", "gast_go_2", "gast_go_3", "samira"]:
		_check(world._npc_present(p, id), "Nachts da: %s" % id)
	_check(not world._npc_present(p, "basar_1"), "Nachts ist der Basar leer")
	_check(world.npcs.hadrak.cell == Vector2i(31, 7), "Nachts sitzt Hadrak beim Gasthaus")
	world.start_dialog(p, "layla")
	_check(world.dialog_view(p).text.contains("Hadrak"), "Layla nachts")
	Tageszeit.feste_stunde = -1.0
	print("Glutoase-Figuren: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
