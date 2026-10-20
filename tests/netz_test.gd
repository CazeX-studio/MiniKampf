extends SceneTree
## Prüft das Zusammenspielen (Lernprojekt 4) mit zwei echten Programmen:
## Dieses hier ist Gastgeber, ein zweites (tests/netz_mitspieler.gd) tritt über das Netz bei,
## läuft, redet und prüft selbst, ob es den Gastgeber sieht.
## Aufruf: Godot --headless --path . --script res://tests/netz_test.gd

var _failed := 0
var _time := 0.0
var _pid := -1
var _guest_id := ""
var _guest_start := Vector2.ZERO
var _saw_move := false
var _saw_dialog := false


func _initialize() -> void:
	_start.call_deferred()


func _start() -> void:
	_test_lock()
	Netz.save_override = "user://spielstand_test_gastgeber.json"
	if Netz.host("Testhost", "knight_m") != OK:
		print("Netz: Gastgeber startet nicht")
		quit(1)
		return
	SaveGame.delete()
	# Der Gastgeber steht selbst in der Stadt (wie in kreuzweg.gd)
	Netz.world.add_player(Netz.my_id, Netz.my_name, Netz.my_look, WorldState.start_cell())
	_pid = OS.create_process(OS.get_executable_path(),
			["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/netz_mitspieler.gd"])
	_check(_pid > 0, "Mitspieler-Programm startet")


func _process(delta: float) -> bool:
	_time += delta
	if Netz.world == null:
		return false
	for id: String in Netz.world.players:
		if id != Netz.my_id and _guest_id == "":
			_guest_id = id
			_guest_start = Netz.world.players[id].pos
	if _guest_id != "" and Netz.world.players.has(_guest_id):
		var guest: PlayerState = Netz.world.players[_guest_id]
		if guest.pos.distance_to(_guest_start) > 1.0:
			_saw_move = true
		if guest.in_dialog():
			_saw_dialog = true
	if _pid > 0 and not OS.is_process_running(_pid):
		var code := OS.get_process_exit_code(_pid)
		_check(_guest_id != "", "Mitspieler ist beim Gastgeber in Kreuzweg angekommen")
		_check(_saw_move, "Mitspieler läuft beim Gastgeber (Befehl „steuern“ über das Netz)")
		_check(_saw_dialog, "Mitspieler redet beim Gastgeber (Einleitung startet)")
		_check(Netz.world.players.size() == 1, "Mitspieler ist nach dem Verlassen wieder weg")
		_check(code == 0, "Mitspieler hat alle seine Prüfungen bestanden (Rückgabe %d)" % code)
		_finish()
		return true
	if _time > 40.0:
		_check(false, "Mitspieler ist in 40 Sekunden fertig")
		OS.kill(_pid)
		_finish()
		return true
	return false


## Derselbe Spielstand wie allein – außer ein anderes Fenster auf diesem PC benutzt ihn gerade.
func _test_lock() -> void:
	var lock_file := ProjectSettings.globalize_path(Netz.LOCK_PATH)
	var file := FileAccess.open(Netz.LOCK_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({fenster = "anderes", zeit = Time.get_unix_time_from_system()}))
	file.close()
	Netz._set_me("Zweites Fenster", "elf_m", "")
	_check(SaveGame.path == "user://spielstand_fenster_zweitesfenster.json", "Zweites Fenster auf demselben PC bekommt einen eigenen Spielstand")
	file = FileAccess.open(Netz.LOCK_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({fenster = "anderes", zeit = Time.get_unix_time_from_system() - 60.0}))
	file.close()
	Netz._set_me("Marco", "elf_m", "")
	_check(SaveGame.path == SaveGame.DEFAULT_PATH, "Sonst gilt derselbe Spielstand wie allein")
	_check(Netz._node()._owns_lock(), "Dieses Fenster merkt sich, dass es den Spielstand benutzt")
	Netz.stop()
	_check(not FileAccess.file_exists(Netz.LOCK_PATH), "Beim Beenden wird der Spielstand wieder freigegeben")
	DirAccess.remove_absolute(lock_file)


func _finish() -> void:
	SaveGame.delete()
	Netz.stop()
	print("Netz: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failed += 1
	print("%s %s" % ["OK    " if ok else "FEHLER", what])
