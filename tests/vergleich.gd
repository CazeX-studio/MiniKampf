extends SceneTree
## Lässt viele automatische Kämpfe mit festen Startwerten laufen und schreibt alles in eine Datei.
## Aufruf: Godot --headless --path . --script res://tests/vergleich.gd -- alt   (oder: -- neu)
## Danach die beiden Dateien tests/ergebnis_alt.txt und tests/ergebnis_neu.txt vergleichen.

const TEAMS: Array = [
	["tank", "archer", "ritualist", "singer"],
	["mechanic", "quartermaster", "blade", "smith"],
	["tamer", "archer", "kunoichi", "ritualist"],
	["twilight", "tank", "singer", "blade"],
	["tamer", "kunoichi", "smith", "singer"],
]
const STARTERS: Array[String] = ["moosling", "glutwelpe", "bachotter"]
const SEEDS := 3


func _initialize() -> void:
	# Erst wenn der Baum läuft, bekommen neue Knoten ihr _ready
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var mode: String = args[0] if not args.is_empty() else "alt"
	var harness: GDScript = load("res://tests/%s_kampf.gd" % mode)
	var out: PackedStringArray = []
	var results := {}
	var number := 0
	for t in TEAMS.size():
		for encounter: String in Sandbox.ENCOUNTER_ORDER:
			for s in SEEDS:
				number += 1
				var team: Array[String] = []
				team.assign(TEAMS[t])
				Sandbox.team = team
				Sandbox.encounter = encounter
				Sandbox.starter = STARTERS[(t + s) % STARTERS.size()]
				var start_seed := 1000 * (t + 1) + 10 * s + encounter.length()
				print("Kampf ", number)
				if OS.has_environment("AB") and number < int(OS.get_environment("AB")): continue
				if OS.has_environment("NUR") and str(number) != OS.get_environment("NUR"): continue
				var node: Node = harness.new()
				node.start_seed = start_seed
				root.add_child(node)
				var lines: PackedStringArray = node.protokoll.lines
				out.append("=== Kampf %d: %s gegen %s, Startwert %d" % [number, ", ".join(team), encounter, start_seed])
				out.append_array(lines)
				var result := "kein Ende"
				for line in lines:
					if line.begins_with("ENDE"):
						result = line
				results[result] = results.get(result, 0) + 1
				if result == "kein Ende":
					print("HAENGT: Kampf %d
" % number, "
".join(lines.slice(-8)))
					quit()
					return
				root.remove_child(node)
				node.free()
	var file := FileAccess.open("res://tests/ergebnis_%s.txt" % mode, FileAccess.WRITE)
	file.store_string("\n".join(out) + "\n")
	print("%d Kämpfe, Ergebnisse: %s" % [number, results])
	quit()
