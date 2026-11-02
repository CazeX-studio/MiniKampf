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
				Fx.spawn(feld, Fx.Kind.RING, ziel_ansicht.center(), Color("e0b070"), 70.0, 0.25)
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
			Fx.spawn(feld, Fx.Kind.SPARKS, ort, GRUEN, 70.0, 0.6)
			_pflaster(feld, ort)
		"deckung":
			_huepfer(v, 20.0, 0.16)
			Geraeusche.play("parade", 0.7)
			if ziel_ansicht != null:
				_kuppel(feld, ziel_ansicht.home_feet())
			await k.wait(0.35)
		"deckung_funke":
			Geraeusche.play("parade", 0.7)
			Fx.spawn(feld, Fx.Kind.SPARKS, v.center(), SCHILD.lightened(0.4), 80.0, 0.35)
		"sternenmut_an":
			# Das Schwert leuchtet lila wie ein Splitter, ein heller Glockenton
			Geraeusche.play("perfekt", 1.5)
			v.glow(STERN, 1.0)
			Fx.spawn(feld, Fx.Kind.GLOW, v.center(), STERN, 120.0, 0.6)
			await k.wait(0.4)
		"sternenmut_schlag":
			Geraeusche.play("kritisch", 0.9)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				Fx.spawn(feld, Fx.Kind.SLASH, ort, STERN, 110.0, 0.4)
				Fx.spawn(feld, Fx.Kind.SPARKS, ort, STERN.lightened(0.4), 130.0, 0.7)
				Fx.spawn(feld, Fx.Kind.RING, ort, STERN, 170.0, 0.5)
			k.screen_flash(STERN)
		"schnellschuss":
			_pose(v)
			Geraeusche.play("wurf", 1.7)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				await _pfeil(feld, v.center(), ort, Color("e8ffd0"), 0.14, 3.0)
				Fx.spawn(feld, Fx.Kind.SPARKS, ort, Color("e8ffd0"), 40.0, 0.25)
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
				await _pfeil(feld, v.center(), ort, Color("f4ffe0"), 0.12, 7.0)
				if name == "durchschlag":
					_schneise(feld, v.center(), ort, Color("e8ffc8"))
					Geraeusche.play("parade", 0.5)
				Fx.spawn(feld, Fx.Kind.SPARKS, ort, STAUB, 100.0, 0.5)
				k._shake(10.0)
		"durchschlag_weiter":
			if ziel_ansicht != null:
				_schneise(feld, v.center(), ziel_ansicht.center(), Color("e8ffc8"))
				Fx.spawn(feld, Fx.Kind.SPARKS, ziel_ansicht.center(), STAUB, 70.0, 0.4)
				await k.wait(0.15)
		"hagel_auf":
			# Steil in den Himmel schießen und hinterherschauen
			_pose(v)
			Geraeusche.play("wurf", 1.2)
			for i in 3:
				_pfeil(feld, v.center(), v.center() + Vector2(-40.0 - 30.0 * i, -520.0), Color("e8ffd0"), 0.22, 3.0)
			await k.wait(0.35)
		"hagel_regen":
			if ziel_ansicht != null:
				_regen(k, feld, ziel_ansicht.home_feet())
		"netzpfeil":
			_pose(v)
			Geraeusche.play("wurf", 0.8)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				var mitte := v.center().lerp(ort, 0.5) + Vector2(0, -120)
				await _pfeil(feld, v.center(), mitte, Color.WHITE, 0.14, 3.0)
				await _pfeil(feld, mitte, ort, Color.WHITE, 0.14, 3.0)
				Geraeusche.play("parade", 0.5)
				_netz(feld, ort)
				_zappeln(ziel_ansicht)
		"schnellfeuer":
			# Immer schneller, die Spuren werden heller (seite zählt die Pfeile)
			_pose(v)
			Geraeusche.play("wurf", 1.5 + 0.1 * seite)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				await _pfeil(feld, v.center(), ort, WALD.lightened(0.15 * seite), maxf(0.15 - 0.02 * seite, 0.07), 3.0)
				Fx.spawn(feld, Fx.Kind.SPARKS, ort, Color("e8ffd0"), 34.0, 0.2)
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
				await _pfeil(feld, v.center(), ort, Color("ff5050"), 0.2, 4.0)
				_fadenkreuz(feld, ort)
		"elementpfeil":
			v.glow(farbe, 0.4)
			await k.wait(0.25)
			_pose(v)
			Geraeusche.play("wurf", 1.1)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				await _pfeil(feld, v.center(), ort, farbe, 0.18, 5.0)
				Fx.spawn(feld, Fx.Kind.RING, ort, farbe, 80.0, 0.3)
				Fx.spawn(feld, Fx.Kind.SPARKS, ort, farbe, 70.0, 0.4)
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
				await _pfeil(feld, v.center(), ort, WALD.lightened(0.4), 0.45, 8.0)
				Geraeusche.play("kritisch", 0.6)
				k._change_speed(0.3, 0.25)
				k._shake(14.0)
				k.screen_flash(WALD)
				Fx.spawn(feld, Fx.Kind.RING, ort, WALD, 170.0, 0.5)
				Fx.spawn(feld, Fx.Kind.SPARKS, ort, WALD, 170.0, 0.8)
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
			Fx.spawn(feld, Fx.Kind.SPARKS, v.home_feet(), STAUB, 90.0 + 40.0 * seite, 0.5)
			Fx.spawn(feld, Fx.Kind.RING, v.home_feet(), STAUB, 70.0 + 30.0 * seite, 0.3)
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
				Fx.spawn(feld, Fx.Kind.RING, ziel_ansicht.home_feet(), Color("ff6060"), 80.0, 0.4)
				Fx.spawn(feld, Fx.Kind.SPARKS, ziel_ansicht.center(), Color("ff8080"), 80.0, 0.6)
		"pflege":
			# Kniet sich zum Monster und gibt ihm eine Beere
			var kniend := _kniefall(v)
			await k.wait(0.35)
			kniend.kill()
			v.body.position = v._home
			if ziel_ansicht != null:
				Fx.spawn(feld, Fx.Kind.SPARKS, ziel_ansicht.center(), WALD, 80.0, 0.7)
		"lockfutter":
			_pose(v)
			Geraeusche.play("wurf", 0.7)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				await _bogenwurf(feld, v.center(), ort, Color("e8c890"))
				Fx.spawn(feld, Fx.Kind.SPARKS, ziel_ansicht.home_feet(), Color("e8c890"), 40.0, 0.4)
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
				_schneise(feld, v.center(), ziel_ansicht.center(), WALD)
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
			for i in 3:
				Fx.spawn(feld, Fx.Kind.RING, quelle.center(), Color("8fb8ff"), 140.0 + 70.0 * i, 0.45)
				await k.wait(0.12)
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
				Fx.spawn(feld, Fx.Kind.SPARKS, ziel_ansicht.home_feet(), STAUB, 180.0, 0.8)
				Fx.spawn(feld, Fx.Kind.RING, ziel_ansicht.home_feet(), STAUB, 170.0, 0.5)
			k._change_speed(0.3, 0.25)
			k._shake(14.0)
		"hammer_treffer":
			Geraeusche.play("parade", 0.6)
			if ziel_ansicht != null:
				Fx.spawn(feld, Fx.Kind.SPARKS, ziel_ansicht.center(), GLUT, 100.0, 0.5)
				_symbol(feld, ziel_ansicht.center() + Vector2(0, -60), Color("ff5050"), PFEIL_RUNTER)
		"schmiede_moment":
			_pose(v)
			Geraeusche.play("parade", 0.9)
			Fx.spawn(feld, Fx.Kind.SPARKS, v.center(), GLUT, 70.0, 0.4)
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
			Fx.spawn(feld, Fx.Kind.SPARKS, v.center(), Color(Color.WHITE, 0.7), 80.0, 0.6)
		"gluehend":
			_pose(v)
			Geraeusche.play("zauber", 0.7)
			v.glow(GLUT, 1.0)
			Fx.spawn(feld, Fx.Kind.GLOW, v.center(), Color(GLUT, 0.5), 100.0, 0.8)
			Fx.spawn(feld, Fx.Kind.SPARKS, v.center(), GLUT, 90.0, 0.8)
			await k.wait(0.4)
		"angesengt":
			if ziel_ansicht != null:
				ziel_ansicht.glow(GLUT, 0.4)
				Fx.spawn(feld, Fx.Kind.SPARKS, ziel_ansicht.center(), GLUT, 60.0, 0.3)
		"funkenflug":
			if ziel_ansicht != null:
				await _pfeil(feld, v.center(), ziel_ansicht.center(), GLUT, 0.15, 6.0)
				Fx.spawn(feld, Fx.Kind.SPARKS, ziel_ansicht.center(), GLUT, 70.0, 0.3)
		"ambossschlag":
			_huepfer(v, 50.0, 0.2)
			await k.wait(0.4)
			Geraeusche.play("kritisch", 0.5)
			Fx.spawn(feld, Fx.Kind.RING, v.home_feet(), GLUT, 300.0, 0.5)
			Fx.spawn(feld, Fx.Kind.SPARKS, v.home_feet(), STAUB, 160.0, 0.7)
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
				Fx.spawn(feld, Fx.Kind.SPARKS, v.center(), farbe_teil, 80.0, 0.35)
				await k.wait(0.28)
			Geraeusche.play("perfekt", 0.6)
			v.glow(Color("f2c14e"), 1.2)
			Fx.spawn(feld, Fx.Kind.SPARKS, v.center(), Color("f2c14e"), 170.0, 0.9)
			Fx.spawn(feld, Fx.Kind.RING, v.center(), Color("f2c14e"), 150.0, 0.5)
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
				for winkel: float in [-0.8, 0.8]:
					var spur := Fx.spawn(feld, Fx.Kind.SLASH, ziel_ansicht.center(), KLINGE, 60.0, 0.28)
					spur.rotation = winkel
		"klinge_neu":
			Fx.spawn(feld, Fx.Kind.SPARKS, v.center() + Vector2(0, -30), KLINGE, 34.0, 0.3)
		"klinge_flug":
			if ziel_ansicht != null:
				_pfeil(feld, v.center(), ziel_ansicht.center(), KLINGE, 0.12, 3.0)
		"wirbel":
			# Pirouette: ein Kreis aus Schnitt-Spuren, Sand wirbelt auf
			_huepfer(v, 10.0, 0.12)
			Geraeusche.play("wurf", 1.4)
			for i in 6:
				var richtung := Vector2.from_angle(TAU * i / 6.0)
				var spur := Fx.spawn(feld, Fx.Kind.SLASH, v.center() + richtung * 56.0, KLINGE, 44.0, 0.3)
				spur.rotation = richtung.angle()
			Fx.spawn(feld, Fx.Kind.SPARKS, v.home_feet(), STAUB, 90.0, 0.5)
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
				await _pfeil(feld, v.center(), ziel_ansicht.center(), KLINGE, 0.2, 4.0)
				Geraeusche.play("perfekt", 1.7)
				Fx.spawn(feld, Fx.Kind.SPARKS, ziel_ansicht.center(), KLINGE, 60.0, 0.5)
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
					_pfeil(feld, v.center() + Vector2(0, -50 + 25 * i), ort, KLINGE.lightened(0.1 * i), 0.16, 4.0)
					await k.wait(0.08)
				await k.wait(0.1)
				Fx.spawn(feld, Fx.Kind.SPARKS, ort, KLINGE, 60.0 + 16.0 * seite, 0.4)
				if seite >= Fighter.MAX_BLADES:
					Geraeusche.play("kritisch", 1.0)
					Fx.spawn(feld, Fx.Kind.GLOW, ort, Color(KLINGE, 0.8), 150.0, 0.4)
					Fx.spawn(feld, Fx.Kind.RING, ort, KLINGE, 190.0, 0.45)
					k.screen_flash(KLINGE)
					k._change_speed(0.3, 0.2)
		"schwarm":
			# Die Klingen vervielfachen sich, Nachbilder tanzen
			Geraeusche.play("treffer", 0.8)
			_nachbild(feld, v)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				for i in 4:
					_pfeil(feld, v.center() + Vector2(randf_range(-50, 50), randf_range(-70, 70)), ort, KLINGE, 0.2, 3.0)
				Fx.spawn(feld, Fx.Kind.SLASH, ort, KLINGE, 50.0, 0.25)
		"sternenfunke":
			_pose(v)
			Geraeusche.play("perfekt", 1.9)
			if ziel_ansicht != null:
				await _bogenwurf(feld, v.center(), ziel_ansicht.center(), KOMET)
				Fx.spawn(feld, Fx.Kind.SPARKS, ziel_ansicht.center(), KOMET, 60.0, 0.35)
		"lied":
			# Sie spielt: ruhig (farbe Mond) oder schnell mit Schritt nach vorn (farbe Komet)
			_pose(v)
			_huepfer(v, 8.0, 0.14)
			Geraeusche.play("zauber", 0.8 if farbe == MOND else 1.3)
			await k.wait(0.3)
		"mond_ueber":
			if ziel_ansicht != null:
				_symbol(feld, ziel_ansicht.center() + Vector2(0, -60), MOND, STERN_FORM)
				ziel_ansicht.glow(MOND, 0.5)
		"polarstern":
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				_schneise(feld, ort + Vector2(0, -170), ort + Vector2(0, 50), MOND)
				_symbol(feld, ort + Vector2(0, -170), MOND, STERN_FORM)
				ziel_ansicht.glow(MOND, 0.6)
		"komet_um":
			if ziel_ansicht != null:
				ziel_ansicht.glow(KOMET, 0.6)
				Fx.spawn(feld, Fx.Kind.RING, ziel_ansicht.center(), Color("ff8a3d"), 80.0, 0.4)
		"mondkuppel":
			if ziel_ansicht != null:
				Geraeusche.play("perfekt", 0.8)
				_kuppel(feld, ziel_ansicht.home_feet())
		"schnuppe":
			# Sternschnuppe von oben, die Tonleiter fällt (seite zählt die Schnuppen)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				await _pfeil(feld, ort + Vector2(160, -380), ort, KOMET, 0.15, 6.0)
				Geraeusche.play("treffer", maxf(1.7 - 0.12 * seite, 0.7))
				Fx.spawn(feld, Fx.Kind.SPARKS, ort, KOMET, 70.0, 0.35)
		"rueckkehr":
			# Ein einzelner Stern sinkt auf den Gefallenen, Lichtfunken steigen auf
			Geraeusche.play("perfekt", 0.9)
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				await _pfeil(feld, ort + Vector2(0, -330), ort, KOMET, 0.4, 5.0)
				Fx.spawn(feld, Fx.Kind.SPARKS, ort, Color("fff3b0"), 90.0, 0.7)
				_huepfer(ziel_ansicht, 14.0, 0.12)
		"dissonanz":
			_pose(v)
			Geraeusche.play("parade", 0.4)
			if ziel_ansicht != null:
				for i in 2:
					Fx.spawn(feld, Fx.Kind.RING, ziel_ansicht.center(), Color("ff5050"), 70.0 + 40.0 * i, 0.3)
					await k.wait(0.1)
				_zappeln(ziel_ansicht)
		"sternenlicht":
			if ziel_ansicht != null:
				var ort := ziel_ansicht.center()
				_schneise(feld, ort + Vector2(0, -320), ort, Color("fff3b0"))
				Fx.spawn(feld, Fx.Kind.SPARKS, ort, Color("fff3b0"), 80.0, 0.6)


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


