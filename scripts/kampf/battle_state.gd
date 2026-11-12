class_name BattleState
extends RefCounted
## Die Regeln eines Kampfes, ganz ohne Grafik (design.md, Abschnitt 4 und 5):
## - Zugreihenfolge nach Tempo, zwei Reihen, Reaktionen, Ult-Leisten, Elemente, Begleiter, Wellen
## - Entscheidungen kommen von einem "Steuerer" (controller): die Anzeige (Spieler tippt) oder ein Computer-Spieler.
##   Er muss diese Befehle beantworten:
##     play(events)                         spielt gemeldete Ereignisse ab (darf warten)
##     choose_action(fighter) -> {ab, target}   Fähigkeit und Ziel für einen Helden oder Begleiter
##     react(attacker, target, duration) -> bool  perfekte Reaktion getroffen?
##     choose_option(title, options) -> String     Entscheidung (z. B. nach dem Dungeon)
## - Alles, was passiert, wird als Ereignis gemeldet (z. B. {type = "float", f = Sporenwolf, text = "-12"}).
##   Die Anzeige (combat.gd) spielt diese Ereignisse ab. Der Zustand wartet nie auf Animationen.
## Die Fähigkeiten der Klassen stehen in skills.gd, die Werte in sandbox.gd.

## Nahkampf-Schaden wird so stark verringert, wenn Angreifer oder Ziel hinten stehen.
const BACK_ROW_MELEE := 0.6
const CRIT_CHANCE := 0.1
const CRIT_MULT := 1.5
## Mana nur durch Handeln (Projekt 14, K.2, Beschluss 29.10.): Im Kampf füllt es sich nicht von selbst.
## Zurück gibt es (Anteil vom Höchstwert): normaler Angriff etwas, perfekte Parade oder perfektes Ausweichen mehr,
## Abwarten etwas (WAIT_MANA), dazu Manatränke. Vorläufige Werte, Feinschliff am Ende.
const MANA_ATTACK := 0.15
const MANA_PERFECT := 0.25
const BUFF_TURNS := 2
const ATK_BUFF := 1.4
const DEF_BUFF := 0.7
const VULN_MULT := 1.3
## Zwischen zwei Wellen heilen sich die Helden um diesen Anteil.
const WAVE_HEAL := 0.25
## Reaktion auf einen Gegner-Angriff (Ring und Balken): verpasst, normal, perfekt
## Aufgeladener Angriff (Glimmerkäfer): so viel stärker
const AUFGELADEN := 1.6
const REACT_NONE := 0
const REACT_NORMAL := 1
const REACT_PERFECT := 2
## Normal pariert oder ausgewichen: so viel weniger Schaden
const NORMAL_REACT_BLOCK := 0.25
## Tödlicher Angriff (Sternenfresser) normal pariert: so viel vom vollen Leben geht verloren
const DEADLY_PARRIED := 0.9
## Abwarten (für alle Klassen): so viel Schaden kommt noch an, so viel Mana gibt es (Anteil vom Höchstwert),
## und um diesen Anteil eines Zuges ist man früher wieder dran. Vorläufige Werte.
const WAIT_DAMAGE := 0.67
const WAIT_MANA := 0.15
const WAIT_HASTE := 0.35
## Paradeschule (Lektion 3): so viele Angriffe von Ye – zwei mit Erklärung, dann zwei Übungsversuche
const PARRY_SCHOOL_ATTACKS := 4
## Pro Stufe über 1 bekommt ein Held so viel mehr Leben und Mana (Novize in der Kreuzweg-Demo).
const LEVEL_HP := 10
const LEVEL_MANA := 4

## Monster in der Wildnis (Grünwacht): pro Stufe über 1 so viel mehr Leben und Schaden (vorläufig, Feinschliff am Ende)
const MONSTER_HP_PER_LEVEL := 0.09
const MONSTER_POWER_PER_LEVEL := 0.06


## Stufenabstand (Grünwacht, Entscheidung 21.10.: Die Stufe soll mehr zählen): Ist der Gegner höher als man selbst,
## macht man pro Stufe so viel weniger Schaden und Heilung und bekommt so viel härtere Treffer. Ist man höher, umgekehrt.
## Höchstens MAX_LEVEL_GAP Stufen zählen. Bei gleicher Stufe ändert sich nichts. Vorläufig, Feinschliff am Ende.
const GAP_HERO_PER_LEVEL := 0.06
const GAP_ENEMY_PER_LEVEL := 0.08
const MAX_LEVEL_GAP := 5


## Stufenabstand Gegner minus Held, begrenzt auf ±MAX_LEVEL_GAP.
static func level_gap(enemy_level: int, hero_level: int) -> int:
	return clampi(enemy_level - hero_level, -MAX_LEVEL_GAP, MAX_LEVEL_GAP)


## Schaden und Heilung des Helden bei diesem Stufenabstand (1 = gleich stark).
static func gap_hero_factor(gap: int) -> float:
	return 1.0 - GAP_HERO_PER_LEVEL * gap


## Schaden der Gegner bei diesem Stufenabstand (1 = gleich stark).
static func gap_enemy_factor(gap: int) -> float:
	return 1.0 + GAP_ENEMY_PER_LEVEL * gap


static func monster_hp(level: int) -> float:
	return 1.0 + MONSTER_HP_PER_LEVEL * maxi(level - 1, 0)


static func monster_power(level: int) -> float:
	return 1.0 + MONSTER_POWER_PER_LEVEL * maxi(level - 1, 0)

## Boss-Werte
const BOSS_FIST := 23
const BOSS_ROCKFALL := 30
const BOSS_CHAIN := 10
const BOSS_RAGE_AT := 0.3
const BOSS_RAGE_MULT := 1.3

var heroes: Array[Fighter] = []
## Begleiter auf dem Feld (Roboter, kämpfendes Monster)
var companions: Array[Fighter] = []
var enemies: Array[Fighter] = []
## Trainer der Gegner-Monster (Rivale Kobalt): handeln mit, zählen aber nicht als Gegner (nicht angreifbar)
var trainers: Array[Fighter] = []
var current: Fighter
var battle_over := false
var won := false
## Zeitpunkt des aktuellen Zuges auf der Zugleiste
var now := 0.0
var skills: Skills
## Dungeon-Regeln (Pilzhöhle), sonst null
var dungeon: DungeonRegeln
## Lava-Takt (Vulkanschmiede der Ketten): steigt abwechselnd vorne und hinten
var lava: LavaTakt
var controller: Object
## Zufall der Spielregeln. Gleicher Startwert + gleiche Entscheidungen = gleicher Kampf.
var rng := RandomNumberGenerator.new()
## Nach so vielen Zügen wird abgebrochen (0 = nie, nur für automatische Tests).
var max_turns := 0
## Kritische Treffer der laufenden Aktion (lädt die Ult des Bogenschützen).
var crits := 0
var team: Array[String] = []
var encounter := ""
var waves: Array = []
var wave := 0
var turns := 0
## Kampf aus der Welt (Kreuzweg-Demo) statt aus der Sandbox: {name, helden: [{klasse, name, aussehen, stufe, computer}],
## wellen: [[Gegner …]], erlaubt: [Fähigkeiten]}. Leer = Sandbox (Team und Gegner aus der Auswahl).
var setup := {}
## Helden, die der Computer steuert (Novizen-Mitstreiter): Fighter -> true
var computer := {}
## Lektion mit vorgegebener erster Aktion (setup.zuerst): schon erledigt?
var first_done := false
## Langer Lernkampf (setup.phasen): perfekte Paraden zu Beginn der aktuellen Phase
var parry_base := 0
## Paradeschule: so oft hat Ye in dieser Lektion schon angegriffen
var parry_attempts := 0

var _events: Array[Dictionary] = []
var _last_crit := false
## Element des Treffers, der gerade verbucht wird (für das Aufleuchten von Feuer, Blitz, Licht und Sternenkraft)
var _last_element := ""
var _last_eff := 1.0
## Stufen der Helden, für die der Stufenabstand zu den Gegnern zählt
var _gap_levels: Array[int] = []


func _init(p_controller: Object, p_team: Array[String], p_encounter: String, p_seed: int) -> void:
	controller = p_controller
	team = p_team
	encounter = p_encounter
	rng.seed = p_seed
	skills = Skills.new(self)


## Startet den Kampf und läuft, bis er vorbei ist.
func run() -> void:
	_create_heroes()
	if setup.has("wellen"):
		waves = setup.wellen
		# Dungeon in der Welt (Pilzhöhle unter dem Urbaum): dieselben Mechaniken wie in der Sandbox
		if setup.get("dungeon", "") == "pilzhoehle":
			dungeon = Pilzhoehle.new(self)
		if setup.get("dungeon", "") == "vulkanschmiede":
			lava = LavaTakt.new(self)
			dungeon = Vulkanschmiede.new(self)
		_spawn_wave(int(setup.get("start_welle", 0)))
		await _battle_loop()
		return
	waves = Sandbox.ENCOUNTERS[encounter].waves
	if Sandbox.ENCOUNTERS[encounter].get("dungeon", "") == "pilzhoehle":
		dungeon = Pilzhoehle.new(self)
	if Sandbox.ENCOUNTERS[encounter].get("dungeon", "") == "vulkanschmiede":
		lava = LavaTakt.new(self)
		dungeon = Vulkanschmiede.new(self)
	_spawn_wave(0)
	await _battle_loop()


