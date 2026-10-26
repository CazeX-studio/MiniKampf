extends SceneTree
## Test für die Belohnung am Kampfende: Was ein Sieg bringt, wird vorher berechnet (für den Sieg-Bildschirm),
## und die Welt meldet Erfahrung, Gold und Stufe danach nicht noch einmal.
## Aufruf: Godot --headless --path . --script res://tests/belohnung_test.gd

var _failed := 0


func _initialize() -> void:
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "vega", Vector2i(6, 15))
	p.progress.level = 10
	p.progress.xp = int(GameData.level_xp()[10]) - 5
	var notes: Array[String] = []
	world.notice.connect(func(_id: String, text: String) -> void: notes.append(text))
	var battle := GameData.battle("wild:0")
	var reward := world.battle_reward(p, "wild:0", false)
	_check(reward.erfahrung == int(battle.erfahrung) and reward.gold == int(battle.gold), "Wildnis: Erfahrung und Gold wie im Kampf")
	_check(reward.stufen == [11], "Stufe 11 wird erreicht (%s)" % [reward.stufen])
	var gold := p.progress.gold
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "wild:0", gewonnen = true, belohnung_gezeigt = true, karte = ""})
	_check(p.progress.gold == gold + reward.gold and p.progress.level == 11, "Belohnung kommt trotzdem an")
	_check(not notes.any(func(t: String) -> bool: return t.contains("Erfahrung") or t.contains("Gold") or t.contains("Stufe")),
			"Keine doppelte Meldung nach dem Kampf: %s" % [notes])
	# Ohne Anzeige am Kampfende (z. B. alter Weg): Meldungen wie bisher
	notes.clear()
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "wild:0", gewonnen = true})
	_check(notes.any(func(t: String) -> bool: return t.contains("Erfahrung")), "Sonst meldet die Welt die Erfahrung")
	# Geschichtskampf: Erfahrung nur beim ersten Sieg
	var story := world.battle_reward(p, "grundausbildung", false)
	_check(story.erfahrung == int(GameData.battle("grundausbildung").get("erfahrung", 0)), "Geschichtskampf: Erfahrung beim ersten Sieg")
	p.progress.flags["kampf_gewonnen:grundausbildung"] = true
	_check(world.battle_reward(p, "grundausbildung", false).erfahrung == 0, "Beim zweiten Sieg keine Erfahrung mehr")
	print("Belohnung: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


func _check(ok: bool, what: String) -> void:
	print(("OK     " if ok else "FEHLER ") + what)
	if not ok:
		_failed += 1
