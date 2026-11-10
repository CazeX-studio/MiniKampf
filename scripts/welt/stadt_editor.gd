extends Node2D
## Stadt-Editor (S4a): eine Stadt (Kreuzweg, Wipfelheim, Glutoase) von oben ansehen, Baukasten-Teile und Figuren
## antippen und verschieben: mit Maus oder Finger ziehen oder Feld für Feld mit den Pfeil-Knöpfen (fürs Handy).
## Figuren mit eigenem Platz für die Nacht verschiebt man im Nacht-Modus an ihren Nachtplatz.
## Gespeichert wird nur, was sich geändert hat (StadtAenderungen): am PC in Godot direkt in die Spieldaten,
## im Browser für diesen Browser und als Datei zum Herunterladen, die Marco Claude schickt.
## Hinzufügen und Löschen kommt mit S4b.

const FIGUR_GROESSE := 0.8
## Fläche einer Figur auf dem Bildschirm über ihrem Fußpunkt (zum Antippen)
const FIGUR_RECT := Rect2(-22, -100, 44, 104)
const ZOOMS: Array[float] = [0.35, 0.5, 0.7, 1.0, 1.4]
## Pfeil-Knöpfe: Richtung auf dem Bildschirm -> Schritt in Feldern
const SCHRITTE := {"↖": Vector2i(-1, 0), "↗": Vector2i(0, -1), "↙": Vector2i(0, 1), "↘": Vector2i(1, 0)}
const NACHT_FARBE := Color(0.55, 0.6, 0.85)

## Gewählt (bleibt beim Neuladen der Szene)
static var stadt := "kreuzweg"
static var nacht := false
static var zoom_stufe := 1
## Noch nicht Gespeichertes bleibt beim Wechsel von Stadt oder Tageszeit erhalten
static var _offen := {}
static var _offen_geaendert := false

## Alle Änderungen aller Städte (wie in data/stadt_aenderungen.json)
var aenderungen := {}
## Teile der Karte: {o (Teil mit aktuellem Feld), von (Feld in den Kartendaten), node, bild, rect, flach}
var objekte: Array[Dictionary] = []
## Figuren: {id, name, look, von, von_nacht (oder null), feld, nachts (oder null), node}
var figuren: Array[Dictionary] = []
## Ausgewählt: {art = "teil"/"figur", nr}
var auswahl := {}
var geaendert := false

var _teile: Dictionary
var _flach: Node2D
var _sortiert: Node2D
var _rahmen: Node2D
var _kamera: Camera2D
var _modulate: CanvasModulate
var _info: Label
var _meldung: Label
var _pfeile: Array[Button] = []
var _zurueck_knopf: Button
## Ziehen: "teil" (Auswahl verschieben), "kamera" (Bild verschieben) oder ""
var _ziehen := ""
var _greif_versatz := Vector2i.ZERO
var _gezogen := false


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("1b2418"))
	Tageszeit.feste_stunde = 23.0 if nacht else 12.0
	aenderungen = _offen if _offen_geaendert else StadtAenderungen.laden().duplicate(true)
	geaendert = _offen_geaendert
	_offen = {}
	_offen_geaendert = false
	_teile = GameData.get_file("baukasten_teile")
	_modulate = CanvasModulate.new()
	_modulate.color = NACHT_FARBE if nacht else Color.WHITE
	add_child(_modulate)
	var info: Dictionary = StadtAenderungen.STAEDTE[stadt]
	var karte := GameData.roh(info.karte)
	var boden := BaukastenBoden.new()
	boden.setup(_teile, PackedStringArray(karte.get("boden", [])))
	add_child(boden)
	_flach = Node2D.new()
	_flach.z_index = -5
	add_child(_flach)
	_sortiert = Node2D.new()
	_sortiert.y_sort_enabled = true
	add_child(_sortiert)
	_rahmen = Node2D.new()
	_rahmen.z_index = 60
	_rahmen.draw.connect(_rahmen_malen)
	add_child(_rahmen)

	var aend: Dictionary = aenderungen.get(stadt, {})
	for o: Dictionary in karte.get("objekte", []):
		var von: Array = [int(o.feld[0]), int(o.feld[1])]
		for v: Dictionary in aend.get("objekte", []):
			if v.get("teil", "") == o.teil and StadtAenderungen.gleiches_feld(von, v.von):
				o.feld = [int(v.nach[0]), int(v.nach[1])]
		var eintrag := {o = o, von = von}
		objekte.append(eintrag)
		_teil_bauen(eintrag)
	var npcs := StadtAenderungen.figuren_von(GameData.roh(info.figuren[0]), info)
	for id: String in npcs:
		var d: Dictionary = npcs[id]
		var f := {id = id, name = str(d.get("name", id)), look = str(d.get("aussehen", "")),
				von = [int(d.feld[0]), int(d.feld[1])], von_nacht = null, nachts = null}
		if d.has("nachts"):
			f.von_nacht = [int(d.nachts[0]), int(d.nachts[1])]
		var neu: Dictionary = aend.get("figuren", {}).get(id, {})
		f.feld = neu.get("feld", f.von).duplicate()
		if f.von_nacht != null:
			f.nachts = neu.get("nachts", f.von_nacht).duplicate()
		var view := WorldCharacter.new()
		view.setup(f.look, f.name, Color(d.get("farbe", "ffffff")), Color("f2c14e"))
		view.scale = Vector2(FIGUR_GROESSE, FIGUR_GROESSE)
		view.idle_fps = 3.0
		_sortiert.add_child(view)
		f.node = view
		figuren.append(f)
		_figur_stellen(f)

	_kamera = Camera2D.new()
	_kamera.zoom = Vector2.ONE * ZOOMS[zoom_stufe]
	add_child(_kamera)
	var groesse := Vector2(karte.boden[0].length(), karte.boden.size()) if not karte.get("boden", []).is_empty() else Vector2.ZERO
	_kamera.position = BaukastenBoden.cell_to_screen(groesse * 0.5)
	_hud_bauen()
	_auswahl_zeigen()


