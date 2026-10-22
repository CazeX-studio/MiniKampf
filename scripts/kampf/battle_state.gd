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
const MANA_REGEN := 6
const BUFF_TURNS := 2
const ATK_BUFF := 1.4
const DEF_BUFF := 0.7
const VULN_MULT := 1.3
## Zwischen zwei Wellen heilen sich die Helden um diesen Anteil.
const WAVE_HEAL := 0.25
## Reaktion auf einen Gegner-Angriff (Ring und Balken): verpasst, normal, perfekt
const REACT_NONE := 0
const REACT_NORMAL := 1
const REACT_PERFECT := 2
## Normal pariert oder ausgewichen: so viel weniger Schaden
const NORMAL_REACT_BLOCK := 0.25
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
var current: Fighter
var battle_over := false
var won := false
## Zeitpunkt des aktuellen Zuges auf der Zugleiste
var now := 0.0
var skills: Skills
## Dungeon-Regeln (Pilzhöhle), sonst null
var dungeon: Pilzhoehle
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
		_spawn_wave(int(setup.get("start_welle", 0)))
		await _battle_loop()
		return
	waves = Sandbox.ENCOUNTERS[encounter].waves
	if Sandbox.ENCOUNTERS[encounter].get("dungeon", "") == "pilzhoehle":
		dungeon = Pilzhoehle.new(self)
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
func projectile_bg(from: Fighter, to: Fighter, color: Color, duration := 0.3) -> void:
	_emit({type = "projectile", from = from, to = to, color = color, duration = duration, blocking = false})


func lunge(f: Fighter, target: Fighter, duration: float, blocking := true) -> void:
	_emit({type = "lunge", f = f, target = target, duration = duration, blocking = blocking})


## Kurze Pause in der Anzeige.
func wait(seconds: float) -> void:
	_emit({type = "wait", seconds = seconds})


## Leuchten an einer Figur (z. B. bei Siegeln oder Explosionen).
func burst(f: Fighter, color: Color, radius := 160.0) -> void:
	if on_field(f):
		_emit({type = "burst", f = f, color = color, radius = radius})


func screen_flash(color: Color) -> void:
	_emit({type = "flash", color = color})


## Kleiner Hüpfer einer Figur.
func hop(f: Fighter) -> void:
	_emit({type = "hop", f = f})


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
		else:
			h = Fighter.new(spec.get("name", data.hero), id, data.title, true, data.hp + LEVEL_HP * level_bonus, data.tempo, data.color)
			h.max_mana = data.mana + LEVEL_MANA * level_bonus if data.mana > 0 else 0
		h.look = spec.get("aussehen", "")
		h.mana = data.get("start_mana", h.max_mana)
		h.reaction = spec.get("reaktion", data.reaction)
		h.back_row = data.back
		heroes.append(h)
		if setup.has("helden"):
			team.append(id)
		h.ult = float(spec.get("ult", 0.0))
		if spec.has("traenke"):
			h.wares = {heiltrank = int(spec.traenke)}
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
			# Stufenabstand zu den Gegnern (nur wenn die Gegner eine Stufe haben)
			if setup.has("gegner_stufe"):
				h.power *= gap_hero_factor(level_gap(int(setup.gegner_stufe), level_bonus + 1))
				_gap_levels.append(level_bonus + 1)
			var buddies: Array[Fighter] = h.monsters.duplicate()
			if h.robot != null:
				buddies.append(h.robot)
			for b in buddies:
				b.power = h.power
				b.max_hp = roundi(b.max_hp * float(spec.macht))
				b.hp = b.max_hp
		_emit({type = "spawn", f = h, place = "hero", index = i, hp = h.hp})
		h.next_time = h.turn_delay() * zufall_range(0.2, 1.0)

	var mechanic := hero("mechanic")
	if mechanic != null:
		add_companion(mechanic.robot)
	var tamer := hero("tamer")
	if tamer != null:
		add_companion(tamer.active_monster)


