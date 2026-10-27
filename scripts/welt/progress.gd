class_name Progress
extends RefCounted
## Fortschritt eines Spielers: Gold, Tasche, Erfahrung und Stufe, Aufträge, Gemerktes.
## Nur Daten und Regeln, keine Grafik. Lässt sich als Dictionary speichern und wieder laden.

## Kästchen in der Tasche (Projekt 4: Tasche mit 30 Plätzen). Jede Sorte Gegenstand braucht ein Kästchen,
## mehr vom Gleichen liegt im selben Kästchen.
const BAG_SIZE := 30

## Geld in Bronze (Anzeige als Bronze, Silber, Gold: siehe geld.gd)
var gold := 0
## Gegenstand -> Anzahl
var items := {}
## Reihenfolge in der Tasche: ein Gegenstand pro Kästchen ("" = leer). Wird über bag_slots() aufgeräumt.
var slots: Array = []
var xp := 0
var level := 1
## Auftrag -> "aktiv", "fertig" oder "abgegeben" (nicht drin = "neu")
var quests := {}
## Gemerkte Dinge (z. B. "ye_kennengelernt", gesammelte Kräuter)
var flags := {}


func quest_state(id: String) -> String:
	return quests.get(id, "neu")


## Mit welcher Klasse man kämpft: erst nachdem man sie beim Lehrmeister gelernt hat ("klasse_gelernt"),
## vorher als Novize (""). Klassen ohne Lehrmeister im Spiel ("lernen_bei" in data/klassen.json) gleich nach der Wahl.
func battle_class() -> String:
	var klasse := str(flags.get("klasse", ""))
	if klasse == "" or flags.has("klasse_gelernt"):
		return klasse
	return "" if GameData.get_file("klassen").get(klasse, {}).has("lernen_bei") else klasse


func item_count(id: String) -> int:
	return items.get(id, 0)


## Belegte Kästchen in der Tasche.
func used_slots() -> int:
	return items.size()


## Passt dieser Gegenstand noch in die Tasche? Mehr vom Gleichen passt immer.
func has_room(id: String) -> bool:
	return items.has(id) or items.size() < BAG_SIZE


func add_item(id: String, count: int) -> void:
	items[id] = item_count(id) + count
	if items[id] <= 0:
		items.erase(id)
	bag_slots()


## Die Kästchen der Tasche (BAG_SIZE Stück; nur wenn ein Auftrag trotz voller Tasche etwas gibt, kurz mehr): Leere Gegenstände fliegen raus,
## neue kommen ins erste freie Kästchen. Die Reihenfolge bleibt sonst, wie der Spieler sie gelegt hat.
func bag_slots() -> Array:
	var seen := {}
	for i in slots.size():
		var id := str(slots[i])
		if id != "" and (not items.has(id) or seen.has(id)):
			slots[i] = ""
		elif id != "":
			seen[id] = true
	while slots.size() < BAG_SIZE:
		slots.append("")
	for id: String in items:
		if seen.has(id):
			continue
		var free := slots.find("")
		if free < 0:
			slots.append(id)
		else:
			slots[free] = id
	# Gegenstände aus Extra-Kästchen rücken in frei gewordene Kästchen nach, leere Extra-Kästchen verschwinden
	for i in range(BAG_SIZE, slots.size()):
		var free := slots.find("")
		if slots[i] != "" and free >= 0 and free < BAG_SIZE:
			slots[free] = slots[i]
			slots[i] = ""
	while slots.size() > BAG_SIZE and slots.back() == "":
		slots.pop_back()
	return slots


## Tauscht zwei Kästchen der Tasche (Ziehen und Ablegen). Ein leeres Ziel-Kästchen ist einfach ein Verschieben.
func move_slot(from: int, to: int) -> void:
	bag_slots()
	if from < 0 or to < 0 or from >= slots.size() or to >= slots.size() or from == to:
		return
	var moved: Variant = slots[from]
	slots[from] = slots[to]
	slots[to] = moved


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
	return {gold = gold, items = items, slots = bag_slots().duplicate(), xp = xp, level = level, quests = quests, flags = flags}


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
	slots = []
	for id: Variant in data.get("slots", []):
		slots.append(str(id))
	bag_slots()