## Kurze Schild-Kuppel über dem Gedeckten.
static func _kuppel(feld: Control, fuss: Vector2) -> void:
	var bogen := Line2D.new()
	bogen.position = fuss
	bogen.width = 5.0
	bogen.default_color = SCHILD
	bogen.z_index = 8
	for i in 25:
		bogen.add_point(Vector2.from_angle(PI + PI * i / 24.0) * Vector2(70, 110))
	feld.add_child(bogen)
	Fx.spawn(feld, Fx.Kind.GLOW, fuss + Vector2(0, -50), Color(SCHILD, 0.3), 90.0, 0.7)
	var tween := bogen.create_tween()
	tween.tween_property(bogen, "modulate:a", 0.0, 0.3).set_delay(0.45)
	tween.tween_callback(bogen.queue_free)


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


## Pfeile regnen nacheinander herab, ihre Schatten erscheinen vorher am Boden.
static func _regen(k: Control, feld: Control, fuss: Vector2) -> void:
	for i in 3:
		var ort := fuss + Vector2(randf_range(-46, 46), randf_range(-10, 10))
		var schatten := Polygon2D.new()
		var punkte := PackedVector2Array()
		for winkel in 12:
			punkte.append(Vector2.from_angle(TAU * winkel / 12.0) * Vector2(16, 6))
		schatten.polygon = punkte
		schatten.color = Color(0, 0, 0, 0.5)
		schatten.position = ort
		schatten.z_index = 1
		feld.add_child(schatten)
		await k.wait(0.1)
		_pfeil(feld, ort + Vector2(30, -420), ort, Color("e8ffd0"), 0.14, 3.0)
		await k.wait(0.14)
		schatten.queue_free()
		Geraeusche.play("treffer", 1.6)
		Fx.spawn(feld, Fx.Kind.SPARKS, ort, STAUB, 30.0, 0.25)


