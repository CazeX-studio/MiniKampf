extends SceneTree
## Verbindungsabbruch und Wiederkommen: Dieses Programm ist Gastgeber, ein zweites (tests/netz_wiederverbinden_gast.gd)
## tritt bei und kommt in die Gruppe. Dann trennt der Gastgeber die Verbindung. Der Mitspieler muss sich von selbst
## neu verbinden, wieder in der Stadt stehen und wieder in derselben Gruppe sein.
## Aufruf: Godot --headless --path . --script res://tests/netz_wiederverbinden_test.gd

var _failed := 0
var _t := 0.0
var _pid := -1
var _step := 0
var _old_id := ""
var _notices: Array[String] = []


func _initialize() -> void:
	_go.call_deferred()


func _go() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://zz_wv_gast.json"))
	Netz.save_override = "user://zz_wv_host_spielstand.json"
	_check(Netz.host("Marco", "knight_m") == OK, "Gastgeber startet")
	Netz.world.add_player(Netz.my_id, Netz.my_name, Netz.my_look, WorldState.start_cell())
	Netz._node().group_notice.connect(func(text: String) -> void: _notices.append(text))
	_pid = OS.create_process(OS.get_executable_path(),
			["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/netz_wiederverbinden_gast.gd"])


func _guest_id() -> String:
	for id: String in Netz.world.players:
		if id != Netz.my_id:
			return id
	return ""


func _process(delta: float) -> bool:
	_t += delta
	match _step:
		0:
			if _guest_id() != "":
				Netz.group_action("einladen", _guest_id())
				_step = 1
				_t = 0.0
			elif _t > 15.0:
				_check(false, "Mitspieler kommt in die Stadt")
				return _finish()
		1:
			if Netz.group.get("members", []).size() == 2 and _t > 1.0:
				_check(true, "Gruppe mit dem Mitspieler steht")
				# Verbindung kappen (wie ein Funkloch)
				_old_id = _guest_id()
				Netz._api().multiplayer_peer.disconnect_peer(int(_old_id.substr(1)))
				_step = 2
				_t = 0.0
		2:
			var id := _guest_id()
			if id != "" and id != _old_id and Netz.group.get("members", []).size() == 2:
				_check(true, "Mitspieler ist mit neuer Verbindung zurück in der Stadt")
				_check(Netz.world.players[id].display_name == "Mira", "… mit demselben Namen")
				_check(Netz.in_my_group(id), "… und wieder in der Gruppe")
				_check("Mira ist wieder da." in _notices, "Meldung „Mira ist wieder da.“")
				_step = 3
				_t = 0.0
			elif _t > 20.0:
				_check(false, "Mitspieler kommt nach dem Abbruch zurück")
				return _finish()
		3:
			if not OS.is_process_running(_pid):
				var data: Variant = JSON.parse_string(FileAccess.get_file_as_string("user://zz_wv_gast.json"))
				var guest: Dictionary = data if data is Dictionary else {}
				_check(int(guest.get("wiederverbinden", 0)) >= 1 and int(guest.get("wieder_da", 0)) == 1, "Mitspieler: Hinweis „verbinde neu“ und wieder verbunden")
				_check(guest.get("in_stadt", false) and guest.get("eigene_figur", false), "Mitspieler steht wieder in der Stadt")
				_check(int(guest.get("gruppe", 0)) == 2, "Mitspieler sieht seine Gruppe wieder")
				return _finish()
			if _t > 30.0:
				_check(false, "Mitspieler ist fertig")
				return _finish()
	return false


func _finish() -> bool:
	if _pid > 0 and OS.is_process_running(_pid):
		OS.kill(_pid)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://zz_wv_gast.json"))
	Netz.stop()
	print("Netz-Wiederverbinden: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
	return true


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failed += 1
	print("%s %s" % ["OK    " if ok else "FEHLER", what])
