extends SceneTree
## Prüft mehrere Karten beim Zusammenspielen: Startet einen Server ohne Grafik, tritt mit einem Spielstand auf dem
## Weg nach Grünwacht bei, läuft in den Wald (der Server bringt einen auf den Waldboden), fährt mit dem Seilaufzug
## nach Wipfelheim, verlässt die Welt und betritt sie wieder (man kommt wieder in Wipfelheim an).
## Aufruf: Godot --headless --path . --script res://tests/netz_gruenwacht_test.gd

const SAVE := "user://spielstand_test_gruenwacht_netz.json"

var _failed := 0
var _time := 0.0
var _step := 0
var _pid := -1


func _initialize() -> void:
	_pid = OS.create_process(OS.get_executable_path(),
			["--headless", "--path", ProjectSettings.globalize_path("res://"), "--", "--server"])
	_check(_pid > 0, "Server ohne Grafik startet")


func _process(delta: float) -> bool:
	_time += delta
	match _step:
		0:
			if _time > 3.0:
				Netz.save_override = SAVE
				Netz.join("localhost", "Waldläufer", "elf_f")
				# Spielstand: Klasse gewählt, auf dem Weg kurz vor dem Wald
				var file := FileAccess.open(SAVE, FileAccess.WRITE)
				file.store_string(JSON.stringify({version = SaveGame.VERSION, karte = "weg_gruenwacht", feld = [3, 6],
						progress = {level = 10, flags = {"angekommen": true, "klasse": "archer", "klasse_bestaetigt": true},
							quests = {nach_gruenwacht = "aktiv"}}}))
				file.close()
				Netz._node().connected.connect(func() -> void:
					change_scene_to_file("res://scenes/kreuzweg.tscn")
					_step = 2
					_time = 0.0)
				_step = 1
		1:
			if _time > 10.0:
				_check(false, "Verbindung zum Server")
				return _finish()
		2:
			if _time > 1.5:
				var town := current_scene
				_check(town != null and town.has_method("local_player"), "Welt ist offen")
				if town == null or not town.has_method("local_player"):
					return _finish()
				_check(town.local_player().map == "weg_gruenwacht" and town._shown_map == "weg_gruenwacht",
						"Mitspieler kommt auf dem Weg nach Grünwacht an (Karte aus dem Spielstand)")
				_check(not town._characters.has("npc:hanne"), "Figuren aus Kreuzweg sind hier nicht zu sehen")
				town._send({type = "move", cell = Vector2i(0, 6)})
				_step = 3
				_time = 0.0
		3:
			if _time > 2.5:
				var town := current_scene
				_check(town.local_player().map == "waldboden", "Der Server bringt einen in den Wald (Waldboden)")
				_check(town._shown_map == "waldboden", "Die Anzeige zeigt jetzt den Waldboden")
				_check(town._info.text.begins_with("Waldboden"), "Oben links steht die Karte: " + town._info.text)
				var lift := ""
				for i in town.state.places.size():
					if town.state.places[i].map == "waldboden" and town.state.places[i].art == "seilaufzug":
						lift = "ort:%d" % i
				_check(town._pickup_nodes.has(lift), "Seilaufzug ist zu sehen")
				town._send({type = "use", target = lift})
				_step = 4
				_time = 0.0
		4:
			if _time > 6.0:
				var town := current_scene
				_check(town.local_player().map == "wipfelheim" and town._shown_map == "wipfelheim", "Mit dem Seilaufzug nach Wipfelheim")
				_check(town._characters.has("npc:ysolde") and town._characters["npc:ysolde"].visible, "Ysolde ist zu sehen")
				_check(town.state.objective(town.local_player()).contains("Ysolde"), "Ziel: mit Ysolde reden")
				# Welt verlassen und wieder betreten (wie nach einem Kampf)
				change_scene_to_file("res://scenes/kreuzweg.tscn")
				_step = 5
				_time = 0.0
		5:
			if _time > 2.0:
				var town := current_scene
				_check(town != null and town.local_player().map == "wipfelheim", "Nach dem erneuten Betreten wieder in Wipfelheim")
				town._go_menu()
				_step = 6
				_time = 0.0
		6:
			if _time > 1.0:
				var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
				_check(data is Dictionary and data.get("karte", "") == "wipfelheim", "Spielstand merkt sich Wipfelheim")
				return _finish()
	return false


func _finish() -> bool:
	OS.kill(_pid)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))
	print("Netz-Grünwacht: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
	return true


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failed += 1
	print("%s %s" % ["OK    " if ok else "FEHLER", what])
