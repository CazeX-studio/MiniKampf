class_name Grundwerte
extends RefCounted
## Grundwerte des Novizen (Leben, Mana, Angriff, Tempo) je nach Stufe, aus data/stufen.json.
## Kampf und Werte-Fenster in der Stadt rechnen beide hiermit, damit überall dieselben Zahlen stehen.

const NAMES := {leben = "Leben", mana = "Mana", angriff = "Angriff", tempo = "Tempo"}
## Angriff, bei dem Schaden und Heilung genau den Grundwert haben
const BASE_ATTACK := 20.0


## Alle Grundwerte auf einer Stufe.
static func for_level(level: int) -> Dictionary:
	var data := GameData.get_file("stufen")
	var base: Dictionary = data.get("grundwerte", {leben = 45, mana = 30, angriff = 20, tempo = 11})
	var growth: Dictionary = data.get("pro_stufe", {})
	var result := {}
	for key: String in NAMES:
		result[key] = int(base.get(key, 0)) + int(growth.get(key, 0)) * maxi(level - 1, 0)
	return result


## Was mit jeder neuen Stufe dazukommt.
static func growth() -> Dictionary:
	return GameData.get_file("stufen").get("pro_stufe", {})


## Faktor für Schaden und Heilung (1.0 auf Stufe 1).
static func power(level: int) -> float:
	return float(for_level(level).angriff) / BASE_ATTACK


## Text wie „Leben +7 · Mana +3 · Angriff +1“ (für Stufenaufstieg und Werte-Fenster).
static func growth_text() -> String:
	var parts: PackedStringArray = []
	var g := growth()
	for key: String in NAMES:
		if int(g.get(key, 0)) > 0:
			parts.append("%s +%d" % [NAMES[key], int(g[key])])
	return " · ".join(parts)
