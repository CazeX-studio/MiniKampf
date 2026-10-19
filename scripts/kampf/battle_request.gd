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
## Heiltränke, die in früheren Versuchen desselben Kampfes („Nochmal versuchen“) getrunken wurden
static var used_before := 0
## Wohin es nach dem Kampf zurückgeht (Stadt oder Klassenwahl)
static var return_scene := "res://scenes/kreuzweg.tscn"


static func active() -> bool:
	return kampf_id != ""


## Bereitet einen Kampf aus data/kaempfe.json vor. Der Spieler ist ein Novize seiner Stufe mit seinen Heiltränken,
## Begleiter (Novizen-Mitstreiter) steuert der Computer.
static func prepare(id: String, level: int, potions := 0) -> bool:
	var data: Dictionary = GameData.battle(id)
	if data.is_empty():
		return false
	# Probestunde: Der Spieler spielt kurz eine richtige Klasse (Ult schon teilweise geladen)
	var klasse: String = data.get("klasse", "novize")
	var player := {klasse = klasse, name = "Du", aussehen = "novize" if klasse == "novize" else "", stufe = level,
			ult = float(data.get("ult_start", 0))}
	if klasse == "novize":
		player["traenke"] = potions
	# Parieren lernt man erst in Lektion 3: davor hat der Novize keine Reaktion
	if not data.get("reaktion", true):
		player["reaktion"] = ""
	var heroes: Array = [player]
	for b: Dictionary in data.get("begleiter", []):
		heroes.append({klasse = "novize", name = b.name, aussehen = b.get("aussehen", "novize"), stufe = level, computer = true})
	kampf_id = id
	result = {}
	return_scene = "res://scenes/kreuzweg.tscn"
	used_before = 0
	setup = {
		name = data.get("name", id),
		ansage = data.get("ansage", ""),
		helden = heroes,
		wellen = data.wellen,
		erlaubt = data.get("erlaubt", []),
		hinweise = data.get("hinweise", {}),
		ziel_paraden = int(data.get("ziel_paraden", 0)),
		kein_nochmal = data.get("kein_nochmal", false),
		hintergrund = data.get("hintergrund", "wiese"),
		zuerst = data.get("zuerst", ""),
	}
	return true


## Der Kampf ist vorbei: Ergebnis für die Welt merken.
static func finish(won: bool, potions_used := 0) -> void:
	result = {kampf = kampf_id, gewonnen = won, traenke_benutzt = used_before + potions_used}
	used_before = 0
	kampf_id = ""
	setup = {}


## „Nochmal versuchen“: getrunkene Tränke sind weg, der neue Versuch beginnt mit dem Rest.
static func retry(potions_used: int) -> void:
	used_before += potions_used
	if not setup.is_empty():
		setup.helden[0]["traenke"] = maxi(0, int(setup.helden[0].get("traenke", 0)) - potions_used)
