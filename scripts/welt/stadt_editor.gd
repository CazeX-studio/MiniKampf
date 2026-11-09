class_name StadtEditor
extends Node2D
## Stadt-Editor (S4a): eine Baukasten-Karte (Kreuzweg, Wipfelheim, Glutoase …) mit allen Teilen und Figuren.
## Antippen wählt ein Teil oder eine Figur, Ziehen oder die Pfeilknöpfe verschieben es Feld für Feld (auch am Handy),
## Teile lassen sich drehen, spiegeln und löschen, alles lässt sich rückgängig machen.
## Speichern: im Godot-Editor direkt in die Kartendaten (data/), sonst (Browser, Werkstatt) als Datei zum Herunterladen,
## die Marco Claude schickt; Claude übernimmt sie mit tools/stadt_editor_uebernehmen.py.
## Hinzufügen neuer Teile und Figuren kommt mit S4b.

const SCREEN := Vector2(1280, 720)
## Figuren so groß wie in der Welt (kreuzweg.gd: BAUKASTEN_FIGUR)
const FIGUR := 0.8
const ZOOMS: Array[float] = [0.35, 0.5, 0.7, 1.0, 1.4]

## Gewählt (bleibt beim Neuaufbau der Szene)
static var karte := "kreuzweg"
static var nacht := false
static var _zoom := 2

var _teile: Dictionary
## Die Kartendaten (Kopie der Datei): boden und objekte
var _daten: Dictionary = {}
var _dateiname := ""
## Figuren dieser Karte: Kennung -> {name, aussehen, feld: Vector2i, nachts: Vector2i oder null, liegt}
var _npcs: Dictionary = {}
## Aufgebaute Teile, gleiche Reihenfolge wie _daten.objekte: {node, bild, flach}
var _teil_views: Array[Dictionary] = []
var _npc_views: Dictionary = {}
## {art = "teil", index} oder {art = "npc", id}, leer = nichts gewählt
var _auswahl: Dictionary = {}
var _rueckgaengig: Array[Dictionary] = []
var _geaendert := false

var _flach: Node2D
var _sortiert: Node2D
var _markierung: Node2D
var _kamera: Camera2D
var _info: Label
var _meldung: Label
var _knoepfe_auswahl: Array[Button] = []

## Ziehen: mit der Maus oder dem Finger
var _zieht := false
var _schiebt_karte := false
var _griff := Vector2i.ZERO
var _letzte_maus := Vector2.ZERO
var _verschoben := false


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("1b2418"))
	_teile = GameData.get_file("baukasten_teile")
	if not karten().has(karte):
		karte = "kreuzweg"
	_laden()
	var boden := BaukastenBoden.new()
	boden.setup(_teile, PackedStringArray(_daten.get("boden", [])))
	add_child(boden)
	_flach = Node2D.new()
	_flach.z_index = -5
	add_child(_flach)
	_sortiert = Node2D.new()
	_sortiert.y_sort_enabled = true
	add_child(_sortiert)
	_markierung = Node2D.new()
	_markierung.z_index = 50
	_markierung.draw.connect(_markierung_zeichnen)
	add_child(_markierung)
	for i in _daten.get("objekte", []).size():
		_teil_views.append({})
		_teil_bauen(i)
	for id: String in _npcs:
		_npc_bauen(id)
	_kamera = Camera2D.new()
	var groesse := Vector2(_daten.boden[0].length(), _daten.boden.size()) if not _daten.get("boden", []).is_empty() else Vector2(40, 40)
	_kamera.position = BaukastenBoden.cell_to_screen(groesse * 0.5)
	_kamera.zoom = Vector2(ZOOMS[_zoom], ZOOMS[_zoom])
	add_child(_kamera)
	_leiste_bauen()
	_info_zeigen()


# --- Karten und Daten -----------------------------------------------------------

