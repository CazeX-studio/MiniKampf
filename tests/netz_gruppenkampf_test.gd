extends SceneTree
## Vier Spieler mit echter Kampf-Anzeige und echtem Netz: Dieses Programm ist Gastgeber (und spielt mit),
## drei weitere (tests/netz_gruppenkampf_gast.gd) treten bei. Alle bilden eine Gruppe, schreiben im Chat und kämpfen
## den Gruppenkampf bei Ye zu viert (kein Platz mehr für Novizen-Mitstreiter). Am Ende müssen alle genau dasselbe
## Ergebnis haben. Mit weniger Mitspielern: … -- 1  (dann füllen Mitstreiter auf)
## Aufruf: Godot --headless --path . --script res://tests/netz_gruppenkampf_test.gd

var _failed := 0
var _t := 0.0
const GUESTS: Array[Array] = [["Mira", "wizzard_f"], ["Kael", "lizard_m"], ["Lyra", "elf_f"]]
var _pids: Array[int] = []
var _count := 3
var _step := 0
var _guests: Array[String] = []
var _done := false


func _initialize() -> void:
	_go.call_deferred()


func _go() -> void:
	Engine.time_scale = 4.0
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		_count = clampi(int(args[0]), 1, 3)
	for f in _files():
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://" + f))
	Netz.save_override = "user://zz_gk_host_spielstand.json"
	SaveGame.path = Netz.save_override
	SaveGame.delete()
	_check(Netz.host("Marco", "knight_m") == OK, "Gastgeber startet")
	change_scene_to_file("res://scenes/kreuzweg.tscn")
	for i in _count:
		_pids.append(OS.create_process(OS.get_executable_path(),
				["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/netz_gruppenkampf_gast.gd",
				"--", GUESTS[i][0], GUESTS[i][1]]))


func _files() -> Array[String]:
	var files: Array[String] = ["zz_gk_host.json"]
	for g in GUESTS:
		files.append("zz_gk_gast_%s.json" % g[0])
	return files


func _guests_running() -> bool:
	for pid in _pids:
		if OS.is_process_running(pid):
			return true
	return false


func _process(delta: float) -> bool:
	_t += delta
	NetzGruppenkampfHelfer.drive(self)
	match _step:
		0:
			if Netz.world != null:
				for id: String in Netz.world.players:
					if id != Netz.my_id and not id in _guests:
						_guests.append(id)
						Netz.group_action("einladen", id)
			if _guests.size() == _count:
				_step = 1
				_t = 0.0
			elif _t > 30.0:
				_check(false, "Alle %d Mitspieler sind in Kreuzweg" % _count)
				return _finish()
		1:
			if Netz.group.get("members", []).size() == _count + 1 and _t > 3.0:
				_check(true, "Gruppe mit %d Spielern steht" % (_count + 1))
				var greetings := 0
				for entry in Netz.chat_log:
					if str(entry.text).begins_with("Hallo, ich bin"):
						greetings += 1
				_check(greetings == _count, "Chat: alle Mitspieler haben gegrüßt (%d)" % greetings)
				# Wie aus einer gemeinsamen Szene bei Ye: alle kämpfen zusammen
				var ids: Array = [Netz.my_id]
				ids.append_array(_guests)
				Netz.world.group_battle_requested.emit(ids, "gruppenkampf")
				_step = 2
				_t = 0.0
			elif _t > 20.0:
				_check(false, "Gruppe steht")
				return _finish()
		2:
			if current_scene is Combat:
				_check(current_scene._group.mine == 0 and current_scene.state.heroes.size() == 4, "Kampfbildschirm: Gruppenkampf mit vier Helden, ich steuere den ersten")
				var remote := 0
				for h in current_scene.state.heroes:
					if current_scene._is_remote(h):
						remote += 1
				_check(remote == _count, "%d Helden gehören den Mitspielern" % _count)
				_check(current_scene.state.computer.size() == 3 - _count, "%d Novizen-Mitstreiter spielt der Computer" % (3 - _count))
				_step = 3
				_t = 0.0
			elif _t > 10.0:
				_check(false, "Kampfbildschirm öffnet sich")
				return _finish()
		3:
			if not _done and NetzGruppenkampfHelfer.finish(self, "zz_gk_host.json"):
				_done = true
			if _done and not _guests_running():
				var host := _read("zz_gk_host.json")
				var all_same := true
				for i in _count:
					var guest := _read("zz_gk_gast_%s.json" % GUESTS[i][0])
					_check(not guest.is_empty(), "%s hat zu Ende gekämpft" % GUESTS[i][0])
					all_same = all_same and host == guest
				_check(all_same, "Alle haben genau dasselbe Ergebnis (Sieger, Züge, Leben aller Figuren)")
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
	for pid in _pids:
		if OS.is_process_running(pid):
			OS.kill(pid)
	SaveGame.delete()
	for f in _files():
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://" + f))
	Netz.stop()
	print("Netz-Gruppenkampf: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
	return true


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failed += 1
	print("%s %s" % ["OK    " if ok else "FEHLER", what])
