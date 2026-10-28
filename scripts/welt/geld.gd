class_name Geld
extends RefCounted
## Geld wird als eine einzige Zahl gespeichert (in Bronze) und als Bronze, Silber und Gold angezeigt.
## Münznamen und Umrechnung stehen nur hier.

## Münzen von klein nach groß
const MUENZEN: Array[String] = ["Bronze", "Silber", "Gold"]
## So viele einer Münze ergeben die nächstgrößere (100 Bronze = 1 Silber, 100 Silber = 1 Gold)
const STUFE := 100


## Betrag in Münzen zerlegt: [Gold, Silber, Bronze] (größte zuerst).
static func zerlegen(betrag: int) -> Array[int]:
	var rest := absi(betrag)
	var teile: Array[int] = []
	for i in MUENZEN.size():
		if i == MUENZEN.size() - 1:
			teile.push_front(rest)
		else:
			teile.push_front(rest % STUFE)
			rest /= STUFE
	return teile


## Lesbarer Betrag, z. B. 12345 → „1 Gold 23 Silber 45 Bronze“. Münzen mit 0 fallen weg, 0 → „0 Bronze“.
static func text(betrag: int) -> String:
	var teile := zerlegen(betrag)
	var woerter: PackedStringArray = []
	for i in teile.size():
		if teile[i] > 0:
			woerter.append("%d %s" % [teile[i], MUENZEN[MUENZEN.size() - 1 - i]])
	if woerter.is_empty():
		return "0 %s" % MUENZEN[0]
	return ("−" if betrag < 0 else "") + " ".join(woerter)
