class_name Progress
extends RefCounted
## Fortschritt eines Spielers: Gold, Tasche, Erfahrung und Stufe, Aufträge, Gemerktes.
## Nur Daten und Regeln, keine Grafik. Lässt sich als Dictionary speichern und wieder laden.

## Kästchen in der Tasche (Projekt 4: Tasche mit 30 Plätzen). Jede Sorte Gegenstand braucht ein Kästchen,
## mehr vom Gleichen liegt im selben Kästchen.
const BAG_SIZE := 30
## Gürtel (Projekt 5): so viele Plätze, jeder fasst einen kleinen Stapel einer Sorte.
## Nur Gegenstände mit "guertel": true in data/gegenstaende.json (Tränke). Befüllt wird nur außerhalb des Kampfes.
const BELT_SLOTS := 4
const BELT_STACK := 5
## Plätze in der Bank zu Beginn (Projekt 4). Jede Sorte Gegenstand braucht einen Platz, wie in der Tasche.
const BANK_START := 20

## Geld in Bronze (Anzeige als Bronze, Silber, Gold: siehe geld.gd)
var gold := 0
## Gegenstand -> Anzahl
var items := {}
## Reihenfolge in der Tasche: ein Gegenstand pro Kästchen ("" = leer). Wird über bag_slots() aufgeräumt.
var slots: Array = []
## Beute nach einem Sieg, die nicht mehr in die Tasche gepasst hat: Gegenstand -> Anzahl.
## Sie wartet im Beute-Fenster, bis man sie nimmt (nach dem Wegwerfen von etwas anderem) oder liegen lässt.
var loot := {}
## Bank (Projekt 4): Gegenstand -> Anzahl. Dieselbe Bank an jeder Bankstelle, gespeichert mit dem Spielstand.
var bank := {}
## Plätze in der Bank (später gegen Gold erweiterbar)
var bank_size := BANK_START
## Gürtel: BELT_SLOTS Plätze, je {id, anzahl} oder leer ({}). Was am Gürtel hängt, ist nicht mehr in der Tasche.
var belt: Array = [{}, {}, {}, {}]
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


## Darf dieser Gegenstand an den Gürtel?
static func belt_allowed(id: String) -> bool:
	return GameData.item(id).get("guertel", false)


## Wie viele davon am Gürtel hängen.
func belt_count(id: String) -> int:
	var n := 0
	for entry: Dictionary in belt:
		if entry.get("id", "") == id:
			n += int(entry.anzahl)
	return n


## Tränke für den Kampf: Gürtel und Tasche zusammen (bis Schritt 2 „nur der Gürtel zählt“ kommt).
func potion_count(id: String) -> int:
	return item_count(id) + belt_count(id)


## Im Kampf verbrauchte Tränke abziehen: zuerst vom Gürtel, dann aus der Tasche.
func use_potions(id: String, count: int) -> void:
	for entry: Dictionary in belt:
		if count <= 0:
			return
		if entry.get("id", "") == id:
			var taken := mini(count, int(entry.anzahl))
			entry.anzahl -= taken
			count -= taken
			if int(entry.anzahl) <= 0:
				entry.clear()
	if count > 0:
		add_item(id, -mini(count, item_count(id)))


## Aus der Tasche an den Gürtel hängen: füllt einen angefangenen Platz derselben Sorte bis BELT_STACK auf,
## sonst einen leeren Platz. Gibt die Anzahl zurück (0 = ging nicht).
func belt_put(id: String) -> int:
	var have := item_count(id)
	if have <= 0 or not belt_allowed(id):
		return 0
	var slot := -1
	for i in belt.size():
		if belt[i].get("id", "") == id and int(belt[i].anzahl) < BELT_STACK:
			slot = i
			break
	if slot < 0:
		for i in belt.size():
			if belt[i].is_empty():
				slot = i
				break
	if slot < 0:
		return 0
	var now := int(belt[slot].get("anzahl", 0))
	var moved := mini(have, BELT_STACK - now)
	belt[slot] = {id = id, anzahl = now + moved}
	add_item(id, -moved)
	return moved


## Einen Gürtelplatz zurück in die Tasche legen. Gibt die Anzahl zurück (0 = ging nicht, z. B. Tasche voll).
func belt_take(slot: int) -> int:
	if slot < 0 or slot >= belt.size() or belt[slot].is_empty():
		return 0
	var id: String = belt[slot].id
	if not has_room(id):
		return 0
	var count := int(belt[slot].anzahl)
	add_item(id, count)
	belt[slot] = {}
	return count


## Ganzen Stapel aus der Tasche in die Bank legen. Gibt die Anzahl zurück (0 = ging nicht).
func deposit(id: String) -> int:
	var count := item_count(id)
	if count <= 0 or not bank_has_room(id):
		return 0
	bank[id] = int(bank.get(id, 0)) + count
	add_item(id, -count)
	return count


## Ganzen Stapel aus der Bank in die Tasche holen. Gibt die Anzahl zurück (0 = ging nicht).
func withdraw(id: String) -> int:
	var count := int(bank.get(id, 0))
	if count <= 0 or not has_room(id):
		return 0
	bank.erase(id)
	add_item(id, count)
	return count


## Passt dieser Gegenstand noch in die Bank? Mehr vom Gleichen passt immer.
func bank_has_room(id: String) -> bool:
	return bank.has(id) or bank.size() < bank_size


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
	return {gold = gold, items = items, slots = bag_slots().duplicate(), beute = loot, bank = bank, bank_plaetze = bank_size, guertel = belt,
			xp = xp, level = level, quests = quests, flags = flags}


func load_dict(data: Dictionary) -> void:
	gold = int(data.get("gold", 0))
	loot = {}
	var saved_loot: Dictionary = data.get("beute", {})
	for id: String in saved_loot:
		loot[id] = int(saved_loot[id])
	bank = {}
	var saved_bank: Dictionary = data.get("bank", {})
	for id: String in saved_bank:
		bank[id] = int(saved_bank[id])
	bank_size = int(data.get("bank_plaetze", BANK_START))
	belt = []
	var saved_belt: Array = data.get("guertel", [])
	for i in BELT_SLOTS:
		var entry: Dictionary = saved_belt[i] if i < saved_belt.size() and saved_belt[i] is Dictionary else {}
		belt.append({id = str(entry.id), anzahl = int(entry.anzahl)} if entry.has("id") and int(entry.get("anzahl", 0)) > 0 else {})
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
