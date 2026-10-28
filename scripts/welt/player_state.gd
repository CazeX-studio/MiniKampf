class_name PlayerState
extends RefCounted
## Ein Spieler in der Welt – nur Daten, keine Grafik.
## Später kommt derselbe Zustand vom Server, die Anzeige liest ihn nur.

var id: String
var display_name: String
## Welche Figur gezeigt wird: eigene Figur („kofi“), zusammengesetzt aus „Figur erstellen“ („novize_w+mira“)
## oder ein Name aus dem 0x72-Paket
var look: String
## Name aus „Figur erstellen“ (steht über der Figur); "" = display_name zeigen
var figur_name := ""
## Karte, auf der der Spieler gerade steht (Kennung, siehe WorldState.maps)
var map := "kreuzweg"
## Feld, auf dem der Spieler gerade steht
var cell: Vector2i
## Genaue Position in Feld-Koordinaten (zwischen zwei Feldern beim Laufen)
var pos: Vector2
## Noch zu laufende Felder
var path: Array[Vector2i] = []
## Was benutzt wird, sobald der Spieler angekommen ist: "npc:ye" (reden) oder "punkt:2" (Sammelpunkt)
var use_target := ""
## Blickrichtung auf dem Bildschirm: 1 = rechts, -1 = links
var facing := 1
## Direkte Steuerung (Tasten oder Steuerknopf): Richtung in Feld-Koordinaten, Länge 0 bis 1.
## Solange sie nicht null ist, läuft der Spieler frei statt einen Weg entlang.
var steer := Vector2.ZERO
## Beim Zusammenspielen: Der Gastgeber meldet, dass diese Figur gerade läuft (nur Anzeige im Spiegelbild).
## Beim Gastgeber: Der Mitspieler meldet, dass er gerade läuft.
var remote_walking := false
## Beim Gastgeber: Dieser Mitspieler bewegt sich selbst und meldet seinen Platz (er wird nicht mehr zurückgezogen)
var remote_driven := false
## Laufendes Gespräch: {id = Dialog, node = Knoten} oder leer
var dialog := {}
## Nach dem Betreten einer Karte (z. B. zurück aus einem Kampf) greifen Monster so lange nicht an (Sekunden)
var safe_time := 3.0
## Ein NPC, der von sich aus zu diesem Spieler läuft (z. B. Marv): {id, pos (Vector2), path (Felder), facing,
## phase = "hin" (läuft her, der Spieler wartet), "reden" (Gespräch läuft) oder "zurueck" (geht wieder an seinen Platz)}
var npc_walk := {}
## Geöffneter Laden (Kennung aus data/laeden.json) oder ""
var shop := ""
## Gold, Tasche, Erfahrung, Aufträge, Gemerktes
var progress := Progress.new()


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
	return is_moving() or steer != Vector2.ZERO or remote_walking


func in_dialog() -> bool:
	return not dialog.is_empty()


## Kommt gerade ein NPC auf den Spieler zu? Dann wartet der Spieler, bis er da ist.
func awaiting_npc() -> bool:
	return npc_walk.get("phase", "") == "hin"