## Netz, das sich um den Gegner legt.
static func _netz(feld: Control, ort: Vector2) -> void:
	var netz := Node2D.new()
	netz.position = ort
	netz.z_index = 8
	for i in range(-3, 4):
		for richtung: float in [1.0, -1.0]:
			var faden := Line2D.new()
			faden.width = 2.0
			faden.default_color = Color("f0ece0")
			faden.add_point(Vector2(i * 16.0 - 44.0 * richtung, -44))
			faden.add_point(Vector2(i * 16.0 + 44.0 * richtung, 44))
			netz.add_child(faden)
	netz.scale = Vector2(1.5, 1.5)
	feld.add_child(netz)
	var tween := netz.create_tween()
	tween.tween_property(netz, "scale", Vector2.ONE, 0.15)
	tween.tween_interval(0.5)
	tween.tween_property(netz, "modulate:a", 0.0, 0.25)
	tween.tween_callback(netz.queue_free)


## Der Gegner zappelt im Netz.
static func _zappeln(v: FighterView) -> void:
	var x := v.position.x
	var tween := v.create_tween()
	for i in 3:
		tween.tween_property(v, "position:x", x - 5.0, 0.05)
		tween.tween_property(v, "position:x", x + 5.0, 0.05)
	tween.tween_property(v, "position:x", x, 0.05)


