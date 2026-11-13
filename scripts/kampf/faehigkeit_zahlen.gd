class_name FaehigkeitZahlen
extends RefCounted
## Zahlen in den Fähigkeiten-Beschreibungen (A23, design.md „Zahlen in den Fähigkeiten-Beschreibungen“, Marco 11.11.):
## Jede Zahl, die wächst, steht als fertiger Wert da (mit Stufe, Ausrüstung und Fähigkeitsstufe) und hat die Farbe
## dessen, womit sie wächst: Waffenkraft orange, Zauberkraft blau-violett, Tempo türkis, Stufe gold. Feste Werte
## (Mana, Runden, Anzahl) bleiben weiß; Schilde wachsen seit 13.11. mit (Marco). Mit Einzelheiten (Taste D, am Handy beim Gedrückthalten) steht dahinter
## der Grundwert und um wie viel Prozent ihn jede Sache erhöht.

const FARBEN := {waffe = "ff9a4c", zauber = "a99bff", tempo = "5fe0d0", stufe = "f2c14e"}
const NAMEN := {waffe = "Waffenkraft", zauber = "Zauberkraft", tempo = "Tempo", stufe = "Stufe"}
## Klassen, deren Waffe Zauberkraft gibt (A23b: Instrumente, Stäbe, Runen)
const ZAUBER_KLASSEN: Array[String] = ["singer", "tank", "ritualist", "twilight"]
## Fähigkeiten aus vielen kleinen Treffern: Sie wachsen mit dem Tempo (A23b)
const TEMPO_FAEHIGKEITEN: Array[String] = ["rapid", "sturmschritte"]
## Je Tempo-Punkt über dem Grundtempo der Klasse so viel mehr Schaden (höchstens / mindestens)
const TEMPO_JE_PUNKT := 0.04
const TEMPO_MIN := 0.8
const TEMPO_MAX := 1.4
## Zahlen, die wachsen: Schilde (seit 13.11.), Schaden (vor Nahkampf, Fernkampf, Magie, Element, „an alle“), „à“/„je“ (Einzeltreffer), Heilung (LP)
const MUSTER := "(?<=à |je |[Hh]eilt |Stabschlag |Schild )(\\d+)(?!\\d)(?! Mana| Härte| Klinge| Runde| Zug| Angriff)|(\\d+)(?= (?:Nahkampf|Fernkampf|Magie|Schaden|an alle|LP|Licht|Feuer|Wasser|Erde|Wind|Blitz|Pflanze|Schatten|Sternenkraft))"

static var _regex: RegEx


## Womit die Zahlen dieser Fähigkeit wachsen: "waffe", "zauber", "tempo" oder "stufe".
static func art(f: Fighter, ab: Dictionary) -> String:
	if f.klass == "novize" or ab.get("novize", false):
		return "stufe"
	if str(ab.get("id", "")) in TEMPO_FAEHIGKEITEN:
		return "tempo"
	return "zauber" if f.klass in ZAUBER_KLASSEN else "waffe"


## Tempo-Faktor einer Figur: je Punkt über dem Grundtempo ihrer Klasse etwas mehr (Waffen-Tempo, Bonus-Werte).
static func tempo_faktor(f: Fighter) -> float:
	var grund := int(Sandbox.CLASSES.get(f.klass, {}).get("tempo", f.tempo))
	return clampf(1.0 + TEMPO_JE_PUNKT * (f.tempo - grund), TEMPO_MIN, TEMPO_MAX)


## Die einzelnen Erhöhungen als [Name, Faktor] (Faktor 1.0 = nichts).
static func faktoren(f: Fighter, ab: Dictionary, stufen_bonus: float, faehigkeit_stufe: int) -> Array[Array]:
	var liste: Array[Array] = []
	var welche := art(f, ab)
	liste.append(["Stufe %d" % int(f.get_meta("stufe", 1)), float(f.get_meta("faktor_stufe", 1.0))])
	liste.append([NAMEN.zauber if welche == "zauber" else NAMEN.waffe, float(f.get_meta("faktor_kraft", 1.0))])
	if welche == "tempo":
		liste.append(["Tempo %d" % f.tempo, tempo_faktor(f)])
	liste.append(["Fähigkeitsstufe %d" % faehigkeit_stufe, 1.0 + stufen_bonus * maxi(faehigkeit_stufe - 1, 0)])
	var abstand := float(f.get_meta("faktor_abstand", 1.0))
	if not is_equal_approx(abstand, 1.0):
		liste.append(["Stufenabstand zu den Gegnern", abstand])
	return liste


## Beschreibung mit farbigen, fertigen Werten (BBCode). details: Grundwert und Prozente dahinter.
static func text(f: Fighter, ab: Dictionary, info: String, faehigkeit_stufe: int, details := false) -> String:
	if _regex == null:
		_regex = RegEx.new()
		_regex.compile(MUSTER)
	var welche := art(f, ab)
	var liste := faktoren(f, ab, Faehigkeiten.stufen_bonus(), faehigkeit_stufe)
	var gesamt := 1.0
	for eintrag: Array in liste:
		gesamt *= float(eintrag[1])
	var ergebnis := ""
	var ende := 0
	for treffer: RegExMatch in _regex.search_all(info):
		var gruppe := 1 if treffer.get_string(1) != "" else 2
		var anfang := treffer.get_start(gruppe)
		var grundwert := int(treffer.get_string(gruppe))
		var farbe: String = FARBEN[welche]
		# Magie und Licht/Schatten eines Kämpfers wachsen trotzdem mit seiner Kraft; nur die Farbe der Klasse zählt
		ergebnis += info.substr(ende, anfang - ende)
		ergebnis += "[color=#%s]%d[/color]" % [farbe, maxi(1, roundi(grundwert * gesamt))]
		if details:
			ergebnis += " [color=#9a9384](%d%s)[/color]" % [grundwert, _prozente(liste)]
		ende = treffer.get_end(gruppe)
	ergebnis += info.substr(ende)
	return ergebnis


## Die Prozente als Text, z. B. „ · Stufe 12 +60 % · Waffenkraft +10 %“ (nur, was etwas ausmacht).
static func _prozente(liste: Array[Array]) -> String:
	var teile := ""
	for eintrag: Array in liste:
		var prozent := roundi((float(eintrag[1]) - 1.0) * 100.0)
		if prozent != 0:
			teile += " · %s %s%d %%" % [eintrag[0], "+" if prozent > 0 else "−", absi(prozent)]
	return teile


## Kurze Erklärung der Farben (unter den Einzelheiten).
static func legende() -> String:
	var teile: PackedStringArray = []
	for welche: String in ["waffe", "zauber", "tempo", "stufe"]:
		teile.append("[color=#%s]%s[/color]" % [FARBEN[welche], NAMEN[welche]])
	teile.append("fest: weiß")
	return " · ".join(teile)
