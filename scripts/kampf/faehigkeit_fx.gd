class_name FaehigkeitFx
extends RefCounted
## Eigene Bewegungen und Effekte einzelner Fähigkeiten (K.6, nach den Steckbriefen). Skills melden sie mit c.zeige("name", f, ziel).
## "seite" unterscheidet Wiederholungen derselben Bewegung, z. B. Hieb von links und von rechts.

const STERN := Color("c9a6ff")
const SCHILD := Color("8fd3ff")
const GRUEN := Color("7dffa0")
const WALD := Color("8fe86a")
const STAUB := Color("c8b898")
const GLUT := Color("ff9a4c")
const KLINGE := Color("ffd0a0")
const MOND := Color("cfe6ff")
const KOMET := Color("ffe680")
const STAHL := Color("d8e0ec")
const PFEIL_RUNTER := [Vector2(-14, -10), Vector2(14, -10), Vector2(0, 12)]
const PFEIL_HOCH := [Vector2(-14, 10), Vector2(14, 10), Vector2(0, -12)]
const STERN_FORM := [Vector2(0, -16), Vector2(4, -5), Vector2(15, -5), Vector2(6, 2), Vector2(9, 13), Vector2(0, 7),
		Vector2(-9, 13), Vector2(-6, 2), Vector2(-15, -5), Vector2(-4, -5)]
const HIRSCH := "res://assets/figuren/hirsch_idle_anim_f0.png"