## Alle Karten aus dem Baukasten: Kennung -> Anzeigename (Kreuzweg zuerst).
static func karten() -> Dictionary:
	var liste := {"kreuzweg": "Kreuzweg"}
	var alle := GameData.get_file("karten")
	for id: String in alle:
		if alle[id] is Dictionary and alle[id].has("baukasten"):
			liste[id] = str(alle[id].get("name", id))
	return liste


## Datei mit Boden und Teilen dieser Karte (ohne .json).
static func karten_datei(id: String) -> String:
	if id == "kreuzweg":
		return "kreuzweg_karte"
	return str(GameData.get_file("karten").get(id, {}).get("baukasten", ""))


## Figuren einer Karte aus den Daten (kreuzweg.json bzw. karten.json).
static func figuren_der_karte(id: String) -> Dictionary:
	var quelle: Dictionary = GameData.get_file("kreuzweg").get("npcs", {}) if id == "kreuzweg" \
			else GameData.get_file("karten").get(id, {}).get("npcs", {})
	var liste := {}
	for npc_id: String in quelle:
		var d: Dictionary = quelle[npc_id]
		liste[npc_id] = {name = str(d.get("name", npc_id)), aussehen = str(d.get("aussehen", "novize")),
				feld = Vector2i(int(d.feld[0]), int(d.feld[1])),
				nachts = Vector2i(int(d.nachts[0]), int(d.nachts[1])) if d.has("nachts") else null,
				liegt = bool(d.get("liegt", false)), bedingt = d.has("wenn")}
	return liste


func _laden() -> void:
	_dateiname = karten_datei(karte)
	_daten = GameData.get_file(_dateiname).duplicate(true)
	_npcs = figuren_der_karte(karte)


# --- Aufbau ----------------------------------------------------------------------

func _teil_bauen(i: int) -> void:
	var alt: Dictionary = _teil_views[i]
	if alt.has("node") and is_instance_valid(alt.node):
		alt.node.queue_free()
	var o: Dictionary = _daten.objekte[i]
	var fertig := BaukastenBoden.teil_bauen(o, _teile)
	if fertig.is_empty():
		_teil_views[i] = {}
		return
	(_flach if fertig.flach else _sortiert).add_child(fertig.node)
	_teil_views[i] = {node = fertig.node, bild = fertig.bild, flach = fertig.flach}


func _npc_feld(id: String) -> Vector2i:
	var n: Dictionary = _npcs[id]
	return n.nachts if nacht and n.nachts != null else n.feld


func _npc_bauen(id: String) -> void:
	if _npc_views.has(id) and is_instance_valid(_npc_views[id]):
		_npc_views[id].queue_free()
	var n: Dictionary = _npcs[id]
	var view := WorldCharacter.new()
	view.setup(n.aussehen, n.name, Color.WHITE, Color("f2c14e"))
	view.liegt = n.liegt
	view.idle_fps = 3.0
	view.scale = Vector2(FIGUR, FIGUR)
	view.position = BaukastenBoden.cell_to_screen(Vector2(_npc_feld(id)) + Vector2(0.5, 0.5))
	_sortiert.add_child(view)
	_npc_views[id] = view


# --- Auswahl ---------------------------------------------------------------------

func _maus_feld(welt: Vector2) -> Vector2i:
	var x := (welt.x / (BaukastenBoden.TILE_W * 0.5) + welt.y / (BaukastenBoden.TILE_H * 0.5)) * 0.5
	var y := (welt.y / (BaukastenBoden.TILE_H * 0.5) - welt.x / (BaukastenBoden.TILE_W * 0.5)) * 0.5
	return Vector2i(floori(x), floori(y))


