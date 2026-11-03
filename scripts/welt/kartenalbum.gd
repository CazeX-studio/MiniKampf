class_name KartenAlbum
## Kartenalbum (D15, Projekt 8 Schritt 1–3): eine Seite pro Region mit festen Plätzen (data/kartenspiel.json, "seiten").
## Die Sammlung steht im Spielstand unter dem Gemerkten "karten" (Kennung -> Anzahl). Gefundene Karten liegen erst
## verdeckt in der Tasche ("monsterkarte_<Kennung>") und kommen mit „Aktivieren“ ins Album.

const UNBEKANNT := "monsterkarte"
const PREFIX := "monsterkarte_"


## Die Seiten des Albums: [{name, karten: [Kennung, …]}, …]
static func seiten() -> Array:
	return GameData.get_file("kartenspiel").get("seiten", [])


## Wie viele verschiedene Karten einer Seite man hat: [hat, insgesamt]
static func zaehler(sammlung: Dictionary, seite: Dictionary) -> Array[int]:
	var hat := 0
	for id: String in seite.karten:
		if int(sammlung.get(id, 0)) > 0:
			hat += 1
	return [hat, (seite.karten as Array).size()]


## Gegenstand für eine verdeckt gefundene Karte.
static func verdeckt(karte: String) -> String:
	return PREFIX + karte


## Ist das eine verdeckte Monsterkarte in der Tasche? Gibt die Kennung der Karte zurück ("" = nein).
static func karte_von(gegenstand: String) -> String:
	return gegenstand.trim_prefix(PREFIX) if gegenstand.begins_with(PREFIX) else ""


## Element und Schwächen eines Monsters für die Album-Info: {element, schwaechen: [Element, …]}
static func info(karte: String) -> Dictionary:
	var element := str(Sandbox.ENEMIES.get(karte, {}).get("element", ""))
	return {element = element, schwaechen = Elements.weaknesses(element) if element != "" else []}


# --- D16: Besitzeffekte, Deck, Ankauf -------------------------------------------

## Welche Werte Karten verbessern können (Namen für die Anzeige)
const BONUS_NAMEN := {leben = "Leben", mana = "Mana", angriff = "Angriff", tempo = "Tempo"}
## So viele Karten nimmt man zu Kreuzweg-Karten mit
const DECK_GROESSE := 5


## Bonus einer Karte, z. B. {leben = 3}. Verbesserte Karten (+1 bis +10, D17) bringen mehr.
static func bonus(karte: String, stufe := 0) -> Dictionary:
	var grund: Dictionary = KartenSpiel.card(karte).get("bonus", {})
	if stufe <= 0:
		return grund
	var staerker := float(_verbessern().get("staerker", 0.25))
	var ergebnis := {}
	for wert: String in grund:
		ergebnis[wert] = roundi(int(grund[wert]) * (1.0 + staerker * stufe))
	return ergebnis


## Was alle Karten im Album zusammen bringen. Jede Sorte zählt einmal, egal wie viele man davon hat.
## stufen: Kennung -> Stufe der Verbesserung (Gemerktes "karten_stufe").
static func boni(sammlung: Dictionary, stufen: Dictionary = {}) -> Dictionary:
	var summe := {}
	for karte: String in sammlung:
		if int(sammlung[karte]) <= 0:
			continue
		var b := bonus(karte, int(stufen.get(karte, 0)))
		for wert: String in b:
			summe[wert] = int(summe.get(wert, 0)) + int(b[wert])
	return summe


## Boni aus dem Gemerkten eines Spielers (Sammlung und Stufen).
static func boni_von(flags: Dictionary) -> Dictionary:
	return boni(flags.get("karten", {}), flags.get("karten_stufe", {}))


# --- D17: volle Seiten, Verbessern -----------------------------------------------

## Hat man alle Karten dieser Seite?
static func seite_voll(sammlung: Dictionary, seite: Dictionary) -> bool:
	var zahl := zaehler(sammlung, seite)
	return zahl[0] == zahl[1] and zahl[1] > 0


static func _verbessern() -> Dictionary:
	return GameData.get_file("kartenspiel").get("verbessern", {})


## Höchste Stufe beim Verbessern (+10)
static func hoechste_stufe() -> int:
	return int(_verbessern().get("hoechste", 10))


## Was das Verbessern auf diese Stufe kostet (Bronze, dazu eine doppelte Karte).
static func verbessern_preis(ziel: int) -> int:
	return int(_verbessern().get("bronze_je_stufe", 10)) * ziel


## Chance, dass das Verbessern auf diese Stufe klappt (bis +4 sicher).
static func verbessern_chance(ziel: int) -> float:
	if ziel <= int(_verbessern().get("sicher_bis", 4)):
		return 1.0
	return float(_verbessern().get("chance", {}).get(str(ziel), 0.3))


## Boni als Text, z. B. „+3 Leben · +1 Tempo“ ("" = keine).
static func boni_text(b: Dictionary) -> String:
	var teile: PackedStringArray = []
	for wert: String in BONUS_NAMEN:
		if int(b.get(wert, 0)) != 0:
			teile.append("+%d %s" % [int(b[wert]), BONUS_NAMEN[wert]])
	return " · ".join(teile)


## Das Deck für Kreuzweg-Karten: die im Album gewählten Karten (nur, was man hat), der Rest mit den stärksten aufgefüllt.
static func deck(sammlung: Dictionary, gewaehlt: Array) -> Array:
	var uebrig := sammlung.duplicate()
	var ergebnis: Array = []
	for karte: String in gewaehlt:
		if ergebnis.size() < DECK_GROESSE and int(uebrig.get(karte, 0)) > 0:
			ergebnis.append(karte)
			uebrig[karte] = int(uebrig[karte]) - 1
	ergebnis.append_array(KartenSpiel.best_deck(uebrig, DECK_GROESSE - ergebnis.size()))
	return ergebnis


## Was Bingo für eine doppelte Karte zahlt (Bronze): die Hälfte ihrer vier Werte, aufgerundet.
static func ankaufpreis(karte: String) -> int:
	var summe := 0
	for v in KartenSpiel.values(karte):
		summe += int(v)
	return ceili(summe / 2.0)
