class_name KartenSpiel
extends RefCounted
## Regeln von „Kreuzweg-Karten“ (design.md, angelehnt an Triple Triad) – ohne Grafik.
## 3×3-Feld, jeder hat 5 Karten mit vier Zahlen (oben, rechts, unten, links). Wer eine Karte legt, vergleicht jede Seite
## mit der angrenzenden gegnerischen Karte: Ist die eigene Zahl höher, gehört die Nachbarkarte jetzt ihm.
## Wer am Ende mehr Karten hat (auf dem Feld und noch auf der Hand), gewinnt. Wer anfängt, wird ausgelost.
## Karten und Gegner stehen in data/kartenspiel.json.

const SPIELER := 0
const GEGNER := 1
## Nachbarn eines Feldes: [Richtung, Seite der eigenen Karte, Seite der Nachbarkarte] (0 oben, 1 rechts, 2 unten, 3 links)
const NEIGHBORS := [[Vector2i(0, -1), 0, 2], [Vector2i(1, 0), 1, 3], [Vector2i(0, 1), 2, 0], [Vector2i(-1, 0), 3, 1]]

## Feld 0–8 (Reihe für Reihe): {karte, besitzer} oder leer
var board: Array[Dictionary] = []
## Hände: [Spieler-Karten, Gegner-Karten] (Kennungen)
var hands: Array = [[], []]
## Wer gerade dran ist
var turn := SPIELER
## Zuletzt umgedrehte Felder (für die Anzeige)
var last_flips: Array[int] = []


func _init(player_cards: Array, opponent_cards: Array, first := SPIELER) -> void:
	for i in 9:
		board.append({})
	hands = [player_cards.duplicate(), opponent_cards.duplicate()]
	turn = first


static func card(id: String) -> Dictionary:
	return GameData.get_file("kartenspiel").get("karten", {}).get(id, {name = id, werte = [1, 1, 1, 1]})


static func values(id: String) -> Array:
	return card(id).get("werte", [1, 1, 1, 1])


func is_free(cell: int) -> bool:
	return cell >= 0 and cell < 9 and board[cell].is_empty()


func finished() -> bool:
	for c in board:
		if c.is_empty():
			return false
	return true


## Eine Karte von der Hand auf ein freies Feld legen. Gibt false zurück, wenn das nicht geht.
func place(who: int, hand_index: int, cell: int) -> bool:
	if who != turn or not is_free(cell) or hand_index < 0 or hand_index >= hands[who].size():
		return false
	var id: String = hands[who][hand_index]
	hands[who].remove_at(hand_index)
	board[cell] = {karte = id, besitzer = who}
	last_flips = flips_for(id, cell, who)
	for f in last_flips:
		board[f].besitzer = who
	turn = 1 - who
	return true


## Welche Felder eine Karte an dieser Stelle umdrehen würde.
func flips_for(id: String, cell: int, who: int) -> Array[int]:
	var result: Array[int] = []
	var mine := values(id)
	var pos := Vector2i(cell % 3, cell / 3)
	for n: Array in NEIGHBORS:
		var other: Vector2i = pos + n[0]
		if other.x < 0 or other.y < 0 or other.x > 2 or other.y > 2:
			continue
		var index := other.y * 3 + other.x
		var neighbor: Dictionary = board[index]
		if neighbor.is_empty() or neighbor.besitzer == who:
			continue
		if int(mine[n[1]]) > int(values(neighbor.karte)[n[2]]):
			result.append(index)
	return result


## Punkte: Karten auf dem Feld plus Karten auf der Hand.
func score(who: int) -> int:
	var points: int = hands[who].size()
	for c in board:
		if not c.is_empty() and c.besitzer == who:
			points += 1
	return points


## Zug des Computers (für den Gegner, in Tests auch für den Spieler): "schlau" nimmt den Zug mit den meisten umgedrehten Karten (bei Gleichstand die schwächste
## Karte, damit starke für später bleiben), "zufall" legt irgendwas (Marv).
func computer_move(style: String, rng: RandomNumberGenerator, who := GEGNER) -> Vector2i:
	var free: Array[int] = []
	for i in 9:
		if is_free(i):
			free.append(i)
	if style == "zufall":
		return Vector2i(rng.randi() % hands[who].size(), free[rng.randi() % free.size()])
	var best := Vector2i(0, free[0])
	var best_score := -INF
	for h in hands[who].size():
		var id: String = hands[who][h]
		var strength := 0
		for v in values(id):
			strength += int(v)
		for cell in free:
			# Viele umdrehen ist gut, starke Karten aufheben auch ein bisschen, Ecken sind sicherer
			var corner := 0.5 if cell in [0, 2, 6, 8] else 0.0
			var points := flips_for(id, cell, who).size() * 10.0 - strength * 0.2 + corner + rng.randf() * 0.1
			if points > best_score:
				best_score = points
				best = Vector2i(h, cell)
	return best


## Die stärksten Karten einer Sammlung (Kennung -> Anzahl), höchstens count Stück.
static func best_deck(collection: Dictionary, count := 5) -> Array:
	var all: Array = []
	for id: String in collection:
		for i in int(collection[id]):
			all.append(id)
	all.sort_custom(func(a: String, b: String) -> bool:
		var sa := 0
		var sb := 0
		for v in values(a):
			sa += int(v)
		for v in values(b):
			sb += int(v)
		return sa > sb)
	return all.slice(0, count)
