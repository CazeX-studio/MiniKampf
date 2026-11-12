class_name KampfKI
extends RefCounted
## Einfacher Computer-Spieler: für automatische Testkämpfe und die Novizen-Mitstreiter in der Kreuzweg-Demo.
## Entscheidet nur mit seinem eigenen Zufall (fester Startwert), damit Testläufe wiederholbar sind.
## "rules" ist das Objekt mit abilities / blocked_reason / choice_blocked / valid_targets (Skills).

var rng := RandomNumberGenerator.new()
## Nur für Messungen (tests/boss_messen.gd): Diese Boss-Mechaniken ignoriert der Computer (Aktionen wie "anker", "kette"
## oder Ziele wie "kuehlbecken"), so zeigt sich, ob ein Boss auch ohne sie zu schaffen ist.
static var ohne_mechanik: Array[String] = []
## Nur für Messungen (tests/klassen_messen.gd, BALANCING.md): kluge Spielweise. Der Computer drückt Schutz und Schwächen
## nur, wenn sie gerade etwas bringen, spannt den Bogen vor dem Schuss und zielt mit Einzelziel-Fähigkeiten auf den
## stärksten Gegner. Im Spiel bleibt es aus (die Mitstreiter spielen wie bisher).
static var klug := false


func _init(p_seed: int) -> void:
	rng.seed = p_seed


