extends SceneTree
## Kampf-Editor (S2): Kampf aus frei gewählten Monstern und aus dem Spiel bauen, Probe-Lauf ohne Grafik, Bildschirm.
## Aufruf: Godot --headless --path . -s tests/kampf_editor_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var a := KampfEditor.standard()
	a.gruppe[0] = {klasse = "archer", stufe = 12}
	a.gruppe[1] = {klasse = "smith", stufe = 12}
	a.monster = ["wiesenhoppler", "knollenkaefer", "tauschleim", ""]
	a.monster_stufe = 10
	a.ort = "palmenrast"
	var s := KampfEditor.setup_bauen(a)
	_check(s.helden.size() == 2 and s.helden[0].klasse == "archer" and s.helden[0].stufe == 12 and s.helden[1].get("computer", false),
			"Gruppe: Bogenschütze Stufe 12, Rüstungsschmied vom Computer")
	_check(s.helden[0].has("macht") and s.helden[0].traenke == 3, "Macht nach Stufe, Heiltränke beim eigenen Helden")
	_check(s.wellen == [["wiesenhoppler", "knollenkaefer", "tauschleim"]] and s.gegner_stufe == 10, "Drei Monster auf Stufe 10")
	_check(s.hintergrund == "palmenrast", "Ort gewählt")
	a.computer = false
	_check(not KampfEditor.setup_bauen(a).helden[1].get("computer", false), "Mitstreiter auch selbst steuerbar")
	a.monster = ["", "", "", ""]
	_check(KampfEditor.setup_bauen(a).is_empty(), "Ohne Monster kein Kampf")
	a.monster = ["kettenschmied_1", "", "", ""]
	_check(KampfEditor.setup_bauen(a).dungeon == "vulkanschmiede", "Boss bringt die Regeln seines Dungeons mit")
	# Kampf aus dem Spiel
	var b := KampfEditor.standard()
	b.art = "spiel"
	b.kampf = "kael_rivale"
	b.gruppe[0] = {klasse = "blade", stufe = 15}
	var s2 := KampfEditor.setup_bauen(b)
	_check(s2.name == GameData.battle("kael_rivale").name and s2.hintergrund == "glutoase_schmiede", "Kampf aus dem Spiel mit seinem Ort")
	_check(s2.helden.size() == 1 and s2.helden[0].klasse == "blade", "Eigene Gruppe statt der Begleiter aus dem Spiel")
	_check(KampfEditor.monster_liste().size() > 50 and not "knoten_vorne" in KampfEditor.monster_liste(), "Monster-Liste ohne Boss-Teile")
	# Probe-Lauf: Kämpfe laufen ohne Grafik durch
	var start := Time.get_ticks_msec()
	var ergebnisse: Array[Dictionary] = []
	a.monster = ["wiesenhoppler", "knollenkaefer", "", ""]
	a.monster_stufe = 3
	a.gruppe = [{klasse = "archer", stufe = 15}, {klasse = "", stufe = 1}, {klasse = "", stufe = 1}, {klasse = "", stufe = 1}]
	var leicht := KampfEditor.setup_bauen(a)
	for i in 10:
		ergebnisse.append(ProbeKampf.einmal(root, leicht, i + 1))
	var ms := Time.get_ticks_msec() - start
	var siege := ergebnisse.filter(func(e: Dictionary) -> bool: return e.gewonnen).size()
	_check(siege >= 9, "Leichter Kampf: fast immer gewonnen (%d von 10)" % siege)
	print("        10 Probe-Kämpfe in %d ms" % ms)
	var text := KampfEditor.auswertung(ergebnisse)
	_check(text.contains("von 10 Kämpfen gewonnen"), "Auswertung: " + text.split("\n")[0])
	a.monster = ["sonnenloewe", "sonnenloewe", "sonnenloewe", "sonnenloewe"]
	a.monster_stufe = 25
	a.gruppe[0] = {klasse = "novize", stufe = 1}
	var schwer := KampfEditor.setup_bauen(a)
	var verloren := 0
	for i in 5:
		if not ProbeKampf.einmal(root, schwer, i + 1).gewonnen:
			verloren += 1
	_check(verloren == 5, "Unmöglicher Kampf: immer verloren")
	# Bildschirm
	change_scene_to_file("res://scenes/kampf_editor.tscn")
	for i in 5:
		await process_frame
	_check(current_scene is KampfEditor and current_scene.find_children("*", "OptionButton", true, false).size() >= 11, "Bildschirm mit allen Auswahl-Knöpfen")
	print("Kampf-Editor: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
