extends Node2D
## Stadt-Editor (S4): eine Stadt (Kreuzweg, Wipfelheim, Glutoase) von oben ansehen, Baukasten-Teile und Figuren
## antippen und verschieben: mit Maus oder Finger ziehen oder Feld für Feld mit den Pfeil-Knöpfen (fürs Handy).
## Figuren mit eigenem Platz für die Nacht verschiebt man im Nacht-Modus an ihren Nachtplatz.
## S4b: Teile aus dem Baukasten und Volk-Figuren hinzufügen, Teile spiegeln, Teile und Volk löschen, Rückgängig.
## Gespeichert wird nur, was sich geändert hat (StadtAenderungen): am PC in Godot direkt in die Spieldaten,
## im Browser für diesen Browser und als Datei zum Herunterladen, die Marco Claude schickt.

const FIGUR_GROESSE := 0.8
## Fläche einer Figur auf dem Bildschirm über ihrem Fußpunkt (zum Antippen)
const FIGUR_RECT := Rect2(-22, -100, 44, 104)
const ZOOMS: Array[float] = [0.35, 0.5, 0.7, 1.0, 1.4]
## Pfeil-Knöpfe: Richtung auf dem Bildschirm -> Schritt in Feldern
const SCHRITTE := {"↖": Vector2i(-1, 0), "↗": Vector2i(0, -1), "↙": Vector2i(0, 1), "↘": Vector2i(1, 0)}
const NACHT_FARBE := Color(0.55, 0.6, 0.85)
## So viele Schritte kann man zurücknehmen
const RUECKGAENGIG_MAX := 30

## Gewählt (bleibt beim Neuladen der Szene)
static var stadt := "kreuzweg"
static var nacht := false
static var zoom_stufe := 1
## Noch nicht Gespeichertes bleibt beim Wechsel von Stadt oder Tageszeit erhalten, ebenso der Bildausschnitt
static var _offen := {}
static var _offen_geaendert := false
static var _offen_rueckgaengig: Array = []
static var _kamera_orte := {}

## Alle Änderungen aller Städte (wie in data/stadt_aenderungen.json)
var aenderungen := {}
## Teile der Karte: {o (Teil mit aktuellem Feld), von (Feld in den Kartendaten, null bei neuen Teilen),
## gespiegelt_vorher, weg, node, bild, rect, flach}
var objekte: Array[Dictionary] = []
## Figuren: {id, name, look, dialog, von (null bei neuen), von_nacht (oder null), feld, nachts (oder null), weg, node}
var figuren: Array[Dictionary] = []
## Ausgewählt: {art = "teil"/"figur", nr}
var auswahl := {}
var geaendert := false
## Frühere Stände dieser Stadt (für „Rückgängig“)
var rueckgaengig: Array = []

