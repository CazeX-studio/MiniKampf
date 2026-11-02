class_name Effekte
extends RefCounted
## Effekt-Liste als feste Bausteine (Projekt 14, K.4, Beschluss 29.10.): Klassen und Monster benutzen dieselben
## Bausteine, jeder Effekt sieht gleich aus, egal wer ihn auslöst (gleiche Farbe, gleicher Text, gleiches Zeichen
## in der Zustandszeile). Eigene Animationen bekommt jede Fähigkeit trotzdem (K.6).
##
## Anwenden: Effekte.anwenden(kampf, quelle, ziel, "brennen", staerke, zuege). Dauer-Effekte stehen im Kämpfer unter
## Fighter.effekte (Kennung -> {zuege, staerke, stapel, quelle}) und wirken zu Beginn seines Zuges (zug_beginn).
## Monster können einen Effekt an einen Angriff hängen: in Sandbox.ENEMIES unter attacks[...].effekt = {art, staerke, zuege}.

const ARTEN := {
	brennen = {name = "Brennen", farbe = "ff7a3d", kurz = "Brennt", info = "Feuer-Schaden zu Beginn jedes Zuges", staerke = 5, zuege = 3},
	gift = {name = "Gift", farbe = "9ad94a", kurz = "Gift", info = "Schaden zu Beginn jedes Zuges, stapelt bis 3", staerke = 3, zuege = 4, max_stapel = 3},
	laehmen = {name = "Lähmen", farbe = "ffe14d", kurz = "Gelähmt", info = "Setzt den nächsten Zug aus", staerke = 0, zuege = 1},
	festhalten = {name = "Festhalten", farbe = "c8a070", kurz = "Festgehalten", info = "Kann die Reihe nicht wechseln und nicht abwarten", staerke = 0, zuege = 2},
	verfehlen = {name = "Verfehlen", farbe = "d8d8e8", kurz = "Verfehlt bald", info = "Der nächste Angriff verfehlt", staerke = 0, zuege = 3},
	zugleiste = {name = "Zugleiste schieben", farbe = "7ac8ff", kurz = "", info = "Schiebt auf der Zugleiste zurück (positiv) oder nach vorne (negativ)", staerke = 0.5, zuege = 0},
	heilen = {name = "Heilen", farbe = "6dff8a", kurz = "", info = "Heilt sofort", staerke = 20, zuege = 0},
	schutz = {name = "Schutz", farbe = "8fd3ff", kurz = "", info = "Schild, der Schaden abfängt", staerke = 20, zuege = 0},
	schattenmale = {name = "Schattenmale", farbe = "8a6ad9", kurz = "Male", info = "Je Mal Schaden zu Beginn jedes Zuges, höchstens 5 Male", staerke = 2, zuege = 3, max_stapel = 5},
}


## Einen Effekt anwenden. staerke und zuege < 0 = Grundwerte aus ARTEN.
static func anwenden(c: BattleState, quelle: Fighter, ziel: Fighter, art: String, staerke: float = -1.0, zuege: int = -1) -> void:
	if not ARTEN.has(art) or ziel == null or not ziel.is_alive():
		return
	var d: Dictionary = ARTEN[art]
	var wert: float = float(d.staerke) if staerke < 0.0 else staerke
	var dauer: int = int(d.zuege) if zuege < 0 else zuege
	var farbe := Color(d.farbe)
	c.emit_effect(ziel, art, farbe)
	match art:
		"heilen":
			c.heal(quelle, ziel, roundi(wert))
			return
		"schutz":
			ziel.add_shield(quelle if quelle != null else ziel, roundi(wert))
			c.float_text(ziel, "Schutz +%d" % roundi(wert), farbe)
			c.refresh()
			return
		"zugleiste":
			if wert >= 0.0:
				c.delay(ziel, wert)
				c.float_text(ziel, "Zurückgeschoben", farbe)
			else:
				c.hasten(ziel, -wert)
				c.float_text(ziel, "Nach vorne", farbe)
			c.refresh()
			return
	var alt: Dictionary = ziel.effekte.get(art, {})
	var stapel := 1
	if d.has("max_stapel"):
		stapel = mini(int(alt.get("stapel", 0)) + 1, int(d.max_stapel))
	ziel.effekte[art] = {zuege = maxi(dauer, int(alt.get("zuege", 0))), staerke = wert, stapel = stapel, quelle = quelle}
	var text: String = d.name if stapel <= 1 else "%s ×%d" % [d.name, stapel]
	c.float_text(ziel, text, farbe)
	c.add_log("[color=#%s]%s[/color]: %s" % [d.farbe, text, ziel.display_name])
	c.refresh()


## Zu Beginn des Zuges: Brennen, Gift und Schattenmale wirken, die Zeit läuft ab.
## Gibt true zurück, wenn der Kämpfer gelähmt ist und diesen Zug aussetzt.
static func zug_beginn(c: BattleState, f: Fighter) -> bool:
	var gelaehmt := false
	for art: String in f.effekte.keys():
		var e: Dictionary = f.effekte[art]
		var d: Dictionary = ARTEN[art]
		match art:
			"brennen", "gift", "schattenmale":
				var schaden := roundi(float(e.staerke) * int(e.stapel))
				if schaden > 0 and f.is_alive():
					c.emit_effect(f, art, Color(d.farbe))
					c.apply_damage(f, schaden, e.quelle as Fighter, "effekt")
			"laehmen":
				gelaehmt = true
				c.float_text(f, "Gelähmt!", Color(d.farbe))
		# verfehlen läuft erst ab, wenn ein Angriff wirklich verfehlt hat (siehe verfehlt), sonst nach Zeit
		e.zuege = int(e.zuege) - 1
		if int(e.zuege) <= 0:
			f.effekte.erase(art)
	return gelaehmt


## Hat der Angreifer „Verfehlen“? Dann verfehlt dieser Angriff, und der Effekt ist verbraucht.
static func verfehlt(c: BattleState, angreifer: Fighter) -> bool:
	if angreifer == null or not angreifer.effekte.has("verfehlen"):
		return false
	angreifer.effekte.erase("verfehlen")
	return true


static func hat(f: Fighter, art: String) -> bool:
	return f.effekte.has(art)


## Kurze Texte für die Zustandszeile unter der Figur (immer dieselben, egal wer den Effekt ausgelöst hat).
static func zustaende(f: Fighter) -> Array[String]:
	var liste: Array[String] = []
	for art: String in f.effekte:
		var e: Dictionary = f.effekte[art]
		var kurz: String = ARTEN[art].kurz
		if kurz != "":
			liste.append(kurz if int(e.stapel) <= 1 else "%s %d" % [kurz, int(e.stapel)])
	return liste
