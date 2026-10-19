class_name GameData
extends RefCounted
## Lädt die Datendateien aus res://data (Dialoge, Aufträge, Gegenstände, Stufen, Texte, Stadt).
## Die Dateien werden einmal gelesen und dann im Speicher behalten.

const FILES := ["dialoge", "auftraege", "gegenstaende", "stufen", "texte", "kreuzweg", "kaempfe", "laeden", "erfolge"]

static var _cache := {}


static func get_file(file_name: String) -> Dictionary:
	if not _cache.has(file_name):
		var text := FileAccess.get_file_as_string("res://data/%s.json" % file_name)
		var parsed: Variant = JSON.parse_string(text)
		if parsed is Dictionary:
			_cache[file_name] = parsed
		else:
			push_error("Datendatei kaputt oder fehlt: data/%s.json" % file_name)
			_cache[file_name] = {}
	return _cache[file_name]


static func dialog(id: String) -> Dictionary:
	return get_file("dialoge").get(id, {})


static func quest(id: String) -> Dictionary:
	return get_file("auftraege").get(id, {})


static func item(id: String) -> Dictionary:
	return get_file("gegenstaende").get(id, {name = id, beschreibung = ""})


static func item_name(id: String) -> String:
	return item(id).get("name", id)


## Kurzer Text aus texte.json, mit Platzhaltern (%s, %d) gefüllt.
static func text(id: String, args: Array = []) -> String:
	var t: String = get_file("texte").get(id, id)
	return t % args if not args.is_empty() else t


## Erfahrung, die man insgesamt für jede Stufe braucht (Stufe 1 = Eintrag 0).
static func level_xp() -> Array:
	return get_file("stufen").get("erfahrung_fuer_stufe", [0])


static func max_level() -> int:
	return level_xp().size()


## Ein Kampf aus data/kaempfe.json. "probe:<klasse>" = Probestunde mit dieser Klasse
## (gemeinsame Vorlage "probestunde", Erklärung aus den Klassendaten).
static func battle(id: String) -> Dictionary:
	var all := get_file("kaempfe")
	if not id.begins_with("probe:"):
		return all.get(id, {})
	var klasse := id.substr(6)
	if not Sandbox.CLASSES.has(klasse) or not all.has("probestunde"):
		return {}
	var data: Dictionary = all.probestunde.duplicate(true)
	var c: Dictionary = Sandbox.CLASSES[klasse]
	data["klasse"] = klasse
	data["name"] = "Probestunde: %s" % c.title
	data["hinweise"] = {erster_zug = str(data.get("hinweis_vorlage", "%s")) % [c.title, c.role, c.mechanic, c.reaction_text, c.ult]}
	return data
