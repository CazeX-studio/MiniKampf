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
## Gruppenkampf beim Zusammenspielen: {bid, seed, mine = eigener Held (Nummer), owners = [Spieler je Held, "" = Computer]}.
## Leer = allein.
static var group := {}


static func active() -> bool:
	return kampf_id != ""


## Mit der eigenen Klasse in der Welt (ab Grünwacht): pro Stufe über 1 so viel mehr Schaden und Heilung
## (vorläufig, Feinschliff am Ende). Leben und Mana wachsen wie beim Novizen (BattleState.LEVEL_HP).
const HERO_POWER_PER_LEVEL := 0.05


static func hero_power(level: int) -> float:
	return 1.0 + HERO_POWER_PER_LEVEL * maxi(level - 1, 0)


## Mit welcher Klasse man kämpft: in der Probestunde die geprobte, bei Monstern in der Wildnis die eigene
## (wenn schon gewählt), sonst als Novize.
static func fighting_class(data: Dictionary, own_class: String) -> String:
	if data.get("eigene_klasse", false) and Sandbox.CLASSES.has(own_class) and own_class != "novize":
		return own_class
	return data.get("klasse", "novize")


## Bereitet einen Kampf aus data/kaempfe.json vor. Der Spieler ist ein Novize seiner Stufe mit seinen Heiltränken,
## Begleiter (Novizen-Mitstreiter) steuert der Computer. own_class: die gewählte Klasse (für Kämpfe in der Wildnis),
## own_monsters: das Rudel eines Zähmers (leer = noch keins, dann wie in der Probestunde alle drei Start-Monster).
static func prepare(id: String, level: int, potions := 0, own_class := "", own_monsters: Array = []) -> bool:
	var data: Dictionary = GameData.battle(id)
	if data.is_empty():
		return false
	# Probestunde: Der Spieler spielt kurz eine richtige Klasse (Ult schon teilweise geladen)
	var klasse := fighting_class(data, own_class)
	var player := {klasse = klasse, name = "Du", aussehen = "novize" if klasse == "novize" else "", stufe = level,
			ult = float(data.get("ult_start", 0))}
	if data.get("eigene_klasse", false):
		player["macht"] = hero_power(level)
		if klasse == "tamer":
			player["monster"] = own_monsters
	if klasse == "novize":
		player["traenke"] = potions
	# Parieren lernt man erst in Lektion 3: davor hat der Novize keine Reaktion (im langen Lernkampf je Phase)
	if not data.get("reaktion", true):
		player["reaktion"] = ""
	# Langer Lernkampf: jede Phase ist eine Welle mit eigenen Regeln
	var phases: Array = data.get("phasen", [])
	var waves: Array = data.get("wellen", [])
	if not phases.is_empty():
		waves = phases.map(func(ph: Dictionary) -> Array: return ph.gegner)
	var heroes: Array = [player]
	for b: Dictionary in data.get("begleiter", []):
		heroes.append({klasse = "novize", name = b.name, aussehen = b.get("aussehen", "novize"), stufe = level, computer = true})
	kampf_id = id
	result = {}
	return_scene = "res://scenes/kreuzweg.tscn"
	used_before = 0
	group = {}
	setup = _make_setup(id, data, heroes, phases, waves)
	return true


