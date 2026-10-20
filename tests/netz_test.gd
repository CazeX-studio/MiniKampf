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
	SaveGame.path = "user://spielstand_zusammen_testhost.json"
	SaveGame.delete()
	if Netz.host("Testhost", "knight_m") != OK:
		print("Netz: Gastgeber startet nicht")
		quit(1)
		return
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


func _finish() -> void:
	Netz.stop()
	print("Netz: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failed += 1
	print("%s %s" % ["OK    " if ok else "FEHLER", what])
