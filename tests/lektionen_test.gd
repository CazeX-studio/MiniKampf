extends SceneTree
## Spielt alle Kämpfe der Kreuzweg-Demo (data/kaempfe.json) mehrfach mit dem Computer durch:
## Laufen sie ohne Fehler, und wie oft gewinnt ein durchschnittlicher Spieler (Parade in der Hälfte der Fälle)?
## Aufruf: Godot --headless --path . --script res://tests/lektionen_test.gd

## Mit welcher Stufe man den Kampf im normalen Ablauf erreicht
const LEVELS := {lektion_tempo = 2, lektion_faehigkeiten = 2, lektion_parieren = 3, lektion_reihen = 3, gruppenkampf = 4}
const RUNS := 30


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var harness: GDScript = load("res://tests/neu_kampf.gd")
	var problems := 0
	for kampf_id: String in LEVELS:
		var wins := 0
		var turns := 0
		for i in RUNS:
			BattleRequest.prepare(kampf_id, LEVELS[kampf_id])
			var node: Node = harness.new()
			node.start_seed = 500 + i
			node.setup = BattleRequest.setup
			root.add_child(node)
			var end := ""
			for line in node.protokoll.lines:
				if line.begins_with("ENDE"):
					end = line
			if end == "":
				problems += 1
				print("FEHLER: %s endet nicht" % kampf_id)
			if end == "ENDE Sieg":
				wins += 1
			turns += node.state.turns
			root.remove_child(node)
			node.free()
		print("%-22s Stufe %d: %2d von %d gewonnen, im Schnitt %d Züge" % [kampf_id, LEVELS[kampf_id], wins, RUNS, turns / RUNS])
	BattleRequest.kampf_id = ""
	quit(problems)