## Gegenseitige Verweise lösen (Held <-> Roboter/Monster, Schilde), sonst bleiben die Teilnehmer im Speicher.
func cleanup() -> void:
	var everyone := all_fighters()
	for h in heroes:
		everyone.append_array(h.monsters)
		if h.robot != null:
			everyone.append(h.robot)
	for f in everyone:
		f.owner = null
		f.robot = null
		f.active_monster = null
		f.monsters.clear()
		f.protecting = null
		f.smoke_source = null
		f.shields.clear()
	skills = null
	dungeon = null
	lava = null
	controller = null


# --- Ereignisse ---------------------------------------------------------------

func _emit(event: Dictionary) -> void:
	_events.append(event)


## Gibt alle gesammelten Ereignisse an den Steuerer und wartet, bis er sie abgespielt hat.
func _flush() -> void:
	if _events.is_empty():
		return
	var events := _events
	_events = []
	await controller.play(events)


func add_log(text: String) -> void:
	_emit({type = "log", text = text})


## Schwebender Text über einer Figur (Schaden, Heilung, Hinweise).
func float_text(f: Fighter, text: String, color: Color, offset := 0.0) -> void:
	if on_field(f):
		_emit({type = "float", f = f, text = text, color = color, offset = offset})


## Text der Statuszeile über den Knöpfen.
func status(text: String) -> void:
	_emit({type = "status", text = text})


## Ein Geschoss fliegt; die Anzeige wartet, bis es angekommen ist.
func projectile(from: Fighter, to: Fighter, color: Color, duration := 0.3) -> void:
	_emit({type = "projectile", from = from, to = to, color = color, duration = duration, blocking = true})


## Wie projectile, aber die Anzeige macht sofort weiter (mehrere Geschosse gleichzeitig).
## attack_name: Name des Angriffs, damit die Anzeige die passende Animation zeigen kann (z. B. Steinwurf).
func projectile_bg(from: Fighter, to: Fighter, color: Color, duration := 0.3, attack_name := "") -> void:
	_emit({type = "projectile", from = from, to = to, color = color, duration = duration, blocking = false,
			name = attack_name})


func lunge(f: Fighter, target: Fighter, duration: float, blocking := true, attack_name := "") -> void:
	_emit({type = "lunge", f = f, target = target, duration = duration, blocking = blocking, name = attack_name})


## Kurze Pause in der Anzeige.
func wait(seconds: float) -> void:
	_emit({type = "wait", seconds = seconds})


## Leuchten an einer Figur (z. B. bei Siegeln oder Explosionen).
func burst(f: Fighter, color: Color, radius := 160.0) -> void:
	if on_field(f):
		_emit({type = "burst", f = f, color = color, radius = radius})


func screen_flash(color: Color) -> void:
	_emit({type = "flash", color = color})


## Eigene Bewegung oder eigener Effekt einer Fähigkeit (siehe FaehigkeitFx).
func zeige(fx_name: String, f: Fighter, ziel: Fighter = null, seite := 0, farbe := Color.WHITE) -> void:
	_emit({type = "fx", name = fx_name, f = f, ziel = ziel, seite = seite, farbe = farbe})


## Kleiner Hüpfer einer Figur.
func hop(f: Fighter) -> void:
	_emit({type = "hop", f = f})


## Kurzer Film, wenn ein Boss in Phase 2 geht (PhasenFilm, A9b). Die Anzeige wartet, bis er vorbei ist.
func phasen_film(f: Fighter, motiv: String, titel: String, untertitel: String, farbe: Color) -> void:
	_emit({type = "phasen_film", f = f, motiv = motiv, titel = titel, untertitel = untertitel, farbe = farbe})


## Großer Schriftzug in der Bildmitte (z. B. "Welle 2").
func banner(text: String) -> void:
	_emit({type = "banner", text = text})


func move_to_row(f: Fighter) -> void:
	_emit({type = "row", f = f})


## Dunkelheit über dem Kampffeld (0 = hell, 1 = schwarz).
func set_darkness(amount: float) -> void:
	_emit({type = "darkness", amount = amount})


## Eine Laterne wird entzündet (Pilzhöhle): Die Anzeige stellt sie mit Lichtkreis aufs Feld.
func light_lantern(f: Fighter) -> void:
	_emit({type = "lantern", f = f})


func set_order_visible(on: bool) -> void:
	_emit({type = "order_visible", on = on})


## Anzeige auf den neuesten Stand bringen (Namensschilder, Zugleiste).
func refresh() -> void:
	_emit({type = "refresh"})


## Neue Lebenspunkte einer Figur (damit die Leiste im richtigen Moment sinkt).
func _hp_changed(f: Fighter) -> void:
	if on_field(f):
		_emit({type = "hp", f = f, hp = f.hp})


# --- Zufall -------------------------------------------------------------------

## Kommazahl von 0 bis unter 1 (aus dem Zufall dieses Kampfes).
func zufall() -> float:
	return rng.randf()


func zufall_range(from: float, to: float) -> float:
	return rng.randf_range(from, to)


## Zufälliges Element einer Liste.
func pick(list: Array) -> Variant:
	return list[rng.randi() % list.size()]


# --- Teilnehmer ---------------------------------------------------------------

func _create_heroes() -> void:
	var specs: Array = setup.get("helden", [])
	if specs.is_empty():
		for id in team:
			specs.append({klasse = id})
	for i in specs.size():
		var spec: Dictionary = specs[i]
		var id: String = spec.klasse
		var data: Dictionary = Sandbox.CLASSES[id]
		# Höhere Stufe: mehr Leben und Mana (der Novize bekommt seine Grundwerte, s. Grundwerte)
		var level_bonus := int(spec.get("stufe", 1)) - 1
		var h: Fighter
		if id == "novize":
			# Novize: Grundwerte je nach Stufe (data/stufen.json)
			var stats := Grundwerte.for_level(level_bonus + 1)
			h = Fighter.new(spec.get("name", data.hero), id, data.title, true, stats.leben, stats.tempo, data.color)
			h.max_mana = stats.mana
			h.power = Grundwerte.power(level_bonus + 1)
			h.set_meta("faktor_stufe", h.power)
		else:
			h = Fighter.new(spec.get("name", data.hero), id, data.title, true, data.hp + LEVEL_HP * level_bonus, data.tempo, data.color)
			h.max_mana = data.mana + LEVEL_MANA * level_bonus if data.mana > 0 else 0
		# Ausrüstung (Projekt 14, K.1): Waffen-Tempo, Bonus-Werte, Verteidigung und Widerstand
		var gear: Dictionary = spec.get("ausruestung", {})
		if not gear.is_empty():
			h.tempo = maxi(1, h.tempo + int(gear.get("tempo", 0)))
			h.max_hp += int(gear.get("leben", 0))
			h.hp = h.max_hp
			if h.max_mana > 0:
				h.max_mana += int(gear.get("mana", 0))
			h.schutz = float(gear.get("schutz", 1.0))
			h.magieschutz = float(gear.get("magieschutz", 1.0))
		h.look = spec.get("aussehen", "")
		h.set_meta("stufe", level_bonus + 1)
		h.mana = data.get("start_mana", h.max_mana)
		# Kampf in der Wildnis: mit dem Mana, das man aus der Welt mitbringt (Hinsetzen füllt es, Projekt 14, K.2)
		if spec.has("mana_anteil") and h.max_mana > 0:
			h.mana = roundi(h.max_mana * clampf(float(spec.mana_anteil), 0.0, 1.0))
		h.reaction = spec.get("reaktion", data.reaction)
		h.back_row = data.back
		heroes.append(h)
		if setup.has("helden"):
			team.append(id)
		h.ult = float(spec.get("ult", 0.0))
		if spec.has("traenke"):
			h.wares = {heiltrank = int(spec.traenke)}
		# Gelernte Fähigkeiten aus dem Baum (nur bei Klassen mit Baum, siehe Faehigkeiten)
		if spec.has("band"):
			h.set_meta("band", spec.band)
		if spec.get("sternenmut", false):
			h.set_meta("sternenmut", true)
		if spec.has("novize_gelernt"):
			h.set_meta("novize_gelernt", spec.novize_gelernt)
		if spec.has("faehigkeiten"):
			h.set_meta("faehigkeiten", spec.faehigkeiten)
			h.set_meta("leiste", spec.get("leiste", []))
		# Besondere Munition (Elementpfeil des Bogenschützen)
		var munition: Dictionary = spec.get("munition", {})
		for pfeil: String in munition:
			if Skills.MUNITION.has(pfeil) and int(munition[pfeil]) > 0:
				h.wares[pfeil] = int(munition[pfeil])
		if int(spec.get("manatraenke", 0)) > 0:
			h.wares["manatrank"] = int(spec.manatraenke)
		if spec.get("computer", false):
			computer[h] = true
		# Zähmer in der Welt: sein eigenes Rudel (Start-Monster von Professor Esche und gezähmte Monster)
		if spec.has("monster") and not spec.monster.is_empty():
			h.set_meta("monster", spec.monster)
		skills.setup_hero(h)
		# Kampf in der Welt mit der eigenen Klasse (ab Grünwacht): Schaden und Heilung wachsen mit der Stufe,
		# Roboter und Monster des Helden werden genauso stärker (spec.macht, siehe BattleRequest)
		if spec.has("macht"):
			h.power = float(spec.macht)
			h.set_meta("faktor_stufe", h.power)
			# Stufenabstand zu den Gegnern (nur wenn die Gegner eine Stufe haben)
			if setup.has("gegner_stufe"):
				var abstand := gap_hero_factor(level_gap(int(setup.gegner_stufe), level_bonus + 1))
				h.power *= abstand
				h.set_meta("faktor_abstand", abstand)
				_gap_levels.append(level_bonus + 1)
			var buddies: Array[Fighter] = h.monsters.duplicate()
			if h.robot != null:
				buddies.append(h.robot)
			for b in buddies:
				# Monster des Zähmers wachsen nur zu einem kleinen Teil mit der Stufe des Helden (E4, siehe
				# Sandbox.zaehmer_monster_wachstum); auf Stufe 1 ändert sich nichts, gegen einen anderen Zähmer auch nicht
				var anteil := 1.0
				if b != h.robot and not _rivalenkampf():
					anteil = (1.0 + Sandbox.zaehmer_monster_wachstum * (float(spec.macht) - 1.0)) / float(spec.macht)
				b.power = h.power * anteil
				b.max_hp = roundi(b.max_hp * float(spec.macht) * anteil)
				b.hp = b.max_hp
		# Band (passiv, Zähmer): Monster, die schon lange im Rudel sind, sind stärker (höchstens 30 %)
		var band: Dictionary = spec.get("band", {})
		if not band.is_empty() and skills.skill_level(h, "band") > 0 and h.has_meta("faehigkeiten"):
			for m in h.monsters:
				m.power *= 1.0 + minf(0.3, 0.01 * int(band.get(m.klass, 0)) * skills.skill_level(h, "band"))
		# Waffenkraft: mehr Schaden und Heilung (mit der Grundausrüstung bleibt alles wie vorher)
		if not gear.is_empty():
			h.power *= float(gear.get("macht", 1.0))
			# Für die Zahlen in den Beschreibungen (A23): Anteil von Waffen- bzw. Zauberkraft
			h.set_meta("faktor_kraft", float(gear.get("macht", 1.0)))
		_emit({type = "spawn", f = h, place = "hero", index = i, hp = h.hp})
		h.next_time = h.turn_delay() * zufall_range(0.2, 1.0)

	var mechanic := hero("mechanic")
	if mechanic != null:
		add_companion(mechanic.robot)
	var tamer := hero("tamer")
	if tamer != null:
		add_companion(tamer.active_monster)
		show_supporters(tamer)


