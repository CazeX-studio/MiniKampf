extends SceneTree
## A9b2: Endboss der Pilzhöhle, Phase 2 (Vorbote): Film beim Wechsel, im Dunkeln kaum zu treffen, voll nur mit dem
## Splitterlicht oder wenn Laternen das Feld hell halten.
## Aufruf: Godot --headless --path . -s tests/pilzhoehle_boss_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	var k := BattleState.new(null, [] as Array[String], "", 21)
	k.setup = {gegner_stufe = 20, dungeon = "pilzhoehle", helden = [{klasse = "tank", name = "A", stufe = 20},
			{klasse = "archer", name = "B", stufe = 20}]}
	k._create_heroes()
	var p := Pilzhoehle.new(k)
	k.dungeon = p
	k.spawn_enemies(["wurzelmutter", "knoten_vorne", "knoten_hinten"])
	p.on_wave(0)
	var mutter := p._find("wurzelmutter")
	mutter.hp = 0
	p.check_phase()
	var vorbote := p._find("vorbote")
	_check(p.phase2 and vorbote != null, "Phase 2: Der Vorbote bricht aus dem Splitter")
	_check(k._events.any(func(ev: Dictionary) -> bool: return ev.type == "phasen_film" and ev.f == vorbote and ev.motiv == "leere"),
			"Beim Wechsel läuft ein Film, ein Riss der Leere öffnet sich")
	var a: Fighter = k.heroes[0]
	var b: Fighter = k.heroes[1]
	var halter := a if a.light else b
	var anderer := b if halter == a else a
	_check(halter.light and not anderer.light, "Einer hält das Splitterlicht")
	# Im Dunkeln
	p.darkness = 3
	var leben := vorbote.hp
	k.apply_damage(vorbote, 50, anderer)
	var dunkel := leben - vorbote.hp
	leben = vorbote.hp
	k.apply_damage(vorbote, 50, halter)
	var mit_licht := leben - vorbote.hp
	_check(dunkel > 0 and dunkel * 3 < mit_licht, "Im Dunkeln trifft man ihn kaum (%d), mit dem Splitterlicht voll (%d)" % [dunkel, mit_licht])
	leben = vorbote.hp
	k.apply_damage(vorbote, 50)
	_check(leben - vorbote.hp < mit_licht, "Auch Brennen und Gift kommen im Dunkeln kaum an")
	# Laterne: Das Feld wird hell, alle treffen voll
	var laterne := p.extra_abilities(anderer).filter(func(x: Dictionary) -> bool: return x.id == "lantern")
	_check(laterne.size() == 1, "Jeder kann eine Laterne entzünden")
	p.execute(anderer, laterne[0], null)
	_check(p.darkness == 1 and p.im_licht(anderer), "Laterne: Dunkelheit sinkt, jetzt trifft jeder voll")
	leben = vorbote.hp
	k.apply_damage(vorbote, 50, anderer)
	_check(leben - vorbote.hp == mit_licht, "Im Hellen trifft auch, wer kein Licht hält, voll")
	_check(p.intent(vorbote).find("kaum zu treffen") < 0, "Die Anzeige sagt, wann er kaum zu treffen ist")
	p.darkness = 4
	_check(p.intent(vorbote).find("kaum zu treffen") >= 0, "… und im Dunkeln steht es dabei")
	k.cleanup()
	print("Pilzhöhle-Boss: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
