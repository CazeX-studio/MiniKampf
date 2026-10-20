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
var _saw_group := false
var _saw_fighting := false


func _initialize() -> void:
	_start.call_deferred()


func _start() -> void:
	_test_lock()
	_test_sampling()
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
			# Begrüßung im Chat, zweimal schnell hintereinander (die zweite ist zu schnell und wird verworfen)
			Netz.chat("Willkommen!")
			Netz.chat("Zu schnell")
			# Mitspieler in die Gruppe einladen (er nimmt an)
			Netz.group_action("einladen", _guest_id)
	if _guest_id != "" and Netz.world.players.has(_guest_id):
		var guest: PlayerState = Netz.world.players[_guest_id]
		if guest.pos.distance_to(_guest_start) > 1.0:
			_saw_move = true
		if guest.in_dialog():
			_saw_dialog = true
	if Netz.group.get("members", []).size() == 2 and Netz.i_lead():
		_saw_group = true
	for m: Dictionary in Netz.group.get("members", []):
		if m.id == _guest_id and not m.in_stadt:
			_saw_fighting = true
	if _pid > 0 and not OS.is_process_running(_pid):
		var code := OS.get_process_exit_code(_pid)
		_check(_guest_id != "", "Mitspieler ist beim Gastgeber in Kreuzweg angekommen")
		_check(_saw_move, "Mitspieler läuft beim Gastgeber (Befehl „steuern“ über das Netz)")
		_check(_saw_dialog, "Mitspieler redet beim Gastgeber (Einleitung startet)")
		_check(Netz.world.players.size() == 1, "Mitspieler ist nach dem Verlassen wieder weg")
		var texts: Array[String] = []
		for entry in Netz.chat_log:
			texts.append("%s|%s" % [entry.name, entry.text])
		_check("|Testkind ist in Kreuzweg." in texts, "Chat-Hinweis: Mitspieler ist in Kreuzweg")
		_check("Testhost|Willkommen!" in texts, "Gastgeber schreibt im Chat")
		_check(not "Testhost|Zu schnell" in texts, "Zu schnelle zweite Nachricht wird verworfen")
		_check("Testkind|Hallo zusammen Zeile 2" in texts, "Chat-Nachricht des Mitspielers kommt an (ohne Zeilenumbruch)")
		_check("|Testkind hat das Spiel verlassen." in texts, "Chat-Hinweis: Mitspieler hat das Spiel verlassen")
		_check(Netz.clean_chat("x".repeat(500)).length() == Netz.CHAT_MAX_LENGTH, "Zu lange Nachrichten werden gekürzt")
		_check(_saw_group, "Gruppe: Mitspieler hat die Einladung angenommen, Gastgeber führt")
		_check(_saw_fighting, "Gruppe: Wer die Stadt verlässt (z. B. Kampf), bleibt in der Gruppe")
		_check(Netz.group.is_empty(), "Gruppe: Geht der Mitspieler, ist die Gruppe aufgelöst")
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


## Mitspieler sehen andere Figuren gleichmäßig zwischen zwei Berichten des Gastgebers.
func _test_sampling() -> void:
	var history: Array = [[1.0, Vector2(0, 0), 1, true], [1.2, Vector2(2, 0), 1, true], [1.4, Vector2(2, 2), -1, false]]
	_check(Netz.sample_history(history, 1.1).pos.is_equal_approx(Vector2(1, 0)), "Zwischen zwei Berichten: genau dazwischen")
	_check(Netz.sample_history(history, 1.3).pos.is_equal_approx(Vector2(2, 1)), "Zwischen dem zweiten und dritten Bericht")
	_check(Netz.sample_history(history, 5.0).pos == Vector2(2, 2), "Nach dem letzten Bericht: bleibt stehen, wenn die Figur stand")
	var walking: Array = [[1.0, Vector2(0, 0), 1, true], [1.2, Vector2(1, 0), 1, true]]
	_check(Netz.sample_history(walking, 1.3).pos.is_equal_approx(Vector2(1.5, 0)), "Aussetzer: Eine laufende Figur läuft kurz weiter")
	_check(Netz.sample_history(walking, 9.0).pos.is_equal_approx(Vector2(1.0 + 5.0 * Netz.EXTRAPOLATE_MAX, 0)), "… aber nicht endlos")
	_check(Netz.sample_history(history, 0.0).pos == Vector2(0, 0), "Vor dem ersten Bericht: am Anfang")


func _finish() -> void:
	SaveGame.delete()
	Netz.stop()
	print("Netz: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failed += 1
	print("%s %s" % ["OK    " if ok else "FEHLER", what])
