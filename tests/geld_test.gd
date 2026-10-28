extends SceneTree
## Test für das Geld: eine Zahl in Bronze, angezeigt als Bronze, Silber und Gold (100 : 1),
## und der Testknopf in der Tasche gibt Geld dazu.
## Aufruf: Godot --headless --path . --script res://tests/geld_test.gd


func _initialize() -> void:
	var failed := 0
	failed += _check("Nichts", Geld.text(0), "0 Bronze")
	failed += _check("Nur Bronze", Geld.text(75), "75 Bronze")
	failed += _check("Springt auf Silber", Geld.text(100), "1 Silber")
	failed += _check("Silber und Bronze", Geld.text(150), "1 Silber 50 Bronze")
	failed += _check("Knapp unter Gold", Geld.text(9999), "99 Silber 99 Bronze")
	failed += _check("Springt auf Gold", Geld.text(10000), "1 Gold")
	failed += _check("Alle drei", Geld.text(12345), "1 Gold 23 Silber 45 Bronze")
	failed += _check("Gold ohne Silber", Geld.text(20007), "2 Gold 7 Bronze")
	failed += _check("Viel Gold", Geld.text(1234567), "123 Gold 45 Silber 67 Bronze")
	failed += _check("Zerlegen", Geld.split(12345), [1, 23, 45])
	failed += _check("Farbig", Geld.bbcode(0), "[color=#d08a4e]0 Bronze[/color]")
	# Testknopf: 75 Bronze zweimal ergibt 1 Silber 50 Bronze
	var state := WorldState.new()
	var p := state.add_player("a", "Test", "elf_m", WorldState.start_cell())
	p.progress.gold = 0
	state.apply_command("a", {type = "test_geld", bronze = 75})
	state.apply_command("a", {type = "test_geld", bronze = 75})
	failed += _check("Testknopf", Geld.text(p.progress.gold), "1 Silber 50 Bronze")
	# Speichern und Laden: weiter eine einzige Zahl
	var copy := Progress.new()
	copy.load_dict(JSON.parse_string(JSON.stringify(p.progress.to_dict())))
	failed += _check("Gespeichert", copy.gold, 150)
	print("Geld: %s" % ("alles richtig" if failed == 0 else "%d Fehler" % failed))
	quit(failed)


func _check(what: String, got: Variant, want: Variant) -> int:
	if got == want:
		return 0
	print("FEHLER: %s – bekommen %s, erwartet %s" % [what, got, want])
	return 1
