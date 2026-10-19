extends SceneTree
## Kleiner Test für das Element-System.
## Aufruf: Godot --headless --path . --script res://tests/elemente_test.gd


func _initialize() -> void:
	var cases := [
		["Feuer", "Pflanze", 1.5],
		["Pflanze", "Feuer", 0.5],
		["Feuer", "Blitz", 1.0],
		["Licht", "Schatten", 1.5],
		["Licht", "Licht", 1.0],
		["Sternenkraft", "Feuer", 1.0],
		["", "Feuer", 1.0],
		["Gift", "Feuer", 1.0],
		["Feuer", "Gift", 1.0],
		["Unbekannt", "Auch unbekannt", 1.0],
	]
	var failed := 0
	for c: Array in cases:
		var got := Elements.multiplier(c[0], c[1])
		if not is_equal_approx(got, c[2]):
			failed += 1
			print("FEHLER: %s gegen %s = %s, erwartet %s" % [c[0], c[1], got, c[2]])
	print("Elemente: %d von %d richtig" % [cases.size() - failed, cases.size()])
	quit(failed)
