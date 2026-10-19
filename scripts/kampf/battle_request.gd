class_name BattleRequest
extends RefCounted
## Ein Kampf, der aus der Welt (Kreuzweg-Demo) gestartet wird, z. B. eine Lektion bei Ye.
## Merkt sich zwischen den Bildschirmen, welcher Kampf läuft und wie er ausging.

## Kennung aus data/kaempfe.json ("" = kein Kampf aus der Welt, also Sandbox)
static var kampf_id := ""
## Aufbau für BattleState.setup
static var setup := {}
## Ergebnis für die Welt: {kampf, gewonnen}. Leer = noch nichts zu melden.
static var result := {}


static func active() -> bool:
	return kampf_id != ""


## Bereitet einen Kampf aus data/kaempfe.json vor. Der Spieler ist ein Novize seiner Stufe,
## Begleiter (Novizen-Mitstreiter) steuert der Computer.
static func prepare(id: String, level: int) -> bool:
	var data: Dictionary = GameData.get_file("kaempfe").get(id, {})
	if data.is_empty():
		return false
	var player := {klasse = "novize", name = "Du", aussehen = "novize", stufe = level}
	# Parieren lernt man erst in Lektion 3: davor hat der Novize keine Reaktion
	if not data.get("reaktion", true):
		player["reaktion"] = ""
	var heroes: Array = [player]
	for b: Dictionary in data.get("begleiter", []):
		heroes.append({klasse = "novize", name = b.name, aussehen = b.get("aussehen", "novize"), stufe = level, computer = true})
	kampf_id = id
	result = {}
	setup = {
		name = data.get("name", id),
		ansage = data.get("ansage", ""),
		helden = heroes,
		wellen = data.wellen,
		erlaubt = data.get("erlaubt", []),
		hinweise = data.get("hinweise", {}),
		ziel_paraden = int(data.get("ziel_paraden", 0)),
	}
	return true


## Der Kampf ist vorbei: Ergebnis für die Welt merken.
static func finish(won: bool) -> void:
	result = {kampf = kampf_id, gewonnen = won}
	kampf_id = ""
	setup = {}
