class_name Hoehen
extends RefCounted
## Ebenen einer Karte (E3h3b, Glutoase am Berg): Jede Zeile der Karte liegt auf einer Stufe (0 = unten), Rampen
## (Treppen) steigen gleichmäßig an. Nur fürs Zeichnen: Laufen und Sperren bleiben wie im Raster.
## Daten in data/karten.json, z. B.
##   "hoehen": {"stufe": 48, "zeilen": [[0, 10, 2], [11, 26, 1], [27, 45, 0]],
##              "rampen": [{"feld": [22, 26, 2, 2], "oben": 1, "unten": 0}]}
## zeilen: [erste Zeile, letzte Zeile, Stufe]; rampen: Fläche [x, y, Breite, Tiefe], hinten (kleines y) „oben“,
## vorne „unten“. stufe: Höhe einer Stufe in Bildpunkten.

const TILE_W := 64.0
const TILE_H := 32.0

var stufe := 48.0
var _zeilen: Array = []
var _rampen: Array[Dictionary] = []
var hoechste := 0


static func aus_daten(d: Variant) -> Hoehen:
	if not d is Dictionary or (d as Dictionary).is_empty():
		return null
	var h := Hoehen.new()
	h.stufe = float(d.get("stufe", 48))
	for z: Array in d.get("zeilen", []):
		h._zeilen.append([int(z[0]), int(z[1]), int(z[2])])
		h.hoechste = maxi(h.hoechste, int(z[2]))
	for r: Dictionary in d.get("rampen", []):
		h._rampen.append({feld = Rect2i(int(r.feld[0]), int(r.feld[1]), int(r.feld[2]), int(r.feld[3])),
				oben = float(r.oben), unten = float(r.unten)})
	return h


## Stufe eines Feldes (auf einer Rampe die untere)
func stufe_feld(c: Vector2i) -> int:
	for r in _rampen:
		if (r.feld as Rect2i).has_point(c):
			return int(r.unten)
	for z: Array in _zeilen:
		if c.y >= z[0] and c.y <= z[1]:
			return z[2]
	return 0


## Höhe in Bildpunkten an einer Stelle in Feldern (Kommazahlen, Mitte eines Feldes = x,5). Auf Rampen gleitend.
func px(pos: Vector2) -> float:
	var c := Vector2i(floori(pos.x), floori(pos.y))
	for r in _rampen:
		var f: Rect2i = r.feld
		if f.has_point(c):
			var anteil := clampf((pos.y - f.position.y) / float(f.size.y), 0.0, 1.0)
			return lerpf(r.oben, r.unten, anteil) * stufe
	return stufe_feld(c) * stufe


## Höhe, auf der ein Baukasten-Teil steht: die Stufe seiner vordersten Zeile (Treppen stehen unten)
func teil_px(rect: Rect2i) -> float:
	return stufe_feld(Vector2i(rect.position.x, rect.end.y - 1)) * stufe


## Feld unter einem Punkt auf dem Bildschirm (Weltkoordinaten): erst auf den oberen Stufen suchen.
func feld_bei(p: Vector2) -> Vector2i:
	for stufe_nr in range(hoechste, 0, -1):
		var c := flach_feld(p + Vector2(0, stufe_nr * stufe))
		if stufe_feld(c) == stufe_nr:
			return c
	return flach_feld(p)


static func flach_feld(p: Vector2) -> Vector2i:
	var x := (p.x / (TILE_W * 0.5) + p.y / (TILE_H * 0.5)) * 0.5
	var y := (p.y / (TILE_H * 0.5) - p.x / (TILE_W * 0.5)) * 0.5
	return Vector2i(floori(x), floori(y))
