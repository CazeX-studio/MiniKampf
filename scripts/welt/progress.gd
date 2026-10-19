class_name Progress
extends RefCounted
## Fortschritt eines Spielers: Gold, Tasche, Erfahrung und Stufe, Aufträge, Gemerktes.
## Nur Daten und Regeln, keine Grafik. Lässt sich als Dictionary speichern und wieder laden.

var gold := 0
## Gegenstand -> Anzahl
var items := {}
var xp := 0
var level := 1
## Auftrag -> "aktiv", "fertig" oder "abgegeben" (nicht drin = "neu")
var quests := {}
## Gemerkte Dinge (z. B. "ye_kennengelernt", gesammelte Kräuter)
var flags := {}


func quest_state(id: String) -> String:
	return quests.get(id, "neu")


func item_count(id: String) -> int:
	return items.get(id, 0)


func add_item(id: String, count: int) -> void:
	items[id] = item_count(id) + count
	if items[id] <= 0:
		items.erase(id)


## Fügt Erfahrung hinzu. Gibt die neu erreichten Stufen zurück (meist leer).
func add_xp(amount: int) -> Array[int]:
	xp += amount
	var reached: Array[int] = []
	var table := GameData.level_xp()
	while level < table.size() and xp >= int(table[level]):
		level += 1
		reached.append(level)
	return reached


## Erfahrung für die aktuelle und die nächste Stufe (für die Anzeige). Bei Höchststufe ist "next" -1.
func xp_range() -> Vector2i:
	var table := GameData.level_xp()
	var next := int(table[level]) if level < table.size() else -1
	return Vector2i(int(table[level - 1]), next)


func to_dict() -> Dictionary:
	return {gold = gold, items = items, xp = xp, level = level, quests = quests, flags = flags}


func load_dict(data: Dictionary) -> void:
	gold = int(data.get("gold", 0))
	xp = int(data.get("xp", 0))
	level = int(data.get("level", 1))
	quests = data.get("quests", {})
	flags = data.get("flags", {})
	items = {}
	var saved_items: Dictionary = data.get("items", {})
	for id: String in saved_items:
		items[id] = int(saved_items[id])