var _teile: Dictionary
var _flach: Node2D
var _sortiert: Node2D
var _rahmen: Node2D
var _kamera: Camera2D
var _modulate: CanvasModulate
var _info: Label
var _meldung: Label
var _auswahl_knoepfe: Array[Button] = []
var _spiegel_knopf: Button
var _loesch_knopf: Button
var _rueck_knopf: Button
var _dazu_panel: PanelContainer
var _teil_wahl: OptionButton
var _koerper_wahl: OptionButton
var _kopf_wahl: OptionButton
var _volk_wahl: OptionButton
## Ziehen: "teil" (Auswahl verschieben), "kamera" (Bild verschieben) oder ""
var _ziehen := ""
var _greif_versatz := Vector2i.ZERO
var _gezogen := false


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("1b2418"))
	Tageszeit.feste_stunde = 23.0 if nacht else 12.0
	aenderungen = _offen if _offen_geaendert else StadtAenderungen.laden().duplicate(true)
	geaendert = _offen_geaendert
	rueckgaengig = _offen_rueckgaengig
	_offen = {}
	_offen_geaendert = false
	_offen_rueckgaengig = []
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
	# Teile aus der Karte, mit den gespeicherten Änderungen
	for o: Dictionary in karte.get("objekte", []):
		var e := {o = o, von = [int(o.feld[0]), int(o.feld[1])], gespiegelt_vorher = bool(o.get("gespiegelt", false)), weg = false}
		for v: Dictionary in aend.get("objekte", []):
			if v.has("von") and v.get("teil", "") == o.teil and StadtAenderungen.gleiches_feld(e.von, v.von):
				if v.has("nach"):
					o.feld = [int(v.nach[0]), int(v.nach[1])]
				if v.has("gespiegelt"):
					o.gespiegelt = bool(v.gespiegelt)
				e.weg = bool(v.get("weg", false))
		objekte.append(e)
		_teil_bauen(e)
	for v: Dictionary in aend.get("objekte", []):
		if v.has("neu") and _teile.objekte.has(str(v.get("teil", ""))):
			var e := {o = {teil = str(v.teil), feld = [int(v.neu[0]), int(v.neu[1])], gespiegelt = bool(v.get("gespiegelt", false))},
					von = null, gespiegelt_vorher = false, weg = false}
			objekte.append(e)
			_teil_bauen(e)
	# Figuren aus den Daten, mit den gespeicherten Änderungen, dazu die neuen
	var npcs := StadtAenderungen.figuren_von(GameData.roh(info.figuren[0]), info)
	for id: String in npcs:
		var d: Dictionary = npcs[id]
		var f := {id = id, name = str(d.get("name", id)), look = str(d.get("aussehen", "")), dialog = str(d.get("dialog", id)),
				von = [int(d.feld[0]), int(d.feld[1])], von_nacht = null, nachts = null, farbe = str(d.get("farbe", "ffffff"))}
		if d.has("nachts"):
			f.von_nacht = [int(d.nachts[0]), int(d.nachts[1])]
		var neu: Dictionary = aend.get("figuren", {}).get(id, {})
		f.feld = _feld(neu.get("feld", f.von))
		if f.von_nacht != null:
			f.nachts = _feld(neu.get("nachts", f.von_nacht))
		f.weg = bool(neu.get("weg", false))
		_figur_dazu(f)
	var neue: Dictionary = aend.get("neue_figuren", {})
	for id: String in neue:
		var d: Dictionary = neue[id]
		_figur_dazu({id = id, name = str(d.get("name", "Bürger")), look = str(d.get("aussehen", "grund_mann+v_m1")),
				dialog = str(d.get("dialog", "volk_buerger")), von = null, von_nacht = null, nachts = null,
				feld = _feld(d.feld), weg = false, farbe = "ffffff"})

	_kamera = Camera2D.new()
	_kamera.zoom = Vector2.ONE * ZOOMS[zoom_stufe]
	add_child(_kamera)
	var groesse := Vector2(karte.boden[0].length(), karte.boden.size()) if not karte.get("boden", []).is_empty() else Vector2.ZERO
	_kamera.position = _kamera_orte.get(stadt, BaukastenBoden.cell_to_screen(groesse * 0.5))
	_hud_bauen()
	_auswahl_zeigen()


func _exit_tree() -> void:
	Tageszeit.feste_stunde = -1.0
	if _kamera != null:
		_kamera_orte[stadt] = _kamera.position


static func _feld(a: Array) -> Array:
	return [int(a[0]), int(a[1])]


# --- Teile und Figuren ----------------------------------------------------------

func _teil_bauen(eintrag: Dictionary) -> void:
	if eintrag.has("node"):
		(eintrag.node as Node).queue_free()
	var fertig := {} if eintrag.weg else BaukastenBoden.teil_bauen(eintrag.o, _teile)
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