func _exit_tree() -> void:
	Tageszeit.feste_stunde = -1.0


# --- Teile und Figuren ----------------------------------------------------------

func _teil_bauen(eintrag: Dictionary) -> void:
	if eintrag.has("node"):
		(eintrag.node as Node).queue_free()
	var fertig := BaukastenBoden.teil_bauen(eintrag.o, _teile)
	if fertig.is_empty():
		eintrag.node = Node2D.new()
		eintrag.bild = Rect2()
		eintrag.rect = Rect2i()
		eintrag.flach = true
		_flach.add_child(eintrag.node)
		return
	eintrag.node = fertig.node
	eintrag.bild = fertig.bild
	eintrag.rect = fertig.rect
	eintrag.flach = fertig.flach
	(_flach if fertig.flach else _sortiert).add_child(fertig.node)


## Figur an ihren Platz (bei Nacht an den Nachtplatz, wenn sie einen hat)
func _figur_stellen(f: Dictionary) -> void:
	var feld: Array = _platz(f)
	(f.node as Node2D).position = BaukastenBoden.cell_to_screen(Vector2(feld[0], feld[1]) + Vector2(0.5, 0.5))


func _platz(f: Dictionary) -> Array:
	return f.nachts if nacht and f.nachts != null else f.feld


## Was liegt an dieser Stelle (Weltkoordinaten)? Figuren zuerst, dann das kleinste Teil, dessen Bild dort ist.
func finden(punkt: Vector2) -> Dictionary:
	for i in range(figuren.size() - 1, -1, -1):
		var node: Node2D = figuren[i].node
		var r := Rect2(node.position + FIGUR_RECT.position * FIGUR_GROESSE, FIGUR_RECT.size * FIGUR_GROESSE)
		if r.has_point(punkt):
			return {art = "figur", nr = i}
	var bestes := {}
	var flaeche := INF
	for i in objekte.size():
		var bild: Rect2 = objekte[i].bild
		if bild.has_point(punkt) and bild.get_area() < flaeche:
			flaeche = bild.get_area()
			bestes = {art = "teil", nr = i}
	return bestes


## Feld unter einem Punkt (Weltkoordinaten)
static func feld_bei(punkt: Vector2) -> Vector2i:
	var x := (punkt.x / (BaukastenBoden.TILE_W * 0.5) + punkt.y / (BaukastenBoden.TILE_H * 0.5)) * 0.5
	var y := (punkt.y / (BaukastenBoden.TILE_H * 0.5) - punkt.x / (BaukastenBoden.TILE_W * 0.5)) * 0.5
	return Vector2i(floori(x), floori(y))