static func spielen(k: Control, name: String, f: Fighter, ziel: Fighter, seite: int, farbe := Color.WHITE) -> void:
	if not k.has_view(f):
		return
	var v: FighterView = k.view(f)
	var ziel_ansicht: FighterView = k.view(ziel) if ziel != null and k.has_view(ziel) else null
	var feld: Control = k._field
	match name:
		"schildstoss_anlauf":
			# Zwei schnelle Schritte nach vorn
			v.play("run", 0.4)
			_huepfer(v, 8.0, 0.1)
			await k.wait(0.2)
			_huepfer(v, 8.0, 0.1)
			await k.wait(0.2)
		"schildstoss_treffer":
			Geraeusche.play("treffer", 0.55)
			if ziel_ansicht != null:
				_funken(feld, ziel_ansicht.center(), 1.0)
				_taumeln(ziel_ansicht)
		"hieb":
			# Schnitt-Spur von links oder rechts
			_huepfer(v, 12.0, 0.1)
			Geraeusche.play("parade", 1.25 + 0.15 * seite)
			if ziel_ansicht != null:
				FxBild.spawn(feld, "hieb", ziel_ansicht.center(), 0.3, seite == 0)
		"erste_hilfe":
			# Kniet kurz und legt den Verband an
			v.play("cast", 0.6)
			var tiefe := _kniefall(v)
			Geraeusche.play("wurf", 0.6)
			await k.wait(0.45)
			tiefe.kill()
			v.body.position = v._home
			var ort := ziel_ansicht.center() if ziel_ansicht != null else v.center()
			FxBild.spawn(feld, "heilung", ort + Vector2(0, -20), 0.7, false, 0.0, 0.7)
			_pflaster(feld, ort)
		"deckung":
			_huepfer(v, 20.0, 0.16)
			Geraeusche.play("parade", 0.7)
			if ziel_ansicht != null:
				_kuppel(feld, ziel_ansicht.home_feet())
			await k.wait(0.35)
		"deckung_funke":
			Geraeusche.play("parade", 0.7)
			_funken(feld, v.center(), 0.9).modulate = SCHILD.lightened(0.4)
		"sternenmut_an":
			# Das Schwert leuchtet lila wie ein Splitter, ein heller Glockenton
			Geraeusche.play("perfekt", 1.5)
			v.glow(STERN, 1.0)
			Fx.spawn(feld, Fx.Kind.GLOW, v.center(), STERN, 120.0, 0.6)
			await k.wait(0.4)
		"sternenmut_schlag":
			Geraeusche.play("kritisch", 0.9)
			if ziel_ansicht != null:
				FxBild.spawn(feld, "sternenmut_hieb", ziel_ansicht.center(), 0.45, f.is_ally(), 0.0, 0.9)
			k.screen_flash(STERN)
		"schnellschuss":
			_pose(v)
			Geraeusche.play("wurf", 1.7)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				await _pfeilflug(feld, v.center(), ort, 0.14)
				_funken(feld, ort, 0.6)
		"spannen":
			Geraeusche.play("wurf", 0.5)
			v.glow(WALD, 0.7)
			Fx.spawn(feld, Fx.Kind.RING, v.home_feet(), WALD, 70.0, 0.6)
			Fx.spawn(feld, Fx.Kind.GLOW, v.center(), Color(WALD, 0.5), 60.0, 0.6)
			await k.wait(0.5)
		"ladeschuss", "durchschlag":
			_pose(v)
			_rueckstoss(v)
			Geraeusche.play("kritisch", 1.3)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				await _pfeilflug(feld, v.center(), ort, 0.12, 0.65)
				FxBild.streifen(feld, "schneise", v.center(), ort, 0.4)
				if name == "durchschlag":
					Geraeusche.play("parade", 0.5)
				_funken(feld, ort, 1.1)
				FxBild.am_boden(feld, "staubwolke", ziel_ansicht.home_feet(), 0.5)
				k._shake(10.0)
		"durchschlag_weiter":
			if ziel_ansicht != null:
				FxBild.streifen(feld, "schneise", v.center(), ziel_ansicht.center(), 0.35, 0.8)
				_funken(feld, ziel_ansicht.center(), 0.8)
				await k.wait(0.15)
		"hagel_auf":
			# Steil in den Himmel schießen und hinterherschauen
			_pose(v)
			Geraeusche.play("wurf", 1.2)
			var hoch := -1.0 if f.is_ally() else 1.0
			for i in 3:
				_pfeilflug(feld, v.center(), v.center() + Vector2(hoch * (40.0 + 30.0 * i), -520.0), 0.22)
			await k.wait(0.35)
		"hagel_regen":
			if ziel_ansicht != null:
				_regen(k, feld, ziel_ansicht.home_feet())
		"netzpfeil":
			_pose(v)
			Geraeusche.play("wurf", 0.8)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				await FxBild.flug(feld, "pfeil_flug", v.center(), ort, 0.28, 0.5, 120.0)
				Geraeusche.play("parade", 0.5)
				FxBild.spawn(feld, "netz", ort, 0.6, f.is_ally(), 0.0, 0.6, 0.3)
				_zappeln(ziel_ansicht)
		"schnellfeuer":
			# Immer schneller, die Spuren werden heller (seite zählt die Pfeile)
			_pose(v)
			Geraeusche.play("wurf", 1.5 + 0.1 * seite)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				await _pfeilflug(feld, v.center(), ort, maxf(0.15 - 0.02 * seite, 0.07))
				_funken(feld, ort, 0.5)
		"schnellfeuer_ende":
			Geraeusche.play("wurf", 2.2)
			_huepfer(v, 10.0, 0.1)
		"schwachstelle":
			v.glow(Color("ff5050"), 0.6)
			await k.wait(0.45)
			_pose(v)
			Geraeusche.play("perfekt", 1.8)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				await _pfeilflug(feld, v.center(), ort, 0.2)
				FxBild.spawn(feld, "fadenkreuz", ort, 0.5, false, 0.0, 0.55, 0.7)
		"elementpfeil":
			v.glow(farbe, 0.4)
			await k.wait(0.25)
			_pose(v)
			Geraeusche.play("wurf", 1.1)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				_pfeil(feld, v.center(), ort, farbe, 0.18, 5.0)
				await _pfeilflug(feld, v.center(), ort, 0.18)
				Fx.spawn(feld, Fx.Kind.RING, ort, farbe, 80.0, 0.3)
				_funken(feld, ort, 1.0).modulate = farbe.lightened(0.3)
		"jaegerpfeil":
			# Der Bogen füllt sich mit Waldlicht, der Geist des Silberhirschs läuft neben dem Pfeil
			v.glow(WALD, 1.0)
			Fx.spawn(feld, Fx.Kind.GLOW, v.center(), Color(WALD, 0.6), 110.0, 0.6)
			await k.wait(0.35)
			_pose(v)
			Geraeusche.play("wurf", 0.7)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				_hirschgeist(feld, v.home_feet() + Vector2(0, -60), ort, 0.45)
				await _pfeilflug(feld, v.center(), ort, 0.45, 0.65)
				Geraeusche.play("kritisch", 0.6)
				k._change_speed(0.3, 0.25)
				k._shake(14.0)
				k.screen_flash(WALD)
				FxBild.am_boden(feld, "waldlicht", ziel_ansicht.home_feet() + Vector2(0, 12), 0.8, 0.9)
		"schleuder":
			_pose(v)
			Geraeusche.play("wurf")
			if ziel_ansicht != null:
				await _bogenwurf(feld, v.center(), ziel_ansicht.center(), Color("c9b28a"))
		"pfiff":
			# Zwei Pfiffe, der Stab schwenkt
			_pose(v)
			Geraeusche.play("perfekt", 2.0)
			await k.wait(0.14)
			Geraeusche.play("perfekt", 2.3)
			await k.wait(0.14)
		"auftritt":
			# f ist das neue Monster, ziel der Zähmer; seite > 0: Großer Auftritt
			_huepfer(v, 34.0, 0.14)
			if ziel_ansicht != null:
				_schneise(feld, ziel_ansicht.center(), v.center(), Color("fff3b0"))
			await k.wait(0.28)
			Geraeusche.play("treffer", 0.7)
			FxBild.am_boden(feld, "staubwolke", v.home_feet() + Vector2(0, 8), 0.5, 0.7 + 0.3 * seite)
			if seite > 0:
				_kuppel(feld, v.home_feet())
		"anfeuern":
			_huepfer(v, 12.0, 0.1)
			Geraeusche.play("parade", 1.7)
			if ziel_ansicht != null:
				await k.wait(0.15)
				_huepfer(ziel_ansicht, 16.0, 0.1)
				Geraeusche.play("treffer", 0.6)
				ziel_ansicht.glow(Color("ff6060"), 0.7)
				FxBild.am_boden(feld, "rote_funken", ziel_ansicht.home_feet() + Vector2(0, 10), 0.7, 0.6)
		"pflege":
			# Kniet sich zum Monster und gibt ihm eine Beere
			var kniend := _kniefall(v)
			await k.wait(0.35)
			kniend.kill()
			v.body.position = v._home
			if ziel_ansicht != null:
				FxBild.spawn(feld, "heilung", ziel_ansicht.center() + Vector2(0, -20), 0.7, false, 0.0, 0.7)
		"lockfutter":
			_pose(v)
			Geraeusche.play("wurf", 0.7)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				await _futterwurf(feld, v.center(), ziel_ansicht.home_feet() + Vector2(0, -20))
				_zeichen(feld, ort + Vector2(0, -60), "?", Color("e8c890"))
		"gemeinsam_blitz":
			if ziel_ansicht != null:
				Fx.spawn(feld, Fx.Kind.GLOW, ziel_ansicht.center(), Color(Color.WHITE, 0.7), 120.0, 0.35)
				Fx.spawn(feld, Fx.Kind.RING, ziel_ansicht.center(), Color("fff3b0"), 120.0, 0.35)
			k.screen_flash(Color("fff3b0"))
		"wachstum":
			# Grünes Licht strömt ins Monster, es wächst, der Boden wackelt
			_pose(v)
			if ziel_ansicht != null:
				FxBild.spawn(feld, "wachstum", ziel_ansicht.center(), 0.6, false, 0.0, 0.7)
				Geraeusche.play("kritisch", 0.5)
				k._shake(6.0)
				ziel_ansicht.glow(WALD, 0.7)
				if not ziel_ansicht.has_meta("grund_scale"):
					ziel_ansicht.set_meta("grund_scale", ziel_ansicht.body.scale)
				var gross: Vector2 = ziel_ansicht.get_meta("grund_scale") * 1.5
				await ziel_ansicht.create_tween().tween_property(ziel_ansicht.body, "scale", gross, 0.4).set_trans(Tween.TRANS_BACK).finished
		"wachstum_ende":
			if v.has_meta("grund_scale"):
				v.create_tween().tween_property(v.body, "scale", v.get_meta("grund_scale"), 0.3)
		"bruellen":
			_pose(v)
			var quelle := ziel_ansicht if ziel_ansicht != null else v
			Geraeusche.play("kritisch", 0.5)
			k._shake(6.0)
			await _schallwellen(feld, quelle, "bruellen", 0.45)
		"eingeschuechtert":
			if ziel_ansicht != null:
				_taumeln(ziel_ansicht)
				_symbol(feld, ziel_ansicht.center() + Vector2(0, -60), Color("8fb8ff"), PFEIL_RUNTER)
		"zweites_leben":
			# Lichtfunken sammeln sich, ein Ton schwillt an, das Monster steht auf
			Geraeusche.play("perfekt", 0.8)
			if ziel_ansicht != null:
				Fx.spawn(feld, Fx.Kind.GLOW, ziel_ansicht.center(), Color("fff3b0"), 110.0, 0.7)
				Fx.spawn(feld, Fx.Kind.SPARKS, ziel_ansicht.center(), Color("fff3b0"), 90.0, 0.7)
				await k.wait(0.4)
				_huepfer(ziel_ansicht, 14.0, 0.12)
		"rudelruf_an":
			_pose(v)
			Geraeusche.play("perfekt", 1.6)
			await k.wait(0.35)
		"rudelruf_ende":
			Geraeusche.play("kritisch", 0.6)
			if ziel_ansicht != null:
				FxBild.am_boden(feld, "staubwolke", ziel_ansicht.home_feet() + Vector2(0, 8), 0.7, 1.1)
				FxBild.spawn(feld, "schockwelle", ziel_ansicht.home_feet(), 0.5, false, 0.0, 1.0)
			k._change_speed(0.3, 0.25)
			k._shake(14.0)
		"hammer_treffer":
			Geraeusche.play("parade", 0.6)
			if ziel_ansicht != null:
				FxBild.spawn(feld, "hammer_funken", ziel_ansicht.center(), 0.5, false, 0.0, 0.7)
				_symbol(feld, ziel_ansicht.center() + Vector2(0, -60), Color("ff5050"), PFEIL_RUNTER)
		"schmiede_moment":
			_pose(v)
			Geraeusche.play("parade", 0.9)
			FxBild.spawn(feld, "hammer_funken", v.center(), 0.4, false, 0.0, 0.5)
			await k.wait(0.2)
		"amboss":
			# Der Amboss fällt vom Rücken in den Boden, alle Gegner schauen zu ihm
			await _amboss(k, feld, v.home_feet() + Vector2(-70 if f.is_ally() else 70, 0))
		"bedroht":
			if ziel_ansicht != null:
				_symbol(feld, ziel_ansicht.center() + Vector2(0, -60), Color("ff5050"), PFEIL_RUNTER)
		"verstaerken":
			# Zwei helle Klopftöne auf die Rüstung
			for i in 2:
				Geraeusche.play("parade", 1.6)
				_huepfer(v, 6.0, 0.06)
				await k.wait(0.16)
			if ziel_ansicht != null:
				ziel_ansicht.glow(STAHL, 0.6)
				_kuppel(feld, ziel_ansicht.home_feet())
		"abfangen":
			_huepfer(v, 20.0, 0.16)
			Geraeusche.play("parade", 0.8)
			if ziel_ansicht != null:
				_schneise(feld, v.center(), ziel_ansicht.center(), GLUT)
			await k.wait(0.3)
		"haerten":
			# Kniet ab, Schlag auf die Schulter, die Rüstung glüht weiß und kühlt zischend ab
			var kniend := _kniefall(v)
			await k.wait(0.2)
			kniend.kill()
			v.body.position = v._home
			Geraeusche.play("treffer", 0.8)
			v.glow(Color.WHITE, 0.8)
			await k.wait(0.3)
			Geraeusche.play("wurf", 0.4)
			FxBild.spawn(feld, "kuehlung", v.center() + Vector2(0, -20), 0.8, false, 0.0, 0.7)
		"gluehend":
			_pose(v)
			Geraeusche.play("zauber", 0.7)
			v.glow(GLUT, 1.0)
			Fx.spawn(feld, Fx.Kind.GLOW, v.center(), Color(GLUT, 0.5), 100.0, 0.8)
			FxBild.am_boden(feld, "glut", v.home_feet(), 0.8, 0.7)
			await k.wait(0.4)
		"angesengt":
			if ziel_ansicht != null:
				ziel_ansicht.glow(GLUT, 0.4)
				FxBild.spawn(feld, "glut", ziel_ansicht.center(), 0.5, false, 0.0, 0.5)
		"funkenflug":
			if ziel_ansicht != null:
				await _pfeil(feld, v.center(), ziel_ansicht.center(), GLUT, 0.15, 6.0)
				FxBild.spawn(feld, "glut", ziel_ansicht.center(), 0.4, false, 0.0, 0.45)
		"ambossschlag":
			_huepfer(v, 50.0, 0.2)
			await k.wait(0.4)
			Geraeusche.play("kritisch", 0.5)
			FxBild.spawn(feld, "risse", v.home_feet() + Vector2(0, 6), 0.6, false, 0.0, 0.9, 0.4).z_index = 2
			FxBild.spawn(feld, "schockwelle", v.home_feet(), 0.5, false, 0.0, 1.5)
			FxBild.am_boden(feld, "staubwolke", v.home_feet() + Vector2(0, 8), 0.7, 1.0)
			k._change_speed(0.3, 0.2)
			k._shake(16.0)
			await k.wait(0.15)
		"betaeubt":
			if ziel_ansicht != null:
				_symbol(feld, ziel_ansicht.center() + Vector2(0, -60), Color("ffe08a"), STERN_FORM)
		"haerte_geben":
			_pose(v)
			Geraeusche.play("perfekt", 1.4)
			v.glow(STAHL, 0.6)
			await k.wait(0.2)
		"haerte_splitter":
			if ziel_ansicht != null:
				_pfeil(feld, v.center(), ziel_ansicht.center(), STAHL, 0.25, 4.0)
				ziel_ansicht.glow(STAHL, 0.7)
		"meisterstueck":
			# Drei Schläge im Takt, je einer für Platte, Kette und Runen, dann der goldene Glanz
			for farbe_teil: Color in [Color("b8c0cc"), Color("e8ecf4"), Color("6fa8ff")]:
				Geraeusche.play("parade", 0.9)
				_pose(v)
				v.glow(farbe_teil, 0.3)
				FxBild.spawn(feld, "hammer_funken", v.center(), 0.3, false, 0.0, 0.5).modulate = farbe_teil.lightened(0.3)
				await k.wait(0.28)
			Geraeusche.play("perfekt", 0.6)
			v.glow(Color("f2c14e"), 1.2)
			FxBild.spawn(feld, "goldregen", v.center() + Vector2(0, -20), 1.0, false, 0.0, 0.8)
			k.screen_flash(Color("f2c14e"))
		"nachbild":
			_nachbild(feld, v)
		"sturm_schritt":
			# Schnelle Trommelschläge im Takt, bei jedem Sprung ein Nachbild
			_nachbild(feld, v)
			Geraeusche.play("treffer", 0.9 + 0.1 * seite)
		"kreuzschnitt":
			Geraeusche.play("parade", 1.4)
			if ziel_ansicht != null:
				FxBild.spawn(feld, "kreuzschnitt", ziel_ansicht.center(), 0.35, false, 0.0, 0.7)
		"klinge_neu":
			_funken(feld, v.center() + Vector2(0, -30), 0.4).modulate = KLINGE
		"klinge_flug":
			if ziel_ansicht != null:
				_klingenflug(feld, v.center(), ziel_ansicht.center(), 0.12)
		"wirbel":
			# Pirouette: ein Kreis aus Schnitt-Spuren, Sand wirbelt auf
			_huepfer(v, 10.0, 0.12)
			Geraeusche.play("wurf", 1.4)
			FxBild.spawn(feld, "wirbelkreis", v.center() + Vector2(0, 14), 0.4, not f.is_ally(), 0.0, 0.8)
			FxBild.am_boden(feld, "staubwolke", v.home_feet() + Vector2(0, 8), 0.5, 0.7)
			await k.wait(0.25)
		"faecher":
			_pose(v)
			Geraeusche.play("kritisch", 0.7)
			await _sichel(feld, v.center(), -1.0 if f.is_ally() else 1.0)
			k._change_speed(0.3, 0.15)
		"partnertanz":
			Geraeusche.play("treffer", 0.9)
			_huepfer(v, 12.0, 0.1)
			await k.wait(0.2)
			Geraeusche.play("treffer", 0.9)
			if ziel_ansicht != null:
				_huepfer(ziel_ansicht, 12.0, 0.1)
				await _klingenflug(feld, v.center(), ziel_ansicht.center(), 0.2)
				Geraeusche.play("perfekt", 1.7)
				_funken(feld, ziel_ansicht.center(), 0.8).modulate = KLINGE
		"kaefig":
			_pose(v)
			Geraeusche.play("wurf", 1.8)
			if ziel_ansicht != null:
				await _klingenring(feld, ziel_ansicht.center())
		"klingensturm":
			# Die Klingen schießen nacheinander los (seite: wie viele); bei fünf ein großer Abschluss
			_pose(v)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				for i in seite:
					Geraeusche.play("wurf", 1.5 + 0.08 * i)
					_klingenflug(feld, v.center() + Vector2(0, -50 + 25 * i), ort, 0.16)
					await k.wait(0.08)
				await k.wait(0.1)
				_funken(feld, ort, 0.6 + 0.12 * seite).modulate = KLINGE
				if seite >= Fighter.MAX_BLADES:
					Geraeusche.play("kritisch", 1.0)
					Fx.spawn(feld, Fx.Kind.GLOW, ort, Color(KLINGE, 0.8), 150.0, 0.4)
					FxBild.spawn(feld, "kreuzschnitt", ort, 0.4, false, 0.0, 1.0)
					k.screen_flash(KLINGE)
					k._change_speed(0.3, 0.2)
		"schwarm":
			# Die Klingen vervielfachen sich, Nachbilder tanzen
			Geraeusche.play("treffer", 0.8)
			_nachbild(feld, v)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				for i in 4:
					_klingenflug(feld, v.center() + Vector2(randf_range(-50, 50), randf_range(-70, 70)), ort, 0.2)
				FxBild.spawn(feld, "kreuzschnitt", ort, 0.3, false, 0.0, 0.6)
		"sternenfunke":
			_pose(v)
			Geraeusche.play("perfekt", 1.9)
			if ziel_ansicht != null:
				await FxBild.flug(feld, "stern_flug", v.center(), ziel_ansicht.center(), 0.26, 0.5, 90.0)
				_funken(feld, ziel_ansicht.center(), 0.8)
		"lied":
			# Sie spielt: ruhig (farbe Mond) oder schnell mit Schritt nach vorn (farbe Komet)
			_pose(v)
			_huepfer(v, 8.0, 0.14)
			Geraeusche.play("zauber", 0.8 if farbe == MOND else 1.3)
			FxBild.spawn(feld, "noten" if farbe == MOND else "noten_gold", v.center() + Vector2(0, -50), 0.7,
					not f.is_ally(), 0.0, 0.7)
			await k.wait(0.3)
		"mond_ueber":
			if ziel_ansicht != null:
				FxBild.spawn(feld, "mond", ziel_ansicht.center() + Vector2(0, -70), 0.5, false, 0.0, 0.45, 0.4)
				ziel_ansicht.glow(MOND, 0.5)
		"polarstern":
			if ziel_ansicht != null:
				_lichtstrahl(feld, ziel_ansicht, 0.6).modulate = MOND.lightened(0.3)
				ziel_ansicht.glow(MOND, 0.6)
		"komet_um":
			if ziel_ansicht != null:
				ziel_ansicht.glow(KOMET, 0.6)
				var ort := ziel_ansicht.center()
				FxBild.flug(feld, "komet", ort + Vector2(-110, -30), ort + Vector2(110, -30), 0.35, 0.5, 50.0)
		"mondkuppel":
			if ziel_ansicht != null:
				Geraeusche.play("perfekt", 0.8)
				_kuppel(feld, ziel_ansicht.home_feet())
		"schnuppe":
			# Sternschnuppe von oben, die Tonleiter fällt (seite zählt die Schnuppen)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				var seitlich := -160.0 if f.is_ally() else 160.0
				await FxBild.flug(feld, "stern_flug", ort + Vector2(-seitlich, -380), ort, 0.15, 0.5)
				Geraeusche.play("treffer", maxf(1.7 - 0.12 * seite, 0.7))
				_funken(feld, ort, 0.9)
		"rueckkehr":
			# Ein einzelner Stern sinkt auf den Gefallenen, Lichtfunken steigen auf
			Geraeusche.play("perfekt", 0.9)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				await FxBild.flug(feld, "stern_flug", ort + Vector2(0, -330), ort, 0.4, 0.5)
				_lichtstrahl(feld, ziel_ansicht, 0.7)
				FxBild.spawn(feld, "heilung", ort + Vector2(0, -20), 0.8, false, 0.0, 0.7)
				_huepfer(ziel_ansicht, 14.0, 0.12)
		"dissonanz":
			_pose(v)
			Geraeusche.play("parade", 0.4)
			if ziel_ansicht != null:
				await _schallwellen(feld, v, "bruellen_rot", 0.35)
				_zappeln(ziel_ansicht)
		"sternenlicht":
			if ziel_ansicht != null:
				_lichtstrahl(feld, ziel_ansicht, 0.6)
				FxBild.spawn(feld, "heilung", ziel_ansicht.center() + Vector2(0, -20), 0.7, false, 0.0, 0.7)


