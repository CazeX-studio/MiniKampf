class_name GameData
extends RefCounted
## Lädt die Datendateien aus res://data (Dialoge, Aufträge, Gegenstände, Stufen, Texte, Stadt).
## Die Dateien werden einmal gelesen und dann im Speicher behalten.

const FILES := ["dialoge", "auftraege", "gegenstaende", "stufen", "texte", "kreuzweg", "kaempfe", "laeden", "erfolge", "klassen", "karten", "erinnerungen", "kartenspiel"]

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


## Alle Monster in der Wildnis aus data/karten.json, in fester Reihenfolge (Kennung im Spiel: "monster:<Nummer>").
## Je Eintrag: {karte, feld, gegner, stufe}.
static func wild_monsters() -> Array[Dictionary]:
	if _cache.has("_wild"):
		return _cache._wild
	var result: Array[Dictionary] = []
	var maps := get_file("karten")
	for map_id: String in maps:
		if not maps[map_id] is Dictionary:
			continue
		for d: Dictionary in maps[map_id].get("monster", []):
			result.append({karte = map_id, feld = Vector2i(int(d.feld[0]), int(d.feld[1])), gegner = d.gegner,
					stufe = int(d.get("stufe", 1)), hintergrund = maps[map_id].get("kampf_hintergrund", "wald"),
					dungeon = maps[map_id].get("dungeon", "")})
	_cache["_wild"] = result
	return result


## Erfahrung und Geld für einen Sieg über Monster in der Wildnis (jedes Mal, nicht nur beim ersten Sieg).
const WILD_XP_PER_LEVEL := 12
## Geld ist knapp (design.md): jedes Monster gibt 1 Bronze, dazu 1 Bronze je 5 Stufen
## (Stufe 10 = 3, Stufe 15 = 4, Stufe 20 = 5 Bronze). Ein Heiltrank kostet etwa so viel wie 6 bis 8 Monster.
const WILD_BRONZE := 1
const WILD_LEVELS_PER_BRONZE := 5


## Bronze, das ein einzelnes Monster dieser Stufe in der Wildnis fallen lässt.
static func wild_bronze(stufe: int) -> int:
	return WILD_BRONZE + stufe / WILD_LEVELS_PER_BRONZE


## Ein Kampf aus data/kaempfe.json. "probe:<klasse>" = Probestunde mit dieser Klasse
## (gemeinsame Vorlage "probestunde", Erklärung aus den Klassendaten). "wild:<Nummer>" = Monster in der Wildnis.
static func battle(id: String) -> Dictionary:
	if id.begins_with("wild:"):
		var list := wild_monsters()
		var index := int(id.substr(5))
		if index < 0 or index >= list.size():
			return {}
		var m: Dictionary = list[index]
		var names: PackedStringArray = []
		for enemy: String in m.gegner:
			names.append(Sandbox.ENEMIES[enemy].name)
		return {name = "%s (Stufe %d)" % [" und ".join(names), m.stufe], ansage = text("wild_ansage" if names.size() == 1 else "wild_ansage_mehrere", [" und ".join(names)]),
				wellen = [m.gegner], gegner_stufe = m.stufe, eigene_klasse = true, wild = true, hintergrund = m.hintergrund,
				erfahrung = WILD_XP_PER_LEVEL * m.stufe * m.gegner.size(), gold = wild_bronze(m.stufe) * m.gegner.size(),
				dungeon = m.dungeon, entscheidung_in_der_welt = true}
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
