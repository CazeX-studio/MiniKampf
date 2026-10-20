extends SceneTree
## Gemeinsamer Kampf mit echter Kampf-Anzeige und echtem Netz: Dieses Programm ist Gastgeber (und spielt mit),
## ein zweites (tests/netz_gruppenkampf_gast.gd) tritt bei. Beide kämpfen den Gruppenkampf bei Ye zusammen
## (zwei Spieler, zwei Novizen-Mitstreiter). Am Ende müssen beide genau dasselbe Ergebnis haben.
## Aufruf: Godot --headless --path . --script res://tests/netz_gruppenkampf_test.gd

var _failed := 0
var _t := 0.0
var _pid := -1
var _step := 0
var _guest := ""
var _done := false


func _initialize() -> void:
	_go.call_deferred()


func _go() -> void:
	Engine.time_scale = 4.0
	for f in ["zz_gk_host.json", "zz_gk_gast.json"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://" + f))
	Netz.save_override = "user://zz_gk_host_spielstand.json"
	SaveGame.path = Netz.save_override
	SaveGame.delete()
	_check(Netz.host("Marco", "knight_m") == OK, "Gastgeber startet")
	change_scene_to_file("res://scenes/kreuzweg.tscn")
	_pid = OS.create_process(OS.get_executable_path(),
			["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/netz_gruppenkampf_gast.gd"])


func _process(delta: float) -> bool:
	_t += delta
	NetzGruppenkampfHelfer.drive(self)
	match _step:
		0:
			for id: String in Netz.world.players if Netz.world else {}:
				if id != Netz.my_id:
					_guest = id
			if _guest != "":
				Netz.group_action("einladen", _guest)
				_step = 1
				_t = 0.0
		1:
			if Netz.group.get("members", []).size() == 2:
				_check(true, "Gruppe steht")
				# Wie aus einer gemeinsamen Szene bei Ye: beide kämpfen zusammen
				Netz.world.group_battle_requested.emit([Netz.my_id, _guest], "gruppenkampf")
				_step = 2
				_t = 0.0
			elif _t > 20.0:
				_check(false, "Gruppe steht")
				return _finish()
		2:
			if current_scene is Combat:
				_check(current_scene._group.mine == 0 and current_scene.state.heroes.size() == 4, "Kampfbildschirm: Gruppenkampf mit vier Helden, ich steuere den ersten")
				_check(current_scene._is_remote(current_scene.state.heroes[1]), "Der zweite Held gehört dem Mitspieler")
				_check(current_scene.state.computer.size() == 2, "Zwei Novizen-Mitstreiter spielt der Computer")
				_step = 3
				_t = 0.0
			elif _t > 10.0:
				_check(false, "Kampfbildschirm öffnet sich")
				return _finish()
		3:
			if not _done and NetzGruppenkampfHelfer.finish(self, "zz_gk_host.json"):
				_done = true
			if _done and not OS.is_process_running(_pid):
				var host := _read("zz_gk_host.json")
				var guest := _read("zz_gk_gast.json")
				_check(not guest.is_empty(), "Mitspieler hat zu Ende gekämpft")
				_check(host == guest, "Beide haben genau dasselbe Ergebnis (Sieger, Züge, Leben aller Figuren)")
				print("    %s nach %d Zügen" % ["Sieg" if host.get("won", false) else "Niederlage", int(host.get("turns", 0))])
				_check(current_scene != null and current_scene.has_method("local_player"), "Zurück in der Stadt")
				return _finish()
			if _t > 400.0:
				_check(false, "Kampf ist in der Zeit fertig")
				return _finish()
	return false


func _read(file_name: String) -> Dictionary:
	var path := "user://" + file_name
	if not FileAccess.file_exists(path):
		return {}
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return data if data is Dictionary else {}


func _finish() -> bool:
	if _pid > 0 and OS.is_process_running(_pid):
		OS.kill(_pid)
	SaveGame.delete()
	for f in ["zz_gk_host.json", "zz_gk_gast.json"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://" + f))
	Netz.stop()
	print("Netz-Gruppenkampf: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
	return true


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failed += 1
	print("%s %s" % ["OK    " if ok else "FEHLER", what])
