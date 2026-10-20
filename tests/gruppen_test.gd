extends SceneTree
## Prüft die Gruppen-Regeln ohne Netz: einladen, annehmen, ablehnen, volle Gruppe, verlassen, Führung, entfernen.
## Aufruf: Godot --headless --path . --script res://tests/gruppen_test.gd

var _failed := 0


func _initialize() -> void:
	var g := Gruppen.new()
	var notices := {}
	g.notice.connect(func(id: String, text: String) -> void:
		notices[id] = notices.get(id, []) + [text])
	var invited := []
	g.invited.connect(func(id: String, from_id: String, _from_name: String) -> void: invited.append([id, from_id]))
	for id: String in ["a", "b", "c", "d", "e"]:
		g.set_player_name(id, id.to_upper())

	_check(g.invite("a", "b", 0.0) and invited == [["b", "a"]], "A lädt B ein")
	_check(g.accept("b", 1.0), "B nimmt an")
	_check(g.group("a").members == ["a", "b"] and g.is_leader("a"), "Gruppe A+B, A führt")
	_check(not g.invite("b", "c", 2.0), "Nur der Gruppenführer kann einladen")
	_check(not g.invite("a", "a", 2.0), "Sich selbst einladen geht nicht")
	g.invite("a", "c", 2.0)
	g.decline("c")
	_check(not g.group_of.has("c") and "C hat die Einladung abgelehnt." in notices.a, "C lehnt ab")
	g.invite("a", "c", 3.0)
	_check(not g.accept("c", 3.0 + Gruppen.INVITE_SECONDS + 1.0), "Abgelaufene Einladung gilt nicht")
	g.invite("a", "c", 100.0)
	g.accept("c", 101.0)
	g.invite("a", "d", 102.0)
	g.accept("d", 103.0)
	_check(g.group("a").members.size() == 4, "Vier in der Gruppe")
	_check(not g.invite("a", "e", 104.0), "Gruppe ist voll (höchstens 4)")
	g.promote("a", "c")
	_check(g.is_leader("c") and not g.is_leader("a"), "Führung an C übergeben")
	g.kick("a", "d")
	_check(g.group_of.has("d"), "Nur der Gruppenführer kann jemanden entfernen")
	g.kick("c", "d")
	_check(not g.group_of.has("d") and g.group("c").members.size() == 3, "C nimmt D aus der Gruppe")
	g.leave("c")
	_check(g.is_leader("a") and g.group("a").members == ["a", "b"], "Gruppenführer geht: der Nächste führt")
	g.remove_player("b")
	_check(g.group_of.is_empty() and g.groups.is_empty(), "Wer allein übrig bleibt, ist nicht mehr in einer Gruppe")
	_check(g.invite("d", "e", 200.0) and g.accept("e", 201.0) and g.is_leader("d"), "Neue Gruppe D+E")
	g.invite("d", "a", 202.0)
	g.remove_player("d")
	_check(not g.invites.has("a"), "Einladungen von Spielern, die gehen, verfallen")

	print("Gruppen: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failed += 1
	print("%s %s" % ["OK    " if ok else "FEHLER", what])