func _figur_dazu(f: Dictionary) -> void:
	var view := WorldCharacter.new()
	view.setup(f.look, f.name, Color(f.farbe), Color("f2c14e"))
	view.scale = Vector2(FIGUR_GROESSE, FIGUR_GROESSE)
	view.idle_fps = 3.0
	view.visible = not f.weg
	_sortiert.add_child(view)
	f.node = view
	figuren.append(f)
	_figur_stellen(f)


## Figur an ihren Platz (bei Nacht an den Nachtplatz, wenn sie einen hat)
func _figur_stellen(f: Dictionary) -> void:
	var feld: Array = _platz(f)
	(f.node as Node2D).position = BaukastenBoden.cell_to_screen(Vector2(feld[0], feld[1]) + Vector2(0.5, 0.5))


func _platz(f: Dictionary) -> Array:
	return f.nachts if nacht and f.nachts != null else f.feld


## Volk (Dialog „volk_…“) und neue Figuren darf man löschen, Figuren der Geschichte nur verschieben.
static func loeschbar(f: Dictionary) -> bool:
	return f.von == null or str(f.dialog).begins_with("volk_")


## Was liegt an dieser Stelle (Weltkoordinaten)? Figuren zuerst, dann das kleinste Teil, dessen Bild dort ist.
func finden(punkt: Vector2) -> Dictionary:
	for i in range(figuren.size() - 1, -1, -1):
		if figuren[i].weg:
			continue
		var node: Node2D = figuren[i].node
		var r := Rect2(node.position + FIGUR_RECT.position * FIGUR_GROESSE, FIGUR_RECT.size * FIGUR_GROESSE)
		if r.has_point(punkt):
			return {art = "figur", nr = i}
	var bestes := {}
	var flaeche := INF
	for i in objekte.size():
		var bild: Rect2 = objekte[i].bild
		if not objekte[i].weg and bild.has_point(punkt) and bild.get_area() < flaeche:
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


# --- Ändern ---------------------------------------------------------------------

## Vor jeder Änderung: den jetzigen Stand für „Rückgängig“ merken
func merken() -> void:
	rueckgaengig.append(aenderungen.get(stadt, {}).duplicate(true))
	if rueckgaengig.size() > RUECKGAENGIG_MAX:
		rueckgaengig.pop_front()
	if _rueck_knopf != null:
		_rueck_knopf.disabled = false


## Den letzten Schritt zurücknehmen (die Stadt wird mit dem früheren Stand neu aufgebaut)
func zuruecknehmen() -> void:
	if rueckgaengig.is_empty():
		return
	aenderungen[stadt] = rueckgaengig.pop_back()
	geaendert = true
	_neu_aufbauen(func() -> void: pass)


## Die Auswahl auf ein neues Feld stellen (ohne neuen Rückgängig-Schritt, den setzt der Aufrufer).
func verschieben(ziel: Vector2i) -> void:
	if auswahl.is_empty() or ziel == auswahl_feld():
		return
	if auswahl.art == "teil":
		var eintrag: Dictionary = objekte[auswahl.nr]
		# Gleiche Teile auf demselben Feld (z. B. Marktstand tags offen, nachts zu) wandern zusammen
		var alt: Array = eintrag.o.feld.duplicate()
		for e: Dictionary in objekte:
			if not e.weg and e.o.teil == eintrag.o.teil and StadtAenderungen.gleiches_feld(e.o.feld, alt):
				e.o.feld = [ziel.x, ziel.y]
				_teil_bauen(e)
	else:
		var f: Dictionary = figuren[auswahl.nr]
		f["nachts" if nacht and f.nachts != null else "feld"] = [ziel.x, ziel.y]
		_figur_stellen(f)
	_uebernehmen()


## Ein Feld weiter (Pfeil-Knöpfe)
func schritt(richtung: Vector2i) -> void:
	if auswahl.is_empty():
		return
	merken()
	verschieben(auswahl_feld() + richtung)


