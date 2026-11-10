class_name StadtAenderungen
extends RefCounted
## Stadt-Editor (S4): Was Marco in einer Stadt verschoben hat, steht getrennt von den Kartendaten in
## data/stadt_aenderungen.json und wird beim Laden der Daten darübergelegt (GameData.get_file). So bleiben die
## Änderungen erhalten, auch wenn Claude eine Karte mit den Werkzeugen (tools/*_karten.py) neu erzeugt.
## Aufbau je Stadt:
##   "objekte": [{"teil": "…", "von": [x, y], "nach": [x, y]}]   Baukasten-Teil, erkannt an Teil und altem Feld
##   "figuren": {"<NPC-Kennung>": {"feld": [x, y], "nachts": [x, y]}}   neuer Platz bei Tag und/oder bei Nacht
## Im Browser speichert der Editor in user://stadt_aenderungen.json (gilt dann nur in diesem Browser, in der Werkstatt)
## und gibt die Datei zum Herunterladen aus; Marco schickt sie Claude, der sie nach data/ legt.

const DATEI := "res://data/stadt_aenderungen.json"
const DATEI_BROWSER := "user://stadt_aenderungen.json"
## Städte im Editor: Baukasten-Datei der Teile und wo die Figuren stehen (Datei und Weg darin)
const STAEDTE := {
	"kreuzweg": {name = "Kreuzweg", karte = "kreuzweg_karte", figuren = ["kreuzweg"]},
	"wipfelheim": {name = "Wipfelheim (Grünwacht)", karte = "karte_wipfelheim", figuren = ["karten", "wipfelheim"]},
	"glutoase": {name = "Glutoase", karte = "karte_glutoase", figuren = ["karten", "glutoase"]},
}

## Nur für die Prüfungen: andere Dateien
static var datei := DATEI
static var datei_browser := DATEI_BROWSER


## Die geltenden Änderungen: in der Werkstatt die des Browsers (wenn es welche gibt), sonst die aus dem Spiel.
static func laden() -> Dictionary:
	if Tester.werkzeuge() and FileAccess.file_exists(datei_browser):
		var eigene := _lesen(datei_browser)
		if not eigene.is_empty():
			return eigene
	return _lesen(datei)


static func _lesen(pfad: String) -> Dictionary:
	if not FileAccess.file_exists(pfad):
		return {}
	var daten: Variant = JSON.parse_string(FileAccess.get_file_as_string(pfad))
	return daten if daten is Dictionary else {}


## Speichert die Änderungen (im Browser und, wenn das Spiel aus Godot läuft, auch in die Spieldaten).
## Danach liest das Spiel seine Daten neu. Ergebnis: Text als Datei (zum Herunterladen).
static func speichern(aenderungen: Dictionary) -> String:
	var text := JSON.stringify(aenderungen, "\t", false) + "\n"
	for pfad: String in ([datei_browser, datei] if OS.has_feature("editor") or datei != DATEI else [datei_browser]):
		var f := FileAccess.open(pfad, FileAccess.WRITE)
		if f != null:
			f.store_string(text)
	GameData.neu_laden()
	return text


## Legt die Änderungen über eine eben geladene Datendatei (von GameData.get_file aufgerufen).
static func anwenden(file_name: String, daten: Dictionary, aenderungen: Dictionary) -> void:
	for stadt: String in STAEDTE:
		var info: Dictionary = STAEDTE[stadt]
		var aend: Dictionary = aenderungen.get(stadt, {})
		if aend.is_empty():
			continue
		if file_name == info.karte:
			objekte_verschieben(daten.get("objekte", []), aend.get("objekte", []))
		if file_name == info.figuren[0]:
			figuren_verschieben(figuren_von(daten, info), aend.get("figuren", {}))


## Die Figuren (NPCs) einer Stadt in ihrer Datendatei.
static func figuren_von(daten: Dictionary, info: Dictionary) -> Dictionary:
	var ort: Dictionary = daten
	for schluessel: String in (info.figuren as Array).slice(1):
		ort = ort.get(schluessel, {})
	return ort.get("npcs", {})


static func objekte_verschieben(objekte: Array, verschoben: Array) -> void:
	for v: Dictionary in verschoben:
		for o: Dictionary in objekte:
			if o.get("teil", "") == v.get("teil", "") and gleiches_feld(o.feld, v.von):
				o.feld = [int(v.nach[0]), int(v.nach[1])]


static func figuren_verschieben(npcs: Dictionary, verschoben: Dictionary) -> void:
	for id: String in verschoben:
		if not npcs.has(id):
			continue
		for platz: String in ["feld", "nachts"]:
			if (verschoben[id] as Dictionary).has(platz) and (platz == "feld" or npcs[id].has("nachts")):
				npcs[id][platz] = [int(verschoben[id][platz][0]), int(verschoben[id][platz][1])]


static func gleiches_feld(a: Array, b: Array) -> bool:
	return a.size() >= 2 and b.size() >= 2 and int(a[0]) == int(b[0]) and int(a[1]) == int(b[1])
