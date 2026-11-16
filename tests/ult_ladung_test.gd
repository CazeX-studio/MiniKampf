extends SceneTree
## P15a: Die Ult-Leiste behält ihre Ladung zwischen den Kämpfen (sie wird nur beim Benutzen leer).
## Aufruf: Godot --headless --path . -s tests/ult_ladung_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	# Ein Kampf mit der eigenen Klasse beginnt mit der Ladung aus der Welt
	BattleRequest.player_ult = 60.0
	BattleRequest.prepare("splitterbaer", 20, 0, "archer")
	var held: Dictionary = BattleRequest.setup.helden[0]
	_check(is_equal_approx(float(held.ult), 60.0) and held.get("ult_aus_welt", false), "Kampf beginnt mit 60 % Ult")
	# Der Kampf meldet die Ladung zurück
	BattleRequest.finish(true, 0, [], 0, -1.0, {}, 85.0)
	_check(is_equal_approx(float(BattleRequest.result.get("ult_ladung", -1.0)), 85.0), "Kampf meldet 85 % zurück")
	# Die Welt merkt sie sich (auch über das Speichern hinweg)
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "novize_w+w1", Vector2i(23, 2))
	p.progress.flags = {"klasse": "archer", "klasse_gelernt": true}
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "splitterbaer", gewonnen = true, ult_ladung = 85.0})
	_check(is_equal_approx(p.progress.ult_ladung, 85.0), "Welt merkt sich 85 %")
	var neu := Progress.new()
	neu.load_dict(p.progress.to_dict())
	_check(is_equal_approx(neu.ult_ladung, 85.0), "Ladung bleibt beim Speichern und Laden")
	# Kämpfe ohne eigene Klasse (Lektionen in Kreuzweg) fangen wie bisher an und melden nichts
	BattleRequest.player_ult = 60.0
	BattleRequest.prepare("splitterbaer", 20, 0, "")
	_check(not BattleRequest.setup.helden[0].get("ult_aus_welt", false), "Ohne eigene Klasse: keine Ladung aus der Welt")
	BattleRequest.player_ult = 0.0
	BattleRequest.result = {}
	print("\n%s" % ("ALLES OK" if _failed == 0 else "%d FEHLER" % _failed))
	quit(1 if _failed > 0 else 0)
