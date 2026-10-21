extends SceneTree
## Spielt die Monster in der Wildnis (Weg nach Grünwacht, Waldboden) mit jeder Klasse allein durch:
## Laufen die Kämpfe ohne Fehler, und wie oft gewinnt ein durchschnittlicher Spieler auf der Stufe des Monsters?
## (Allein leveln muss möglich sein, design.md.) Zahlen vorläufig, Feinschliff am Ende.
## Aufruf: Godot --headless --path . --script res://tests/wildnis_test.gd  (-- --kurz: nur 3 Läufe je Kampf)

const RUNS := 8
## So oft muss man mindestens gewinnen (allein, auf der Stufe des Monsters). Heiler wie der Ritualist sind allein
## am langsamsten; wie stark einzelne Klassen allein sind, kommt in den Feinschliff am Ende.
const MIN_WIN_RATE := 0.55


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var harness: GDScript = load("res://tests/neu_kampf.gd")
	var runs := 3 if "--kurz" in OS.get_cmdline_user_args() else RUNS
	var problems := 0
	var wild := GameData.wild_monsters()
	var classes: Array = GameData.get_file("klassen").reihenfolge
	var total := {}
	for klasse: String in classes:
		var line := "%-14s" % klasse
		var class_wins := 0
		var class_runs := 0
		for index in wild.size():
			var m: Dictionary = wild[index]
			var wins := 0
			for i in runs:
				BattleRequest.prepare("wild:%d" % index, m.stufe, 0, klasse)
				var node: Node = harness.new()
				node.start_seed = 900 + i * 7 + index
				node.setup = BattleRequest.setup
				root.add_child(node)
				var end := ""
				for l in node.protokoll.lines:
					if l.begins_with("ENDE"):
						end = l
				if end == "" or end == "ENDE Abbruch":
					problems += 1
					print("FEHLER: %s gegen Monster %d endet nicht" % [klasse, index])
				if end == "ENDE Sieg":
					wins += 1
				root.remove_child(node)
				node.free()
			line += " %d" % wins
			class_wins += wins
			class_runs += runs
			total[index] = int(total.get(index, 0)) + wins
		var rate := float(class_wins) / class_runs
		print("%s  → %d %%" % [line, roundi(rate * 100)])
		if rate < MIN_WIN_RATE:
			problems += 1
			print("FEHLER: %s gewinnt allein zu selten (%d %%)" % [klasse, roundi(rate * 100)])
	print("Je Monster (alle Klassen):")
	for index in wild.size():
		var m: Dictionary = wild[index]
		print("  %2d %-16s %-48s Stufe %d: %d %%" % [index, m.karte, ", ".join(m.gegner), m.stufe,
				roundi(100.0 * total[index] / (runs * classes.size()))])
	BattleRequest.kampf_id = ""
	print("Wildnis: %s" % ("alles richtig" if problems == 0 else "%d Fehler" % problems))
	quit(problems)