func add_companion(f: Fighter) -> void:
	companions.append(f)
	f.on_bench = false
	_emit({type = "spawn", f = f, place = "robot" if f.klass == "robot" else "monster", index = 0, hp = f.hp})
	f.next_time = now + f.turn_delay() * zufall_range(0.3, 1.0)


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
	elif dungeon != null:
		dungeon.on_wave(index)
	elif "boss" in ids:
		add_log("[b]Ein Steinwächter (Erde) und seine Begleiter greifen an![/b]")
	else:
		add_log("[b]Monster mit vier Elementen greifen an![/b] Auf die Farbe am Namen achten.")


## Langer Lernkampf: Jede Phase (Lektion) bringt eigene Regeln mit – erlaubte Fähigkeiten, Reaktion an/aus,
## Paraden-Ziel, Pflicht-Aktion, Ansage und Ye-Erklärungen.
func _apply_phase(index: int) -> void:
	var phase: Dictionary = setup.phasen[index]
	setup.erlaubt = phase.get("erlaubt", [])
	setup.ziel_paraden = int(phase.get("ziel_paraden", 0))
	setup.zuerst = phase.get("zuerst", "")
	setup.hinweise = phase.get("hinweise", {})
	setup.ansage = phase.get("ansage", "")
	first_done = false
	var player := heroes[0]
	player.reaction = Sandbox.CLASSES[player.klass].reaction if phase.get("reaktion", true) else ""
	parry_base = player.stat_perfect


## Ersetzt alle Gegner durch neue (Kennungen aus Sandbox.ENEMIES).
func spawn_enemies(ids: Array) -> void:
	for e in enemies:
		_emit({type = "despawn", f = e})
	enemies.clear()
	# Gruppenkampf: Bosse wie der Sternenfresser haben mehr Leben, je mehr Spieler mitkämpfen (setup.gegner_leben)
	var hp_scale: float = Sandbox.HP_SCALE[heroes.size() - 1] * float(setup.get("gegner_leben", 1.0))
	# Monster in der Wildnis haben eine Stufe (setup.gegner_stufe): mehr Leben und härtere Treffer
	var level := int(setup.get("gegner_stufe", 1))
	var has_big := false
	for id: String in ids:
		has_big = has_big or Sandbox.ENEMIES[id].get("big", false)
	for i in ids.size():
		var id: String = ids[i]
		var data: Dictionary = Sandbox.ENEMIES[id]
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
		if data.has("title"):
			e.display_name = data.title
		enemies.append(e)
		e.intent = skills.enemy_intent(e)
		_emit({type = "spawn", f = e, place = "boss_wave" if has_big else "wave", index = i, hp = e.hp})
		e.next_time = now + e.turn_delay() * zufall_range(0.2, 1.0)


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
		if f.is_alive():
			turns += 1
			if f.is_ally():
				await _player_turn(f)
			else:
				await _enemy_turn(f)
		f.next_time += f.turn_delay()
		current = null
		_emit({type = "turn", f = null})
		if await _check_end():
			return


