extends SceneTree
## Mitspieler für tests/netz_test.gd: tritt beim Gastgeber auf localhost bei,
## läuft nach rechts, startet die Einleitung, prüft das Spiegelbild und geht wieder.

var _failed := 0
var _time := 0.0
var _step := 0
var _notices: Array[String] = []
var _start_pos := Vector2.ZERO
var _checked_instant := false


func _initialize() -> void:
	_start.call_deferred()


func _start() -> void:
	Netz.save_override = "user://spielstand_test_mitspieler.json"
	if Netz.join("localhost", "Testkind", "elf_f") != OK:
		quit(2)
		return
	SaveGame.delete()
	Netz._node().connected.connect(_on_connected)
	Netz._node().connection_failed.connect(func() -> void:
		print("Mitspieler: keine Verbindung")
		quit(3))


func _on_connected() -> void:
	# Wie kreuzweg.gd: eigenen Spieler ins Spiegelbild stellen und beitreten
	var p := Netz.world.add_player(Netz.my_id, Netz.my_name, Netz.my_look, WorldState.start_cell())
	Netz.world.notice.connect(func(id: String, text: String) -> void:
		if id == Netz.my_id:
			_notices.append(text))
	Netz.enter_world(p)
	_step = 1
	_time = 0.0


func _process(delta: float) -> bool:
	_time += delta
	if _step == 0 and _time > 20.0:
		print("Mitspieler: Zeit abgelaufen beim Verbinden")
		quit(4)
		return true
	var w := Netz.world
	if w == null:
		return false
	match _step:
		1:
			if _time > 1.0:
				_check(w.players.size() == 2, "Mitspieler sieht den Gastgeber (2 Spieler im Spiegelbild)")
				var host: PlayerState = w.players.get("p1")
				_check(host != null and host.display_name == "Testhost" and host.look == "knight_m", "Name und Figur des Gastgebers kommen an")
				_step = 2
				_time = 0.0
				_start_pos = w.players[Netz.my_id].pos
				Netz.send({type = "steer", dir = Vector2(1, 0)})
		2:
			if not _checked_instant and _time > 0.05:
				_checked_instant = true
				_check(w.players[Netz.my_id].pos.distance_to(_start_pos) > 0.05, "Eigene Figur läuft sofort los (ohne auf den Gastgeber zu warten)")
			if _time > 1.0:
				Netz.send({type = "steer", dir = Vector2.ZERO})
				_step = 3
				_time = 0.0
		3:
			if _time > 0.6:
				var me: PlayerState = w.players[Netz.my_id]
				_check(me.pos.distance_to(Vector2(WorldState.start_cell())) > 1.0, "Eigene Figur hat sich im Spiegelbild bewegt")
				Netz.send({type = "start"})
				Netz.chat("Hallo zusammen\nZeile 2")
				_step = 4
				_time = 0.0
		4:
			if _time > 1.0:
				var me: PlayerState = w.players[Netz.my_id]
				_check(me.in_dialog(), "Einleitung kommt vom Gastgeber zurück (eigenes Gespräch)")
				_check(w.dialog_view(me).get("text", "") != "", "Gesprächstext lässt sich im Spiegelbild lesen")
				var texts: Array[String] = []
				for entry in Netz.chat_log:
					texts.append("%s|%s" % [entry.name, entry.text])
				_check("Testhost|Willkommen!" in texts, "Chat: Nachricht des Gastgebers kommt an")
				_check("Testkind|Hallo zusammen Zeile 2" in texts, "Chat: eigene Nachricht kommt bei allen an")
				Netz.leave_world()
				_step = 5
				_time = 0.0
		5:
			if _time > 1.0:
				SaveGame.delete()
				Netz.stop()
				print("Mitspieler: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
				quit(_failed)
				return true
	return false


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failed += 1
	print("Mitspieler %s %s" % ["OK    " if ok else "FEHLER", what])