## Tritt ein anderer Zähmer an (Rivale Kobalt)? Dann kämpft Monster gegen Monster, und die eigenen Monster wachsen voll mit.
func _rivalenkampf() -> bool:
	for welle: Array in setup.get("wellen", []):
		for id: Variant in welle:
			if id is String and Sandbox.ENEMIES.get(id, {}).get("trainer", false):
				return true
	return false


func add_companion(f: Fighter) -> void:
	companions.append(f)
	f.on_bench = false
	_emit({type = "spawn", f = f, place = "robot" if f.klass == "robot" else "monster", index = 0, hp = f.hp})
	f.next_time = now + f.turn_delay() * zufall_range(0.3, 1.0)


## Die Unterstützer des Zähmers stehen sichtbar auf dem Feld (man kann sie nicht angreifen, sie sind „auf der Bank“).
func show_supporters(tamer: Fighter) -> void:
	for m in tamer.monsters:
		if m != tamer.active_monster:
			_emit({type = "despawn", f = m})
	var supporters := skills.supporters(tamer)
	for i in supporters.size():
		_emit({type = "spawn", f = supporters[i], place = "support", index = i, hp = supporters[i].hp})


func remove_companion(f: Fighter) -> void:
	_emit({type = "despawn", f = f})
	companions.erase(f)
	f.on_bench = true


## Zähmen: Das Monster verlässt die Gegner und wartet beim Zähmer auf der Bank (halbes Leben).
func tame(tamer: Fighter, e: Fighter) -> void:
	_emit({type = "despawn", f = e})
	enemies.erase(e)
	var data: Dictionary = Sandbox.ENEMIES[e.klass]
	var m := Fighter.new(data.name, e.klass, "Gezähmt", false, data.hp, data.tempo, Elements.color(data.element))
	m.element = data.element
	m.owner = tamer
	m.on_bench = true
	m.hp = maxi(1, data.hp / 2)
	m.power = tamer.power
	# Für die Welt: Dieses Monster bleibt nach dem Kampf im Rudel (BattleRequest.finish)
	m.set_meta("neu_gezaehmt", true)
	tamer.monsters.append(m)
	add_log("[color=#8fd36b][b]%s zähmt %s![/b][/color] Es wartet auf der Bank (Wechsel)." % [tamer.display_name, m.display_name])
	refresh()


func _spawn_wave(index: int) -> void:
	wave = index
	if setup.has("phasen"):
		_apply_phase(index)
	var ids: Array = waves[index]
	spawn_enemies(ids)
	if setup.has("phasen"):
		add_log("\n[b]%s[/b]" % setup.phasen[index].get("name", ""))
	elif waves.size() > 1:
		add_log("\n[b]Welle %d von %d[/b]" % [index + 1, waves.size()])
	if setup.has("ansage"):
		add_log("[b]%s[/b]" % setup.ansage)
	# Dungeon-Mechaniken (z. B. welche Mechanik der Zwischenboss heute nutzt) auch in der Welt, wo es eine Ansage gibt
	# (Sporenkönigin seit 04.11. auch in der Welt mit Mechanik, Marcos Entscheidung)
	if dungeon != null:
		dungeon.on_wave(index)
	elif setup.has("ansage"):
		pass
	elif "boss" in ids:
		add_log("[b]Ein Steinwächter (Erde) und seine Begleiter greifen an![/b]")
	else:
		add_log("[b]Monster mit vier Elementen greifen an![/b] Auf die Farbe am Namen achten.")


## Langer Lernkampf: Jede Phase (Lektion) bringt eigene Regeln mit – erlaubte Fähigkeiten, Reaktion an/aus,
## Ye kommentiert in der Paradeschule (D20b, Sprüche aus design.md): bei den Übungsversuchen nach jeder Parade,
## beim ersten Übungsversuch wird sein Schirm kurz zu einer anderen Waffe.
func _ye_sagt(grade: int) -> void:
	if parry_attempts == 3:
		add_log("[color=#c8b8e8][i]Für einen Augenblick ist Yes Schirm ein Schwert. Dann wieder ein Schirm. Ye tut, als wäre nichts gewesen.[/i][/color]")
	if parry_attempts <= 2:
		return
	var spruch := "Nicht nachdenken. Deine Hände wissen es vor dir."
	if grade == REACT_NONE:
		spruch = "Zu langsam. Noch mal."
	elif grade == REACT_PERFECT and parry_attempts == PARRY_SCHOOL_ATTACKS:
		spruch = "Nicht schlecht. Für einen Anfänger."
	add_log("[color=#cfe2ff]Ye: „%s“[/color]" % spruch)


## Paraden-Ziel, Pflicht-Aktion, Ansage und Ye-Erklärungen.
func _apply_phase(index: int) -> void:
	var phase: Dictionary = setup.phasen[index]
	setup.erlaubt = phase.get("erlaubt", [])
	setup.ziel_paraden = int(phase.get("ziel_paraden", 0))
	setup.paradeschule = phase.get("paradeschule", false)
	parry_attempts = 0
	setup.zuerst = phase.get("zuerst", "")
	setup.hinweise = phase.get("hinweise", {})
	setup.ansage = phase.get("ansage", "")
	first_done = false
	var player := heroes[0]
	player.reaction = Sandbox.CLASSES[player.klass].reaction if phase.get("reaktion", true) else ""
	parry_base = player.stat_perfect


## Ersetzt alle Gegner durch neue (Kennungen aus Sandbox.ENEMIES).
func spawn_enemies(ids: Array) -> void:
	for e in enemies + trainers:
		_emit({type = "despawn", f = e})
	enemies.clear()
	trainers.clear()
	var with_trainer := ids.any(func(id: String) -> bool: return Sandbox.ENEMIES[id].get("trainer", false))
	var slot := 0
	# Gruppenkampf: Bosse wie der Sternenfresser haben mehr Leben, je mehr Spieler mitkämpfen (setup.gegner_leben)
	var hp_scale: float = Sandbox.HP_SCALE[heroes.size() - 1] * float(setup.get("gegner_leben", 1.0))
	var has_big := false
	for id: String in ids:
		has_big = has_big or Sandbox.ENEMIES[id].get("big", false)
	for i in ids.size():
		var id: String = ids[i]
		var data: Dictionary = Sandbox.ENEMIES[id]
		var e := _monster_bauen(id, hp_scale)
		if data.get("trainer", false):
			# Der Trainer steht hinten, sein Monster vorne; angreifen kann man ihn nicht
			e.trainer = true
			trainers.append(e)
			_emit({type = "spawn", f = e, place = "trainer", index = 0, hp = e.hp})
			e.next_time = now + e.turn_delay() * zufall_range(0.4, 1.0)
			continue
		enemies.append(e)
		e.intent = skills.enemy_intent(e)
		e.set_meta("platz", slot + (2 if with_trainer else 0))
		_emit({type = "spawn", f = e, place = "boss_wave" if has_big else "wave", index = slot + (2 if with_trainer else 0), hp = e.hp})
		slot += 1
		e.next_time = now + e.turn_delay() * zufall_range(0.2, 1.0)


