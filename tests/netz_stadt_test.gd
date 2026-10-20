extends SceneTree
## Prüft die echte Stadt-Anzeige beim Zusammenspielen: Startet einen Server ohne Grafik
## (wie später im Internet: Godot --headless --path . -- --server), tritt bei, öffnet Kreuzweg,
## redet, lädt die Stadt neu (Verlassen und wieder Beitreten) und geht zurück ins Menü.
## Aufruf: Godot --headless --path . --script res://tests/netz_stadt_test.gd

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
				Netz.save_override = "user://spielstand_test_stadt.json"
				Netz.join("localhost", "Stadttest", "wizzard_f")
				SaveGame.delete()
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
				_check(town != null and town.has_method("local_player"), "Kreuzweg ist offen")
				_check(town.local_id == Netz.my_id and Netz.my_id != "p1", "Eigene Kennung kommt vom Server")
				_check(town.state == Netz.world, "Die Stadt zeigt das Spiegelbild der Server-Welt")
				_check(town.local_player().in_dialog(), "Einleitung vom Server ist zu sehen (Befehl „start“ beim Betreten)")
				_check(town._dialog.visible, "Gesprächsfenster ist offen")
				town._send({type = "dialog_next"})
				_step = 3
				_time = 0.0
		3:
			if _time > 1.0:
				var town := current_scene
				_check(town._characters.has(Netz.my_id), "Eigene Figur steht in der Stadt")
				_check(not town._characters.has("gefaehrte"), "Kein Testgefährte beim Zusammenspielen")
				_check(town._chat_button != null and town._chat_button.visible, "Chat-Knopf ist da")
				town._open_chat()
				_check(town._chat_input.visible and town._chat_input.has_focus(), "Chat-Eingabe öffnet sich")
				town._on_chat_submitted("Hallo Kreuzweg")
				_check(not town._chat_input.visible, "Nach dem Abschicken schließt die Eingabe")
				_step = 31
				_time = 0.0
		31:
			if _time > 1.0:
				var town := current_scene
				var lines: Array[String] = []
				for line in town._chat_lines:
					lines.append(line.text)
				_check("Stadttest: Hallo Kreuzweg" in lines, "Eigene Nachricht steht im Chat")
				_check(town._characters[Netz.my_id]._bubble != null, "Sprechblase über der eigenen Figur")
				town._restart()
				_step = 4
				_time = 0.0
		4:
			if _time > 1.5:
				var town := current_scene
				_check(town != null and town.local_player().in_dialog(), "Nach „Neu beginnen“ wieder beigetreten, Einleitung kommt erneut")
				town._go_menu()
				_step = 5
				_time = 0.0
		5:
			if _time > 1.0:
				_check(not Netz.online(), "Menü beendet das Zusammenspielen")
				_check(SaveGame.path == SaveGame.DEFAULT_PATH, "Allein-Spielstand gilt wieder")
				_check(FileAccess.file_exists("user://spielstand_test_stadt.json"), "Spielstand beim Verlassen gespeichert")
				return _finish()
	return false


func _finish() -> bool:
	OS.kill(_pid)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://spielstand_test_stadt.json"))
	print("Netz-Stadt: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
	return true


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failed += 1
	print("%s %s" % ["OK    " if ok else "FEHLER", what])