## Feld der Auswahl (bei Teilen die hintere Ecke der Grundfläche, wie in den Kartendaten)
func auswahl_feld() -> Vector2i:
	if auswahl.is_empty():
		return Vector2i.ZERO
	var feld: Array = objekte[auswahl.nr].o.feld if auswahl.art == "teil" else _platz(figuren[auswahl.nr])
	return Vector2i(int(feld[0]), int(feld[1]))


## Die Auswahl auf ein neues Feld stellen und die Änderung merken.
func verschieben(ziel: Vector2i) -> void:
	if auswahl.is_empty() or ziel == auswahl_feld():
		return
	var aend: Dictionary = aenderungen.get_or_add(stadt, {})
	if auswahl.art == "teil":
		var eintrag: Dictionary = objekte[auswahl.nr]
		# Gleiche Teile auf demselben Feld (z. B. Marktstand tags offen, nachts zu) wandern zusammen
		var alt: Array = eintrag.o.feld.duplicate()
		for e: Dictionary in objekte:
			if e.o.teil == eintrag.o.teil and StadtAenderungen.gleiches_feld(e.o.feld, alt):
				e.o.feld = [ziel.x, ziel.y]
				_teil_bauen(e)
		var liste: Array = aend.get_or_add("objekte", [])
		var gefunden := false
		for v: Dictionary in liste.duplicate():
			if v.teil == eintrag.o.teil and StadtAenderungen.gleiches_feld(v.von, eintrag.von):
				gefunden = true
				if StadtAenderungen.gleiches_feld(eintrag.von, [ziel.x, ziel.y]):
					liste.erase(v)
				else:
					v.nach = [ziel.x, ziel.y]
		if not gefunden:
			liste.append({teil = eintrag.o.teil, von = eintrag.von.duplicate(), nach = [ziel.x, ziel.y]})
	else:
		var f: Dictionary = figuren[auswahl.nr]
		var platz := "nachts" if nacht and f.nachts != null else "feld"
		f[platz] = [ziel.x, ziel.y]
		_figur_stellen(f)
		var alle: Dictionary = aend.get_or_add("figuren", {})
		var eigene: Dictionary = alle.get_or_add(f.id, {})
		var von: Array = f.von_nacht if platz == "nachts" else f.von
		if StadtAenderungen.gleiches_feld(von, f[platz]):
			eigene.erase(platz)
		else:
			eigene[platz] = [ziel.x, ziel.y]
		if eigene.is_empty():
			alle.erase(f.id)
	geaendert = true
	_auswahl_zeigen()


## Auswahl zurück an den Platz aus den Kartendaten
func an_alten_platz() -> void:
	if auswahl.is_empty():
		return
	if auswahl.art == "teil":
		var von: Array = objekte[auswahl.nr].von
		verschieben(Vector2i(von[0], von[1]))
	else:
		var f: Dictionary = figuren[auswahl.nr]
		var von: Array = f.von_nacht if nacht and f.nachts != null else f.von
		verschieben(Vector2i(von[0], von[1]))


func speichern() -> String:
	_aufraeumen()
	var text := StadtAenderungen.speichern(aenderungen)
	geaendert = false
	if OS.has_feature("web"):
		JavaScriptBridge.download_buffer(text.to_utf8_buffer(), "stadt_aenderungen.json", "application/json")
		_meldung.text = "Gespeichert (gilt in diesem Browser). Die Datei „stadt_aenderungen.json“ ist heruntergeladen: Schick sie Claude."
	elif OS.has_feature("editor"):
		_meldung.text = "Gespeichert in data/stadt_aenderungen.json. Gilt ab dem nächsten Betreten der Stadt."
	else:
		_meldung.text = "Gespeichert (gilt auf diesem Gerät)."
	_auswahl_zeigen()
	return text


## Leere Einträge weglassen, damit die Datei klein bleibt
func _aufraeumen() -> void:
	for s: String in aenderungen.keys():
		var a: Dictionary = aenderungen[s]
		for teil: String in ["objekte", "figuren"]:
			if a.has(teil) and (a[teil] as Variant).is_empty():
				a.erase(teil)
		if a.is_empty():
			aenderungen.erase(s)


