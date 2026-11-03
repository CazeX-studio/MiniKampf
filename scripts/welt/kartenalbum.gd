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


## Bonus einer Karte, z. B. {leben = 3}.
static func bonus(karte: String) -> Dictionary:
	return KartenSpiel.card(karte).get("bonus", {})


## Was alle Karten im Album zusammen bringen. Jede Sorte zählt einmal, egal wie viele man davon hat.
static func boni(sammlung: Dictionary) -> Dictionary:
	var summe := {}
	for karte: String in sammlung:
		if int(sammlung[karte]) <= 0:
			continue
		var b := bonus(karte)
		for wert: String in b:
			summe[wert] = int(summe.get(wert, 0)) + int(b[wert])
	return summe


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
