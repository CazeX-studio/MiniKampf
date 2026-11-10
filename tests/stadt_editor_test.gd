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
	var kreuzweg_text := FileAccess.get_file_as_string("res://data/kreuzweg.json")
	_check(StadtEditor.als_text(JSON.parse_string(kreuzweg_text), kreuzweg_text) == kreuzweg_text, "kreuzweg.json: Format bleibt gleich")
	var npcs := {ye = {name = "Ye", feld = [1, 2], aussehen = "ye", dialog = "ye"}, buerger = {name = "B", feld = [3, 3], aussehen = "x", dialog = "volk_b"}}
	StadtEditor.figuren_setzen(npcs, {npcs = {ye = {feld = [5, 6], nachts = [7, 8]}, volk_neu_x_1 = {neu = true, name = "Neu", feld = [9, 9],
			aussehen = "grund_frau+v_w1", dialog = "volk_neu", wenn = {nacht = false}}}, geloescht = ["buerger"]})
	_check(npcs.ye.feld == [5, 6] and npcs.ye.nachts == [7, 8], "Speichern: Platz tags und nachts übernommen")
	_check(not npcs.has("buerger") and npcs.volk_neu_x_1.aussehen == "grund_frau+v_w1" and npcs.volk_neu_x_1.wenn == {nacht = false},
			"Speichern: gelöschte Figur weg, neue Figur dazu")

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

	# Drehen: flache Teile in 45°-Schritten, stehende vorne/quer (ohne Bild von hinten)
	var flach := -1
	var stehend := -1
	for i in editor._daten.objekte.size():
		var d: Dictionary = editor._teile.objekte.get(editor._daten.objekte[i].teil, {})
		if d.get("flach", false) and d.get("drehbar", true) and flach < 0:
			flach = i
		elif not d.get("flach", false) and not d.has("bild_hinten") and stehend < 0:
			stehend = i
	if flach < 0:
		# Wipfelheim hat keine flachen Teile: zum Prüfen Blumen dazulegen
		editor._daten.objekte.append({teil = "blumen", feld = [12, 12]})
		editor._teil_views.append({})
		flach = editor._daten.objekte.size() - 1
		editor._teil_bauen(flach)
	_check(flach >= 0 and stehend >= 0, "Flache und stehende Teile zum Drehen")
	editor.waehlen({art = "teil", index = flach})
	var flach_rect := BaukastenBoden.grundflaeche(editor._daten.objekte[flach], editor._teile)
	editor.drehen()
	_check(int(editor._daten.objekte[flach].drehung) == 45 and not editor._teil_views[flach].is_empty(), "Flaches Teil um 45° gedreht")
	editor.drehen()
	var quer := BaukastenBoden.grundflaeche(editor._daten.objekte[flach], editor._teile)
	_check(quer.size == Vector2i(flach_rect.size.y, flach_rect.size.x), "Um 90° gedreht liegt es quer (%s -> %s)" % [flach_rect.size, quer.size])
	for i in 6:
		editor.drehen()
	_check(not editor._daten.objekte[flach].has("drehung"), "Achtmal gedreht: wieder wie vorher")
	editor.waehlen({art = "teil", index = stehend})
	editor.drehen()
	_check(editor._daten.objekte[stehend].get("gespiegelt", false), "Stehendes Teil ohne Bild von hinten: Drehen stellt es quer")
	editor.drehen()
	_check(not editor._daten.objekte[stehend].has("gespiegelt") and not editor._daten.objekte[stehend].has("hinten"), "Nochmal: wieder vorne")
	var probe := {teil = editor._daten.objekte[stehend].teil, feld = [5, 5], hinten = true}
	var teile_mit_hinten: Dictionary = editor._teile.duplicate(true)
	teile_mit_hinten.objekte[probe.teil].bild_hinten = teile_mit_hinten.objekte[probe.teil].bild
	_check(not BaukastenBoden.teil_bauen(probe, teile_mit_hinten).is_empty(), "Mit Bild von hinten baut sich die Ansicht von hinten auf")

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
	# S4b: Hinzufügen und Löschen
	var teile_vorher: int = editor._daten.objekte.size()
	editor.teil_hinzufuegen("gw_wohnbaumhaus")
	_check(editor._daten.objekte.size() == teile_vorher + 1 and editor._auswahl.get("index", -1) == teile_vorher, "Teil hinzugefügt und gewählt")
	var neu := editor.figur_hinzufuegen("grund_frau+v_w1", "Sammlerin", "nachts")
	_check(editor._npcs.has(neu) and editor._npcs[neu].wenn == {nacht = true}, "Volks-Figur hinzugefügt (nur nachts): %s" % neu)
	_check(editor.aenderungen().npcs[neu].get("neu", false) and editor.aenderungen().npcs[neu].dialog == "volk_neu", "Neue Figur wird mit gespeichert")
	_check(not GameData.dialog("volk_neu").is_empty(), "Neue Figuren haben einen Satz (volk_neu)")
	editor.waehlen({art = "npc", id = "ysolde"})
	editor.loeschen()
	_check(editor._npcs.has("ysolde"), "Ysolde gehört zur Geschichte und bleibt")
	var volk := ""
	for id: String in editor._npcs:
		if str(editor._npcs[id].dialog).begins_with("volk_") and not editor._npcs[id].neu:
			volk = id
			break
	editor.waehlen({art = "npc", id = volk})
	editor.loeschen()
	_check(volk != "" and not editor._npcs.has(volk) and editor.aenderungen().geloescht == [volk], "Volk gelöscht: %s" % volk)
	editor.rueckgaengig()
	_check(editor._npcs.has(volk) and editor.aenderungen().geloescht.is_empty(), "Löschen rückgängig: wieder da")
	editor._hinzu_panel.visible = true
	await process_frame
	_check(editor._teile_raster.get_child_count() > 100, "Fenster „Hinzufügen“ zeigt die Teile (%d)" % editor._teile_raster.get_child_count())
	editor._region = 2
	editor._teile_fuellen()
	await process_frame
	await process_frame
	var nur_gw := true
	for k: Node in editor._teile_raster.get_children():
		if not k.is_queued_for_deletion() and not (k as Button).text.begins_with("gw_"):
			nur_gw = false
	_check(nur_gw, "Filter Grünwacht zeigt nur Teile aus Grünwacht")
	editor._geaendert = false
	editor.queue_free()
	print("Stadt-Editor: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