## Ein Gegner nach seinen Daten. Monster in der Wildnis haben eine Stufe (setup.gegner_stufe): mehr Leben und härtere
## Treffer. Ohne Stufe (Lernkämpfe) kämpfen Monster nach Regelblatt auf ihrer kleinsten Stufe (MONSTER.md).
func _monster_bauen(id: String, hp_scale: float, stufe := 0) -> Fighter:
	var data: Dictionary = Sandbox.ENEMIES[id]
	var level := stufe if stufe > 0 else int(setup.get("gegner_stufe", data.get("stufe_min", 1)))
	# Was sich nicht wehrt (Splitter-Knoten, Zielscheiben), wächst nicht mit der Stufe: Es gehört zur Mechanik
	var level_hp := 1.0 if data.get("passive", false) else monster_hp(level)
	var e := Fighter.new(data.name, id, data.element, false, roundi(data.hp * hp_scale * level_hp), data.tempo, Elements.color(data.element))
	e.element = data.element
	e.power = monster_power(level) * _enemy_gap_factor(level)
	e.resist = data.get("resist", 1.0)
	e.big = data.get("big", false)
	e.passive = data.get("passive", false)
	e.plate = data.get("panzer", 1.0)
	e.stagger_length = data.get("erschuettert", 2)
	e.deadly = data.get("toedlich", false)
	e.set_meta("stufe", level)
	if data.has("title"):
		e.display_name = data.title
	return e


## Ein Monster kommt mitten im Kampf dazu (Herbeirufen, MONSTER.md: höchstens einmal pro Kampf).
func add_enemy(id: String, stufe: int) -> void:
	var e := _monster_bauen(id, Sandbox.HP_SCALE[heroes.size() - 1], stufe)
	# Freier Platz: einer, auf dem kein lebendes Monster steht
	var belegt := enemies.filter(func(m: Fighter) -> bool: return m.is_alive()).map(func(m: Fighter) -> int: return int(m.get_meta("platz", 0)))
	var platz := 0
	while belegt.has(platz):
		platz += 1
	e.set_meta("platz", platz)
	enemies.append(e)
	e.intent = skills.enemy_intent(e)
	_emit({type = "spawn", f = e, place = "wave", index = platz, hp = e.hp})
	float_text(e, "Herbeigerufen!", Color("ffd34d"))
	e.next_time = now + e.turn_delay() * zufall_range(0.6, 1.0)
	refresh()


## Härtere oder schwächere Treffer der Gegner durch den Stufenabstand (in der Gruppe zählt die mittlere Stufe).
func _enemy_gap_factor(enemy_level: int) -> float:
	if _gap_levels.is_empty():
		return 1.0
	var total := 0
	for l in _gap_levels:
		total += l
	return gap_enemy_factor(level_gap(enemy_level, roundi(float(total) / _gap_levels.size())))


## Wipe-Mechanik: Die ganze Gruppe stirbt.
func wipe(reason: String) -> void:
	add_log("[color=red][b]%s Die ganze Gruppe ist besiegt.[/b][/color]" % reason)
	screen_flash(Color("200030"))
	for f in allies():
		f.hp = 0
		_hp_changed(f)
	refresh()


func all_fighters() -> Array[Fighter]:
	var result: Array[Fighter] = []
	result.append_array(heroes)
	result.append_array(companions)
	result.append_array(enemies)
	result.append_array(trainers)
	return result


func alive(group: Array[Fighter]) -> Array[Fighter]:
	var result: Array[Fighter] = []
	for f in group:
		if f.is_alive():
			result.append(f)
	return result


## Lebende Helden und Begleiter auf dem Feld.
func allies() -> Array[Fighter]:
	var result := alive(heroes)
	result.append_array(alive(companions))
	return result


## Steht die Figur auf dem Kampffeld (nicht auf der Bank, nicht gezähmt oder ersetzt)?
func on_field(f: Fighter) -> bool:
	return f in heroes or f in companions or f in enemies


func hero(klass: String) -> Fighter:
	for h in heroes:
		if h.klass == klass:
			return h
	return null


# --- Zugreihenfolge -----------------------------------------------------------

## Wer als Nächstes dran ist: kleinster Zeitpunkt, bei Gleichstand zuerst die Helden.
func _earliest(times: Dictionary) -> Fighter:
	var best: Fighter = null
	for f: Fighter in times:
		if best == null or times[f] < times[best] - 0.001 \
				or (absf(times[f] - times[best]) <= 0.001 and f.is_ally() and not best.is_ally()):
			best = f
	return best


## Simuliert die nächsten Züge (für die Leiste oben).
func peek_order(count: int) -> Array[Fighter]:
	var times := {}
	for f in alive(all_fighters()):
		if not f.passive:
			times[f] = f.next_time
	var result: Array[Fighter] = []
	while result.size() < count and not times.is_empty():
		var f := _earliest(times)
		result.append(f)
		times[f] += f.turn_delay()
	return result


## Der nächste Gegner auf der Zugleiste (für den gut getimten Monster-Wechsel).
func next_enemy() -> Fighter:
	for f in peek_order(12):
		if not f.is_ally():
			return f
	return null


## Schiebt ein Ziel auf der Zugleiste nach hinten (Anteil eines Zuges).
func delay(target: Fighter, fraction: float) -> void:
	target.next_time += target.turn_delay() * fraction


## Holt ein Ziel auf der Zugleiste nach vorne (Anteil eines Zuges).
func hasten(target: Fighter, fraction: float) -> void:
	target.next_time = maxf(now + 0.01, target.next_time - target.turn_delay() * fraction)


func _battle_loop() -> void:
	while not battle_over:
		var times := {}
		for f in alive(all_fighters()):
			if not f.passive:
				times[f] = f.next_time
		var f := _earliest(times)
		current = f
		now = f.next_time
		# Lava-Takt: neue Runden anbrechen lassen (Ankündigung, Lava steigt und sinkt)
		if lava != null:
			lava.vor_dem_zug(now)
			await _flush()
		_emit({type = "turn", f = f})
		await _flush()
		if max_turns > 0 and turns >= max_turns:
			battle_over = true
			_emit({type = "end", won = false, aborted = true})
			await _flush()
			return
		_begin_turn(f)
		if await _check_end():
			return
		if f.is_alive() and _gelaehmt:
			# Gelähmt (Effekt-Liste): Dieser Zug fällt aus
			add_log("%s ist gelähmt und setzt aus." % f.display_name)
			wait(0.6)
		elif f.is_alive():
			turns += 1
			if f.is_ally():
				await _player_turn(f)
			else:
				await _enemy_turn(f)
		f.next_time += f.turn_delay()
		# Wer abgewartet hat, ist etwas früher wieder dran
		if f.waiting:
			f.next_time -= f.turn_delay() * WAIT_HASTE
		current = null
		_emit({type = "turn", f = null})
		if await _check_end():
			return


## Mana zurückgeben (Anteil vom Höchstwert). Gibt zurück, wie viel es wirklich gab.
func gain_mana(f: Fighter, share: float) -> int:
	if f.max_mana <= 0 or not f.is_alive():
		return 0
	var before := f.mana
	f.mana = mini(f.mana + roundi(f.max_mana * share), f.max_mana)
	return f.mana - before


## Was zu Beginn jedes eigenen Zuges passiert (Abklingzeiten, Mana, Klassen-Mechaniken).
## Wurde der Kämpfer zu Beginn seines Zuges gelähmt? (siehe Effekte.zug_beginn)
var _gelaehmt := false
## Wer vom letzten Gegner-Angriff wirklich getroffen wurde (für Effekte, die am Angriff hängen)
var _getroffen: Array[Fighter] = []
## Das Ziel, das ein Held für seine Fähigkeit gewählt hat, solange sie läuft (null sonst). Das Kühlbecken des
## Kettenschmieds macht nur nass, wer es gezielt angreift, nicht wer es mit einem Rundumschlag streift (A9b).
var aktions_ziel: Fighter = null
var held_handelt := false


## Ein Effekt aus der Effekt-Liste wird sichtbar (gleich für alle, die ihn auslösen).
func emit_effect(f: Fighter, art: String, color: Color) -> void:
	_emit({type = "effekt", f = f, art = art, color = color})


func _begin_turn(f: Fighter) -> void:
	for id: String in f.cooldowns.keys():
		f.cooldowns[id] = maxi(f.cooldowns[id] - 1, 0)
	f.atk_buff_turns = maxi(f.atk_buff_turns - 1, 0)
	f.def_buff_turns = maxi(f.def_buff_turns - 1, 0)
	f.vuln_turns = maxi(f.vuln_turns - 1, 0)
	f.blind_turns = maxi(f.blind_turns - 1, 0)
	f.schwach_turns = maxi(f.schwach_turns - 1, 0)
	# Mondwiegenlied: Heilung über mehrere Runden
	if f.has_meta("wiegenlied"):
		var lied: Dictionary = f.get_meta("wiegenlied")
		lied.zuege = int(lied.zuege) - 1
		if f.is_alive():
			heal(lied.quelle as Fighter, f, int(lied.heilung))
		if int(lied.zuege) <= 0:
			f.remove_meta("wiegenlied")
	# Rüstungsschmied: Glühende Rüstung und Meisterstück laufen ab
	for zeit: String in ["gluehend", "meisterstueck"]:
		if f.has_meta(zeit):
			var rest := int(f.get_meta(zeit)) - 1
			if rest <= 0:
				f.remove_meta(zeit)
			else:
				f.set_meta(zeit, rest)
	# Wachstumsschub (Zähmer) läuft ab
	if f.has_meta("wachstum"):
		var w: Dictionary = f.get_meta("wachstum")
		w.zuege = int(w.zuege) - 1
		if int(w.zuege) <= 0:
			f.max_hp -= int(w.leben)
			f.hp = mini(f.hp, f.max_hp)
			f.power /= 1.3
			f.remove_meta("wachstum")
			zeige("wachstum_ende", f)
			float_text(f, "Schrumpft", Color("8fd36b"))
	f.stagger_turns = maxi(f.stagger_turns - 1, 0)
	f.waiting = false
	# Deckung geben hält nur bis zum eigenen nächsten Zug
	for other in all_fighters():
		if other.has_meta("gedeckt_von") and other.get_meta("gedeckt_von") == f:
			other.remove_meta("gedeckt_von")
			other.remove_meta("gedeckt_alle")
	_gelaehmt = Effekte.zug_beginn(self, f)
	skills.begin_turn(f)
	refresh()