## Was liegt an dieser Stelle? Figuren vor Teilen, stehende Teile vor flachen, das vorderste zuerst.
func treffer(welt: Vector2) -> Dictionary:
	var bestes := {}
	var beste_tiefe := -INF
	for id: String in _npc_views:
		var v: WorldCharacter = _npc_views[id]
		if Rect2(v.position + Vector2(-22, -100) * FIGUR, Vector2(44, 104) * FIGUR).has_point(welt) and v.position.y > beste_tiefe:
			bestes = {art = "npc", id = id}
			beste_tiefe = v.position.y
	if not bestes.is_empty():
		return bestes
	for flach_runde: bool in [false, true]:
		for i in _teil_views.size():
			var t: Dictionary = _teil_views[i]
			if t.is_empty() or t.flach != flach_runde or not (t.bild as Rect2).has_point(welt):
				continue
			if t.node.position.y > beste_tiefe:
				bestes = {art = "teil", index = i}
				beste_tiefe = t.node.position.y
		if not bestes.is_empty():
			return bestes
	return {}


func waehlen(was: Dictionary) -> void:
	_auswahl = was
	_markierung.queue_redraw()
	_info_zeigen()


## Feld der Auswahl (Teil: linke obere Ecke der Grundfläche, Figur: ihr Feld).
func _auswahl_feld() -> Vector2i:
	if _auswahl.get("art", "") == "teil":
		var o: Dictionary = _daten.objekte[_auswahl.index]
		return Vector2i(int(o.feld[0]), int(o.feld[1]))
	if _auswahl.get("art", "") == "npc":
		return _npc_feld(_auswahl.id)
	return Vector2i.ZERO


# --- Ändern ----------------------------------------------------------------------

func _merken() -> void:
	_rueckgaengig.append({objekte = _daten.objekte.duplicate(true), npcs = _npcs.duplicate(true)})
	if _rueckgaengig.size() > 100:
		_rueckgaengig.pop_front()


## Auswahl um so viele Felder verschieben (Pfeilknöpfe, Ziehen).
func verschieben(schritt: Vector2i, merken := true) -> void:
	if _auswahl.is_empty() or schritt == Vector2i.ZERO:
		return
	if merken:
		_merken()
	var ziel := _auswahl_feld() + schritt
	if _auswahl.art == "teil":
		_daten.objekte[_auswahl.index].feld = [ziel.x, ziel.y]
		_teil_bauen(_auswahl.index)
	else:
		var n: Dictionary = _npcs[_auswahl.id]
		if nacht and n.nachts != null:
			n.nachts = ziel
		else:
			n.feld = ziel
		_npc_bauen(_auswahl.id)
	_geaendert = true
	_markierung.queue_redraw()
	_info_zeigen()


func spiegeln() -> void:
	if _auswahl.get("art", "") != "teil":
		return
	_merken()
	var o: Dictionary = _daten.objekte[_auswahl.index]
	if o.get("gespiegelt", false):
		o.erase("gespiegelt")
	else:
		o.gespiegelt = true
	_teil_bauen(_auswahl.index)
	_geaendert = true
	_markierung.queue_redraw()


## Drehen: flache Teile in 45°-Schritten auf dem Boden; stehende Teile reihum vorne, quer (gespiegelt), von hinten
## und von hinten quer – die Ansicht von hinten nur, wenn es dafür ein Bild gibt („bild_hinten“ in baukasten_teile.json).
func drehen() -> void:
	if _auswahl.get("art", "") != "teil":
		return
	var o: Dictionary = _daten.objekte[_auswahl.index]
	var d: Dictionary = _teile.objekte.get(o.teil, {})
	_merken()
	# Flache Teile ohne Höhe (Gras, Teppich, Steine) frei drehen; Brücken haben Geländer, die drehen sich wie Häuser
	if d.get("flach", false) and d.get("drehbar", true):
		var neu := posmod(int(o.get("drehung", 0)) + 45, 360)
		if neu == 0:
			o.erase("drehung")
		else:
			o.drehung = neu
	else:
		var stufe := (1 if o.get("gespiegelt", false) else 0) + (2 if o.get("hinten", false) else 0)
		stufe = (stufe + 1) % (4 if d.has("bild_hinten") else 2)
		_setzen(o, "gespiegelt", stufe % 2 == 1)
		_setzen(o, "hinten", stufe >= 2)
		if not d.has("bild_hinten"):
			_melden("Für die Ansicht von hinten fehlt noch ein Bild, darum nur vorne und quer.")
	_teil_bauen(_auswahl.index)
	_geaendert = true
	_markierung.queue_redraw()
	_info_zeigen()


