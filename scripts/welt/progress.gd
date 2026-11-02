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
## Angelegte Ausrüstung (Projekt 14, K.1): Platz -> Gegenstand (siehe Ausruestung.PLAETZE). Was angelegt ist,
## liegt nicht mehr in der Tasche. Jeder startet mit der Grundausrüstung.
var ausruestung: Dictionary = Ausruestung.START.duplicate()
## Mana außerhalb des Kampfes als Anteil (0 bis 1, Projekt 14, K.2): Nach Kämpfen in der Wildnis bleibt, was übrig
## war. Hinsetzen füllt es wieder auf, am Lagerfeuer schneller.
var mana_anteil := 1.0
## Klassenstufe (Projekt 14, K.3): Erfahrung, die man nach dem Lernen der Klasse sammelt, zählt auch hierfür.
## Die Stufen kommen aus derselben Tabelle wie die Charakterstufe. Jede Klassenstufe gibt einen Fähigkeitspunkt.
var klassen_xp := 0
## Gelernte Fähigkeiten aus dem Baum der Klasse: Kennung -> Stufe (siehe Faehigkeiten)
var faehigkeiten := {}
## Feste Leiste (Projekt 14, K.3): sechs Plätze mit Fähigkeiten aus dem Baum ("" = frei), vor dem Kampf bestückt.
## Angriff, Abwarten, Gürtel und Ult sind im Kampf immer zusätzlich da.
const LEISTE_PLAETZE := 6
var leiste: Array = ["", "", "", "", "", ""]
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


## Fähigkeiten des Novizen, die man bei Ye lernt (Projekt 14, K.5): Fähigkeit -> Merker der Lektion.
## Den Hieb kann man immer.
const NOVIZE_LEKTIONEN := {schildstoss = "lektion_schildstoss", doppelschlag = "lektion_doppelschlag",
		erste_hilfe = "lektion_erste_hilfe", deckung = "lektion_deckung"}


## Welche Novizen-Fähigkeiten schon gelernt sind.
func novize_gelernt() -> Array:
	var liste: Array = ["schlag"]
	for id: String in NOVIZE_LEKTIONEN:
		if flags.has(NOVIZE_LEKTIONEN[id]):
			liste.append(id)
	return liste


## Klassenstufe: 0 = noch keine Klasse gelernt, sonst ab 1 (Tabelle wie die Charakterstufe).
func klassenstufe() -> int:
	if not flags.has("klasse_gelernt") or battle_class() == "":
		return 0
	var table := GameData.level_xp()
	var stufe := 1
	while stufe < table.size() and klassen_xp >= int(table[stufe]):
		stufe += 1
	return stufe


## Fähigkeitspunkte, die noch nicht verteilt sind (ein Punkt pro Klassenstufe).
func freie_punkte() -> int:
	var benutzt := 0
	for id: String in faehigkeiten:
		benutzt += int(faehigkeiten[id])
	return maxi(0, klassenstufe() - benutzt)


## Höchstes Mana, mit dem man in den Kampf geht: gelernte Klasse oder Novize, dazu der Mana-Bonus der Ausrüstung.
## (Dieselbe Rechnung wie im Werte-Fenster und in BattleState.)
func max_mana() -> int:
	var klasse := battle_class()
	var basis := 0
	if flags.has("klasse_bestaetigt") and Sandbox.CLASSES.has(klasse) and klasse != "novize":
		var data: Dictionary = Sandbox.CLASSES[klasse]
		basis = int(data.mana) + BattleState.LEVEL_MANA * (level - 1) if int(data.mana) > 0 else 0
	else:
		basis = int(Grundwerte.for_level(level).mana)
	if basis <= 0:
		return 0
	return basis + int(Ausruestung.kampfwerte(ausruestung).mana)


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


## Tränke für den Kampf: nur was am Gürtel hängt (Projekt 5, „der Gürtel ist die Grenze“).
func potion_count(id: String) -> int:
	return belt_count(id)


## Tasche und Gürtel zusammen (z. B. zum Verkaufen).
func total_count(id: String) -> int:
	return item_count(id) + belt_count(id)


## Gegenstände wegnehmen (Verkaufen, Aufträge): zuerst aus der Tasche, dann vom Gürtel.
func remove_item(id: String, count: int) -> void:
	var from_bag := mini(count, item_count(id))
	add_item(id, -from_bag)
	if count - from_bag > 0:
		use_potions(id, count - from_bag)


## Im Kampf verbrauchte Tränke abziehen: zuerst vom Gürtel, dann (falls nötig) aus der Tasche.
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
	# Nach dem Lernen der Klasse wächst auch die Klassenstufe
	if flags.has("klasse_gelernt") and battle_class() != "":
		klassen_xp += amount
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
	return {gold = gold, items = items, slots = bag_slots().duplicate(), beute = loot, bank = bank, bank_plaetze = bank_size, guertel = belt, ausruestung = ausruestung, mana_anteil = mana_anteil, lektionen_v2 = true, klassen_xp = klassen_xp, faehigkeiten = faehigkeiten, leiste = leiste,
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
	# Ältere Spielstände ohne Ausrüstung bekommen die Grundausrüstung
	ausruestung = {}
	var saved_gear: Dictionary = data.get("ausruestung", Ausruestung.START)
	for platz: String in saved_gear:
		if platz in Ausruestung.PLAETZE and str(saved_gear[platz]) != "":
			ausruestung[platz] = str(saved_gear[platz])
	mana_anteil = clampf(float(data.get("mana_anteil", 1.0)), 0.0, 1.0)
	klassen_xp = int(data.get("klassen_xp", 0))
	leiste = []
	var saved_bar: Array = data.get("leiste", [])
	for i in LEISTE_PLAETZE:
		leiste.append(str(saved_bar[i]) if i < saved_bar.size() else "")
	# Ältere Spielstände mit gelernter Klasse: Klassen-Erfahrung ab Stufe 10 schätzen (dort lernt man die Klasse)
	if not data.has("klassen_xp") and (data.get("flags", {}) as Dictionary).has("klasse_gelernt"):
		var table := GameData.level_xp()
		klassen_xp = maxi(0, int(data.get("xp", 0)) - int(table[mini(9, table.size() - 1)]))
	faehigkeiten = {}
	var saved_skills: Dictionary = data.get("faehigkeiten", {})
	for id: String in saved_skills:
		if int(saved_skills[id]) > 0:
			faehigkeiten[id] = int(saved_skills[id])
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
	# Alter Spielstand ohne Gürtel: Tränke aus der Tasche kommen an den Gürtel, damit man im Kampf nicht ohne dasteht
	if not data.has("guertel"):
		for id: String in items.keys():
			if belt_allowed(id):
				while belt_put(id) > 0:
					pass
	# Ältere Spielstände (vor D8b): Wer die Grundausbildung hatte, kannte schon alles außer „Deckung geben“
	if not data.has("lektionen_v2") and quest_state("grundausbildung") == "abgegeben":
		for flag: String in ["lektion_schildstoss", "lektion_doppelschlag", "lektion_erste_hilfe"]:
			flags[flag] = true
		if level >= 8:
			flags["lektion_deckung"] = true
	# Ältere Spielstände ohne Leiste: gelernte Fähigkeiten kommen von selbst darauf
	if not data.has("leiste"):
		for id: String in faehigkeiten:
			if Faehigkeiten.fuer_leiste(self, id) and "" in leiste:
				leiste[leiste.find("")] = id
	bag_slots()