## Wählt eine Fähigkeit und ein Ziel. Gibt {ab, target} zurück.
func choose(rules: Skills, f: Fighter) -> Dictionary:
	var options: Array[Dictionary] = []
	for ab in rules.abilities(f):
			# Abwarten und Deckung geben nimmt der Computer nicht (er soll mitkämpfen und seinen Platz halten)
		if ohne_mechanik.has(str(ab.id)):
			continue
		if rules.blocked_reason(f, ab) != "" or ab.id == "abwarten" or ab.id == "deckung":
			continue
		if ab.target == "choice":
			for choice: Dictionary in ab.choices:
				if rules.choice_blocked(f, ab, choice) != "":
					continue
				var picked := ab.duplicate()
				picked.choice = choice.id
				picked.target = choice.get("then", ab.get("then", "none"))
				if picked.target == "none" or not rules.valid_targets(f, picked).is_empty():
					options.append(picked)
		elif ab.target == "none" or not rules.valid_targets(f, ab).is_empty():
			options.append(ab)
	if klug:
		var sinnvoll := options.filter(func(ab: Dictionary) -> bool: return _klug_erlaubt(rules, f, ab))
		if not sinnvoll.is_empty():
			options = sinnvoll
	# Rüstungsschmied: die Rüstung tragen, die zu den meisten Gegnern passt, und sonst nicht wechseln
	# (jeder Wechsel kostet einen Zug und die ganze Härte)
	var pick: Dictionary = {}
	if f.klass == "smith":
		var passend := _beste_ruestung(rules)
		for ab in options:
			if ab.id == "armor" and str(ab.get("choice", "")) == passend and f.armor != passend and not f.has_meta("meisterstueck"):
				pick = ab
		options = options.filter(func(ab: Dictionary) -> bool: return ab.id != "armor")
		# Allein kämpfend: keine Schutz-Knöpfe, die nichts bringen (Bedrohung ohne Gruppe, Schutz, der schon wirkt),
		# sonst schlägt er kaum zu und der Kampf zieht sich endlos
		if rules.c.allies().filter(func(h: Fighter) -> bool: return h != f and h.is_alive()).is_empty():
			var schon_geschuetzt := f.def_buff_turns > 0 or f.shield_total() > 0
			options = options.filter(func(ab: Dictionary) -> bool:
				return not (ab.id in ["anvil", "gemeinsame_haerte"] or (ab.id == "reinforce" and schon_geschuetzt)
						or (ab.id == "gluehend" and f.has_meta("gluehend"))))
	# Ult immer sofort, sonst zufällig (Reihe wechseln nur selten)
	for ab in options:
		# (Meisterstück des Rüstungsschmieds nicht, solange noch ein Schild hält: sonst greift er nie an)
		if ab.id == "ult" and not (f.klass == "smith" and f.shield_total() > 0) and pick.is_empty():
			pick = ab
	# Hammerbrüder: Holen beide zum Doppelschlag aus, einen stören (das täte jede Gruppe)
	if pick.is_empty():
		for ab in options:
			# Kettenschmied: wackelnden Anker festhämmern, Gefesselte befreien
			if ab.id in ["stoeren", "anker", "kette"] and not ohne_mechanik.has(str(ab.id)):
				pick = ab
			# Sporenkönigin: ab drei Giftwolken eine vertreiben (bei fünf fällt die Gruppe)
			if ab.id == "clear_cloud" and rules.c.dungeon is Pilzhoehle and (rules.c.dungeon as Pilzhoehle).clouds >= 3:
				pick = ab
			# Vorbote (A9b2): Wer das Splitterlicht hält, greift an und reicht es weiter, bevor es zu sehr brennt;
			# die anderen halten mit Laternen das Feld hell
			if rules.c.dungeon is Pilzhoehle and not ohne_mechanik.has(str(ab.id)):
				var dunkel := (rules.c.dungeon as Pilzhoehle).darkness
				if ab.id == "pass_light" and f.light_turns >= 2 and rng.randf() < 0.7:
					pick = ab
				if ab.id == "lantern" and not f.light and dunkel > Pilzhoehle.HELL_GENUG and rng.randf() < 0.6:
					pick = ab
	# Lava-Takt (Vulkanschmiede): Ist die Lava in der eigenen Reihe angekündigt, meist die Reihe wechseln
	# (mit wenig Leben immer, sonst in der Hälfte der Fälle; ein Zug zum Ausweichen lohnt sich nicht immer)
	if pick.is_empty() and rules.c.lava != null and rules.c.lava.angekuendigt == ("hinten" if f.back_row else "vorne") \
			and (f.hp * 2 < f.max_hp or rng.randf() < 0.5):
		for ab in options:
			if ab.id == "row":
				pick = ab
	if pick.is_empty():
		var weighted: Array[Dictionary] = []
		for ab in options:
			# Reihe wechseln nur selten, der schwache Schildstoß nur manchmal
			if (ab.id != "row" or rng.randf() < 0.15) and (ab.id != "schildstoss" or rng.randf() < 0.3):
				weighted.append(ab)
		if weighted.is_empty():
			weighted = options
		# Nichts geht (z. B. festgehalten und ohne Mana): irgendetwas, das erlaubt ist
		if weighted.is_empty():
			for ab in rules.abilities(f):
				if rules.blocked_reason(f, ab) == "":
					weighted.append(ab)
		pick = weighted[rng.randi() % weighted.size()]
		# Klug: Der Bogen wird vor dem Schuss gespannt, ein gespannter Bogen schießt
		if klug and f.klass == "archer":
			for ab in options:
				if (ab.id == "charge" and pick.id == "shot" and not f.charged) or (ab.id == "shot" and f.charged):
					pick = ab
	var target: Fighter = null
	if pick.target != "none":
		var targets := rules.valid_targets(f, pick)
		# Kühlbecken (Kettenschmied): hineinschlagen, um nass zu werden, solange er noch Panzer hat (A9b: sonst kommt
		# kaum Schaden durch), nicht, wenn man schon nass ist; nass gezielt den Kettenschmied treffen
		var ohne_becken := targets.filter(func(t: Fighter) -> bool: return t.klass != "kuehlbecken")
		if not ohne_becken.is_empty() and ohne_becken.size() < targets.size():
			var ks := _kettenschmied(rules)
			var panzer := ks != null and ks.panzer > 0
			if ohne_mechanik.has("kuehlbecken") or f.has_meta("nass") or rng.randf() < (0.4 if panzer else 0.85):
				targets.assign(ohne_becken)
				var boss := ohne_becken.filter(func(t: Fighter) -> bool: return t.klass == "kettenschmied_2")
				if panzer and f.has_meta("nass") and not boss.is_empty() and not ohne_mechanik.has("kuehlbecken"):
					targets.assign(boss)
			else:
				targets.assign(targets.filter(func(t: Fighter) -> bool: return t.klass == "kuehlbecken"))
		targets.assign(_boss_ziele(rules, targets))
		if klug:
			targets.assign(_kluge_ziele(f, pick, targets))
		target = targets[rng.randi() % targets.size()]
	return {ab = pick, target = target}


