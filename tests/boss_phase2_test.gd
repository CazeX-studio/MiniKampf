extends SceneTree
## A9b: Endbosse der Dungeons (Alpha-Punkte 38, 39): Film beim Wechsel in Phase 2, stärkere Fesseln beim Kettenschmied,
## Phase 2 nur mit der Mechanik (Vorbote: Die Leere schluckt im Dunkeln; Kettenschmied: Panzer hält fast alles ab).
## Aufruf: Godot --headless --path . -s tests/boss_phase2_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _hat_film(k: BattleState) -> bool:
	return k._events.any(func(ev: Dictionary) -> bool: return ev.type == "phase_film" and ev.f != null and ev.titel != "")


func _vorbote() -> void:
	var k := BattleState.new(null, [] as Array[String], "", 5)
	k.setup = {gegner_stufe = 20, dungeon = "pilzhoehle", helden = [{klasse = "blade", name = "A", stufe = 20},
			{klasse = "novize", name = "B", stufe = 20}, {klasse = "novize", name = "C", stufe = 20}]}
	k._create_heroes()
	var p := Pilzhoehle.new(k)
	k.dungeon = p
	k.spawn_enemies(["wurzelmutter", "knoten_vorne", "knoten_hinten"])
	p.on_wave(0)
	k._events.clear()
	p._find("wurzelmutter").hp = 0
	p.check_phase()
	var vorbote := p._find("vorbote")
	_check(p.phase2 and vorbote != null, "Phase 2: Der Vorbote erscheint")
	_check(_hat_film(k), "Beim Wechsel in Phase 2 läuft ein Film")
	var halter: Fighter = null
	var anderer: Fighter = null
	for h in k.heroes:
		if h.light:
			halter = h
		elif anderer == null:
			anderer = h
	p.darkness = Pilzhoehle.HELL_GENUG + 2
	var leben := vorbote.hp
	k.apply_damage(vorbote, 50, anderer)
	_check(leben - vorbote.hp == roundi(50 * Pilzhoehle.LEERE_DURCH), "Im Dunkeln schluckt die Leere fast alles (%d)" % (leben - vorbote.hp))
	leben = vorbote.hp
	k.apply_damage(vorbote, 50, halter)
	_check(leben - vorbote.hp == 50, "Wer das Splitterlicht hält, trifft voll")
	p.darkness = Pilzhoehle.HELL_GENUG
	leben = vorbote.hp
	k.apply_damage(vorbote, 50, anderer)
	_check(leben - vorbote.hp == 50, "Im Licht der Laternen trifft jeder voll")
	_check("geschützt" in p.intent(vorbote) or "verwundbar" in p.intent(vorbote), "Anzeige: geschützt oder verwundbar")
	k.cleanup()


func _kettenschmied() -> void:
	var k := BattleState.new(null, [] as Array[String], "", 13)
	k.setup = {gegner_stufe = 20, dungeon = "vulkanschmiede", helden = [{klasse = "tank", name = "A", stufe = 20},
			{klasse = "smith", name = "B", stufe = 20}, {klasse = "archer", name = "C", stufe = 20}]}
	k._create_heroes()
	k.lava = LavaTakt.new(k)
	var v := Vulkanschmiede.new(k)
	k.dungeon = v
	k.spawn_enemies(["kettenschmied_1"])
	v.on_wave(0)
	var ks := v.ks
	var boss: Fighter = k.enemies[0]
	var a: Fighter = k.heroes[0]
	var b: Fighter = k.heroes[1]
	# Gefesselt: Der Partner bekommt einen Teil jedes Schlags mit, die Kette brennt bei jedem Zug
	ks.gefesselt.assign([a, b])
	var leben_a := a.hp
	var leben_b := b.hp
	k.apply_damage(a, 40, boss)
	_check(a.hp < leben_a and b.hp < leben_b, "Gefesselt: Der Schlag trifft beide")
	_check("Gefesselt" in ks.intent(boss), "Anzeige beim Kettenschmied: wer gefesselt ist")
	leben_a = a.hp
	leben_b = b.hp
	boss.step = 0
	ks._fessel_pruefen(boss)
	_check(a.hp < leben_a and b.hp < leben_b, "Die glühende Kette brennt bei seinem Zug")
	ks.gefesselt.clear()
	# Phase 2
	k._events.clear()
	boss.hp = 0
	v.check_phase()
	var zwei := v._find("kettenschmied_2")
	_check(ks.phase2 and zwei != null and _hat_film(k), "Phase 2: entfesselt, mit Film")
	var leben := zwei.hp
	k.apply_damage(zwei, 50, k.heroes[2])
	_check(leben - zwei.hp == roundi(50 * Kettenschmied.PANZER_DURCH), "Mit Panzer kommt nur ein kleiner Teil durch")
	k.apply_damage(v._find("kuehlbecken"), 10, a)
	leben = zwei.hp
	k.apply_damage(zwei, 30, a)
	_check(ks.panzer == Kettenschmied.PANZER - 1 and leben - zwei.hp >= 30 + roundi(zwei.max_hp * Kettenschmied.PANZER_WUNDE) - 1,
			"Nass und hart getroffen: Panzer splittert und reißt eine Wunde")
	k.cleanup()


func _initialize() -> void:
	_vorbote()
	_kettenschmied()
	print("Boss-Phase 2: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
