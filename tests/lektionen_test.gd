extends SceneTree
## Spielt alle Kämpfe der Kreuzweg-Demo (data/kaempfe.json) mehrfach mit dem Computer durch:
## Laufen sie ohne Fehler, und wie oft gewinnt ein durchschnittlicher Spieler (Parade in der Hälfte der Fälle)?
## Aufruf: Godot --headless --path . --script res://tests/lektionen_test.gd

## Mit welcher Stufe man den Kampf im normalen Ablauf erreicht
const LEVELS := {
	"lektion_tempo": 2, "lektion_faehigkeiten": 2, "lektion_parieren": 3, "lektion_reihen": 3, "gruppenkampf": 4,
	"probe:tank": 5, "probe:twilight": 5, "probe:mechanic": 5, "probe:quartermaster": 5, "probe:smith": 5,
	"probe:blade": 5, "probe:singer": 5, "probe:archer": 5, "probe:tamer": 5, "probe:ritualist": 5, "probe:kunoichi": 5,
}
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
			# Lektion 1 und 2: Der Novize kann noch nicht parieren
			if not GameData.battle(kampf_id).get("reaktion", true):
				for line in node.protokoll.lines:
					if line.contains("Du reagierst perfekt"):
						problems += 1
						print("FEHLER: %s: Parieren schon möglich" % kampf_id)
			# Lektion mit vorgegebener erster Aktion („Nach hinten“): vorher trifft der Spieler nichts
			if kampf_id == "lektion_reihen":
				var lines: PackedStringArray = node.protokoll.lines
				var moved := -1
				var first_hit := -1
				for n in lines.size():
					if moved < 0 and lines[n] == "LOG Du wechselt nach hinten.":
						moved = n
					if first_hit < 0 and lines[n].begins_with("TXT Rüpelkobold:"):
						first_hit = n
				if moved < 0 or (first_hit >= 0 and first_hit < moved):
					problems += 1
					print("FEHLER: Lektion 4 beginnt nicht mit „Nach hinten“")
			if end == "ENDE Sieg":
				wins += 1
			turns += node.state.turns
			root.remove_child(node)
			node.free()
		print("%-22s Stufe %d: %2d von %d gewonnen, im Schnitt %d Züge" % [kampf_id, LEVELS[kampf_id], wins, RUNS, turns / RUNS])
	BattleRequest.kampf_id = ""
	quit(problems)