# --- Eingabe --------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			_zoomen(1)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			_zoomen(-1)
		elif mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				var punkt := get_global_mouse_position()
				var treffer := finden(punkt)
				_gezogen = false
				if treffer.is_empty():
					_ziehen = "kamera"
				else:
					auswahl = treffer
					_ziehen = "teil"
					_greif_versatz = feld_bei(punkt) - auswahl_feld()
					_auswahl_zeigen()
			else:
				# Antippen ohne Ziehen auf eine leere Stelle: Auswahl aufheben
				if _ziehen == "kamera" and not _gezogen:
					auswahl = {}
					_auswahl_zeigen()
				_ziehen = ""
	elif event is InputEventMouseMotion and _ziehen != "":
		var mm := event as InputEventMouseMotion
		_gezogen = _gezogen or mm.relative.length() > 2.0
		if _ziehen == "kamera":
			_kamera.position -= mm.relative / _kamera.zoom
		else:
			verschieben(feld_bei(get_global_mouse_position()) - _greif_versatz)
	elif event is InputEventKey and event.pressed:
		match event.physical_keycode:
			KEY_ESCAPE:
				get_tree().change_scene_to_file("res://scenes/editor.tscn")
			KEY_LEFT:
				_kamera.position.x -= 200.0 / _kamera.zoom.x
			KEY_RIGHT:
				_kamera.position.x += 200.0 / _kamera.zoom.x
			KEY_UP:
				_kamera.position.y -= 150.0 / _kamera.zoom.y
			KEY_DOWN:
				_kamera.position.y += 150.0 / _kamera.zoom.y


func _zoomen(richtung: int) -> void:
	zoom_stufe = clampi(zoom_stufe + richtung, 0, ZOOMS.size() - 1)
	_kamera.zoom = Vector2.ONE * ZOOMS[zoom_stufe]


# --- Anzeige --------------------------------------------------------------------

## Gelber Rahmen um die Grundfläche der Auswahl (Figur: ihr Feld)
func _rahmen_malen() -> void:
	if auswahl.is_empty():
		return
	var r := Rect2i(auswahl_feld(), Vector2i.ONE)
	if auswahl.art == "teil":
		r = objekte[auswahl.nr].rect
	var ecken := PackedVector2Array([Vector2(r.position), Vector2(r.end.x, r.position.y), Vector2(r.end), Vector2(r.position.x, r.end.y), Vector2(r.position)])
	var punkte := PackedVector2Array()
	for e in ecken:
		punkte.append(BaukastenBoden.cell_to_screen(e))
	_rahmen.draw_colored_polygon(punkte.slice(0, 4), Color(1.0, 0.83, 0.3, 0.25))
	_rahmen.draw_polyline(punkte, Color("ffd34d"), 3.0)
	if auswahl.art == "teil":
		var bild: Rect2 = objekte[auswahl.nr].bild
		_rahmen.draw_rect(bild, Color(1.0, 0.83, 0.3, 0.6), false, 2.0)


func _auswahl_zeigen() -> void:
	_rahmen.queue_redraw()
	if _info == null:
		return
	for p in _pfeile:
		p.disabled = auswahl.is_empty()
	_zurueck_knopf.disabled = auswahl.is_empty()
	var kopf := "%s%s%s" % [StadtAenderungen.STAEDTE[stadt].name, ", nachts (Nachtplätze der Figuren)" if nacht else ", tagsüber",
			"  (nicht gespeichert)" if geaendert else ""]
	if auswahl.is_empty():
		_info.text = "%s\nTeil oder Figur antippen, dann ziehen oder mit den Pfeilen verschieben." % kopf
		return
	var feld := auswahl_feld()
	if auswahl.art == "teil":
		var e: Dictionary = objekte[auswahl.nr]
		var zusatz := "  (nur zeitweise)" if e.o.has("wenn") else ""
		var name := "%s „%s“" % [e.o.teil, e.o.name] if e.o.has("name") else str(e.o.teil)
		_info.text = "%s\nTeil: %s%s\nFeld %d, %d (vorher %d, %d)" % [kopf, name, zusatz, feld.x, feld.y, e.von[0], e.von[1]]
	else:
		var f: Dictionary = figuren[auswahl.nr]
		var platz := "Nachtplatz" if nacht and f.nachts != null else ("Platz (Tag und Nacht)" if f.nachts == null else "Tagplatz")
		var von: Array = f.von_nacht if nacht and f.nachts != null else f.von
		_info.text = "%s\nFigur: %s, %s\nFeld %d, %d (vorher %d, %d)" % [kopf, f.name, platz, feld.x, feld.y, von[0], von[1]]