## Aufbau eines Gruppenkampfs (Gastgeber): erst die Spieler der Gruppe, freie Plätze füllen die Novizen-Mitstreiter.
## members: [{name, stufe, traenke, aussehen, klasse, monster}]. Gibt den Aufbau zurück (leer, wenn es den Kampf nicht gibt).
static func build_group(id: String, members: Array) -> Dictionary:
	var data: Dictionary = GameData.battle(id)
	if data.is_empty():
		return {}
	var heroes: Array = []
	for m: Dictionary in members:
		# Im Kampf sieht jeder Spieler aus wie seine Figur in der Stadt (so kann man sich auseinanderhalten)
		var klasse := fighting_class(data, str(m.get("klasse", "")))
		var hero := {klasse = klasse, name = m.name, aussehen = str(m.get("aussehen", "novize")) if klasse == "novize" else "", stufe = int(m.stufe),
				ult = float(data.get("ult_start", 0))}
		if data.get("eigene_klasse", false):
			hero["macht"] = hero_power(int(m.stufe))
			if klasse == "tamer":
				hero["monster"] = m.get("monster", [])
		if klasse == "novize":
			hero["traenke"] = int(m.get("traenke", 0))
		if not data.get("reaktion", true):
			hero["reaktion"] = ""
		heroes.append(hero)
	var allies: Array = data.get("begleiter", [])
	var level := int(members[0].stufe) if not members.is_empty() else 1
	var free := mini(allies.size() + 1, 4) - heroes.size()
	for i in clampi(free, 0, allies.size()):
		var b: Dictionary = allies[i]
		heroes.append({klasse = "novize", name = b.name, aussehen = b.get("aussehen", "novize"), stufe = level, computer = true})
	var phases: Array = data.get("phasen", [])
	var waves: Array = data.get("wellen", [])
	if not phases.is_empty():
		waves = phases.map(func(ph: Dictionary) -> Array: return ph.gegner)
	var result_setup := _make_setup(id, data, heroes, phases, waves)
	# Gemeinsam gibt es kein „Nochmal versuchen“ (alle müssten zustimmen)
	result_setup["kein_nochmal"] = true
	# Manche Bosse (Sternenfresser) passen sich der Gruppengröße an: je weiterer Spieler mehr Leben
	if data.has("gruppe_staerke"):
		result_setup["gegner_leben"] = float(result_setup.gegner_leben) * (1.0 + float(data.gruppe_staerke) * (members.size() - 1))
	return result_setup


## Mitspieler: Gruppenkampf vom Gastgeber übernehmen.
static func prepare_group(id: String, p_setup: Dictionary, info: Dictionary) -> void:
	kampf_id = id
	result = {}
	return_scene = "res://scenes/kreuzweg.tscn"
	used_before = 0
	setup = p_setup
	group = info


static func _make_setup(id: String, data: Dictionary, heroes: Array, phases: Array, waves: Array) -> Dictionary:
	var result_setup := {
		name = data.get("name", id),
		ansage = data.get("ansage", ""),
		helden = heroes,
		wellen = waves,
		erlaubt = data.get("erlaubt", []),
		hinweise = data.get("hinweise", {}),
		ziel_paraden = int(data.get("ziel_paraden", 0)),
		kein_nochmal = data.get("kein_nochmal", false),
		hintergrund = data.get("hintergrund", "wiese"),
		zuerst = data.get("zuerst", ""),
		gegner_stufe = int(data.get("gegner_stufe", 1)),
		# Rivalen und besondere Gegner: so viel mehr Leben (z. B. Kobalt), Gruppenkämpfe rechnen noch die Gruppengröße drauf
		gegner_leben = float(data.get("gegner_leben", 1.0)),
		# Dungeon-Regeln (Pilzhöhle: Mechaniken der Bosse und Monster). Entscheidungen fallen dann in der Welt.
		dungeon = data.get("dungeon", ""),
		entscheidung_in_der_welt = data.get("entscheidung_in_der_welt", false),
		verschlingen_zuege = int(data.get("verschlingen_zuege", 3)),
	}
	if not phases.is_empty():
		result_setup["phasen"] = phases
	return result_setup


## Der Kampf ist vorbei: Ergebnis für die Welt merken.
static func finish(won: bool, potions_used := 0, tamed: Array = []) -> void:
	result = {kampf = kampf_id, gewonnen = won, traenke_benutzt = used_before + potions_used, gezaehmt = tamed}
	used_before = 0
	kampf_id = ""
	setup = {}
	group = {}


## „Nochmal versuchen“: getrunkene Tränke sind weg, der neue Versuch beginnt mit dem Rest.
## Im langen Lernkampf geht es bei der Phase weiter, in der man verloren hat.
static func retry(potions_used: int, phase := 0) -> void:
	used_before += potions_used
	if setup.has("phasen"):
		setup["start_welle"] = phase
	if not setup.is_empty():
		setup.helden[0]["traenke"] = maxi(0, int(setup.helden[0].get("traenke", 0)) - potions_used)
