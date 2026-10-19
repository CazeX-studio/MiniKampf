class_name KampfKI
extends RefCounted
## Einfacher Computer-Spieler für automatische Testkämpfe.
## Entscheidet nur mit seinem eigenen Zufall (fester Startwert), damit Testläufe wiederholbar sind.
## "rules" ist das Objekt mit abilities / blocked_reason / choice_blocked / valid_targets (Skills).

var rng := RandomNumberGenerator.new()


func _init(p_seed: int) -> void:
	rng.seed = p_seed


## Wählt eine Fähigkeit und ein Ziel. Gibt {ab, target} zurück.
func choose(rules: Skills, f: Fighter) -> Dictionary:
	var options: Array[Dictionary] = []
	for ab in rules.abilities(f):
		if rules.blocked_reason(f, ab) != "":
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
		if ab.id == "ult":
			pick = ab
	if pick.is_empty():
		var weighted: Array[Dictionary] = []
		for ab in options:
			if ab.id != "row" or rng.randf() < 0.15:
				weighted.append(ab)
		if weighted.is_empty():
			weighted = options
		pick = weighted[rng.randi() % weighted.size()]
	var target: Fighter = null
	if pick.target != "none":
		var targets := rules.valid_targets(f, pick)
		target = targets[rng.randi() % targets.size()]
	return {ab = pick, target = target}


## Perfekte Reaktion klappt in der Hälfte der Fälle.
func react() -> bool:
	return rng.randf() < 0.5


func choose_option(options: Array[Dictionary]) -> String:
	return options[rng.randi() % options.size()].id
