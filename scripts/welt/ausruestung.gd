class_name Ausruestung
extends RefCounted
## Werte für Waffen und Rüstung (Projekt 14, Schritt K.1, Beschluss 29.10.):
## - Die Waffe gibt Waffenkraft, Kopf, Körper und Schuhe geben Verteidigung (gegen Nahkampf und Fernkampf) und
##   Widerstand (gegen Magie). Platte gibt mehr Verteidigung, Stoff mehr Widerstand. Schmuck gibt nur Bonus-Werte.
## - Bonus-Werte nach Seltenheit: Gewöhnlich 0, Ungewöhnlich 1, Selten 2, Episch 3, Legendär 4, ab Selten ein Sonderwert.
## - Waffen-Tempo: schnell, normal, schwer (schwere Waffen kommen auf der Zugleiste später dran).
## - Etwa ein Drittel der Werte kommt aus der Ausrüstung.
## Die Teile stehen in data/gegenstaende.json unter "ausruestung". Jeder startet mit der Grundausrüstung (START);
## mit ihr kämpft man genauso wie vor der Ausrüstung, bessere Teile machen stärker, ohne Teile ist man schwächer.

const PLAETZE := ["waffe", "kopf", "koerper", "schuhe", "schmuck1", "schmuck2"]
const PLATZ_NAMEN := {waffe = "Waffe", kopf = "Kopf", koerper = "Körper", schuhe = "Schuhe", schmuck1 = "Schmuck", schmuck2 = "Schmuck"}
## Grundausrüstung des Novizen (Platz -> Gegenstand). Kommt in jeden neuen und alten Spielstand.
const START := {waffe = "kurzschwert", kopf = "stoffkappe", koerper = "lederweste", schuhe = "lederstiefel"}

const SELTENHEITEN := ["gewoehnlich", "ungewoehnlich", "selten", "episch", "legendaer"]
const SELTENHEIT_NAMEN := {gewoehnlich = "Gewöhnlich", ungewoehnlich = "Ungewöhnlich", selten = "Selten", episch = "Episch", legendaer = "Legendär"}
## Farben wie in klassischen Rollenspielen (Weiß, Grün, Blau, Lila, Orange)
const SELTENHEIT_FARBEN := {gewoehnlich = "e8e8e8", ungewoehnlich = "6dff8a", selten = "5ab8ff", episch = "c58cff", legendaer = "ffa64d"}

const TEMPO_NAMEN := {schnell = "schnell", normal = "normal", schwer = "schwer"}
## So viel Tempo gibt oder kostet das Waffen-Tempo
const TEMPO_WERT := {schnell = 2, normal = 0, schwer = -2}

## Bonus-Werte, die ein Teil haben kann
const BONUS_NAMEN := {angriff = "Angriff", zauberkraft = "Zauberkraft", leben = "Leben", mana = "Mana", tempo = "Tempo", verteidigung = "Verteidigung", widerstand = "Widerstand"}
## Verteidigung und Widerstand: Schaden mal (GRUNDSCHUTZ + Startwert) / (GRUNDSCHUTZ + eigener Wert)
const GRUNDSCHUTZ := 50.0


## Werte eines Gegenstands ({} = keine Ausrüstung).
static func teil(id: String) -> Dictionary:
	return GameData.item(id).get("ausruestung", {}) if id != "" else {}


static func ist_ausruestung(id: String) -> bool:
	return not teil(id).is_empty()


## Auf welchen Platz ein Teil kommt. Schmuck geht auf den ersten freien Schmuckplatz (sonst den ersten).
static func platz_fuer(id: String, angelegt: Dictionary) -> String:
	var platz := str(teil(id).get("platz", ""))
	if platz == "schmuck":
		return "schmuck2" if str(angelegt.get("schmuck1", "")) != "" and str(angelegt.get("schmuck2", "")) == "" else "schmuck1"
	return platz if platz in PLAETZE else ""


## Summe aller angelegten Teile: {waffenkraft, verteidigung, widerstand, waffen_tempo, boni = {angriff, leben, …}}.
static func summe(angelegt: Dictionary) -> Dictionary:
	var ergebnis := {waffenkraft = 0, zauberkraft = 0, verteidigung = 0, widerstand = 0, waffen_tempo = "normal", boni = {}}
	for platz: String in PLAETZE:
		var t := teil(str(angelegt.get(platz, "")))
		if t.is_empty():
			continue
		ergebnis.waffenkraft += int(t.get("waffenkraft", 0))
		# Waffen der Zauberklassen (Instrumente, Stäbe) geben Zauberkraft statt Waffenkraft (A23b, Marco 11.11.)
		ergebnis.zauberkraft += int(t.get("zauberkraft", 0))
		ergebnis.verteidigung += int(t.get("verteidigung", 0))
		ergebnis.widerstand += int(t.get("widerstand", 0))
		if platz == "waffe":
			ergebnis.waffen_tempo = str(t.get("tempo", "normal"))
		var boni: Dictionary = t.get("boni", {})
		for wert: String in boni:
			ergebnis.boni[wert] = int(ergebnis.boni.get(wert, 0)) + int(boni[wert])
	ergebnis.zauberkraft += int(ergebnis.boni.get("zauberkraft", 0))
	ergebnis.verteidigung += int(ergebnis.boni.get("verteidigung", 0))
	ergebnis.widerstand += int(ergebnis.boni.get("widerstand", 0))
	return ergebnis


