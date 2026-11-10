extends SceneTree
## Stadt-Editor (S4a): In jeder Stadt eine Figur und ein Teil verschieben, speichern und prüfen, dass das Spiel die
## neuen Plätze liest (auch nachdem die Kartendaten neu geladen sind); „Alter Platz“ macht alles rückgängig.
## Arbeitet mit eigenen Dateien, die echten Änderungen bleiben unberührt.
## Aufruf: Godot --headless --path . -s tests/stadt_editor_test.gd

const TEST_DATEI := "user://test_stadt_aenderungen.json"
const TEST_BROWSER := "user://test_stadt_aenderungen_browser.json"

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	_run.call_deferred()


func _laden(stadt: String, nacht := false) -> Node:
	var skript: GDScript = load("res://scripts/welt/stadt_editor.gd")
	skript.stadt = stadt
	skript.nacht = nacht
	change_scene_to_file("res://scenes/stadt_editor.tscn")
	await create_timer(0.3).timeout
	return current_scene


func _run() -> void:
	for d: String in [TEST_DATEI, TEST_BROWSER]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(d))
	StadtAenderungen.datei = TEST_DATEI
	StadtAenderungen.datei_browser = TEST_BROWSER
	GameData.neu_laden()
	for stadt: String in StadtAenderungen.STAEDTE:
		var info: Dictionary = StadtAenderungen.STAEDTE[stadt]
		var ed: Node = await _laden(stadt)
		_check(ed.objekte.size() > 10 and ed.figuren.size() > 5, "%s: %d Teile, %d Figuren" % [stadt, ed.objekte.size(), ed.figuren.size()])
		# Figur antippen (Mitte ihres Bildes) und um ein Feld verschieben
		var f: Dictionary = ed.figuren[0]
		var treffer: Dictionary = ed.finden((f.node as Node2D).position + Vector2(0, -40))
		_check(treffer.get("art", "") == "figur", "%s: Figur %s antippen" % [stadt, f.id])
		ed.auswahl = {art = "figur", nr = 0}
		var vorher: Vector2i = ed.auswahl_feld()
		ed.verschieben(vorher + Vector2i(1, 0))
		# Ein stehendes Teil ohne Bedingung verschieben
		var nr := -1
		for i in ed.objekte.size():
			if not ed.objekte[i].flach and not ed.objekte[i].o.has("wenn"):
				nr = i
				break
		ed.auswahl = {art = "teil", nr = nr}
		var teil: Dictionary = ed.objekte[nr]
		var teil_vorher: Vector2i = ed.auswahl_feld()
		ed.verschieben(teil_vorher + Vector2i(0, 2))
		_check(ed.finden((teil.bild as Rect2).get_center()).get("nr", -1) >= 0, "%s: Teil %s antippen" % [stadt, teil.o.teil])
		ed.speichern()
		# Das Spiel liest die neuen Plätze
		var npcs := StadtAenderungen.figuren_von(GameData.get_file(info.figuren[0]), info)
		var feld: Array = npcs[f.id].feld
		_check(Vector2i(int(feld[0]), int(feld[1])) == vorher + Vector2i(1, 0), "%s: Figur steht im Spiel am neuen Platz" % stadt)
		var gefunden := false
		for o: Dictionary in GameData.get_file(info.karte).objekte:
			if o.teil == teil.o.teil and StadtAenderungen.gleiches_feld(o.feld, [teil_vorher.x, teil_vorher.y + 2]):
				gefunden = true
		_check(gefunden, "%s: Teil steht im Spiel am neuen Platz" % stadt)
		# Neu laden: Der Editor zeigt die gespeicherten Plätze
		ed = await _laden(stadt)
		ed.auswahl = {art = "figur", nr = 0}
		_check(ed.auswahl_feld() == vorher + Vector2i(1, 0), "%s: nach dem Neuladen am neuen Platz" % stadt)
		ed.an_alten_platz()
		ed.auswahl = {art = "teil", nr = nr}
		ed.an_alten_platz()
		ed.speichern()
		_check(not StadtAenderungen.laden().has(stadt), "%s: alter Platz macht alles rückgängig" % stadt)
	# Nachtplatz: Figur mit eigenem Platz für die Nacht
	var ed: Node = await _laden("kreuzweg", true)
	var nr := -1
	for i in ed.figuren.size():
		if ed.figuren[i].nachts != null:
			nr = i
			break
	ed.auswahl = {art = "figur", nr = nr}
	var tag: Array = ed.figuren[nr].feld.duplicate()
	var nacht_vorher: Vector2i = ed.auswahl_feld()
	ed.verschieben(nacht_vorher + Vector2i(0, 1))
	_check(ed.figuren[nr].feld == tag and ed.figuren[nr].nachts == [nacht_vorher.x, nacht_vorher.y + 1],
			"Nachts verschiebt man nur den Nachtplatz (%s)" % ed.figuren[nr].id)
	ed.speichern()
	var welt0 := WorldState.new()
	_check(welt0.npcs[ed.figuren[nr].id].nacht_cell == nacht_vorher + Vector2i(0, 1), "Die Welt kennt den neuen Nachtplatz")
	ed.an_alten_platz()
	ed.speichern()
	# S4b: hinzufügen, spiegeln, löschen, Rückgängig (Glutoase)
	ed = await _laden("glutoase")
	var teile_vorher: int = GameData.get_file("karte_glutoase").objekte.size()
	ed.teil_dazu("fass")
	var neues_feld: Vector2i = ed.auswahl_feld()
	ed.schritt(Vector2i(1, 0))
	var nr_spiegel := -1
	for i in ed.objekte.size():
		if ed.objekte[i].von != null and not ed.objekte[i].flach and not ed.objekte[i].o.has("wenn"):
			nr_spiegel = i
			break
	ed.auswahl = {art = "teil", nr = nr_spiegel}
	ed.spiegeln()
	var nr_weg := nr_spiegel + 1
	while ed.objekte[nr_weg].o.has("wenn") or ed.objekte[nr_weg].o.teil == ed.objekte[nr_spiegel].o.teil:
		nr_weg += 1
	var weg_teil: Dictionary = ed.objekte[nr_weg].o.duplicate(true)
	ed.auswahl = {art = "teil", nr = nr_weg}
	ed.loeschen()
	var volk: Dictionary = ed.volk_liste()
	_check(volk.size() >= 5, "Volk zum Hinzufügen: %d Gespräche" % volk.size())
	ed.figur_dazu("grund_frau+v_w2", "Bürgerin", "volk_buergerin")
	var neue_id: String = ed.figuren[ed.figuren.size() - 1].id
	# Figuren der Geschichte lassen sich nicht löschen
	ed.auswahl = {art = "figur", nr = 0}
	var anzahl_aend: int = ed.rueckgaengig.size()
	ed.loeschen()
	_check(not ed.figuren[0].weg and ed.rueckgaengig.size() == anzahl_aend, "Hadrak lässt sich nicht löschen")
	# Rückgängig: die neue Figur verschwindet wieder, dann kommt sie zurück
	ed.zuruecknehmen()
	await create_timer(0.3).timeout
	ed = current_scene
	_check(not ed._figur_id_belegt(neue_id), "Rückgängig nimmt die neue Figur zurück")
	ed.figur_dazu("grund_frau+v_w2", "Bürgerin", "volk_buergerin")
	ed.speichern()
	var karte: Array = GameData.get_file("karte_glutoase").objekte
	var fass := karte.filter(func(o: Dictionary) -> bool: return o.teil == "fass" and StadtAenderungen.gleiches_feld(o.feld, [neues_feld.x + 1, neues_feld.y]))
	_check(fass.size() == 1, "Neues Fass steht im Spiel (ein Feld weiter)")
	var gespiegelt := karte.filter(func(o: Dictionary) -> bool: return o.teil == ed.objekte[nr_spiegel].o.teil and o.get("gespiegelt", false))
	_check(not gespiegelt.is_empty(), "Gespiegeltes Teil ist im Spiel gespiegelt")
	var geloescht := karte.filter(func(o: Dictionary) -> bool: return o.teil == weg_teil.teil and StadtAenderungen.gleiches_feld(o.feld, weg_teil.feld))
	_check(geloescht.is_empty() and karte.size() == teile_vorher, "Gelöschtes Teil fehlt, Fass dazu (%d Teile)" % karte.size())
	var npcs := StadtAenderungen.figuren_von(GameData.get_file("karten"), StadtAenderungen.STAEDTE.glutoase)
	_check(npcs.has(neue_id) and npcs[neue_id].dialog == "volk_buergerin", "Neue Bürgerin steht im Spiel")
	var welt := WorldState.new()
	_check(welt.npcs.has(neue_id) and welt.npcs[neue_id].map == "glutoase", "Die Welt kennt die neue Bürgerin")
	# Neu laden: alles wie gespeichert
	ed = await _laden("glutoase")
	_check(ed._figur_id_belegt(neue_id) and ed.objekte[nr_weg].weg and ed.objekte[nr_spiegel].o.get("gespiegelt", false),
			"Nach dem Neuladen: neue Figur, gelöschtes und gespiegeltes Teil")
	for d: String in [TEST_DATEI, TEST_BROWSER]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(d))
	StadtAenderungen.datei = StadtAenderungen.DATEI
	StadtAenderungen.datei_browser = StadtAenderungen.DATEI_BROWSER
	GameData.neu_laden()
	print("FERTIG: %s" % ("alles gut" if _failed == 0 else "%d Fehler" % _failed))
	quit(1 if _failed > 0 else 0)
