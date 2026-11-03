extends SceneTree
## D14: Tag und Nacht nach der Uhrzeit. Nacht von 21 bis 6 Uhr, dazwischen Dämmerung; nachts andere Monster.
## Aufruf: Godot --headless --path . -s tests/tageszeit_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	_test_uhr()
	_test_monster()
	Tageszeit.feste_stunde = -1.0
	Tageszeit.versatz = 0.0
	print("Tag und Nacht: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


func _test_uhr() -> void:
	_check(not Tageszeit.ist_nacht(12.0) and Tageszeit.ist_nacht(21.0) and Tageszeit.ist_nacht(3.0) and not Tageszeit.ist_nacht(6.0),
			"Nacht von 21 bis 6 Uhr")
	_check(Tageszeit.dunkelheit(12.0) == 0.0 and Tageszeit.dunkelheit(23.0) == 1.0, "Mittag hell, Mitternacht dunkel")
	var abend := Tageszeit.dunkelheit(20.0)
	var morgen := Tageszeit.dunkelheit(7.0)
	_check(abend > 0.0 and abend < 1.0 and morgen > 0.0 and morgen < 1.0, "Abend und Morgen sind Dämmerung")
	_check(Tageszeit.dunkelheit(19.5) < Tageszeit.dunkelheit(20.5), "Abends wird es langsam dunkler")
	var grund := Color(1, 1, 1)
	var tag := Tageszeit.licht(grund, 12.0)
	var nacht := Tageszeit.licht(grund, 23.0)
	_check(tag == grund, "Tagsüber das normale Licht der Karte")
	_check(nacht.v < tag.v and nacht.b > nacht.r, "Nachts dunkler und bläulich")
	_check(Tageszeit.daemmerung(20.0) > 0.5 and Tageszeit.licht(grund, 20.0).r > Tageszeit.licht(grund, 20.0).b, "Abends warmes Licht")
	_check(Tageszeit.licht_faktor(23.0) > 1.3 and Tageszeit.licht_faktor(12.0) == 1.0, "Nachts leuchten die Lichter stärker")
	Tageszeit.feste_stunde = 20.0
	Tageszeit.versatz = 3.0
	_check(Tageszeit.text() == "23:00" and Tageszeit.ist_nacht(), "Testknopf stellt die Uhr vor (20 + 3 = 23 Uhr)")
	Tageszeit.versatz = 0.0


func _test_monster() -> void:
	Tageszeit.feste_stunde = 12.0
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "elf_m", Vector2i(6, 15))
	p.progress.flags["klasse"] = "archer"
	p.progress.level = 12
	world.change_map(p, "weg_gruenwacht", Vector2i(55, 9))
	world.tick(0.01)
	var tags: Array[int] = []
	var nachts: Array[int] = []
	for i in world.monsters.size():
		if world.monsters[i].karte == "weg_gruenwacht":
			(nachts if str(world.monsters[i].get("zeit", "tag")) == "nacht" else tags).append(i)
	_check(tags.size() >= 4 and nachts.size() >= 2, "Weg nach Grünwacht: Tag- und Nacht-Monster (%d / %d)" % [tags.size(), nachts.size()])
	_check(not world.nacht, "Mittags ist Tag")
	_check(tags.all(func(i: int) -> bool: return world.can_use(p, "monster:%d" % i)), "Tagsüber stehen die Tag-Monster da")
	_check(nachts.all(func(i: int) -> bool: return not world.can_use(p, "monster:%d" % i)), "Tagsüber keine Nacht-Monster")
	var arten := {}
	for i in nachts:
		for g: String in world.monsters[i].gegner:
			arten[g] = true
	_check(arten.has("heulwolf") and arten.has("irrlicht"), "Nachts auf dem Weg: Heulwolf und Irrlicht")

	Tageszeit.feste_stunde = 23.0
	world.tick(1.1)
	_check(world.nacht, "Um 23 Uhr ist Nacht (die Welt prüft ihre Uhr jede Sekunde)")
	_check(nachts.all(func(i: int) -> bool: return world.can_use(p, "monster:%d" % i)), "Nachts stehen die Nacht-Monster da")
	_check(tags.all(func(i: int) -> bool: return not world.can_use(p, "monster:%d" % i)), "Nachts sind die Tag-Monster weg")
	# Kämpfe gegen Nacht-Monster lassen sich vorbereiten, die Monster gibt es im Kampf
	for i in nachts:
		_check(BattleRequest.prepare("wild:%d" % i, 12, 0, "archer"), "Kampf gegen Nacht-Monster %d" % i)
		for g: String in world.monsters[i].gegner:
			_check(Sandbox.ENEMIES.has(g) and FighterView.LOOKS.has(g), "%s gibt es im Kampf mit Bild" % g)
	BattleRequest.kampf_id = ""
	# Im Wald: Nachtuhu und Funkenmarder; in der Pilzhöhle (Dungeon) gibt es keine Tageszeit
	var wald := {}
	for i in world.monsters.size():
		var m: Dictionary = world.monsters[i]
		if m.karte == "waldboden" and str(m.get("zeit", "tag")) == "nacht":
			for g: String in m.gegner:
				wald[g] = true
		if m.karte == "pilzhoehle":
			_check(world.monster_zur_zeit(i), "Pilzhöhle: Monster auch nachts (Dungeon)")
	_check(wald.has("nachtuhu") and wald.has("funkenmarder"), "Nachts im Wald: Nachtuhu und Funkenmarder")
