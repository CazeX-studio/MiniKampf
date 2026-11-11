extends SceneTree
## A9b2: Endboss der Pilzhöhle, Phase 2 (Vorbote): Film beim Wechsel, im Dunkeln kaum zu treffen, voll nur mit dem
## Splitterlicht oder wenn Laternen das Feld hell halten.
## Aufruf: Godot --headless --path . -s tests/pilzhoehle_boss_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


## A9b3: Sporenkönigin ab halbem Leben wütend
func _koenigin() -> void:
	for modus: String in ["bluete", "zwillinge"]:
		Pilzhoehle.modus_fest = modus
		var k := BattleState.new(null, [] as Array[String], "", 23)
		k.setup = {gegner_stufe = 19, dungeon = "pilzhoehle", helden = [{klasse = "tank", name = "A", stufe = 19},
				{klasse = "archer", name = "B", stufe = 19}]}
		k._create_heroes()
		var p := Pilzhoehle.new(k)
		k.dungeon = p
		k.spawn_enemies(["sporenkoenigin", "sporenling", "sporenling"])
		p.on_wave(0)
		var koenigin := p._find("sporenkoenigin")
		koenigin.hp = koenigin.max_hp * 6 / 10
		p.check_phase()
		_check(not p.queen_wut, "%s: Über halbem Leben noch keine Wut" % modus)
		koenigin.hp = koenigin.max_hp / 2
		p.check_phase()
		_check(p.queen_wut and k._events.any(func(ev: Dictionary) -> bool: return ev.type == "phasen_film" and ev.motiv == "sporen"),
				"%s: Ab halbem Leben wütend, mit Film" % modus)
		var a: Fighter = k.heroes[0]
		if modus == "bluete":
			_check(p.intent(koenigin).begins_with("WÜTEND"), "Sporenblüte in Wut: Die Anzeige zeigt die Wut")
		else:
			var leben := koenigin.hp
			k.apply_damage(koenigin, 50, a)
			var geschuetzt := leben - koenigin.hp
			for e in k.enemies:
				if e.klass == "sporenling":
					e.hp = 0
			leben = koenigin.hp
			k.apply_damage(koenigin, 50, a)
			_check(geschuetzt * 3 < leben - koenigin.hp, "Zwillinge in Wut: Solange Knospen leben, kommt kaum Schaden an (%d statt %d)"
					% [geschuetzt, leben - koenigin.hp])
		k.cleanup()
	Pilzhoehle.modus_fest = ""


func _initialize() -> void:
	_koenigin()
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
