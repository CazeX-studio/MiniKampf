class_name KampfKI
extends RefCounted
## Einfacher Computer-Spieler: für automatische Testkämpfe und die Novizen-Mitstreiter in der Kreuzweg-Demo.
## Entscheidet nur mit seinem eigenen Zufall (fester Startwert), damit Testläufe wiederholbar sind.
## "rules" ist das Objekt mit abilities / blocked_reason / choice_blocked / valid_targets (Skills).

var rng := RandomNumberGenerator.new()


func _init(p_seed: int) -> void:
	rng.seed = p_seed


## Wählt eine Fähigkeit und ein Ziel. Gibt {ab, target} zurück.
func choose(rules: Skills, f: Fighter) -> Dictionary:
	var options: Array[Dictionary] = []
	for ab in rules.abilities(f):
			# Abwarten und Deckung geben nimmt der Computer nicht (er soll mitkämpfen und seinen Platz halten)
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
		pick = weighted[rng.randi() % weighted.size()]
	var target: Fighter = null
	if pick.target != "none":
		var targets := rules.valid_targets(f, pick)
		target = targets[rng.randi() % targets.size()]
	return {ab = pick, target = target}


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