## Prüft Sieg und Niederlage. Nach einer gewonnenen Welle kommt die nächste.
func _check_end() -> bool:
	if battle_over:
		return true
	if dungeon != null:
		dungeon.check_phase()
	var lost := alive(heroes).is_empty()
	var cleared := alive(enemies).is_empty()
	# Paraden-Lektion: gewonnen, sobald der Spieler oft genug perfekt pariert hat
	var parries_needed := int(setup.get("ziel_paraden", 0))
	# Paradeschule: nach zwei erklärten Paraden und zwei Übungsversuchen ist die Lektion vorbei, egal wie sie liefen
	if setup.get("paradeschule", false) and not lost and parry_attempts >= PARRY_SCHOOL_ATTACKS:
		add_log("[color=#8affc1][b]Übung beendet – jetzt kennst du beide Paraden![/b][/color]")
		cleared = true
	if parries_needed > 0 and not lost and heroes[0].stat_perfect - parry_base >= parries_needed:
		add_log("[color=#8affc1][b]%d perfekte Paraden – Lektion bestanden![/b][/color]" % parries_needed)
		cleared = true
		if not setup.has("phasen"):
			wave = waves.size() - 1
	if cleared and not lost and wave < waves.size() - 1:
		_next_wave()
		return false
	if not cleared and not lost:
		return false
	battle_over = true
	won = cleared
	current = null
	_emit({type = "turn", f = null})
	status("Sieg!" if won else "Niederlage …")
	if won:
		add_log("\n[color=green][b]Alle Gegner sind besiegt![/b][/color]")
		if dungeon != null:
			await dungeon.final_choice()
	else:
		add_log("\n[color=red][b]Alle Helden sind gefallen.[/b][/color]")
	wait(1.0)
	_emit({type = "end", won = won, aborted = false})
	await _flush()
	return true


func _next_wave() -> void:
	status("Welle geschafft!")
	wait(0.8)
	if setup.has("phasen"):
		banner(setup.phasen[wave + 1].get("name", ""))
	else:
		banner("Welle %d" % (wave + 2))
	for h in alive(heroes):
		heal(null, h, roundi(h.max_hp * WAVE_HEAL))
	_spawn_wave(wave + 1)
	refresh()
	wait(1.0)


## Eine Entscheidung mit mehreren Möglichkeiten (z. B. nach dem Dungeon). Gibt die Kennung zurück.
func ask_choice(title: String, options: Array[Dictionary]) -> String:
	await _flush()
	var id: String = await controller.choose_option(title, options)
	return id


# --- Spieler-Zug --------------------------------------------------------------

func _player_turn(f: Fighter) -> void:
	# Paradeschule: Der Spieler greift nicht an, er wartet auf Yes Angriff
	if setup.get("paradeschule", false) and f == heroes[0]:
		wait(0.5)
		execute(f, skills.wait_ability(), null)
		return
	f.belt_free_used = false
	while true:
		await _flush()
		var command: Dictionary = await controller.choose_action(f)
		if is_valid(f, command.ab, command.target):
			execute(f, command.ab, command.target)
			# Gürtel: der erste Gürtel-Gegenstand im Zug ist gratis, man ist danach noch einmal dran
			if command.ab.get("guertel", false) and not f.belt_free_used and f.is_alive() and not battle_over \
					and not alive(enemies).is_empty():
				f.belt_free_used = true
				float_text(f, "Gratis – noch dran!", Color("f2c14e"))
				status("%s ist noch einmal dran (Gürtel gratis)." % f.display_name)
				refresh()
				continue
			return


## Prüft einen Befehl, bevor er ausgeführt wird (wichtig, sobald Befehle übers Netz kommen).
func is_valid(f: Fighter, ab: Dictionary, target: Fighter) -> bool:
	if skills.blocked_reason(f, ab) != "":
		return false
	if ab.target == "none":
		return true
	return target in skills.valid_targets(f, ab)


## Führt eine Fähigkeit aus.
func execute(f: Fighter, ab: Dictionary, target: Fighter) -> void:
	var id: String = ab.id
	if id == setup.get("zuerst", ""):
		first_done = true
	status("%s: %s" % [f.display_name, ab.name])
	crits = 0
	f.mana -= ab.get("mana", 0)
	# Stufe der Fähigkeit im Baum: jede Stufe über 1 mehr Schaden und Heilung
	if f.has_meta("faehigkeiten"):
		f.set_meta("stufen_mult", 1.0 + Faehigkeiten.stufen_bonus() * maxi(skills.skill_level(f, id) - 1, 0))
	# Fähigkeiten aus vielen kleinen Treffern wachsen mit dem Tempo (A23b)
	f.set_meta("tempo_mult", FaehigkeitZahlen.tempo_faktor(f) if id in FaehigkeitZahlen.TEMPO_FAEHIGKEITEN else 1.0)
	if ab.has("cd"):
		f.cooldowns[id] = ab.cd + 1
	# Normaler Angriff gibt etwas Mana zurück
	if skills.is_basic_attack(f, id):
		gain_mana(f, MANA_ATTACK)

	if id == "abwarten":
		f.waiting = true
		if f.max_mana > 0:
			f.mana = mini(f.mana + roundi(f.max_mana * WAIT_MANA), f.max_mana)
		add_log("%s wartet ab." % f.display_name)
		float_text(f, "Abwarten", Color("cfe2ff"))
		refresh()
		return
	if id == "row":
		f.back_row = not f.back_row
		add_log("%s wechselt nach %s." % [f.display_name, f.row_name()])
		move_to_row(f)
		return
	_emit({type = "cast", f = f, ult = id == "ult", name = ab.name})
	if id == "ult":
		f.ult = 0.0
		f.credit().stat_ults += 1
		add_log("[color=#f2c14e][b]%s entfesselt %s![/b][/color]" % [f.display_name, ab.name])
		wait(0.35)
	elif ab.has("duet"):
		add_log("[color=#ffa8e0][b]Duett: %s![/b][/color]" % ab.name)

	aktions_ziel = target
	held_handelt = true
	skills.execute(f, ab, target)
	held_handelt = false
	aktions_ziel = null
	refresh()
	wait(0.35)


# --- Gegner-Zug ---------------------------------------------------------------

func _enemy_turn(e: Fighter) -> void:
	status("%s ist am Zug …" % e.display_name)
	wait(0.5)
	if dungeon != null and dungeon.handles(e):
		await dungeon.enemy_turn(e)
	elif e.klass == "boss":
		await _boss_turn(e)
	else:
		var data: Dictionary = Sandbox.ENEMIES[e.klass]
		# Lockfutter (Zähmer): abgelenkt, greift seltener an
		if e.has_meta("lockfutter"):
			var rest := int(e.get_meta("lockfutter")) - 1
			if rest <= 0:
				e.remove_meta("lockfutter")
			else:
				e.set_meta("lockfutter", rest)
			if zufall() < 0.5:
				float_text(e, "Frisst …", Color("e8c890"))
				add_log("%s ist mit dem Futter beschäftigt." % e.display_name)
				e.intent = skills.enemy_intent(e)
				return
		var attack := faehigkeit_waehlen(e)
		if attack.get("einmal", false):
			var benutzt: Dictionary = e.get_meta("einmal", {})
			benutzt[attack.name] = true
			e.set_meta("einmal", benutzt)
		# Flüchter (seltene Monster, MONSTER.md 8): laufen nach ein paar eigenen Zügen weg
		if data.has("flieht_nach") and e.step >= int(data.flieht_nach):
			_weglaufen(e)
			return
		if not await _monster_faehigkeit(e, attack):
			var targets := _monster_ziele(attack, e)
			var schaden := _monster_schaden(e, attack)
			for n in maxi(int(attack.get("treffer", 1)), 1):
				if targets.is_empty() or not e.is_alive():
					break
				# Sternenschlund (A15): auch normal pariert ist man besiegt, nur die perfekte Parade rettet
				e.set_meta("streng", attack.get("streng", false))
				await enemy_attack(e, targets, schaden, attack.kind, attack.name)
				e.remove_meta("streng")
				# Effekt am Angriff (Effekt-Liste): trifft nur, wer nicht perfekt pariert oder ausgewichen ist
				for t in _getroffen:
					_monster_effekte(e, t, attack)
					# Lichtfraß (Pilzhöhle): der Lichtkreis um das Ziel schrumpft, es ist ein paar Züge geblendet
					if attack.has("blenden") and t.is_alive():
						t.blind_turns = maxi(t.blind_turns, int(attack.blenden))
						float_text(t, "Geblendet", Color("fff3b0"), 30)
				targets = targets.filter(func(t: Fighter) -> bool: return t.is_alive())
		e.step += 1
		# Zeitbombe (Sternenfresser): nach so vielen eigenen Zügen stirbt die ganze Gruppe
		if data.has("wipe_nach") and e.is_alive() and e.step >= int(data.wipe_nach):
			wipe(data.get("wipe_text", "Zu spät!"))
	e.intent = skills.enemy_intent(e)