## Auswahl zurück an den Platz aus den Kartendaten
func an_alten_platz() -> void:
	if auswahl.is_empty():
		return
	var von: Variant = objekte[auswahl.nr].von if auswahl.art == "teil" else (
			figuren[auswahl.nr].von_nacht if nacht and figuren[auswahl.nr].nachts != null else figuren[auswahl.nr].von)
	if von == null:
		return
	merken()
	verschieben(Vector2i(von[0], von[1]))


## Teil spiegeln (steht dann quer, z. B. ein Tor an einer anderen Straße)
func spiegeln() -> void:
	if auswahl.is_empty() or auswahl.art != "teil":
		return
	merken()
	var e: Dictionary = objekte[auswahl.nr]
	e.o.gespiegelt = not bool(e.o.get("gespiegelt", false))
	_teil_bauen(e)
	_uebernehmen()


func loeschen() -> void:
	if auswahl.is_empty():
		return
	if auswahl.art == "figur" and not loeschbar(figuren[auswahl.nr]):
		_meldung.text = "%s gehört zur Geschichte und lässt sich nur verschieben." % figuren[auswahl.nr].name
		return
	merken()
	if auswahl.art == "teil":
		objekte[auswahl.nr].weg = true
		_teil_bauen(objekte[auswahl.nr])
	else:
		figuren[auswahl.nr].weg = true
		(figuren[auswahl.nr].node as Node2D).visible = false
	auswahl = {}
	_uebernehmen()


## Neues Teil aus dem Baukasten in die Bildmitte stellen und auswählen
func teil_dazu(teil: String) -> void:
	if not _teile.objekte.has(teil):
		return
	merken()
	var e := {o = {teil = teil, feld = _mitte_feld(), gespiegelt = false}, von = null, gespiegelt_vorher = false, weg = false}
	objekte.append(e)
	_teil_bauen(e)
	auswahl = {art = "teil", nr = objekte.size() - 1}
	_uebernehmen()


## Neue Volk-Figur (Baukasten-Körper mit Kopf, Gespräch eines vorhandenen Volks) in die Bildmitte stellen
func figur_dazu(look: String, name: String, dialog: String) -> void:
	merken()
	var nummer := 1
	while _figur_id_belegt("neu_%d" % nummer):
		nummer += 1
	_figur_dazu({id = "neu_%d" % nummer, name = name, look = look, dialog = dialog, von = null, von_nacht = null,
			nachts = null, feld = _mitte_feld(), weg = false, farbe = "ffffff"})
	auswahl = {art = "figur", nr = figuren.size() - 1}
	_uebernehmen()


func _figur_id_belegt(id: String) -> bool:
	for f in figuren:
		if f.id == id:
			return true
	return false


func _mitte_feld() -> Array:
	var feld := feld_bei(_kamera.position) if _kamera != null else Vector2i(10, 10)
	return [feld.x, feld.y]


## Die Änderungen dieser Stadt aus dem, was der Editor zeigt, neu zusammenstellen
func _uebernehmen() -> void:
	var liste: Array = []
	for e: Dictionary in objekte:
		var gespiegelt := bool(e.o.get("gespiegelt", false))
		if e.von == null:
			if not e.weg:
				var neu := {teil = e.o.teil, neu = _feld(e.o.feld)}
				if gespiegelt:
					neu.gespiegelt = true
				liste.append(neu)
			continue
		var v := {teil = e.o.teil, von = e.von.duplicate()}
		if e.weg:
			v.weg = true
		else:
			if not StadtAenderungen.gleiches_feld(e.o.feld, e.von):
				v.nach = _feld(e.o.feld)
			if gespiegelt != e.gespiegelt_vorher:
				v.gespiegelt = gespiegelt
		if v.size() > 2:
			liste.append(v)
	var verschoben := {}
	var neue := {}
	for f: Dictionary in figuren:
		if f.von == null:
			if not f.weg:
				neue[f.id] = {name = f.name, aussehen = f.look, dialog = f.dialog, feld = _feld(f.feld)}
			continue
		var v := {}
		if f.weg:
			v.weg = true
		else:
			if not StadtAenderungen.gleiches_feld(f.feld, f.von):
				v.feld = _feld(f.feld)
			if f.nachts != null and not StadtAenderungen.gleiches_feld(f.nachts, f.von_nacht):
				v.nachts = _feld(f.nachts)
		if not v.is_empty():
			verschoben[f.id] = v
	var aend := {}
	if not liste.is_empty():
		aend.objekte = liste
	if not verschoben.is_empty():
		aend.figuren = verschoben
	if not neue.is_empty():
		aend.neue_figuren = neue
	if aend.is_empty():
		aenderungen.erase(stadt)
	else:
		aenderungen[stadt] = aend
	geaendert = true
	_auswahl_zeigen()