func _hud_bauen() -> void:
	var ebene := CanvasLayer.new()
	ebene.layer = 50
	add_child(ebene)
	var oben := PanelContainer.new()
	oben.theme = Combat.make_theme()
	oben.position = Vector2(4, 4)
	oben.size = Vector2(1272, 48)
	ebene.add_child(oben)
	var zeile := HBoxContainer.new()
	zeile.add_theme_constant_override("separation", 6)
	oben.add_child(zeile)
	var ids: Array = StadtAenderungen.STAEDTE.keys()
	var wahl := OptionButton.new()
	for id: String in ids:
		wahl.add_item(str(StadtAenderungen.STAEDTE[id].name))
	wahl.select(ids.find(stadt))
	wahl.custom_minimum_size = Vector2(230, 34)
	wahl.focus_mode = Control.FOCUS_NONE
	wahl.item_selected.connect(func(i: int) -> void:
		_wechseln(func() -> void: stadt = ids[i]))
	zeile.add_child(wahl)
	zeile.add_child(_knopf("Nacht" if not nacht else "Tag", 90, func() -> void: _wechseln(func() -> void: nacht = not nacht)))
	zeile.add_child(_knopf("−", 44, func() -> void: _zoomen(-1)))
	zeile.add_child(_knopf("+", 44, func() -> void: _zoomen(1)))
	zeile.add_child(_knopf("Speichern", 130, speichern))
	var zuruecksetzen := _knopf("Stadt zurücksetzen", 190, func() -> void: pass)
	zuruecksetzen.pressed.connect(func() -> void:
		# Zweimal tippen, damit nichts aus Versehen verloren geht
		if zuruecksetzen.text != "Wirklich?":
			zuruecksetzen.text = "Wirklich?"
			return
		aenderungen.erase(stadt)
		speichern()
		get_tree().reload_current_scene())
	zeile.add_child(zuruecksetzen)
	zeile.add_child(_knopf("Zurück zum Editor", 190, func() -> void: get_tree().change_scene_to_file("res://scenes/editor.tscn")))
	_meldung = Label.new()
	_meldung.add_theme_font_size_override("font_size", 13)
	_meldung.add_theme_color_override("font_color", Color("8affc1"))
	_meldung.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_meldung.custom_minimum_size = Vector2(300, 0)
	_meldung.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	zeile.add_child(_meldung)

	var unten := PanelContainer.new()
	unten.theme = Combat.make_theme()
	unten.position = Vector2(4, 580)
	unten.size = Vector2(760, 136)
	ebene.add_child(unten)
	_info = Label.new()
	_info.add_theme_font_size_override("font_size", 16)
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	unten.add_child(_info)

	# Pfeile wie die Richtungen der Rauten: ↖ ↗ oben, ↙ ↘ unten, dazwischen „alter Platz“
	var pfeile := PanelContainer.new()
	pfeile.theme = Combat.make_theme()
	pfeile.position = Vector2(1016, 470)
	pfeile.size = Vector2(260, 246)
	ebene.add_child(pfeile)
	var raster := GridContainer.new()
	raster.columns = 2
	raster.add_theme_constant_override("h_separation", 8)
	raster.add_theme_constant_override("v_separation", 8)
	pfeile.add_child(raster)
	for zeichen: String in ["↖", "↗"]:
		raster.add_child(_pfeil(zeichen))
	_zurueck_knopf = _knopf("Alter Platz", 116, an_alten_platz)
	raster.add_child(_zurueck_knopf)
	raster.add_child(_knopf("Auswahl weg", 116, func() -> void:
		auswahl = {}
		_auswahl_zeigen()))
	for zeichen: String in ["↙", "↘"]:
		raster.add_child(_pfeil(zeichen))


## Stadt oder Tageszeit wechseln: Ungespeichertes bleibt erhalten
func _wechseln(aenderung: Callable) -> void:
	_offen = aenderungen
	_offen_geaendert = geaendert
	aenderung.call()
	get_tree().reload_current_scene()


func _pfeil(zeichen: String) -> Button:
	var b := _knopf(zeichen, 116, func() -> void: verschieben(auswahl_feld() + SCHRITTE[zeichen]))
	b.custom_minimum_size = Vector2(116, 64)
	b.add_theme_font_size_override("font_size", 30)
	_pfeile.append(b)
	return b


func _knopf(text: String, breite: float, aktion: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(breite, 34)
	b.add_theme_font_size_override("font_size", 15)
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(aktion)
	return b