## Nächste Fähigkeit eines Monsters nach Steckbrief. Übersprungen werden: Heilen eines anderen Monsters, wenn keins
## mehr da ist, Fähigkeiten, die nur einmal gehen, und solche, die nur bei Lava gehen (Magmaheilung).
func faehigkeit_waehlen(e: Fighter) -> Dictionary:
	var data: Dictionary = Sandbox.ENEMIES[e.klass]
	var attack: Dictionary = data.attacks[e.step % data.attacks.size()]
	for versuch in data.attacks.size():
		var allein: bool = str(attack.get("ziel", "")) == "freund" and not enemies.any(func(m: Fighter) -> bool: return m.is_alive() and m != e)
		var verbraucht: bool = attack.get("einmal", false) and e.get_meta("einmal", {}).has(attack.name)
		var ohne_lava: bool = attack.get("nur_bei_lava", false) and (lava == null or lava.oben == "")
		if not allein and not verbraucht and not ohne_lava:
			break
		e.step += 1
		attack = data.attacks[e.step % data.attacks.size()]
	return attack


## Ziele eines Monster-Angriffs (MONSTER.md): alle, vordere/hintere Reihe, das schwächste Ziel oder mehrere verschiedene.
func _monster_ziele(attack: Dictionary, e: Fighter = null) -> Array[Fighter]:
	var targets: Array[Fighter] = []
	# Sternenfresser (Marco, 11.11.): greift öfter die Hauptperson an, damit sie perfekt parieren und den Panzer öffnen kann
	var vorliebe: float = Sandbox.ENEMIES.get(e.klass, {}).get("spieler_bevorzugt", 0.0) if e != null else 0.0
	if vorliebe > 0.0 and str(attack.get("ziel", "")) == "" and not attack.get("all", false) and zufall() < vorliebe:
		attack = attack.duplicate()
		attack.ziel = "spieler"
	match str(attack.get("ziel", "")):
		"spieler":
			# Ein echter Spieler, kein Mitstreiter des Computers (Sternenschlund, A15)
			var spieler := allies().filter(func(h: Fighter) -> bool: return not computer.has(h))
			targets = [pick(spieler) if not spieler.is_empty() else pick_target()]
			return targets
		"vorne":
			targets.assign(allies().filter(func(h: Fighter) -> bool: return not h.back_row))
			if targets.is_empty():
				targets = allies()
			return targets
		"schwaechster":
			var alle := allies()
			alle.sort_custom(func(a: Fighter, b: Fighter) -> bool: return a.hp < b.hp)
			if not alle.is_empty():
				targets = [alle[0]]
			return targets
	if attack.get("all", false):
		return allies()
	var anzahl := int(attack.get("ziele", 1))
	for i in anzahl:
		var t := pick_target() if attack.kind == "melee" and i == 0 else pick_target(attack.get("back", false), true)
		if i > 0:
			var rest := allies().filter(func(h: Fighter) -> bool: return not targets.has(h))
			if rest.is_empty():
				break
			t = pick(rest)
		targets.append(t)
	return targets


## Schaden eines Monster-Angriffs: Rudel (mehr je weiterem Monster derselben Art), Aufladen (nächster Angriff stärker).
func _monster_schaden(e: Fighter, attack: Dictionary) -> int:
	var schaden := float(attack.base)
	if attack.has("rudel"):
		var rudel := enemies.filter(func(m: Fighter) -> bool: return m.is_alive() and m != e and m.klass == e.klass).size()
		if rudel > 0:
			schaden *= 1.0 + float(attack.rudel) * rudel
			add_log("Das Rudel heult: %s beißt härter." % e.display_name)
	if schaden > 0.0 and e.has_meta("geladen"):
		e.remove_meta("geladen")
		schaden *= AUFGELADEN
	return roundi(schaden)


## Ein Flüchter läuft weg: Er ist aus dem Kampf, aber nicht besiegt.
func _weglaufen(e: Fighter) -> void:
	add_log("[color=#f2c14e]%s läuft weg![/color]" % e.display_name)
	float_text(e, "Weggelaufen!", Color("f2c14e"), 40)
	e.set_meta("geflohen", true)
	e.hp = 0
	_emit({type = "despawn", f = e})
	refresh()


## Effekte einer Monster-Fähigkeit auf ein Ziel ("effekt" ist ein Baustein oder eine Liste; anteil = Teil des
## Lebens der Quelle bei heilen und schutz).
func _monster_effekte(quelle: Fighter, ziel: Fighter, attack: Dictionary) -> void:
	if not attack.has("effekt"):
		return
	var liste: Array = attack.effekt if attack.effekt is Array else [attack.effekt]
	for fx: Dictionary in liste:
		var staerke := float(fx.get("staerke", -1.0))
		if fx.has("anteil"):
			staerke = float(fx.anteil) * quelle.max_hp
		# In der Lava-Runde härter (Schlackenpanzer)
		if attack.has("lava_staerker") and lava != null and lava.oben != "":
			staerke *= float(attack.lava_staerker)
			add_log("Die Lava härtet den %s." % attack.name)
		# Schutz von Monstern stapelt nicht: der neue ersetzt den alten (sonst zieht sich der Kampf endlos)
		if str(fx.art) == "schutz":
			ziel.shields.erase(quelle)
		Effekte.anwenden(self, quelle, ziel, str(fx.art), staerke, int(fx.get("zuege", -1)))


## Fähigkeiten ohne Angriff auf die Helden: auf sich selbst, auf andere Monster oder Herbeirufen.
## Gibt true zurück, wenn die Fähigkeit so ausgeführt wurde (dann folgt kein Angriff).
func _monster_faehigkeit(e: Fighter, attack: Dictionary) -> bool:
	var ziel := str(attack.get("ziel", ""))
	if attack.has("ruf"):
		# Herbeirufen höchstens einmal pro Kampf (MONSTER.md), und nur, wenn noch Platz ist
		if has_meta("gerufen") or enemies.filter(func(m: Fighter) -> bool: return m.is_alive()).size() >= 4:
			_emit({type = "cast", f = e, ult = false, name = attack.name})
			float_text(e, "Niemand kommt …", Color("d8d8e8"))
			return true
		set_meta("gerufen", true)
		_emit({type = "cast", f = e, ult = false, name = attack.name})
		add_log("%s: %s!" % [e.display_name, attack.name])
		add_enemy(str(attack.ruf), int(e.get_meta("stufe", 1)))
		wait(0.4)
		return true
	if ziel not in ["selbst", "freund", "freunde"]:
		return false
	if attack.get("aufladen", false):
		e.set_meta("geladen", true)
		float_text(e, "Lädt sich auf!", Color("ffe14d"), 30)
	_emit({type = "cast", f = e, ult = false, name = attack.name})
	add_log("%s: %s" % [e.display_name, attack.name])
	var ziele: Array[Fighter] = []
	match ziel:
		"selbst":
			ziele = [e]
		"freunde":
			ziele.assign(enemies.filter(func(m: Fighter) -> bool: return m.is_alive()))
		"freund":
			# Das verletzteste andere Monster (sonst sich selbst)
			var andere := enemies.filter(func(m: Fighter) -> bool: return m.is_alive() and m != e)
			andere.sort_custom(func(a: Fighter, b: Fighter) -> bool: return float(a.hp) / a.max_hp < float(b.hp) / b.max_hp)
			if andere.is_empty():
				return true
			ziele = [andere[0]]
	for z in ziele:
		_monster_effekte(e, z, attack)
	wait(0.5)
	return true


func _boss_turn(boss: Fighter) -> void:
	if not boss.enraged and boss.hp <= boss.max_hp * BOSS_RAGE_AT:
		boss.enraged = true
		add_log("[color=red][b]Der Steinwächter wird wütend![/b] Er schlägt härter zu.[/color]")
	match boss.step % 4:
		0:
			await enemy_attack(boss, [pick_target()], BOSS_FIST, "melee", "Steinfaust")
		1:
			await enemy_attack(boss, [pick_target()], BOSS_FIST - 6, "melee", "Steinfaust")
			add_log("[color=yellow]Der Steinwächter hebt die Arme: Gleich regnet es Felsen auf die hintere Reihe! (Magie)[/color]")
		2:
			var targets := allies().filter(func(h: Fighter) -> bool: return h.back_row)
			if targets.is_empty():
				add_log("Felsregen! Aber hinten steht niemand mehr.")
				float_text(boss, "Verfehlt!", Color.WHITE)
			else:
				var typed: Array[Fighter] = []
				typed.assign(targets)
				await enemy_attack(boss, typed, BOSS_ROCKFALL, "magic", "Felsregen")
		3:
			var back := allies().filter(func(h: Fighter) -> bool: return h.back_row)
			var target: Fighter = pick(back) if not back.is_empty() else pick_target()
			if target.back_row:
				target.back_row = false
				add_log("[color=yellow]Kettenzug! %s wird nach vorne gerissen.[/color]" % target.display_name)
				move_to_row(target)
			await enemy_attack(boss, [target], BOSS_CHAIN, "melee", "Kettenzug")
	boss.step += 1