## Kleiner Sprung. Bewegt die ganze Ansicht, damit er neben einem laufenden Angriff funktioniert.
static func _huepfer(v: FighterView, hoehe: float, sekunden: float) -> void:
	var y := v.position.y
	var tween := v.create_tween()
	tween.tween_property(v, "position:y", y - hoehe, sekunden).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(v, "position:y", y, sekunden).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


static func _kniefall(v: FighterView) -> Tween:
	var tween := v.create_tween()
	tween.tween_property(v.body, "position", v._home + Vector2(0, 12), 0.12)
	return tween


## Das Ziel taumelt ein Stück zurück, weiter als bei einem normalen Treffer.
static func _taumeln(v: FighterView) -> void:
	var weg := 1.0 if v.fighter.is_ally() else -1.0
	var x := v.position.x
	var tween := v.create_tween()
	tween.tween_property(v, "position:x", x + 30.0 * weg, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(v, "position:x", x, 0.35).set_trans(Tween.TRANS_SINE)


## Kleines Pflaster-Zeichen, das aufsteigt und verblasst.
static func _pflaster(feld: Control, ort: Vector2) -> void:
	var zeichen := Node2D.new()
	zeichen.position = ort + Vector2(0, -20)
	zeichen.rotation = -0.3
	zeichen.z_index = 9
	for teil: Rect2 in [Rect2(-14, -5, 28, 10), Rect2(-5, -14, 10, 28)]:
		var balken := ColorRect.new()
		balken.position = teil.position
		balken.size = teil.size
		balken.color = Color("f4e6c8")
		zeichen.add_child(balken)
	feld.add_child(zeichen)
	var tween := zeichen.create_tween().set_parallel()
	tween.tween_property(zeichen, "position:y", ort.y - 70.0, 0.7)
	tween.tween_property(zeichen, "modulate:a", 0.0, 0.3).set_delay(0.4)
	tween.chain().tween_callback(zeichen.queue_free)


## Kurze Schild-Kuppel über dem Gedeckten (gemalt, D9h).
static func _kuppel(feld: Control, fuss: Vector2) -> void:
	FxBild.am_boden(feld, "schild_kuppel", fuss + Vector2(0, 8), 0.75, 0.6)


## Kurzer Funken-Einschlag (gemalt), z. B. wo ein Geschoss trifft. Gibt das Bild zurück, damit es eingefärbt werden kann.
static func _funken(feld: Control, ort: Vector2, groesse: float) -> FxBild:
	return FxBild.spawn(feld, "treffer_funken", ort, 0.3, false, 0.0, groesse)


## Ein gemalter Pfeil fliegt zum Ziel.
static func _pfeilflug(feld: Control, von: Vector2, nach: Vector2, sekunden: float, groesse := 0.5) -> void:
	await FxBild.flug(feld, "pfeil_flug", von, nach, sekunden, groesse)


## Eine gemalte Tänzerinnen-Klinge fliegt zum Ziel.
static func _klingenflug(feld: Control, von: Vector2, nach: Vector2, sekunden: float) -> void:
	await FxBild.flug(feld, "klinge_flug", von, nach, sekunden, 0.45)


## Beeren und Körner fliegen im Bogen und verstreuen sich vor dem Monster.
static func _futterwurf(feld: Control, von: Vector2, nach: Vector2) -> void:
	var futter := FxBild.spawn(feld, "futter", von, 0.45, nach.x < von.x, 0.0, 0.5)
	var tween := futter.create_tween()
	tween.tween_method(func(t: float) -> void:
		futter.position = von.lerp(nach, t) + Vector2(0, -360.0 * t * (1.0 - t)), 0.0, 1.0, 0.3)
	await tween.finished


## Gemalte Schallwellen laufen von der Figur zu den Gegnern.
static func _schallwellen(feld: Control, quelle: FighterView, name: String, sekunden: float) -> void:
	var richtung := -1.0 if quelle.fighter.is_ally() else 1.0
	FxBild.spawn(feld, name, quelle.center() + Vector2(richtung * 80.0, 0), sekunden, richtung < 0.0, 0.0, 1.0)
	await feld.get_tree().create_timer(sekunden).timeout


## Gemalter Lichtstrahl, der von oben auf eine Figur fällt.
static func _lichtstrahl(feld: Control, ziel: FighterView, sekunden: float) -> FxBild:
	return FxBild.am_boden(feld, "lichtstrahl", ziel.home_feet() + Vector2(0, 6), sekunden, 0.9)


## Schuss-Haltung, wenn die Figur eine hat.
static func _pose(v: FighterView) -> void:
	if v.has_anim("attack"):
		v.play("attack", 0.3)


## Rückstoß beim Schuss, weg vom Ziel.
static func _rueckstoss(v: FighterView) -> void:
	var weg := 1.0 if v.fighter.is_ally() else -1.0
	var x := v.position.x
	var tween := v.create_tween()
	tween.tween_property(v, "position:x", x + 14.0 * weg, 0.06)
	tween.tween_property(v, "position:x", x, 0.25).set_trans(Tween.TRANS_SINE)


## Dünne, helle Spur eines Pfeils. Kann auch ohne await laufen (mehrere Pfeile gleichzeitig).
static func _pfeil(feld: Control, von: Vector2, nach: Vector2, farbe: Color, sekunden: float, breite: float) -> void:
	var spur := Line2D.new()
	spur.width = breite
	spur.default_color = farbe
	spur.z_index = 8
	spur.material = Fx.add_material()
	spur.add_point(von)
	spur.add_point(von)
	feld.add_child(spur)
	var tween := spur.create_tween()
	tween.tween_method(func(t: float) -> void:
		spur.set_point_position(0, von.lerp(nach, maxf(t - 0.3, 0.0)))
		spur.set_point_position(1, von.lerp(nach, t)), 0.0, 1.0, sekunden)
	await tween.finished
	spur.queue_free()


## Leuchtende Schneise, die kurz stehen bleibt.
static func _schneise(feld: Control, von: Vector2, nach: Vector2, farbe: Color) -> void:
	var spur := Line2D.new()
	spur.width = 12.0
	spur.default_color = farbe
	spur.z_index = 8
	spur.material = Fx.add_material()
	spur.add_point(von)
	spur.add_point(nach)
	feld.add_child(spur)
	var tween := spur.create_tween()
	tween.tween_property(spur, "width", 0.0, 0.6).set_delay(0.2)
	tween.tween_callback(spur.queue_free)


## Pfeile regnen herab und bleiben kurz im Boden stecken (gemalt), mit drei Einschlag-Geräuschen.
static func _regen(k: Control, feld: Control, fuss: Vector2) -> void:
	FxBild.am_boden(feld, "pfeilregen", fuss + Vector2(0, 10), 0.6, 0.8, false, 0.3)
	await k.wait(0.15)
	for i in 3:
		Geraeusche.play("treffer", 1.6)
		await k.wait(0.1)


## Der Gegner zappelt im Netz.
static func _zappeln(v: FighterView) -> void:
	var x := v.position.x
	var tween := v.create_tween()
	for i in 3:
		tween.tween_property(v, "position:x", x - 5.0, 0.05)
		tween.tween_property(v, "position:x", x + 5.0, 0.05)
	tween.tween_property(v, "position:x", x, 0.05)


## Leuchtender Geist des Silberhirschs, läuft neben dem Pfeil her.
static func _hirschgeist(feld: Control, von: Vector2, nach: Vector2, sekunden: float) -> void:
	var geist := Sprite2D.new()
	geist.texture = load(HIRSCH)
	geist.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	geist.scale = Vector2.ONE * 140.0 / geist.texture.get_height()
	geist.flip_h = nach.x < von.x
	geist.modulate = Color(0.8, 0.95, 1.0, 0.85)
	geist.material = Fx.add_material()
	geist.position = von
	geist.z_index = 8
	feld.add_child(geist)
	var tween := geist.create_tween()
	tween.tween_property(geist, "position", nach, sekunden).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(geist, "modulate:a", 0.0, 0.2)
	tween.tween_callback(geist.queue_free)


## Etwas fliegt im Bogen zum Ziel (Stein, Futter).
static func _bogenwurf(feld: Control, von: Vector2, nach: Vector2, farbe: Color) -> void:
	var mitte := von.lerp(nach, 0.5) + Vector2(0, -90)
	await _pfeil(feld, von, mitte, farbe, 0.12, 5.0)
	await _pfeil(feld, mitte, nach, farbe, 0.12, 5.0)


## Kleines Zeichen, das über einer Figur aufsteigt und verblasst.
static func _zeichen(feld: Control, ort: Vector2, text: String, farbe: Color) -> void:
	var schrift := Label.new()
	schrift.text = text
	schrift.add_theme_font_size_override("font_size", 34)
	schrift.add_theme_color_override("font_color", farbe)
	schrift.add_theme_color_override("font_outline_color", Color.BLACK)
	schrift.add_theme_constant_override("outline_size", 5)
	schrift.position = ort - Vector2(10, 20)
	schrift.z_index = 9
	feld.add_child(schrift)
	var tween := schrift.create_tween().set_parallel()
	tween.tween_property(schrift, "position:y", ort.y - 60.0, 0.8)
	tween.tween_property(schrift, "modulate:a", 0.0, 0.3).set_delay(0.5)
	tween.chain().tween_callback(schrift.queue_free)


## Kleine Form (Pfeil, Stern), die über einer Figur aufsteigt und verblasst.
static func _symbol(feld: Control, ort: Vector2, farbe: Color, form: Array) -> void:
	var zeichen := Polygon2D.new()
	zeichen.polygon = PackedVector2Array(form)
	zeichen.color = farbe
	zeichen.position = ort
	zeichen.z_index = 9
	feld.add_child(zeichen)
	var tween := zeichen.create_tween().set_parallel()
	tween.tween_property(zeichen, "position:y", ort.y - 40.0, 0.8)
	tween.tween_property(zeichen, "modulate:a", 0.0, 0.3).set_delay(0.5)
	tween.chain().tween_callback(zeichen.queue_free)


## Der gemalte Amboss fällt in den Boden, dann Risse, Staub und Wackeln.
static func _amboss(k: Control, feld: Control, ort: Vector2) -> void:
	var amboss := Sprite2D.new()
	amboss.texture = FxBild.bilder("amboss")[0]
	amboss.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	amboss.scale = Vector2.ONE * FxBild.GROESSE * 0.4
	amboss.offset = Vector2(0, -amboss.texture.get_height() * 0.5)
	amboss.flip_h = ort.x > feld.size.x * 0.5
	amboss.position = ort + Vector2(0, -160)
	amboss.z_index = 7
	feld.add_child(amboss)
	var tween := amboss.create_tween()
	tween.tween_property(amboss, "position", ort, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	Geraeusche.play("treffer", 0.4)
	k._shake(10.0)
	FxBild.spawn(feld, "risse", ort, 0.5, false, 0.0, 0.6, 0.4).z_index = 2
	FxBild.am_boden(feld, "staubwolke", ort + Vector2(0, 6), 0.5, 0.7)
	var weg := amboss.create_tween()
	weg.tween_property(amboss, "modulate:a", 0.0, 0.3).set_delay(0.6)
	weg.tween_callback(amboss.queue_free)
	await k.wait(0.25)


## Durchsichtiges Nachbild, das kurz stehen bleibt, wo die Figur gerade war.
static func _nachbild(feld: Control, v: FighterView) -> void:
	var bild := Sprite2D.new()
	bild.texture = v.body.texture
	bild.offset = v.body.offset
	bild.scale = v.body.scale
	bild.flip_h = v.body.flip_h
	bild.texture_filter = v.body.texture_filter
	bild.position = v.position + v.body.position
	bild.modulate = Color(0.8, 0.85, 1.0, 0.55)
	bild.z_index = 5
	feld.add_child(bild)
	var tween := bild.create_tween()
	tween.tween_property(bild, "modulate:a", 0.0, 0.45)
	tween.tween_callback(bild.queue_free)


## Breite gemalte Sichel aus Licht, die über die Gegner fegt (Bauch voran).
static func _sichel(feld: Control, von: Vector2, richtung: float) -> void:
	var sichel := FxBild.spawn(feld, "sichel", von, 0.28, richtung > 0.0, 0.0, 1.0)
	var tween := sichel.create_tween()
	tween.tween_property(sichel, "position:x", von.x + richtung * 760.0, 0.28)
	await tween.finished


## Drei gemalte Klingen drehen sich als Ring um das Ziel.
static func _klingenring(feld: Control, ort: Vector2) -> void:
	var ring := Node2D.new()
	ring.position = ort
	ring.z_index = 8
	for i in 3:
		var klinge := Sprite2D.new()
		klinge.texture = FxBild.bilder("klinge_flug")[0]
		klinge.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		klinge.scale = Vector2.ONE * FxBild.GROESSE * 0.4
		var richtung := Vector2.from_angle(TAU * i / 3.0)
		klinge.position = richtung * 60.0
		klinge.rotation = richtung.angle() + PI * 0.5
		ring.add_child(klinge)
	feld.add_child(ring)
	var tween := ring.create_tween()
	tween.tween_property(ring, "rotation", TAU * 2.0, 0.7)
	tween.tween_property(ring, "modulate:a", 0.0, 0.2)
	await tween.finished
	ring.queue_free()
