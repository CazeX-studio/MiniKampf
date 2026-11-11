extends SceneTree
## D20d: Figuren tags und nachts an ihren Plätzen (NPC.md), Volk aus dem Baukasten, Marktstände nachts zu.
## Aufruf: Godot --headless --path . -s tests/tag_nacht_figuren_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "novize_m+m1", Vector2i(30, 30))
	p.progress.flags["gilde_angemeldet"] = true
	p.progress.flags["ausbildung_morgen"] = true
	world.nacht = false
	var tag: Vector2i = world.npcs.ye_tor.cell
	for id: String in ["marktfrau", "marktmann", "buerger_1", "buerger_2", "buerger_3", "buerger_4", "pip", "lotte", "quill", "edmar",
			"tessa", "gorm"]:
		_check(world.npc_visible(p, id), "Tags da: %s" % id)
	p.map = "wegrast"
	_check(world.npc_visible(p, "gast_1") and world.npc_visible(p, "hanne"), "Tags im Wegrast: Hanne und ein Gast")
	for id: String in ["gast_2", "gast_3"]:
		_check(not world.npc_visible(p, id), "Tags nicht da: %s" % id)
	p.map = "kreuzweg"
	for id: String in ["marktfrau", "marktmann", "buerger_1", "gast_1", "tessa", "gorm", "torwache_arkanum"]:
		_check(FigurTeile.bild(world.npcs[id].look, "idle_vorn", 0) != null, "Aus dem Baukasten: %s" % id)

	world.nacht = true
	_check(world.npcs.ye_tor.cell == Vector2i(12, 44) and world.npcs.ye_tor.cell != tag, "Nachts: Ye in der Gilde")
	_check(world.npcs.marv.map == "wegrast" and world.npcs.marv.cell == Vector2i(6, 9), "Nachts: Marv drinnen im Wegrast (A17)")
	_check(world.npcs.tessa.map == "wegrast" and world.npcs.gorm.map == "wegrast", "Nachts: Tessa und Gorm drinnen im Wegrast")
	for id: String in ["marv", "tessa", "gorm"]:
		_check(not world.get_map("wegrast").is_walkable(world.npcs[id].nacht_cell), "%s: Platz im Wegrast ist frei und gesperrt" % id)
	for id: String in ["marktfrau", "marktmann", "buerger_1", "buerger_2", "buerger_4", "pip", "lotte", "quill", "edmar"]:
		_check(not world.npc_visible(p, id), "Nachts nicht da: %s" % id)
	for id: String in ["buerger_3", "bingo", "hatta", "schreiberin", "bank_kreuzweg", "wache"]:
		_check(world.npc_visible(p, id), "Nachts da: %s" % id)
	# Hanne und die Gäste stehen seit A12 drinnen im Gasthaus Wegrast
	p.map = "wegrast"
	for id: String in ["gast_1", "gast_2", "gast_3", "hanne"]:
		_check(world.npc_visible(p, id), "Nachts im Wegrast: %s" % id)
	p.map = "kreuzweg"
	world.start_dialog(p, "tessa")
	_check(world.dialog_view(p).text.begins_with("Schlafen?"), "Tessa nachts")
	world.apply_command("a", {type = "dialog_next"})
	p.progress.flags["nacht"] = true
	_check(world.npc_visible(p, "edmar") and world.npc_visible(p, "pip"), "Am Festabend sind Edmar und die Kinder da")
	p.progress.flags.erase("nacht")
	world.nacht = false
	_check(world.npcs.ye_tor.cell == tag, "Morgens: Ye wieder am Tor")
	_check(world.npcs.tessa.map == "kreuzweg" and world.npcs.marv.map == "kreuzweg", "Morgens: Tessa und Marv wieder draußen")

	# Marktstände: tags offen, nachts zu, der Platz bleibt immer gesperrt
	var offen := 0
	var zu := 0
	for o: Dictionary in GameData.get_file("kreuzweg_karte").objekte:
		if str(o.teil).begins_with("marktstand"):
			_check(o.get("sperrt", false), "%s sperrt den Platz" % o.teil)
			if str(o.teil).ends_with("_zu"):
				zu += 1
				_check(o.wenn == {"nacht": true}, "%s nur nachts" % o.teil)
			else:
				offen += 1
				_check(o.wenn == {"nacht": false}, "%s nur tags" % o.teil)
	_check(offen == 2 and zu == 2, "Zwei Marktstände, je offen und zu")
	_check(world.blocked.has(Vector2i(49, 14)), "Marktstand-Feld gesperrt")
	Tageszeit.feste_stunde = -1.0
	print("Tag und Nacht: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
