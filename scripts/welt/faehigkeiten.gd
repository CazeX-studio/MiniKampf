class_name Faehigkeiten
extends RefCounted
## Fähigkeiten-Bäume (Projekt 14, K.3, Beschluss 29.10.): Jeder Punkt der Klassenstufe lernt oder verbessert eine
## Fähigkeit, manche brauchen andere als Voraussetzung, Reihen werden mit der Klassenstufe frei.
## Neu verteilen beim Lehrmeister (erstes Mal kostenlos). Die Bäume stehen in data/faehigkeiten.json.
## A16 (Marco, 11.11.): Die Novizen-Fähigkeiten aus Ye's Lektionen bleiben nach der Klassenwahl. Sie stehen im Baum oben
## in einer eigenen Reihe „Novize“, kosten keine Punkte und lassen sich frei auf die Leiste legen.

## Novizen-Fähigkeiten, die man als Klasse behält (der Hieb nicht: Jede Klasse hat ihren eigenen Grundangriff)
const NOVIZE: Array[String] = ["schildstoss", "doppelschlag", "erste_hilfe", "deckung"]
const NOVIZE_NAMEN := {schildstoss = "Schildstoß", doppelschlag = "Doppelschlag", erste_hilfe = "Erste Hilfe", deckung = "Deckung geben"}
const NOVIZE_INFO := {
	schildstoss = "Ein Stoß mit dem Schild: wenig Schaden, aber der Gegner rutscht auf der Zugleiste zurück.",
	doppelschlag = "Zwei schnelle Hiebe hintereinander · 10 Mana",
	erste_hilfe = "Heilt dich oder einen Verbündeten · 12 Mana",
	deckung = "Nach vorne, fängt bis zu deinem nächsten Zug einen Treffer für einen Verbündeten ab · 8 Mana",
}


## Novizen-Fähigkeiten, die dieser Spieler als Klasse noch hat (bei Ye gelernt). Als Novize: keine (die hat er ohnehin).
static func novize_behalten(p: Progress) -> Array[String]:
	var liste: Array[String] = []
	if p.battle_class() == "novize" or p.battle_class() == "":
		return liste
	var gelernt := p.novize_gelernt()
	for id: String in NOVIZE:
		if id in gelernt:
			liste.append(id)
	return liste


## Name und Beschreibung einer Fähigkeit für Baum und Leiste: aus dem Baum der Klasse oder eine Novizen-Fähigkeit.
static func anzeige(klasse: String, id: String) -> Dictionary:
	if id in NOVIZE:
		return {id = id, name = NOVIZE_NAMEN[id], info = NOVIZE_INFO[id], novize = true}
	return eintrag(klasse, id)


## Der Baum einer Klasse ({} = die Klasse hat noch keinen, dann gibt es im Kampf alle Fähigkeiten wie bisher).
static func baum(klasse: String) -> Dictionary:
	return GameData.get_file("faehigkeiten").get(klasse, {}) if klasse != "" else {}


static func hat_baum(klasse: String) -> bool:
	return not baum(klasse).is_empty()


## Eine Fähigkeit aus dem Baum ({} = gibt es nicht).
static func eintrag(klasse: String, id: String) -> Dictionary:
	for f: Dictionary in baum(klasse).get("faehigkeiten", []):
		if f.id == id:
			return f
	return {}


## Ab welcher Klassenstufe eine Reihe frei ist.
static func reihe_ab(reihe: int) -> int:
	var ab: Array = GameData.get_file("faehigkeiten").get("reihen_ab", [1, 10, 20, 30])
	return int(ab[clampi(reihe - 1, 0, ab.size() - 1)])


## Kann man die Fähigkeit jetzt (um eine Stufe) lernen? "" = ja, sonst der Grund.
static func grund_gegen(p: Progress, id: String) -> String:
	var klasse := p.battle_class()
	var f := eintrag(klasse, id)
	if f.is_empty():
		return "Gibt es nicht"
	if f.get("bald", false):
		return "Kommt bald"
	var stufe := int(p.faehigkeiten.get(id, 0))
	if stufe >= int(f.get("max", 5)):
		return "Höchste Stufe"
	if p.klassenstufe() < reihe_ab(int(f.reihe)):
		return "Ab Klassenstufe %d" % reihe_ab(int(f.reihe))
	var braucht: Dictionary = f.get("braucht", {})
	for andere: String in braucht:
		if int(p.faehigkeiten.get(andere, 0)) < int(braucht[andere]):
			return "Braucht %s %d" % [eintrag(klasse, andere).get("name", andere), int(braucht[andere])]
	if p.freie_punkte() <= 0:
		return "Keine Punkte frei"
	return ""


## Kann die Fähigkeit auf die Leiste? (gelernt, nicht passiv, nicht der normale Angriff, wirkt schon)
static func fuer_leiste(p: Progress, id: String) -> bool:
	if id in NOVIZE:
		return id in novize_behalten(p)
	var f := eintrag(p.battle_class(), id)
	if f.is_empty() or f.get("passiv", false) or f.get("bald", false) or f.get("grundangriff", false):
		return false
	return int(p.faehigkeiten.get(id, 0)) > 0


## Was das nächste Neuverteilen kostet (Bronze): das erste Mal nichts.
static func preis_neu_verteilen(p: Progress) -> int:
	if int(p.flags.get("neu_verteilt", 0)) == 0:
		return 0
	return int(GameData.get_file("faehigkeiten").get("neu_verteilen_preis", 100)) * p.klassenstufe()


## Mehr Schaden und Heilung je Stufe über 1 (Anteil).
static func stufen_bonus() -> float:
	return float(GameData.get_file("faehigkeiten").get("stufen_bonus", 0.1))
