extends SceneTree
## A9b: Wie oft schafft eine Gruppe einen Boss, mit und ohne seine Mechanik? Spielt Kämpfe ohne Grafik durch.
## Aufruf: Godot --headless --path . -s tests/boss_messen.gd -- <kampf> [anzahl] [stufe] [ohne]
## Mit „allein“ als fünftem Wort kämpft die Klasse ohne die beiden Novizen.
## ohne: Mechaniken, die der Computer im zweiten Durchgang auslässt, mit Komma getrennt (Standard: kuehlbecken).
## Gruppe: jede Demo-Klasse auf der Stufe, dazu zwei Novizen vom Computer (wie Tessa und Gorm).

const KLASSEN := ["archer", "tamer", "blade", "smith", "singer"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var kampf := args[0] if args.size() > 0 else "kettenschmied"
	var anzahl := int(args[1]) if args.size() > 1 else 20
	var stufe := int(args[2]) if args.size() > 2 else 20
	var auslassen: Array[String] = []
	auslassen.assign((args[3] if args.size() > 3 else "kuehlbecken").split(","))
	var allein := args.size() > 4 and args[4] == "allein"
	for ohne: bool in [false, true]:
		KampfKI.ohne_mechanik = auslassen if ohne else ([] as Array[String])
		var siege := 0
		var phase2 := 0
		var zuege := 0
		for klasse: String in KLASSEN:
			var a := KampfEditor.standard()
			a.art = "spiel"
			a.kampf = kampf
			a.gruppe = [{klasse = klasse, stufe = stufe}, {klasse = "" if allein else "novize", stufe = stufe},
					{klasse = "" if allein else "novize", stufe = stufe}, {klasse = "", stufe = 1}]
			var s := KampfEditor.setup_bauen(a)
			var k_siege := 0
			for i in anzahl:
				var e := ProbeKampf.einmal(root, s, 100 + i)
				if e.gewonnen:
					k_siege += 1
					zuege += int(e.zuege)
				if e.get("phase2", false):
					phase2 += 1
			siege += k_siege
			print("  %-7s %s: %2d von %d gewonnen" % [klasse, "ohne Mechanik" if ohne else "mit Mechanik ", k_siege, anzahl])
		var gesamt := anzahl * KLASSEN.size()
		print("%s %s: %d von %d gewonnen (%d %%), Phase 2 erreicht: %d, Züge je Sieg: %d" % [kampf, "OHNE Mechanik" if ohne else "MIT Mechanik",
				siege, gesamt, roundi(100.0 * siege / gesamt), phase2, zuege / maxi(1, siege)])
	KampfKI.ohne_mechanik = []
	quit(0)