## Wen ein Gegner angreift. Bedrohung (Bann-Zeichen, Amboss, Moosschild, Magnet-Haken) zwingt zum Ziel.
## Nahkämpfer zielen meist auf die vordere Reihe, Fernkämpfer und Magier auf irgendwen.
func pick_target(prefer_back := false, anyone := false) -> Fighter:
	var candidates := allies()
	var taunting := candidates.filter(func(h: Fighter) -> bool: return h.taunt > 0)
	if not taunting.is_empty():
		taunting.sort_custom(func(a: Fighter, b: Fighter) -> bool: return a.taunt > b.taunt)
		var forced: Fighter = taunting[0]
		forced.taunt -= 1
		return forced
	var front := candidates.filter(func(h: Fighter) -> bool: return not h.back_row)
	var back := candidates.filter(func(h: Fighter) -> bool: return h.back_row)
	if prefer_back and not back.is_empty():
		return pick(back)
	if anyone:
		return pick(candidates)
	if not front.is_empty() and (back.is_empty() or zufall() < 0.7):
		return pick(front)
	return pick(back)


## Ein Gegner-Angriff mit Chance auf perfekte Reaktion.
## Angriffe mit dem gemalten Blitzeinschlag (A21, Marco 11.11.: bis er andere wählt, der stärkste Angriff jedes Blitz-Monsters)
## Funkenflirr und Messingwächter: Funkenschlag, Funkenmarder: Funkenfell, Donnerhirsch: Blitzgeweih, Funkenechse: Funkenzunge,
## Glasskorpion: Blitzstachel, Gewitterwyvern: Aschegewitter, Glimmerkäfer: Entladung, Funkenwicht: Kettenblitz.
const BLITZ_EINSCHLAG: Array[String] = ["Funkenschlag", "Funkenfell", "Blitzgeweih", "Donnerruf", "Funkenzunge", "Blitzstachel",
		"Aschegewitter", "Entladung", "Kettenblitz"]


func enemy_attack(e: Fighter, p_targets: Array[Fighter], base: int, kind: String, attack_name: String) -> void:
	# Der Roboter fängt Angriffe auf den Verbündeten ab, den er beschützt
	var targets: Array[Fighter] = []
	var mechanic := hero("mechanic")
	for t in p_targets:
		var actual := t
		if mechanic != null and mechanic.robot.is_alive() and mechanic.robot.protecting == t \
				and t != mechanic.robot and p_targets.size() == 1:
			float_text(t, "Roboter schützt!", Color("d9a441"), 26)
			actual = mechanic.robot
		elif t.has_meta("gedeckt_von"):
			# Deckung geben (Novize): einen Treffer fängt der Deckende ab
			var cover: Fighter = t.get_meta("gedeckt_von")
			# Deckung (Novize) hält einen Treffer, Abfangen (Rüstungsschmied) alle bis zu seinem nächsten Zug
			if not t.has_meta("gedeckt_alle") or not cover.is_alive():
				t.remove_meta("gedeckt_von")
				t.remove_meta("gedeckt_alle")
			if cover.is_alive() and cover != t:
				float_text(t, "Deckung!", Color("8fd3ff"), 26)
				zeige("deckung_funke", cover)
				actual = cover
		if not actual in targets:
			targets.append(actual)
	var names: Array[String] = []
	for t in targets:
		names.append(t.display_name)
	if e.element == "":
		add_log("%s: [b]%s[/b] auf %s" % [e.display_name, attack_name, ", ".join(names)])
	else:
		add_log("%s: [b]%s[/b] (%s) auf %s" % [e.display_name, attack_name, e.element, ", ".join(names)])
	status("%s: %s!" % [e.display_name, attack_name])

	var reactors := targets.filter(func(h: Fighter) -> bool: return h.reaction != "" and h.smoke == 0)
	var focus: Fighter = reactors[0] if not reactors.is_empty() else targets[0]
	var duration := zufall_range(0.75, 1.15)
	if kind == "melee":
		lunge(e, focus, duration, false, attack_name)
	else:
		for t in targets:
			projectile_bg(e, t, Elements.color(e.element), duration, attack_name)

	# Reaktion: 0 = verpasst, 1 = normal pariert/ausgewichen (25 % weniger Schaden), 2 = perfekt (Treffer abgewehrt + Klassen-Effekt)
	var grade := REACT_NONE
	if reactors.is_empty():
		wait(duration)
	else:
		await _flush()
		if setup.get("paradeschule", false) and focus == heroes[0]:
			parry_attempts += 1
		var answer: Variant = await controller.react(e, focus, duration)
		# Ältere Steuerer antworten mit ja/nein (ja = perfekt)
		grade = (REACT_PERFECT if answer else REACT_NONE) if answer is bool else int(answer)
	var success := grade == REACT_PERFECT
	if setup.get("paradeschule", false) and focus == heroes[0] and not reactors.is_empty():
		_ye_sagt(grade)
	# Effekt „Verfehlen“ auf dem Angreifer: Dieser Angriff geht daneben
	var daneben := Effekte.verfehlt(self, e)
	_getroffen.clear()
	# Mächtiger Blitzeinschlag (A21) bei den stärksten Angriffen der Blitz-Monster
	if attack_name in BLITZ_EINSCHLAG and not daneben:
		for t in targets:
			if t.is_alive():
				zeige("blitz_einschlag", t)

	for t in targets:
		if not t.is_alive():
			continue
		if daneben:
			float_text(t, "Verfehlt!", Color(Effekte.ARTEN.verfehlen.farbe))
			continue
		if t.smoke > 0:
			t.smoke -= 1
			var saved := calc_damage(e, t, base, kind, e.element)
			if t.smoke_source != null:
				t.smoke_source.credit().stat_blocked += saved
			float_text(t, "Verfehlt!", Color("d8d8e8"))
			continue
		if success and t.reaction != "":
			t.credit().stat_perfect += 1
			# Perfekt pariert oder ausgewichen: mehr Mana zurück
			if gain_mana(t, MANA_PERFECT) > 0:
				float_text(t, "+%d Mana" % roundi(t.max_mana * MANA_PERFECT), Color("6fa8ff"), 40)
			t.stat_blocked += calc_damage(e, t, base, kind, e.element)
			_last_crit = false
			_last_eff = 1.0
			skills.on_perfect_reaction(t, e)
		elif e.deadly:
			# Tödlicher Angriff: normal pariert bleiben 10 % des Lebens übrig, sonst fällt das Ziel sofort.
			# Einen ungeblockten Treffer übersteht jeder einmal mit 10 % (Marco, 11.11.); der Sternenschlund bleibt streng.
			var parried: bool = grade == REACT_NORMAL and t.reaction != "" and not e.get_meta("streng", false)
			var knapp: bool = not parried and not e.get_meta("streng", false) and not t.has_meta("toedlich_ueberlebt")
			if knapp:
				t.set_meta("toedlich_ueberlebt", true)
				parried = true
			float_text(t, ("Knapp überlebt!" if knapp else "Pariert – aber hart getroffen!") if parried else "TÖDLICH!",
					Color("cfe2ff") if parried else Color("ff4d4d"), 78)
			_last_crit = false
			_last_eff = 1.0
			# Schilde helfen gegen diesen Angriff nicht
			t.shields.clear()
			var rest := mini(t.hp, maxi(roundi(t.max_hp * (1.0 - DEADLY_PARRIED)), 1))
			apply_damage(t, t.hp - rest if knapp else (roundi(t.max_hp * DEADLY_PARRIED) if parried else t.hp), e)
		elif grade == REACT_NORMAL and t.reaction != "":
			# Normal pariert oder ausgewichen: nur ein Teil des Schadens kommt an
			float_text(t, "Pariert" if t.reaction == "parry" else "Ausgewichen", Color("cfe2ff"), 78)
			var lost := hit(e, t, base * (1.0 - NORMAL_REACT_BLOCK), kind, e.element)
			t.credit().stat_blocked += roundi(lost * NORMAL_REACT_BLOCK / (1.0 - NORMAL_REACT_BLOCK))
			_getroffen.append(t)
		else:
			hit(e, t, base, kind, e.element)
			_getroffen.append(t)
			skills.after_enemy_hit(e, t, kind)
	# Klingenkäfig: Wer im Käfig angreift, wird von den kreisenden Klingen geschnitten
	if e.has_meta("kaefig") and e.is_alive():
		var kaefig: Dictionary = e.get_meta("kaefig")
		hit(kaefig.quelle, e, 8, "melee")
		kaefig.zuege = int(kaefig.zuege) - 1
		if int(kaefig.zuege) <= 0:
			e.remove_meta("kaefig")
	# Perfekte Parade gegen einen Gepanzerten (Sternenfresser): Der Panzer ist kurz offen
	if success and e.plate < 1.0 and e.is_alive():
		e.stagger_turns = e.stagger_length
		float_text(e, "ERSCHÜTTERT!", Color("fff3b0"), 52)
		add_log("[color=#fff3b0][b]Der Sternenpanzer bekommt Risse![/b] Jetzt angreifen![/color]")
	refresh()
	wait(0.45)


# --- Schaden und Heilung ------------------------------------------------------