## Was die Ausrüstung im Kampf bewirkt (für BattleState, Teil des Helden-Aufbaus „ausruestung“):
## {macht = Faktor für Schaden und Heilung, schutz = Faktor auf Nah- und Fernkampf-Schaden, magieschutz = Faktor auf
## Magie-Schaden, tempo, leben, mana = was dazukommt}. Mit der Grundausrüstung ist alles neutral (1.0 und 0).
## karten_boni: Besitzeffekte der Karten im Album (D16, KartenAlbum.boni), sie zählen wie Bonus-Werte der Ausrüstung.
static func kampfwerte(angelegt: Dictionary, karten_boni: Dictionary = {}) -> Dictionary:
	var s := summe(angelegt)
	var start := summe(START)
	var basis := Grundwerte.BASE_ATTACK
	var boni: Dictionary = s.boni.duplicate()
	for wert: String in karten_boni:
		boni[wert] = int(boni.get(wert, 0)) + int(karten_boni[wert])
	return {
		# Waffen- und Zauberkraft zählen gleich: Jede Klasse trägt nur Waffen, die ihr eine davon geben
		macht = (basis + s.waffenkraft + s.zauberkraft + int(boni.get("angriff", 0))) / (basis + start.waffenkraft + start.zauberkraft),
		schutz = (GRUNDSCHUTZ + start.verteidigung) / (GRUNDSCHUTZ + s.verteidigung),
		magieschutz = (GRUNDSCHUTZ + start.widerstand) / (GRUNDSCHUTZ + s.widerstand),
		tempo = int(TEMPO_WERT.get(s.waffen_tempo, 0)) + int(boni.get("tempo", 0)),
		leben = int(boni.get("leben", 0)),
		mana = int(boni.get("mana", 0)),
	}


## Name in der Farbe der Seltenheit (BBCode).
static func name_farbig(id: String) -> String:
	var t := teil(id)
	var farbe: String = SELTENHEIT_FARBEN.get(str(t.get("seltenheit", "gewoehnlich")), "e8e8e8")
	return "[color=#%s]%s[/color]" % [farbe, GameData.item(id).get("name", id)]


## Die Werte eines Teils als kurze Zeilen, z. B. „Waffenkraft 10 · Tempo: normal“.
static func werte_text(id: String) -> String:
	var t := teil(id)
	if t.is_empty():
		return ""
	var teile: PackedStringArray = []
	teile.append(SELTENHEIT_NAMEN.get(str(t.get("seltenheit", "gewoehnlich")), ""))
	if t.has("waffenkraft"):
		teile.append("Waffenkraft %d" % int(t.waffenkraft))
	if t.has("zauberkraft"):
		teile.append("Zauberkraft %d" % int(t.zauberkraft))
	if t.has("verteidigung"):
		teile.append("Verteidigung %d" % int(t.verteidigung))
	if t.has("widerstand"):
		teile.append("Widerstand %d" % int(t.widerstand))
	if str(t.get("platz", "")) == "waffe":
		teile.append("Tempo: %s" % TEMPO_NAMEN.get(str(t.get("tempo", "normal")), "normal"))
	var boni: Dictionary = t.get("boni", {})
	for wert: String in boni:
		teile.append("%s %+d" % [BONUS_NAMEN.get(wert, wert), int(boni[wert])])
	if t.has("sonderwert"):
		teile.append("Sonderwert: %s" % str(t.sonderwert))
	return " · ".join(teile)


## Vergleich mit dem, was gerade auf dem Platz liegt: grüne Pfeile = besser, rote = schlechter.
## Gibt BBCode zurück, z. B. „▲ Waffenkraft +4 · ▼ Tempo: schwer“. Leer, wenn es nichts zu vergleichen gibt.
static func vergleich(id: String, angelegt: Dictionary) -> String:
	var platz := platz_fuer(id, angelegt)
	if platz == "":
		return ""
	var neu := angelegt.duplicate()
	neu[platz] = id
	var vorher := summe(angelegt)
	var nachher := summe(neu)
	var teile: PackedStringArray = []
	for wert: String in ["waffenkraft", "zauberkraft", "verteidigung", "widerstand"]:
		_pfeil(teile, wert.capitalize(), int(nachher[wert]) - int(vorher[wert]))
	for wert: String in ["angriff", "leben", "mana"]:
		_pfeil(teile, BONUS_NAMEN[wert], int(nachher.boni.get(wert, 0)) - int(vorher.boni.get(wert, 0)))
	var tempo_vorher := int(TEMPO_WERT.get(vorher.waffen_tempo, 0)) + int(vorher.boni.get("tempo", 0))
	var tempo_nachher := int(TEMPO_WERT.get(nachher.waffen_tempo, 0)) + int(nachher.boni.get("tempo", 0))
	_pfeil(teile, "Tempo", tempo_nachher - tempo_vorher)
	if teile.is_empty():
		return "[color=#a0a0a0]= gleich gut wie %s[/color]" % GameData.item(str(angelegt.get(platz, ""))).get("name", "nichts")
	return " · ".join(teile)


static func _pfeil(teile: PackedStringArray, name: String, unterschied: int) -> void:
	if unterschied > 0:
		teile.append("[color=#6dff8a]▲ %s +%d[/color]" % [name, unterschied])
	elif unterschied < 0:
		teile.append("[color=#ff7070]▼ %s %d[/color]" % [name, unterschied])