## Kluge Spielweise: Lohnt sich diese Fähigkeit gerade? (Schutz nur, wenn keiner wirkt; Bedrohung nur, wenn ein
## Verbündeter wenig Leben hat; Gesammeltes erst ausgeben, wenn genug da ist.)
func _klug_erlaubt(rules: Skills, f: Fighter, ab: Dictionary) -> bool:
	var m: Fighter = f.active_monster
	var gegner: Array[Fighter] = rules.c.alive(rules.c.enemies)
	match str(ab.id):
		"schwachstelle", "kaefig", "dissonanz", "reinforce", "abfangen", "polar", "partner":
			if not _passende_ziele(str(ab.id), rules.valid_targets(f, ab)).is_empty():
				return str(ab.id) != "polar" or f.res_def >= 3
			return false
		"anvil":
			return f.taunt == 0 and rules.c.allies().any(func(h: Fighter) -> bool: return h != f and h.is_alive() and h.hp * 2 < h.max_hp)
		"gluehend":
			return not f.has_meta("gluehend")
		"gemeinsame_haerte":
			return f.hard >= 3 and f.def_buff_turns == 0
		"storm":
			return f.blades >= Fighter.MAX_BLADES
		"mondschild":
			return f.res_def >= 3 and f.shield_total() == 0
		"comet":
			return f.res_off >= 3 and f.atk_buff_turns == 0
		"meteor":
			return f.res_off >= 3
		"lullaby":
			return not f.has_meta("wiegenlied")
		"care":
			return m != null and m.hp * 10 < m.max_hp * 6
		"cheer":
			return m != null and m.atk_buff_turns == 0
		"wachstum":
			return m != null and not m.has_meta("wachstum")
		"einschuechtern":
			return gegner.any(func(e: Fighter) -> bool: return e.schwach_turns == 0)
	return true


## Kluge Spielweise: Ziele, bei denen die Fähigkeit etwas bringt (noch nicht geschwächt, noch nicht geschützt).
func _passende_ziele(id: String, targets: Array[Fighter]) -> Array[Fighter]:
	var gut: Array[Fighter] = []
	for t: Fighter in targets:
		var passt := true
		match id:
			"schwachstelle":
				passt = t.vuln_turns == 0 and not t.passive
			"kaefig":
				passt = not t.has_meta("kaefig") and not t.passive
			"dissonanz":
				passt = t.schwach_turns == 0 and not t.passive
			"net":
				passt = not t.passive
			"reinforce":
				passt = t.def_buff_turns == 0 and t.shield_total() == 0
			"abfangen":
				passt = t.hp * 10 < t.max_hp * 6 and not t.has_meta("gedeckt_von")
			"polar":
				passt = t.def_buff_turns == 0
			"partner":
				passt = t.atk_buff_turns == 0
		if passt:
			gut.append(t)
	return gut


