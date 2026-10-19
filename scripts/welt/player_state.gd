class_name PlayerState
extends RefCounted
## Ein Spieler in der Welt – nur Daten, keine Grafik.
## Später kommt derselbe Zustand vom Server, die Anzeige liest ihn nur.

var id: String
var display_name: String
## Welche Pixel-Figur gezeigt wird (Name aus dem 0x72-Paket)
var look: String
## Feld, auf dem der Spieler gerade steht
var cell: Vector2i
## Genaue Position in Feld-Koordinaten (zwischen zwei Feldern beim Laufen)
var pos: Vector2
## Noch zu laufende Felder
var path: Array[Vector2i] = []
## NPC, mit dem gesprochen wird, sobald der Spieler angekommen ist
var talk_target := ""
## Mit welchen NPCs schon gesprochen wurde (für andere Sätze beim zweiten Mal)
var talked := {}
## Blickrichtung auf dem Bildschirm: 1 = rechts, -1 = links
var facing := 1
## Direkte Steuerung (Tasten oder Steuerknopf): Richtung in Feld-Koordinaten, Länge 0 bis 1.
## Solange sie nicht null ist, läuft der Spieler frei statt einen Weg entlang.
var steer := Vector2.ZERO


func _init(p_id: String, p_name: String, p_look: String, p_cell: Vector2i) -> void:
	id = p_id
	display_name = p_name
	look = p_look
	cell = p_cell
	pos = Vector2(p_cell)


func is_moving() -> bool:
	return not path.is_empty()


## Läuft gerade (einen Weg entlang oder frei gesteuert)?
func is_walking() -> bool:
	return is_moving() or steer != Vector2.ZERO
