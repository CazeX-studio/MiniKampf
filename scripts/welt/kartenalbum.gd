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