## Rotes Fadenkreuz über dem Ziel.
static func _fadenkreuz(feld: Control, ort: Vector2) -> void:
	var kreuz := Node2D.new()
	kreuz.position = ort
	kreuz.z_index = 8
	var ring := Line2D.new()
	ring.width = 3.0
	ring.default_color = Color("ff5050")
	for i in 33:
		ring.add_point(Vector2.from_angle(TAU * i / 32.0) * 42.0)
	kreuz.add_child(ring)
	for richtung: Vector2 in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		var strich := Line2D.new()
		strich.width = 3.0
		strich.default_color = Color("ff5050")
		strich.add_point(richtung * 28.0)
		strich.add_point(richtung * 56.0)
		kreuz.add_child(strich)
	feld.add_child(kreuz)
	var tween := kreuz.create_tween()
	tween.tween_property(kreuz, "modulate:a", 0.0, 0.4).set_delay(0.9)
	tween.tween_callback(kreuz.queue_free)


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


## Ein gezeichneter Amboss fällt in den Boden, dann Staub und Wackeln.
static func _amboss(k: Control, feld: Control, ort: Vector2) -> void:
	var amboss := Polygon2D.new()
	amboss.polygon = PackedVector2Array([Vector2(-36, -40), Vector2(36, -40), Vector2(22, -26), Vector2(10, -26), Vector2(14, -10),
			Vector2(26, 0), Vector2(-26, 0), Vector2(-14, -10), Vector2(-10, -26), Vector2(-22, -26)])
	amboss.color = Color("4a5058")
	amboss.position = ort + Vector2(0, -160)
	amboss.z_index = 7
	feld.add_child(amboss)
	var tween := amboss.create_tween()
	tween.tween_property(amboss, "position", ort, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	Geraeusche.play("treffer", 0.4)
	k._shake(10.0)
	Fx.spawn(feld, Fx.Kind.SPARKS, ort, STAUB, 110.0, 0.5)
	Fx.spawn(feld, Fx.Kind.RING, ort, STAUB, 120.0, 0.35)
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


## Breite Sichel aus Licht, die über die Gegner fegt.
static func _sichel(feld: Control, von: Vector2, richtung: float) -> void:
	var sichel := Line2D.new()
	sichel.width = 16.0
	sichel.default_color = KLINGE
	sichel.material = Fx.add_material()
	sichel.z_index = 8
	for i in 17:
		var winkel := (-0.9 + 1.8 * i / 16.0) + (0.0 if richtung > 0.0 else PI)
		sichel.add_point(Vector2.from_angle(winkel) * 150.0)
	sichel.position = von
	feld.add_child(sichel)
	var tween := sichel.create_tween()
	tween.tween_property(sichel, "position:x", von.x + richtung * 760.0, 0.28)
	await tween.finished
	sichel.queue_free()


## Drei Klingen drehen sich als Ring um das Ziel.
static func _klingenring(feld: Control, ort: Vector2) -> void:
	var ring := Node2D.new()
	ring.position = ort
	ring.z_index = 8
	for i in 3:
		var klinge := Line2D.new()
		klinge.width = 5.0
		klinge.default_color = KLINGE
		var richtung := Vector2.from_angle(TAU * i / 3.0)
		klinge.add_point(richtung * 44.0)
		klinge.add_point(richtung.rotated(0.6) * 62.0)
		ring.add_child(klinge)
	feld.add_child(ring)
	var tween := ring.create_tween()
	tween.tween_property(ring, "rotation", TAU * 2.0, 0.7)
	tween.tween_property(ring, "modulate:a", 0.0, 0.2)
	await tween.finished
	ring.queue_free()