func speichern() -> String:
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
		if _ziehen == "kamera":
			_gezogen = _gezogen or mm.relative.length() > 2.0
			_kamera.position -= mm.relative / _kamera.zoom
		else:
			var ziel := feld_bei(get_global_mouse_position()) - _greif_versatz
			if ziel != auswahl_feld():
				# Ein Rückgängig-Schritt pro Ziehen
				if not _gezogen:
					merken()
				_gezogen = true
				verschieben(ziel)
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
			KEY_DELETE:
				loeschen()
			KEY_Z:
				if event.ctrl_pressed:
					zuruecknehmen()


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
	for k in _auswahl_knoepfe:
		k.disabled = auswahl.is_empty()
	_spiegel_knopf.disabled = auswahl.is_empty() or auswahl.art != "teil"
	_loesch_knopf.disabled = auswahl.is_empty() or (auswahl.art == "figur" and not loeschbar(figuren[auswahl.nr]))
	_rueck_knopf.disabled = rueckgaengig.is_empty()
	var kopf := "%s%s%s" % [StadtAenderungen.STAEDTE[stadt].name, ", nachts (Nachtplätze der Figuren)" if nacht else ", tagsüber",
			"  (nicht gespeichert)" if geaendert else ""]
	if auswahl.is_empty():
		_info.text = "%s\nTeil oder Figur antippen, dann ziehen oder mit den Pfeilen verschieben." % kopf
		return
	var feld := auswahl_feld()
	if auswahl.art == "teil":
		var e: Dictionary = objekte[auswahl.nr]
		var zusatz := "  (nur zeitweise)" if e.o.has("wenn") else ("  (neu)" if e.von == null else "")
		var name := "%s „%s“" % [e.o.teil, e.o.name] if e.o.has("name") else str(e.o.teil)
		var vorher := "neu" if e.von == null else "vorher %d, %d" % [e.von[0], e.von[1]]
		_info.text = "%s\nTeil: %s%s\nFeld %d, %d (%s)" % [kopf, name, zusatz, feld.x, feld.y, vorher]
	else:
		var f: Dictionary = figuren[auswahl.nr]
		var platz := "Nachtplatz" if nacht and f.nachts != null else ("Platz (Tag und Nacht)" if f.nachts == null else "Tagplatz")
		var von: Variant = f.von_nacht if nacht and f.nachts != null else f.von
		var vorher := "neu" if von == null else "vorher %d, %d" % [von[0], von[1]]
		_info.text = "%s\nFigur: %s, %s\nFeld %d, %d (%s)" % [kopf, f.name, platz, feld.x, feld.y, vorher]


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
		rueckgaengig = []
		_neu_aufbauen(func() -> void: stadt = ids[i]))
	zeile.add_child(wahl)
	zeile.add_child(_knopf("Nacht" if not nacht else "Tag", 80, func() -> void: _neu_aufbauen(func() -> void: nacht = not nacht)))
	zeile.add_child(_knopf("−", 44, func() -> void: _zoomen(-1)))
	zeile.add_child(_knopf("+", 44, func() -> void: _zoomen(1)))
	var dazu := _knopf("Hinzufügen", 130, func() -> void: pass)
	dazu.pressed.connect(func() -> void: _dazu_panel.visible = not _dazu_panel.visible)
	zeile.add_child(dazu)
	_rueck_knopf = _knopf("Rückgängig", 130, zuruecknehmen)
	zeile.add_child(_rueck_knopf)
	zeile.add_child(_knopf("Speichern", 120, speichern))
	var zuruecksetzen := _knopf("Zurücksetzen", 140, func() -> void: pass)
	zuruecksetzen.pressed.connect(func() -> void:
		# Zweimal tippen, damit nichts aus Versehen verloren geht
		if zuruecksetzen.text != "Wirklich?":
			zuruecksetzen.text = "Wirklich?"
			return
		merken()
		aenderungen.erase(stadt)
		geaendert = true
		_neu_aufbauen(func() -> void: pass))
	zeile.add_child(zuruecksetzen)
	zeile.add_child(_knopf("Zurück", 100, func() -> void: get_tree().change_scene_to_file("res://scenes/editor.tscn")))

	var unten := PanelContainer.new()
	unten.theme = Combat.make_theme()
	unten.position = Vector2(4, 580)
	unten.size = Vector2(760, 136)
	ebene.add_child(unten)
	var spalte := VBoxContainer.new()
	unten.add_child(spalte)
	_info = Label.new()
	_info.add_theme_font_size_override("font_size", 16)
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	spalte.add_child(_info)
	_meldung = Label.new()
	_meldung.add_theme_font_size_override("font_size", 13)
	_meldung.add_theme_color_override("font_color", Color("8affc1"))
	_meldung.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	spalte.add_child(_meldung)

	# Pfeile wie die Richtungen der Rauten: ↖ ↗ oben, ↙ ↘ unten, dazwischen die übrigen Knöpfe zur Auswahl
	var pfeile := PanelContainer.new()
	pfeile.theme = Combat.make_theme()
	pfeile.position = Vector2(1016, 400)
	pfeile.size = Vector2(260, 316)
	ebene.add_child(pfeile)
	var raster := GridContainer.new()
	raster.columns = 2
	raster.add_theme_constant_override("h_separation", 8)
	raster.add_theme_constant_override("v_separation", 8)
	pfeile.add_child(raster)
	for zeichen: String in ["↖", "↗"]:
		raster.add_child(_pfeil(zeichen))
	var alter := _knopf("Alter Platz", 116, an_alten_platz)
	_auswahl_knoepfe.append(alter)
	raster.add_child(alter)
	var weg := _knopf("Auswahl weg", 116, func() -> void:
		auswahl = {}
		_auswahl_zeigen())
	_auswahl_knoepfe.append(weg)
	raster.add_child(weg)
	_spiegel_knopf = _knopf("Spiegeln", 116, spiegeln)
	raster.add_child(_spiegel_knopf)
	_loesch_knopf = _knopf("Löschen", 116, loeschen)
	raster.add_child(_loesch_knopf)
	for zeichen: String in ["↙", "↘"]:
		raster.add_child(_pfeil(zeichen))
	_dazu_panel_bauen(ebene)


