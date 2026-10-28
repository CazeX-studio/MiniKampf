class_name Geld
extends RefCounted
## Geld (Projekt 3): wird als eine einzige Zahl in Bronze gespeichert (Progress.gold)
## und als Bronze, Silber und Gold angezeigt. 100 Bronze = 1 Silber, 100 Silber = 1 Gold.
## Die Münznamen stehen nur in data/texte.json ("muenzen"), damit man sie leicht umbenennen kann.

## Wie viele der kleineren Münze eine größere ergeben
const STUFE := 100


## Münznamen von klein nach groß, z. B. ["Bronze", "Silber", "Gold"].
static func names() -> Array:
	return GameData.get_file("texte").get("muenzen", ["Bronze", "Silber", "Gold"])


## Betrag in Münzen zerlegt, von groß nach klein: [Gold, Silber, Bronze].
static func split(amount: int) -> Array[int]:
	var value := absi(amount)
	return [value / (STUFE * STUFE), (value / STUFE) % STUFE, value % STUFE]


## Betrag als Text, z. B. 12345 -> „1 Gold 23 Silber 45 Bronze“. Leere Münzen fallen weg, 0 -> „0 Bronze“.
static func text(amount: int) -> String:
	var coins := split(amount)
	var coin_names := names()
	var parts: PackedStringArray = []
	for i in coins.size():
		if coins[i] > 0:
			parts.append("%d %s" % [coins[i], coin_names[coin_names.size() - 1 - i]])
	if parts.is_empty():
		parts.append("0 %s" % coin_names[0])
	return ("−" if amount < 0 else "") + " ".join(parts)


## Münzbilder (assets/gegenstaende/muenze_gold, _silber, _bronze), von groß nach klein wie split().
const MUENZ_BILDER := ["muenze_gold", "muenze_silber", "muenze_bronze"]


## Wie text(), aber mit gemalten Münzen statt Münznamen für RichTextLabel, z. B. „1 [Gold] 23 [Silber] 45 [Bronze]“.
static func bbcode_muenzen(amount: int, groesse := 20) -> String:
	var coins := split(amount)
	var parts: PackedStringArray = []
	for i in coins.size():
		if coins[i] > 0 or (i == coins.size() - 1 and parts.is_empty()):
			parts.append("%d [img=%d]res://assets/gegenstaende/%s.png[/img]" % [coins[i], groesse, MUENZ_BILDER[i]])
	return ("−" if amount < 0 else "") + "  ".join(parts)


## Wie text(), aber mit Münzfarben für RichTextLabel (Gold gelb, Silber hellgrau, Bronze kupfer).
static func bbcode(amount: int) -> String:
	const FARBEN := ["f2c14e", "c8ced6", "d08a4e"]
	var coins := split(amount)
	var coin_names := names()
	var parts: PackedStringArray = []
	for i in coins.size():
		if coins[i] > 0 or (i == coins.size() - 1 and parts.is_empty()):
			parts.append("[color=#%s]%d %s[/color]" % [FARBEN[i], coins[i], coin_names[coin_names.size() - 1 - i]])
	return " ".join(parts)