## Berechnet den Schaden eines Angriffs (ohne Schilde und Rüstungen des Ziels).
## kind: melee (Nahkampf), ranged (Fernkampf) oder magic (Magie)
func calc_damage(attacker: Fighter, target: Fighter, base: float, kind: String, element := "") -> int:
	var dmg := base * zufall_range(0.9, 1.1)
	var star := element == "Sternenkraft"
	_last_crit = false
	if attacker.atk_buff_turns > 0:
		dmg *= ATK_BUFF
	if kind == "melee":
		if attacker.back_row:
			dmg *= BACK_ROW_MELEE
		if target.back_row:
			dmg *= BACK_ROW_MELEE
	if target.waiting:
		dmg *= WAIT_DAMAGE
	if target.def_buff_turns > 0 and not star:
		dmg *= DEF_BUFF
	if attacker.blind_turns > 0:
		dmg *= 0.7
	if attacker.schwach_turns > 0:
		dmg *= 0.75
	if attacker.enraged:
		dmg *= BOSS_RAGE_MULT
	if target.vuln_turns > 0:
		dmg *= VULN_MULT
	if not star:
		dmg *= target.resist
	# Ausrüstung: Verteidigung gegen Nah- und Fernkampf, Widerstand gegen Magie
	if kind == "magic":
		dmg *= target.magieschutz
	elif kind == "melee" or kind == "ranged":
		dmg *= target.schutz
	# Sternenpanzer: Treffer prallen fast ab, bis eine perfekte Parade ihn erschüttert
	if target.plate < 1.0 and target.stagger_turns == 0:
		dmg *= target.plate
	_last_eff = Elements.multiplier(element, target.element)
	dmg *= _last_eff
	dmg *= skills.damage_bonus(attacker) * attacker.power
	# Fähigkeit auf höherer Stufe (Fähigkeiten-Baum): mehr Schaden
	dmg *= float(attacker.get_meta("stufen_mult", 1.0)) * float(attacker.get_meta("tempo_mult", 1.0))
	if attacker.is_ally():
		# Passive "Ruhige Hand": Der Bogenschütze trifft aus der hinteren Reihe öfter kritisch.
		var chance := CRIT_CHANCE
		if attacker.klass == "archer" and attacker.back_row:
			# Mit Fähigkeiten-Baum je nach Stufe von „Ruhige Hand“ und „Adlerauge“, sonst wie bisher
			if attacker.has_meta("faehigkeiten"):
				chance += 0.04 * skills.skill_level(attacker, "ruhige_hand") + 0.03 * skills.skill_level(attacker, "adlerauge")
			else:
				chance += 0.2
		# Jagdinstinkt: nach einem perfekten Ausweichen sicher kritisch
		var instinkt := attacker.has_meta("jagdinstinkt")
		if instinkt:
			attacker.remove_meta("jagdinstinkt")
			chance = 1.0
		if zufall() < chance:
			dmg *= CRIT_MULT
			_last_crit = true
			if attacker.klass == "archer" and skills.skill_level(attacker, "adlerauge") > 0 and attacker.has_meta("faehigkeiten") and not instinkt:
				float_text(attacker, "Adlerauge!", Color("f2c14e"), 40)
	return maxi(1, roundi(dmg))


## Angriff: Schaden berechnen und zufügen. Gibt die verlorenen LP zurück.
func hit(attacker: Fighter, target: Fighter, base: float, kind: String, element := "") -> int:
	if not target.is_alive():
		return 0
	# Effekt „Verfehlen“: Der nächste Angriff geht daneben
	if attacker.is_ally() and Effekte.verfehlt(self, attacker):
		float_text(target, "Verfehlt!", Color(Effekte.ARTEN.verfehlen.farbe))
		return 0
	var dmg := calc_damage(attacker, target, base, kind, element)
	_last_element = element
	var lost := apply_damage(target, dmg, attacker, kind)
	if dungeon != null:
		dungeon.on_hit(attacker, target, element, lost)
	return lost


## Zieht Leben ab (Festung, Rüstung, Schilde und Umwandlung eingerechnet).
## Gibt den tatsächlich verlorenen Lebensbetrag zurück.
func apply_damage(target: Fighter, amount: int, source: Fighter = null, kind := "") -> int:
	var crit := _last_crit
	var eff := _last_eff
	var element := _last_element
	_last_crit = false
	_last_eff = 1.0
	_last_element = ""
	if not target.is_alive():
		return 0
	if dungeon != null and dungeon.absorbs(target, amount, source):
		return 0
	if crit:
		crits += 1
	var tank := hero("tank")
	if target.is_ally() and tank != null and target != tank and tank.fortress and tank.is_alive():
		float_text(target, "Festung!", Color("6fa8ff"))
		var halved := roundi(amount * 0.5)
		tank.stat_blocked += amount - halved
		target = tank
		amount = halved
	if tank != null and target == tank and tank.fortress:
		tank.fortress_absorbed += amount

	amount = skills.mitigate(target, amount, kind)

	if target.shield_total() > 0 and amount > 0:
		var blocked_total := 0
		for giver: Fighter in target.shields.keys():
			var used := mini(target.shields[giver], amount)
			target.shields[giver] -= used
			amount -= used
			blocked_total += used
			giver.credit().stat_blocked += used
			if target.shields[giver] <= 0:
				target.shields.erase(giver)
		if blocked_total > 0:
			float_text(target, "Schild -%d" % blocked_total, Color("6fa8ff"), 24)

	# Umwandlung: Der Magier-Tank fängt die Hälfte mit Mana ab. Das lädt seine Ult.
	if target.klass == "tank" and amount > 0:
		var to_mana := mini(target.mana, amount / 2)
		target.mana -= to_mana
		amount -= to_mana
		target.stat_blocked += to_mana
		target.add_ult(to_mana * 1.5)
		if to_mana > 0:
			float_text(target, "-%d Mana" % to_mana, Color("6fa8ff"), 24)

	var lost := mini(amount, target.hp)
	target.hp -= lost
	_hp_changed(target)
	if source != null and source.is_ally() and not target.is_ally():
		source.credit().stat_damage += lost
	# Was der Roboter einsteckt, kommt bei niemand anderem an: zählt beim Mechaniker als abgewehrt
	if target.klass == "robot":
		target.credit().stat_blocked += lost
	elif target.is_ally():
		target.credit().stat_taken += lost

	if crit:
		float_text(target, "KRITISCH -%d" % amount, Color("ffd34d"))
	else:
		float_text(target, "-%d" % amount, Color("ff6b6b"))
	if eff > 1.0:
		float_text(target, "Sehr effektiv!", Color("ffe14d"), 52)
	elif eff < 1.0:
		float_text(target, "Wenig effektiv …", Color(0.75, 0.75, 0.8), 52)
	if on_field(target):
		# Harter Treffer: kritisch oder mindestens ein Viertel des Lebens auf einmal (das Bild hält kurz an und wackelt)
		var heavy := crit or lost * 4 >= target.max_hp
		_emit({type = "hit_fx", f = target, crit = crit, element = element, heavy = heavy})

	skills.after_damage(target, lost)
	if not target.is_alive():
		add_log("[color=red]%s ist besiegt![/color]" % target.display_name)
		skills.on_death(target)
		if not target.is_ally() and Sandbox.ENEMIES.get(target.klass, {}).has("beim_tod") and not target.has_meta("geflohen"):
			_beim_tod(target)
	refresh()
	return lost


## Letzte Glut (Glutgeist): explodiert beim Tod und trifft die vordere Reihe der Helden.
func _beim_tod(e: Fighter) -> void:
	if e.has_meta("explodiert"):
		return
	e.set_meta("explodiert", true)
	var tod: Dictionary = Sandbox.ENEMIES[e.klass].beim_tod
	add_log("[color=#ff8a3d][b]%s: %s![/b][/color]" % [e.display_name, tod.name])
	burst(e, Color("ff8a3d"), 200.0)
	var ziele := allies().filter(func(h: Fighter) -> bool: return not h.back_row)
	if ziele.is_empty():
		ziele = allies()
	for h: Fighter in ziele:
		apply_damage(h, maxi(1, roundi(float(tod.base) * e.power)), e, "magic")


## Giftwolken der Sporenkönigin im Bild (A9c2): so viele hängen gerade über den Helden.
func wolken(anzahl: int) -> void:
	_emit({type = "wolken", anzahl = anzahl})


## Glühende Kette zwischen zwei Helden zeigen (Kettenschmied „Gefesselt“); a = null nimmt sie weg. glut 1 oder 2 (Phase 2).
func fessel(a: Fighter, b: Fighter, glut: int) -> void:
	_emit({type = "fessel", a = a, b = b, glut = glut})


## Lava-Takt anzeigen: reihe "vorne"/"hinten" ("" = keine), stufe "warnung" oder "oben".
func zeige_lava(reihe: String, stufe: String) -> void:
	_emit({type = "lava", reihe = reihe, stufe = stufe})


## Heilt ein Ziel. "source" bekommt die Heilung in der Auswertung gutgeschrieben.
func heal(source: Fighter, target: Fighter, amount: int) -> int:
	# Heilung wächst mit der Stufe (der Novize rechnet seine Stärke schon selbst ein)
	if source != null and source.klass != "novize":
		amount = roundi(amount * source.power)
	# Fähigkeit auf höherer Stufe (Fähigkeiten-Baum): mehr Heilung
	if source != null:
		amount = roundi(amount * float(source.get_meta("stufen_mult", 1.0)))
	var healed := target.heal(amount)
	if source != null:
		source.credit().stat_heal += healed
	if on_field(target):
		_hp_changed(target)
		float_text(target, "+%d" % healed, Color("6dff8a"))
		_emit({type = "heal_fx", f = target})
	return healed


func give_shield(source: Fighter, target: Fighter, amount: int) -> void:
	target.add_shield(source, amount)
	float_text(target, "Schild +%d" % amount, Color("6fa8ff"))
