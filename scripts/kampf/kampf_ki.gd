class_name KampfKI
extends RefCounted
## Einfacher Computer-Spieler: für automatische Testkämpfe und die Novizen-Mitstreiter in der Kreuzweg-Demo.
## Entscheidet nur mit seinem eigenen Zufall (fester Startwert), damit Testläufe wiederholbar sind.
## "rules" ist das Objekt mit abilities / blocked_reason / choice_blocked / valid_targets (Skills).

var rng := RandomNumberGenerator.new()
## Nur für Messungen (tests/boss_messen.gd): Diese Boss-Mechaniken ignoriert der Computer (Aktionen wie "anker", "kette"
## oder Ziele wie "kuehlbecken"), so zeigt sich, ob ein Boss auch ohne sie zu schaffen ist.
static var ohne_mechanik: Array[String] = []


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
	# Ult immer sofort, sonst zufällig (Reihe wechseln nur selten)
	var pick: Dictionary = {}
	for ab in options:
		# (Meisterstück des Rüstungsschmieds nicht, solange noch ein Schild hält: sonst greift er nie an)
		if ab.id == "ult" and not (f.klass == "smith" and f.shield_total() > 0):
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
		target = targets[rng.randi() % targets.size()]
	return {ab = pick, target = target}


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
