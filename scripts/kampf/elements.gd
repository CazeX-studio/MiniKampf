class_name Elements
extends RefCounted
## Element-System aus design.md (Abschnitt 5):
## - Sechs Natur-Elemente im Sechseck: jedes stark gegen zwei, schwach gegen zwei, neutral gegen sein Gegenüber
## - Licht und Schatten: eigenes Paar, gegenseitig stark
## - Sternenkraft: ohne Stärken und Schwächen, ignoriert Resistenzen

const STRONG_MULT := 1.5
const WEAK_MULT := 0.5

const NATURE: Array[String] = ["Feuer", "Erde", "Pflanze", "Blitz", "Wasser", "Wind"]

## Element -> gegen welche Elemente es stark ist
const STRONG := {
	"Feuer": ["Pflanze", "Erde"],
	"Erde": ["Blitz", "Pflanze"],
	"Pflanze": ["Wasser", "Blitz"],
	"Blitz": ["Wasser", "Wind"],
	"Wasser": ["Feuer", "Wind"],
	"Wind": ["Feuer", "Erde"],
}

const COLORS := {
	"Feuer": Color("ff7a3d"),
	"Erde": Color("c99a5b"),
	"Pflanze": Color("6fd36b"),
	"Blitz": Color("ffe14d"),
	"Wasser": Color("4fb3ff"),
	"Wind": Color("b8f0e0"),
	"Licht": Color("fff3b0"),
	"Schatten": Color("b48cff"),
	"Sternenkraft": Color("f0e0ff"),
}


## Schadens-Faktor, wenn "attack" auf "defense" trifft (1,5 / 1 / 0,5).
static func multiplier(attack: String, defense: String) -> float:
	if attack == "" or defense == "" or attack == "Sternenkraft" or defense == "Sternenkraft":
		return 1.0
	var light_dark := ["Licht", "Schatten"]
	if attack in light_dark or defense in light_dark:
		if attack in light_dark and defense in light_dark and attack != defense:
			return STRONG_MULT
		return 1.0
	if defense in STRONG[attack]:
		return STRONG_MULT
	if attack in STRONG[defense]:
		return WEAK_MULT
	return 1.0


## Alle Elemente, die gegen "defense" stark sind.
static func weaknesses(defense: String) -> Array[String]:
	var result: Array[String] = []
	for el: String in COLORS:
		if multiplier(el, defense) > 1.0:
			result.append(el)
	return result


## Das Element aus "options", das gegen "defense" am meisten Schaden macht.
static func best_against(defense: String, options: Array) -> String:
	var best: String = options[0]
	for el: String in options:
		if multiplier(el, defense) > multiplier(best, defense):
			best = el
	return best


static func color(element: String) -> Color:
	return COLORS.get(element, Color(1, 1, 1, 0.6))
