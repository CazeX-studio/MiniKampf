extends SceneTree
## A23: Zahlen in den Fähigkeiten-Beschreibungen (fertiger Wert, Farbe nach dem, womit sie wachsen, Einzelheiten).

var _failed := 0


func _initialize() -> void:
	var held := Fighter.new("Du", "blade", "Klingentänzerin", true, 100, 12, Color.WHITE)
	held.set_meta("stufe", 10)
	held.set_meta("faktor_stufe", 1.5)
	held.set_meta("faktor_kraft", 1.2)
	var ab := {id = "step", name = "Klingenschritt"}
	var text := FaehigkeitZahlen.text(held, ab, "9 Nahkampf, jede Klinge trifft nach (je 2), +1 Klinge · 8 Mana", 1)
	# 9 × 1,5 × 1,2 = 16,2 → 16; 2 × 1,8 = 3,6 → 4; „+1 Klinge“ und „8 Mana“ bleiben
	_check(text.contains("[color=#ff9a4c]16[/color] Nahkampf"), "Schaden fertig und orange (Waffenkraft): " + text)
	_check(text.contains("(je [color=#ff9a4c]4[/color])"), "Einzeltreffer wachsen mit: " + text)
	_check(text.contains("+1 Klinge") and text.contains("8 Mana"), "Feste Werte bleiben weiß: " + text)
	var details := FaehigkeitZahlen.text(held, ab, "9 Nahkampf", 3, true)
	_check(details.contains("(9 = 100 % vom Angriff · Stufe 10 +50 % · Waffenkraft +20 % · Fähigkeitsstufe 3 +20 %)"), "Einzelheiten mit Prozenten: " + details)
	# Zauberklasse: blau-violett, Heilung wächst mit
	var saengerin := Fighter.new("Du", "singer", "Sternensängerin", true, 100, 10, Color.WHITE)
	var heil := FaehigkeitZahlen.text(saengerin, {id = "x"}, "14 Licht, heilt 10 LP, Schild 20", 1)
	_check(heil.contains("[color=#a99bff]14[/color] Licht"), "Zauberkraft blau-violett: " + heil)
	# Schilde wachsen seit 13.11. mit (Marco: Werte sollen nicht fest sein)
	_check(heil.contains("Schild [color=#a99bff]20[/color]"), "Schild wächst mit der Zauberkraft: " + heil)
	# Tempo: Schnellfeuer wächst mit dem Tempo über dem Grundtempo der Klasse
	var bogen := Fighter.new("Du", "archer", "Bogenschütze", true, 100, int(Sandbox.CLASSES.archer.tempo) + 5, Color.WHITE)
	_check(is_equal_approx(FaehigkeitZahlen.tempo_faktor(bogen), 1.2), "5 Tempo mehr: 20 % mehr")
	var schnell := FaehigkeitZahlen.text(bogen, {id = "rapid"}, "3 schnelle Pfeile à 5 auf ein Ziel · 12 Mana", 1)
	_check(schnell.contains("à [color=#5fe0d0]6[/color]") and schnell.contains("3 schnelle"), "Tempo türkis, Anzahl fest: " + schnell)
	# Novize: wächst nur mit der Stufe
	var novize := Fighter.new("Du", "novize", "Novize", true, 100, 10, Color.WHITE)
	_check(FaehigkeitZahlen.text(novize, {id = "hieb"}, "8 Nahkampf", 1).contains("[color=#f2c14e]8[/color]"), "Novize gold (Stufe)")
	# Ausrüstung: Zauberkraft zählt wie Waffenkraft
	_check(Ausruestung.BONUS_NAMEN.has("zauberkraft"), "Bonus-Wert Zauberkraft")
	print("Fähigkeiten-Zahlen: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(1 if _failed > 0 else 0)


func _check(condition: bool, text: String) -> void:
	if not condition:
		_failed += 1
		print("FEHLER: " + text)
