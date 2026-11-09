extends SceneTree
## S4a: Stadt-Editor. Speichern lässt das Format der Kartendateien unverändert, Verschieben, Spiegeln, Löschen und
## Rückgängig wirken auf die Daten, Figuren haben einen Platz tags und nachts.
## Aufruf: Godot --headless --path . -s tests/stadt_editor_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	# Unveränderte Daten werden Zeichen für Zeichen gleich geschrieben (sonst würde jedes Speichern alles umformatieren)
	var karten := StadtEditor.karten()
	_check(karten.has("kreuzweg") and karten.has("wipfelheim") and karten.has("glutoase"), "Karten: %s" % ", ".join(PackedStringArray(karten.values())))
	for id: String in karten:
		var pfad := "res://data/%s.json" % StadtEditor.karten_datei(id)
		var text := FileAccess.get_file_as_string(pfad)
		_check(StadtEditor.als_text(JSON.parse_string(text), text) == text, "%s: Format bleibt beim Speichern gleich" % pfad)
	var karten_text := FileAccess.get_file_as_string("res://data/karten.json")
	_check(StadtEditor.als_text(JSON.parse_string(karten_text), karten_text) == karten_text, "karten.json: Format bleibt gleich")
	var zeile := '\t\t"ye": {"name": "Ausbilder Ye", "feld": [13, 45], "nachts": [2, 3], "aussehen": "ye"},'
	_check(StadtEditor._zeile_setzen(zeile, {feld = [14, 40], nachts = [5, 6]}) == '\t\t"ye": {"name": "Ausbilder Ye", "feld": [14, 40], "nachts": [5, 6], "aussehen": "ye"},',
			"kreuzweg.json: nur Feld und Nachtplatz in der Zeile ändern sich")

	# Die Szene: Teil wählen, verschieben, spiegeln, rückgängig, löschen
	StadtEditor.karte = "wipfelheim"
	StadtEditor.nacht = false
	var editor: StadtEditor = load("res://scenes/stadt_editor.tscn").instantiate()
	root.add_child(editor)
	await process_frame
	var anzahl: int = editor._daten.objekte.size()
	var vorher: Array = editor._daten.objekte[0].feld.duplicate()
	var treffer := editor.treffer((editor._teil_views[0].bild as Rect2).get_center())
	_check(not treffer.is_empty(), "Antippen trifft etwas: %s" % treffer)
	editor.waehlen({art = "teil", index = 0})
	editor.verschieben(Vector2i(1, 0))
	_check(int(editor.aenderungen().objekte[0].feld[0]) == int(vorher[0]) + 1, "Teil ein Feld verschoben")
	editor.spiegeln()
	_check(editor._daten.objekte[0].get("gespiegelt", false), "Teil gespiegelt")
	editor.rueckgaengig()
	editor.rueckgaengig()
	_check(editor._daten.objekte[0].feld == vorher and not editor._daten.objekte[0].has("gespiegelt"), "Zweimal rückgängig: wie vorher")
	editor.waehlen({art = "teil", index = 0})
	editor.loeschen()
	_check(editor._daten.objekte.size() == anzahl - 1, "Teil gelöscht")
	editor.rueckgaengig()
	_check(editor._daten.objekte.size() == anzahl, "Löschen rückgängig gemacht")
	_check(GameData.get_file(StadtEditor.karten_datei("wipfelheim")).objekte[0].feld == vorher, "Die Daten im Spiel bleiben bis zum Speichern unberührt")

	# Figuren: tags und nachts eigener Platz
	var mit_nacht := ""
	for id: String in editor._npcs:
		if editor._npcs[id].nachts != null:
			mit_nacht = id
			break
	_check(mit_nacht != "", "Eine Figur in Wipfelheim hat einen Platz nachts (%s)" % mit_nacht)
	if mit_nacht != "":
		var tag_feld: Vector2i = editor._npcs[mit_nacht].feld
		var nacht_feld: Vector2i = editor._npcs[mit_nacht].nachts
		StadtEditor.nacht = true
		editor.waehlen({art = "npc", id = mit_nacht})
		editor.verschieben(Vector2i(0, 1))
		var paket := editor.aenderungen()
		_check(paket.npcs[mit_nacht].nachts == [nacht_feld.x, nacht_feld.y + 1] and paket.npcs[mit_nacht].feld == [tag_feld.x, tag_feld.y],
				"Nachts verschoben: nur der Platz nachts ändert sich")
		StadtEditor.nacht = false
	editor._geaendert = false
	editor.queue_free()
	print("Stadt-Editor: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
