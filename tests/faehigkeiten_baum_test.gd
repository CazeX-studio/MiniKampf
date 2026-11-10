extends SceneTree
## Fähigkeiten-Baum mit Symbolen (A8a): Für jede Klasse ein Feld pro Fähigkeit und die Grundreihe, Antippen wählt aus,
## „Lernen“ schickt den Befehl, die Leiste hat sechs Plätze. Aufruf: Godot --headless --path . -s tests/faehigkeiten_baum_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for klasse: String in ["archer", "tamer", "smith", "blade", "singer"]:
		var p := Progress.new()
		p.flags = {"klasse": klasse, "klasse_gelernt": true}
		p.klassen_xp = 4100
		var gesendet: Array = []
		var neu := [0]
		FaehigkeitenBaum.gewaehlt = ""
		var baum := FaehigkeitenBaum.new()
		root.add_child(baum)
		baum.bauen(p, func(b: Dictionary) -> void: gesendet.append(b), func() -> void: neu[0] += 1)
		await process_frame
		var anzahl: int = Faehigkeiten.baum(klasse).faehigkeiten.size()
		_check(baum._felder.size() == anzahl + 1, "%s: %d Felder (Fähigkeiten und Grundreihe)" % [klasse, baum._felder.size()])
		var erste: String = Faehigkeiten.baum(klasse).faehigkeiten[0].id
		baum._felder[erste].pressed.emit()
		_check(FaehigkeitenBaum.gewaehlt == erste and neu[0] == 1, "%s: Antippen wählt %s" % [klasse, erste])
		baum.queue_free()
		baum = FaehigkeitenBaum.new()
		root.add_child(baum)
		baum.bauen(p, func(b: Dictionary) -> void: gesendet.append(b), func() -> void: neu[0] += 1)
		await process_frame
		var lernen: Button = null
		for b in baum.find_children("*", "Button", true, false):
			if (b as Button).text == GameData.text("faehigkeiten_lernen"):
				lernen = b
		_check(lernen != null and not lernen.disabled, "%s: Knopf „Lernen“ für die gewählte Fähigkeit" % klasse)
		if lernen != null:
			lernen.pressed.emit()
		_check(gesendet.size() == 1 and gesendet[0].type == "lernen" and gesendet[0].faehigkeit == erste, "%s: Lernen schickt den Befehl" % klasse)
		baum.queue_free()
	FaehigkeitenBaum.gewaehlt = ""
	print("Fähigkeiten-Baum: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