## Was zu Beginn jedes eigenen Zuges passiert (Abklingzeiten, Mana, Klassen-Mechaniken).
func _begin_turn(f: Fighter) -> void:
	for id: String in f.cooldowns.keys():
		f.cooldowns[id] = maxi(f.cooldowns[id] - 1, 0)
	f.atk_buff_turns = maxi(f.atk_buff_turns - 1, 0)
	f.def_buff_turns = maxi(f.def_buff_turns - 1, 0)
	f.vuln_turns = maxi(f.vuln_turns - 1, 0)
	f.blind_turns = maxi(f.blind_turns - 1, 0)
	f.stagger_turns = maxi(f.stagger_turns - 1, 0)
	if f.max_mana > 0:
		f.mana = mini(f.mana + MANA_REGEN, f.max_mana)
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
	while true:
		await _flush()
		var command: Dictionary = await controller.choose_action(f)
		if is_valid(f, command.ab, command.target):
			execute(f, command.ab, command.target)
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
	if ab.has("cd"):
		f.cooldowns[id] = ab.cd + 1

	if id == "row":
		f.back_row = not f.back_row
		add_log("%s wechselt nach %s." % [f.display_name, f.row_name()])
		move_to_row(f)
		return
	_emit({type = "cast", f = f, ult = id == "ult"})
	if id == "ult":
		f.ult = 0.0
		f.credit().stat_ults += 1
		add_log("[color=#f2c14e][b]%s entfesselt %s![/b][/color]" % [f.display_name, ab.name])
		wait(0.35)
	elif ab.has("duet"):
		add_log("[color=#ffa8e0][b]Duett: %s![/b][/color]" % ab.name)

	skills.execute(f, ab, target)
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
		var attack: Dictionary = data.attacks[e.step % data.attacks.size()]
		var targets: Array[Fighter] = []
		if attack.get("all", false):
			targets = allies()
		elif attack.kind == "melee":
			targets = [pick_target()]
		else:
			targets = [pick_target(attack.get("back", false), true)]
		await enemy_attack(e, targets, attack.base, attack.kind, attack.name)
		e.step += 1
		# Zeitbombe (Sternenfresser): nach so vielen eigenen Zügen stirbt die ganze Gruppe
		if data.has("wipe_nach") and e.is_alive() and e.step >= int(data.wipe_nach):
			wipe(data.get("wipe_text", "Zu spät!"))
	e.intent = skills.enemy_intent(e)


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
		lunge(e, focus, duration, false)
	else:
		for t in targets:
			projectile_bg(e, t, Elements.color(e.element), duration)

	# Reaktion: 0 = verpasst, 1 = normal pariert/ausgewichen (25 % weniger Schaden), 2 = perfekt (Treffer abgewehrt + Klassen-Effekt)
	var grade := REACT_NONE
	if reactors.is_empty():
		wait(duration)
	else:
		await _flush()
		var answer: Variant = await controller.react(e, focus, duration)
		# Ältere Steuerer antworten mit ja/nein (ja = perfekt)
		grade = (REACT_PERFECT if answer else REACT_NONE) if answer is bool else int(answer)
	var success := grade == REACT_PERFECT

	for t in targets:
		if not t.is_alive():
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
			t.stat_blocked += calc_damage(e, t, base, kind, e.element)
			_last_crit = false
			_last_eff = 1.0
			skills.on_perfect_reaction(t, e)
		elif grade == REACT_NORMAL and t.reaction != "":
			# Normal pariert oder ausgewichen: nur ein Teil des Schadens kommt an
			float_text(t, "Pariert" if t.reaction == "parry" else "Ausgewichen", Color("cfe2ff"), 78)
			var lost := hit(e, t, base * (1.0 - NORMAL_REACT_BLOCK), kind, e.element)
			t.credit().stat_blocked += roundi(lost * NORMAL_REACT_BLOCK / (1.0 - NORMAL_REACT_BLOCK))
		else:
			hit(e, t, base, kind, e.element)
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
	if target.def_buff_turns > 0 and not star:
		dmg *= DEF_BUFF
	if attacker.blind_turns > 0:
		dmg *= 0.7
	if attacker.enraged:
		dmg *= BOSS_RAGE_MULT
	if target.vuln_turns > 0:
		dmg *= VULN_MULT
	if not star:
		dmg *= target.resist
	# Sternenpanzer: Treffer prallen fast ab, bis eine perfekte Parade ihn erschüttert
	if target.plate < 1.0 and target.stagger_turns == 0:
		dmg *= target.plate
	_last_eff = Elements.multiplier(element, target.element)
	dmg *= _last_eff
	dmg *= skills.damage_bonus(attacker) * attacker.power
	if attacker.is_ally():
		# Passive "Ruhige Hand": Der Bogenschütze trifft aus der hinteren Reihe öfter kritisch.
		var chance := CRIT_CHANCE
		if attacker.klass == "archer" and attacker.back_row:
			chance += 0.2
		if zufall() < chance:
			dmg *= CRIT_MULT
			_last_crit = true
	return maxi(1, roundi(dmg))


## Angriff: Schaden berechnen und zufügen. Gibt die verlorenen LP zurück.
func hit(attacker: Fighter, target: Fighter, base: float, kind: String, element := "") -> int:
	if not target.is_alive():
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
	refresh()
	return lost


## Heilt ein Ziel. "source" bekommt die Heilung in der Auswertung gutgeschrieben.
func heal(source: Fighter, target: Fighter, amount: int) -> int:
	# Heilung wächst mit der Stufe (der Novize rechnet seine Stärke schon selbst ein)
	if source != null and source.klass != "novize":
		amount = roundi(amount * source.power)
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