static func _setzen(o: Dictionary, schluessel: String, an: bool) -> void:
	if an:
		o[schluessel] = true
	else:
		o.erase(schluessel)


func loeschen() -> void:
	if _auswahl.get("art", "") != "teil":
		_melden("Figuren löschen kommt mit S4b.")
		return
	_merken()
	var i: int = _auswahl.index
	if _teil_views[i].has("node"):
		_teil_views[i].node.queue_free()
	_daten.objekte.remove_at(i)
	_teil_views.remove_at(i)
	_geaendert = true
	waehlen({})


func rueckgaengig() -> void:
	if _rueckgaengig.is_empty():
		return
	var stand: Dictionary = _rueckgaengig.pop_back()
	_daten.objekte = stand.objekte
	_npcs = stand.npcs
	for t: Dictionary in _teil_views:
		if t.has("node") and is_instance_valid(t.node):
			t.node.queue_free()
	_teil_views.clear()
	for i in _daten.objekte.size():
		_teil_views.append({})
		_teil_bauen(i)
	for id: String in _npcs:
		_npc_bauen(id)
	waehlen({})


# --- Speichern -------------------------------------------------------------------

## Ganze Zahlen bleiben ganze Zahlen (Godot liest Zahlen als Kommazahlen, die Dateien haben ganze Zahlen).
static func ganzzahlen(wert: Variant) -> Variant:
	if wert is float and is_equal_approx(wert, roundf(wert)):
		return int(roundf(wert))
	if wert is Array:
		return (wert as Array).map(func(v: Variant) -> Variant: return ganzzahlen(v))
	if wert is Dictionary:
		var neu := {}
		for k: Variant in wert:
			neu[k] = ganzzahlen(wert[k])
		return neu
	return wert


## Text einer Datendatei im Format der Datei (Tabs, Schlüssel in der alten Reihenfolge, Zeilenende wie vorher).
static func als_text(daten: Dictionary, vorher: String) -> String:
	var text := JSON.stringify(ganzzahlen(daten), "\t", false)
	return text + "\n" if vorher.ends_with("\n") else text


## Was der Editor geändert hat, als Datei für Claude: {karte, datei, objekte, npcs: {id: {feld, nachts}}}.
func aenderungen() -> Dictionary:
	var figuren := {}
	for id: String in _npcs:
		var n: Dictionary = _npcs[id]
		figuren[id] = {feld = [n.feld.x, n.feld.y]}
		if n.nachts != null:
			figuren[id].nachts = [n.nachts.x, n.nachts.y]
	return {karte = karte, datei = _dateiname, objekte = ganzzahlen(_daten.objekte), npcs = figuren}


func speichern() -> void:
	var paket := aenderungen()
	if OS.has_feature("editor"):
		var fehler := uebernehmen(paket)
		_melden("Gespeichert in data/ (%s)." % _dateiname if fehler == "" else fehler)
		if fehler == "":
			_geaendert = false
		return
	var text := JSON.stringify(paket, "\t", false)
	var name := "stadt_%s.json" % karte
	if OS.has_feature("web"):
		JavaScriptBridge.download_buffer(text.to_utf8_buffer(), name, "application/json")
		_melden("Datei „%s“ heruntergeladen: bitte Claude schicken." % name)
	else:
		var pfad := "user://" + name
		var datei := FileAccess.open(pfad, FileAccess.WRITE)
		if datei != null:
			datei.store_string(text)
		_melden("Gespeichert: %s" % ProjectSettings.globalize_path(pfad))
	_geaendert = false


