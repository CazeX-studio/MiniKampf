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
## Was ein Sieg bringt (WorldState.battle_reward), für die Anzeige am Kampfende. Leer = nichts anzeigen.
static var reward := {}
## Aussehen der eigenen Figur, solange sie als Novize kämpft ("" = Novize aus dem 0x72-Paket)
static var player_look := ""
## Angelegte Ausrüstung der eigenen Figur (Platz -> Gegenstand, siehe Ausruestung). Leer = ohne Ausrüstung kämpfen
## wie bisher (Sandbox).
static var player_gear := {}
## Besitzeffekte der Karten im Album (D16): {leben, mana, angriff, tempo}, wirken wie Bonus-Werte der Ausrüstung
static var player_card_bonus := {}
## Manatränke am Gürtel der eigenen Figur (Projekt 14, K.2)
static var player_mana_potions := 0
## Manatränke, die in früheren Versuchen desselben Kampfes getrunken wurden
static var mana_used_before := 0
## Mana der eigenen Figur vor dem Kampf (Anteil). Kämpfe in der Wildnis (eigene Klasse) beginnen damit und melden
## danach, was übrig ist; Lektionen und Geschichtskämpfe in Kreuzweg beginnen mit vollem Mana.
static var player_mana_share := 1.0
## Gelernte Fähigkeiten der eigenen Figur (Kennung -> Stufe, Projekt 14, K.3). player_skills_known = false: unbekannt
## (Sandbox und Prüfungen), dann kämpft man mit allen Fähigkeiten der Klasse.
static var player_skills := {}
static var player_skills_known := false
## Die feste Leiste der eigenen Figur (sechs Kennungen, "" = frei)
static var player_bar: Array = []
## Kennt die eigene Figur schon die kleine Ult Sternenmut? (lernt man in der Festnacht)
static var player_sternenmut := false
## Welche Novizen-Fähigkeiten die eigene Figur schon bei Ye gelernt hat ([] = unbekannt: alle, z. B. Sandbox)
static var player_novize: Array = []
## Besondere Munition der eigenen Figur aus der Tasche (Pfeil -> Anzahl, siehe Skills.MUNITION)
static var player_munition := {}
## Band des Zähmers: wie viele Kämpfe jedes Monster schon im Rudel war (Monster -> Anzahl)
static var player_band := {}


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
	var novice_look := player_look if player_look != "" else "novize"
	# Aussehen: der Novize mit seiner Figur; Klassen mit eigenem Körper (D18) mit der eigenen Figur in Klassenkleidung
	var eigenes := FigurTeile.mit_klasse(player_look, klasse) if player_look != "" else ""
	var klassen_figur := eigenes if klasse != "novize" and FigurTeile.KLASSEN_KOERPER.has(klasse) \
			and FigurTeile.koerper_von(eigenes).begins_with(str(FigurTeile.KLASSEN_KOERPER[klasse])) else ""
	var player := {klasse = klasse, name = "Du", aussehen = novice_look if klasse == "novize" else klassen_figur, stufe = level,
			ult = float(data.get("ult_start", 0))}
	if data.get("eigene_klasse", false):
		player["macht"] = hero_power(level)
		if klasse == "tamer":
			player["monster"] = own_monsters
	# Tränke am Gürtel: für den Novizen und für jede eigene Klasse (nicht in der Probestunde mit fremder Klasse)
	var eigener_guertel := klasse == "novize" or klasse == own_class
	if eigener_guertel:
		player["traenke"] = potions
	if not player_gear.is_empty() or not player_card_bonus.is_empty():
		player["ausruestung"] = Ausruestung.kampfwerte(player_gear if not player_gear.is_empty() else Ausruestung.START, player_card_bonus)
	# Novize: nur, was er bei Ye schon gelernt hat (Lektionen und Lernkämpfe mit Phasen zeigen, was sie erlauben)
	if klasse == "novize" and not player_novize.is_empty() and not data.has("phasen") and not data.get("lektion", false):
		player["novize_gelernt"] = player_novize.duplicate()
	if klasse == "tamer" and not player_band.is_empty():
		player["band"] = player_band.duplicate()
	if klasse == "archer" and not player_munition.is_empty():
		player["munition"] = player_munition.duplicate()
	if klasse == "novize" and (player_sternenmut or data.get("sternenmut", false)):
		player["sternenmut"] = true
	if eigener_guertel and player_mana_potions > 0:
		player["manatraenke"] = player_mana_potions
	if data.get("eigene_klasse", false):
		player["mana_anteil"] = player_mana_share
	# Fähigkeiten-Baum: in Kämpfen mit der eigenen Klasse nur das Gelernte (Lernkämpfe mit Phasen zeigen alles)
	if player_skills_known and klasse == own_class and Faehigkeiten.hat_baum(klasse) and not data.has("phasen"):
		player["faehigkeiten"] = player_skills.duplicate()
		player["leiste"] = player_bar.duplicate()
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
## members: [{name, stufe, traenke, aussehen, klasse, monster, ausruestung}] (ausruestung: Ausruestung.kampfwerte). Gibt den Aufbau zurück (leer, wenn es den Kampf nicht gibt).
static func build_group(id: String, members: Array) -> Dictionary:
	var data: Dictionary = GameData.battle(id)
	if data.is_empty():
		return {}
	var heroes: Array = []
	for m: Dictionary in members:
		# Im Kampf sieht jeder Spieler aus wie seine Figur in der Stadt (so kann man sich auseinanderhalten)
		var klasse := fighting_class(data, str(m.get("klasse", "")))
		# Mit Klasse: die eigene Figur in Klassenkleidung wie allein (A2b, Alpha-Punkt 16), sonst die Klassenfigur
		var eigenes := str(m.get("aussehen", "novize"))
		var aussehen := eigenes
		if klasse != "novize":
			var gekleidet := FigurTeile.mit_klasse(eigenes, klasse)
			aussehen = gekleidet if FigurTeile.KLASSEN_KOERPER.has(klasse) \
					and FigurTeile.koerper_von(gekleidet).begins_with(str(FigurTeile.KLASSEN_KOERPER[klasse])) else ""
		var hero := {klasse = klasse, name = m.name, aussehen = aussehen, stufe = int(m.stufe),
				ult = float(data.get("ult_start", 0))}
		if data.get("eigene_klasse", false):
			hero["macht"] = hero_power(int(m.stufe))
			if klasse == "tamer":
				hero["monster"] = m.get("monster", [])
		# Tränke am Gürtel: Novize und jede eigene Klasse (wie allein, D12), nicht die fremde Klasse der Probestunde
		if klasse == "novize" or klasse == str(m.get("eigene_klasse", "")):
			hero["traenke"] = int(m.get("traenke", 0))
		if m.has("ausruestung"):
			hero["ausruestung"] = m.ausruestung
		if klasse == "novize" and m.has("novize_gelernt") and not data.has("phasen") and not data.get("lektion", false):
			hero["novize_gelernt"] = m.novize_gelernt
		if klasse == "novize" and (m.get("sternenmut", false) or data.get("sternenmut", false)):
			hero["sternenmut"] = true
		if klasse == "novize" and int(m.get("manatraenke", 0)) > 0:
			hero["manatraenke"] = int(m.manatraenke)
		if m.has("faehigkeiten") and klasse == str(m.get("eigene_klasse", "")) and Faehigkeiten.hat_baum(klasse) and not data.has("phasen"):
			hero["faehigkeiten"] = m.faehigkeiten
			hero["leiste"] = m.get("leiste", [])
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
		rettung = data.get("rettung", false),
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
static func finish(won: bool, potions_used := 0, tamed: Array = [], mana_used := 0, mana_share := -1.0, ammo_used := {}) -> void:
	result = {kampf = kampf_id, gewonnen = won, traenke_benutzt = used_before + potions_used, gezaehmt = tamed,
			manatraenke_benutzt = mana_used_before + mana_used}
	if mana_share >= 0.0:
		result["mana_anteil"] = mana_share
	if not ammo_used.is_empty():
		result["munition_benutzt"] = ammo_used
	mana_used_before = 0
	# Die Belohnung stand schon auf dem Sieg-Bildschirm: Die Welt meldet sie nicht noch einmal
	if won and not reward.is_empty():
		result["belohnung_gezeigt"] = true
		if reward.has("karte_gewuerfelt"):
			result["karte"] = reward.karte
	reward = {}
	used_before = 0
	kampf_id = ""
	setup = {}
	group = {}


## „Nochmal versuchen“: getrunkene Tränke sind weg, der neue Versuch beginnt mit dem Rest.
## Im langen Lernkampf geht es bei der Phase weiter, in der man verloren hat.
static func retry(potions_used: int, phase := 0, mana_used := 0) -> void:
	used_before += potions_used
	mana_used_before += mana_used
	if setup.has("phasen"):
		setup["start_welle"] = phase
	if not setup.is_empty():
		setup.helden[0]["traenke"] = maxi(0, int(setup.helden[0].get("traenke", 0)) - potions_used)
		if setup.helden[0].has("manatraenke"):
			setup.helden[0]["manatraenke"] = maxi(0, int(setup.helden[0].manatraenke) - mana_used)