## Kluge Spielweise: Schwächen auf den stärksten Gegner, Schutz auf den Verbündeten mit dem wenigsten Leben.
func _kluge_ziele(f: Fighter, pick: Dictionary, targets: Array[Fighter]) -> Array[Fighter]:
	var id := str(pick.id)
	if not id in ["schwachstelle", "kaefig", "dissonanz", "net", "reinforce", "abfangen", "polar", "partner"]:
		return targets
	var gut := _passende_ziele(id, targets)
	if gut.is_empty():
		return targets
	if id == "partner":
		return gut
	var feind := id in ["schwachstelle", "kaefig", "dissonanz", "net"]
	var bestes: Fighter = gut[0]
	for t: Fighter in gut:
		if (feind and t.hp > bestes.hp) or (not feind and float(t.hp) / t.max_hp < float(bestes.hp) / bestes.max_hp):
			bestes = t
	return [bestes] as Array[Fighter]


## Wut-Phasen (A9b3): Was jede Gruppe tun würde. Hammerbrüder im Gleichschritt: den gesünderen Bruder schlagen.
## Sporenkönigin mit Zwillingen in Wut: die Knospen zuerst. Mit ohne_mechanik ("gleichschritt", "knospen") das Gegenteil.
func _boss_ziele(rules: Skills, targets: Array[Fighter]) -> Array[Fighter]:
	var d: DungeonRegeln = rules.c.dungeon
	if d is Vulkanschmiede and (d as Vulkanschmiede).modus == "gleichschritt":
		var brueder := targets.filter(func(t: Fighter) -> bool: return t.klass in Vulkanschmiede.BRUEDER)
		if brueder.size() == 2:
			brueder.sort_custom(func(a: Fighter, b: Fighter) -> bool: return float(a.hp) / a.max_hp > float(b.hp) / b.max_hp)
			if ohne_mechanik.has("gleichschritt"):
				return [brueder[1]] as Array[Fighter]
			if rng.randf() < 0.7:
				return [brueder[0]] as Array[Fighter]
	if d is Pilzhoehle and (d as Pilzhoehle).queen_mode == "zwillinge":
		var knospen := targets.filter(func(t: Fighter) -> bool: return t.klass == "sporenling")
		var rest := targets.filter(func(t: Fighter) -> bool: return t.klass != "sporenling")
		if ohne_mechanik.has("knospen") and not rest.is_empty():
			var r: Array[Fighter] = []
			r.assign(rest)
			return r
		if (d as Pilzhoehle).queen_wut and not knospen.is_empty() and rng.randf() < 0.7 and not ohne_mechanik.has("knospen"):
			var k: Array[Fighter] = []
			k.assign(knospen)
			return k
	return targets


## Welche Rüstung des Schmieds zu den meisten lebenden Gegnern passt (nach der Art ihres ersten Angriffs).
func _beste_ruestung(rules: Skills) -> String:
	var zahl := {"melee": 0, "magic": 0, "ranged": 0}
	for e: Fighter in rules.c.alive(rules.c.enemies):
		var angriffe: Array = Sandbox.ENEMIES.get(e.klass, {}).get("attacks", [])
		var art := str(angriffe[0].get("kind", "melee")) if not angriffe.is_empty() else "melee"
		if zahl.has(art):
			zahl[art] += 1
	var beste := "melee"
	for art: String in zahl:
		if int(zahl[art]) > int(zahl[beste]):
			beste = art
	return beste


func _kettenschmied(rules: Skills) -> Kettenschmied:
	var d: DungeonRegeln = rules.c.dungeon
	return (d as Vulkanschmiede).ks if d is Vulkanschmiede else null


## Perfekte Reaktion: klappt mit der angegebenen Wahrscheinlichkeit (Tests: die Hälfte, Mitstreiter: selten).
func react(chance := 0.5) -> bool:
	return rng.randf() < chance


## Reaktion mit Stufe: 2 = perfekt, 1 = normal (25 % weniger Schaden), 0 = verpasst.
func react_grade(perfect_chance: float, normal_chance: float) -> int:
	var roll := rng.randf()
	if roll < perfect_chance:
		return 2
	if roll < perfect_chance + normal_chance:
		return 1
	return 0


func choose_option(options: Array[Dictionary]) -> String:
	return options[rng.randi() % options.size()].id