## Änderungen in die Kartendaten schreiben (Godot-Editor; dieselbe Arbeit macht tools/stadt_editor_uebernehmen.py).
## Gibt "" zurück oder einen Fehlertext.
static func uebernehmen(paket: Dictionary) -> String:
	var datei_pfad := "res://data/%s.json" % paket.datei
	var vorher := FileAccess.get_file_as_string(datei_pfad)
	var daten: Variant = JSON.parse_string(vorher)
	if not daten is Dictionary:
		return "Kartendatei nicht lesbar: " + datei_pfad
	daten.objekte = paket.objekte
	if not _schreiben(datei_pfad, als_text(daten, vorher)):
		return "Kann nicht schreiben: " + datei_pfad
	GameData._cache.erase(str(paket.datei))
	if paket.karte == "kreuzweg":
		# kreuzweg.json: eine Zeile pro Figur, nur Feld und Nachtplatz in der Zeile ersetzen
		var pfad := "res://data/kreuzweg.json"
		var zeilen := FileAccess.get_file_as_string(pfad).split("\n")
		for i in zeilen.size():
			for id: String in paket.npcs:
				if zeilen[i].begins_with('\t\t"%s": {' % id):
					zeilen[i] = _zeile_setzen(zeilen[i], paket.npcs[id])
		if not _schreiben(pfad, "\n".join(zeilen)):
			return "Kann nicht schreiben: " + pfad
		GameData._cache.erase("kreuzweg")
	else:
		var pfad := "res://data/karten.json"
		var text := FileAccess.get_file_as_string(pfad)
		var alle: Dictionary = JSON.parse_string(text)
		var npcs: Dictionary = alle[paket.karte].get("npcs", {})
		for id: String in paket.npcs:
			if npcs.has(id):
				npcs[id].feld = paket.npcs[id].feld
				if paket.npcs[id].has("nachts"):
					npcs[id].nachts = paket.npcs[id].nachts
		if not _schreiben(pfad, als_text(alle, text)):
			return "Kann nicht schreiben: " + pfad
		GameData._cache.erase("karten")
	return ""


static func _zeile_setzen(zeile: String, figur: Dictionary) -> String:
	var re := RegEx.create_from_string('"feld": \\[-?\\d+, -?\\d+\\]')
	zeile = re.sub(zeile, '"feld": [%d, %d]' % [int(figur.feld[0]), int(figur.feld[1])])
	if figur.has("nachts"):
		var re_n := RegEx.create_from_string('"nachts": \\[-?\\d+, -?\\d+\\]')
		zeile = re_n.sub(zeile, '"nachts": [%d, %d]' % [int(figur.nachts[0]), int(figur.nachts[1])])
	return zeile


static func _schreiben(pfad: String, text: String) -> bool:
	var datei := FileAccess.open(pfad, FileAccess.WRITE)
	if datei == null:
		return false
	datei.store_string(text)
	return true


# --- Eingabe ---------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoomen(1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoomen(-1)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_druecken(get_global_mouse_position(), event.position)
			else:
				_zieht = false
				_schiebt_karte = false
	elif event is InputEventMouseMotion and (_zieht or _schiebt_karte):
		if _zieht:
			var feld := _maus_feld(get_global_mouse_position()) - _griff
			var schritt := feld - _auswahl_feld()
			if schritt != Vector2i.ZERO:
				verschieben(schritt, not _verschoben)
				_verschoben = true
		else:
			_kamera.position -= (event.position - _letzte_maus) / _kamera.zoom
			_letzte_maus = event.position
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_ESCAPE:
				_zurueck()
			KEY_Z when event.ctrl_pressed:
				rueckgaengig()
			KEY_DELETE:
				loeschen()
			KEY_UP:
				verschieben(Vector2i(0, -1))
			KEY_DOWN:
				verschieben(Vector2i(0, 1))
			KEY_LEFT:
				verschieben(Vector2i(-1, 0))
			KEY_RIGHT:
				verschieben(Vector2i(1, 0))


func _druecken(welt: Vector2, bildschirm: Vector2) -> void:
	var was := treffer(welt)
	_verschoben = false
	if was.is_empty():
		waehlen({})
		_schiebt_karte = true
		_letzte_maus = bildschirm
		return
	waehlen(was)
	_zieht = true
	_griff = _maus_feld(welt) - _auswahl_feld()