## Auswahl zum Hinzufügen: ein Teil aus dem Baukasten oder eine Volk-Figur
func _dazu_panel_bauen(ebene: CanvasLayer) -> void:
	_dazu_panel = PanelContainer.new()
	_dazu_panel.theme = Combat.make_theme()
	_dazu_panel.position = Vector2(4, 60)
	_dazu_panel.size = Vector2(300, 300)
	_dazu_panel.visible = false
	ebene.add_child(_dazu_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	_dazu_panel.add_child(box)
	box.add_child(_ueberschrift("Teil aus dem Baukasten"))
	var teile: Array = _teile.objekte.keys()
	teile.sort()
	_teil_wahl = _auswahl(teile)
	box.add_child(_teil_wahl)
	box.add_child(_knopf("Teil hinstellen", 280, func() -> void: teil_dazu(teile[_teil_wahl.selected])))
	box.add_child(_ueberschrift("Volk-Figur"))
	var koerper: Array = FigurTeile.koerper_liste().keys().filter(func(k: String) -> bool: return k.begins_with("grund_"))
	koerper.sort()
	_koerper_wahl = _auswahl(koerper.map(func(k: String) -> String: return str(FigurTeile.koerper_liste()[k])))
	box.add_child(_koerper_wahl)
	_kopf_wahl = _auswahl([])
	var koepfe_fuellen := func() -> void:
		_kopf_wahl.clear()
		var k: String = koerper[_koerper_wahl.selected]
		var liste: Array = FigurTeile.koepfe(k).keys().filter(func(id: String) -> bool: return not FigurTeile.koepfe(k)[id].get("nur_figur", false))
		liste.sort()
		for id: String in liste:
			_kopf_wahl.add_item(id)
		var standard := liste.find(FigurTeile.standardkopf(k))
		_kopf_wahl.select(maxi(0, standard))
	koepfe_fuellen.call()
	_koerper_wahl.item_selected.connect(func(_i: int) -> void: koepfe_fuellen.call())
	box.add_child(_kopf_wahl)
	var volk := volk_liste()
	var dialoge: Array = volk.keys()
	_volk_wahl = _auswahl(dialoge.map(func(d: String) -> String: return "%s (%s)" % [volk[d], d.trim_prefix("volk_")]))
	_volk_wahl.tooltip_text = "Name und Gespräch wie bei diesem Volk"
	box.add_child(_volk_wahl)
	box.add_child(_knopf("Figur hinstellen", 280, func() -> void:
		var d: String = dialoge[_volk_wahl.selected]
		figur_dazu("%s+%s" % [koerper[_koerper_wahl.selected], _kopf_wahl.get_item_text(_kopf_wahl.selected)], volk[d], d)))


## Gespräche des Volks aus allen Städten: Dialog -> Name (z. B. "volk_gast_1" -> "Gast")
static func volk_liste() -> Dictionary:
	var liste := {}
	for s: String in StadtAenderungen.STAEDTE:
		var info: Dictionary = StadtAenderungen.STAEDTE[s]
		var npcs := StadtAenderungen.figuren_von(GameData.roh(info.figuren[0]), info)
		for id: String in npcs:
			var d := str(npcs[id].get("dialog", ""))
			if d.begins_with("volk_") and not liste.has(d):
				liste[d] = str(npcs[id].get("name", "Bürger"))
	return liste


## Stadt, Tageszeit oder Stand wechseln: Ungespeichertes und „Rückgängig“ bleiben erhalten
func _neu_aufbauen(aenderung: Callable) -> void:
	_offen = aenderungen
	_offen_geaendert = geaendert
	_offen_rueckgaengig = rueckgaengig
	aenderung.call()
	get_tree().reload_current_scene()


func _pfeil(zeichen: String) -> Button:
	var b := _knopf(zeichen, 116, func() -> void: schritt(SCHRITTE[zeichen]))
	b.custom_minimum_size = Vector2(116, 64)
	b.add_theme_font_size_override("font_size", 30)
	_auswahl_knoepfe.append(b)
	return b


func _ueberschrift(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 15)
	l.add_theme_color_override("font_color", Color("f2c14e"))
	return l


func _auswahl(eintraege: Array) -> OptionButton:
	var k := OptionButton.new()
	for e in eintraege:
		k.add_item(str(e))
	if not eintraege.is_empty():
		k.select(0)
	k.custom_minimum_size = Vector2(280, 32)
	k.clip_text = true
	k.fit_to_longest_item = false
	k.add_theme_font_size_override("font_size", 14)
	k.focus_mode = Control.FOCUS_NONE
	return k


func _knopf(text: String, breite: float, aktion: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(breite, 34)
	b.add_theme_font_size_override("font_size", 15)
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(aktion)
	return b