func _zoomen(richtung: int) -> void:
	_zoom = clampi(_zoom + richtung, 0, ZOOMS.size() - 1)
	_kamera.zoom = Vector2(ZOOMS[_zoom], ZOOMS[_zoom])


# --- Anzeige ---------------------------------------------------------------------

func _markierung_zeichnen() -> void:
	if _auswahl.is_empty():
		return
	var rect := Rect2i(_auswahl_feld(), Vector2i.ONE)
	if _auswahl.art == "teil":
		rect = BaukastenBoden.grundflaeche(_daten.objekte[_auswahl.index], _teile)
	var ecken := PackedVector2Array([BaukastenBoden.cell_to_screen(Vector2(rect.position)),
			BaukastenBoden.cell_to_screen(Vector2(rect.end.x, rect.position.y)),
			BaukastenBoden.cell_to_screen(Vector2(rect.end)),
			BaukastenBoden.cell_to_screen(Vector2(rect.position.x, rect.end.y))])
	_markierung.draw_colored_polygon(ecken, Color(1.0, 0.85, 0.3, 0.25))
	ecken.append(ecken[0])
	_markierung.draw_polyline(ecken, Color("ffd34d"), 3.0)
	if _auswahl.art == "teil" and _teil_views[_auswahl.index].has("bild"):
		_markierung.draw_rect(_teil_views[_auswahl.index].bild, Color(1.0, 0.85, 0.3, 0.6), false, 2.0)


func _info_zeigen() -> void:
	if _info == null:
		return
	var text := "Antippen wählt, Ziehen verschiebt. Leere Stelle ziehen: Karte bewegen. Mausrad oder − +: Zoom."
	if _auswahl.get("art", "") == "teil":
		var o: Dictionary = _daten.objekte[_auswahl.index]
		text = "Teil: %s  ·  Feld %d, %d%s%s" % [o.teil, int(o.feld[0]), int(o.feld[1]),
				("  ·  gespiegelt" if o.get("gespiegelt", false) else "") + ("  ·  von hinten" if o.get("hinten", false) else "")
				+ ("  ·  gedreht %d°" % int(o.drehung) if o.has("drehung") else ""),
				"  ·  nur bei einem Stand der Geschichte" if o.has("wenn") or o.has("nur_stufe") else ""]
	elif _auswahl.get("art", "") == "npc":
		var n: Dictionary = _npcs[_auswahl.id]
		var feld := _npc_feld(_auswahl.id)
		text = "Figur: %s (%s)  ·  Feld %d, %d  ·  %s%s" % [n.name, _auswahl.id, feld.x, feld.y,
				("Platz nachts" if n.nachts != null else "steht tags und nachts hier") if nacht else "Platz tags",
				"  ·  nur bei einem Stand der Geschichte" if n.bedingt else ""]
	_info.text = text
	for k in _knoepfe_auswahl:
		k.disabled = _auswahl.is_empty()


func _melden(text: String) -> void:
	if _meldung != null:
		_meldung.text = text


func _leiste_bauen() -> void:
	var ebene := CanvasLayer.new()
	ebene.layer = 10
	add_child(ebene)
	var oben := PanelContainer.new()
	oben.theme = Combat.make_theme()
	oben.position = Vector2(4, 4)
	oben.size = Vector2(1272, 52)
	ebene.add_child(oben)
	var reihe := HBoxContainer.new()
	reihe.add_theme_constant_override("separation", 8)
	oben.add_child(reihe)
	var titel := Label.new()
	titel.text = "Stadt-Editor"
	titel.add_theme_font_size_override("font_size", 20)
	titel.add_theme_color_override("font_color", Color("f2c14e"))
	reihe.add_child(titel)
	var ids: Array = karten().keys()
	var wahl := OptionButton.new()
	for id: String in ids:
		wahl.add_item(str(karten()[id]))
	wahl.select(ids.find(karte))
	wahl.custom_minimum_size = Vector2(190, 36)
	wahl.focus_mode = Control.FOCUS_NONE
	wahl.item_selected.connect(func(i: int) -> void:
		if _ungespeichert_warnen():
			wahl.select(ids.find(karte))
			return
		karte = ids[i]
		get_tree().reload_current_scene())
	reihe.add_child(wahl)
	var tag := _knopf("Nachts" if nacht else "Tags", 90, Callable())
	tag.pressed.connect(func() -> void:
		nacht = not nacht
		tag.text = "Nachts" if nacht else "Tags"
		for id: String in _npcs:
			_npc_bauen(id)
		_markierung.queue_redraw()
		_info_zeigen())
	tag.tooltip_text = "Figuren an ihrem Platz tags oder nachts zeigen und verschieben"
	reihe.add_child(tag)
	reihe.add_child(_knopf("−", 40, func() -> void: _zoomen(-1)))
	reihe.add_child(_knopf("+", 40, func() -> void: _zoomen(1)))
	reihe.add_child(_knopf("Rückgängig", 120, rueckgaengig))
	reihe.add_child(_knopf("Speichern", 120, speichern))
	_meldung = Label.new()
	_meldung.custom_minimum_size = Vector2(300, 0)
	_meldung.add_theme_font_size_override("font_size", 13)
	_meldung.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_meldung.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reihe.add_child(_meldung)
	reihe.add_child(_knopf("Zurück", 90, _zurueck))

	var unten := PanelContainer.new()
	unten.theme = Combat.make_theme()
	unten.position = Vector2(4, 610)
	unten.size = Vector2(1272, 106)
	ebene.add_child(unten)
	var zeile := HBoxContainer.new()
	zeile.add_theme_constant_override("separation", 12)
	unten.add_child(zeile)
	# Pfeile wie die Rauten auf dem Bildschirm: ↖ ↗ oben, ↙ ↘ unten
	var pfeile := GridContainer.new()
	pfeile.columns = 2
	for p: Array in [["↖", Vector2i(-1, 0)], ["↗", Vector2i(0, -1)], ["↙", Vector2i(0, 1)], ["↘", Vector2i(1, 0)]]:
		var schritt: Vector2i = p[1]
		var k := _knopf(str(p[0]), 56, func() -> void: verschieben(schritt))
		_knoepfe_auswahl.append(k)
		pfeile.add_child(k)
	zeile.add_child(pfeile)
	var rechts := VBoxContainer.new()
	rechts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	zeile.add_child(rechts)
	_info = Label.new()
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info.add_theme_font_size_override("font_size", 15)
	rechts.add_child(_info)
	var aktionen := HBoxContainer.new()
	aktionen.add_theme_constant_override("separation", 8)
	rechts.add_child(aktionen)
	for k: Button in [_knopf("Drehen", 110, drehen), _knopf("Spiegeln", 110, spiegeln), _knopf("Löschen", 110, loeschen), _knopf("Abwählen", 110, func() -> void: waehlen({}))]:
		_knoepfe_auswahl.append(k)
		aktionen.add_child(k)


func _knopf(text: String, breite: float, aktion: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(breite, 36)
	b.add_theme_font_size_override("font_size", 16)
	b.focus_mode = Control.FOCUS_NONE
	if aktion.is_valid():
		b.pressed.connect(aktion)
	return b


func _zurueck() -> void:
	if _ungespeichert_warnen():
		return
	get_tree().change_scene_to_file("res://scenes/editor.tscn")


## Beim ersten Versuch mit ungespeicherten Änderungen warnen (true = abbrechen), beim zweiten verwerfen.
var _gewarnt := false
func _ungespeichert_warnen() -> bool:
	if not _geaendert or _gewarnt:
		return false
	_gewarnt = true
	_melden("Nicht gespeichert! Erst „Speichern“ drücken, oder nochmal, um die Änderungen zu verwerfen.")
	return true
