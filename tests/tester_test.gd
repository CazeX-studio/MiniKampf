extends SceneTree
## Test für den Demo-Start (S1): Spitzname einmal festlegen, eindeutige Tester-Nummer und Tester-Code,
## Formular-Link mit ausgefüllten Feldern, Werkzeuge nur im Godot-Editor, Version.
## Aufruf: Godot --headless --path . --script res://tests/tester_test.gd


func _initialize() -> void:
	var failed := 0
	Tester.datei = "user://tester_test.json"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Tester.datei))
	Tester.neu_laden()
	failed += _check("Noch kein Spitzname", Tester.spitzname(), "")
	failed += _check("Leerer Name geht nicht", Tester.festlegen("   "), false)
	failed += _check("Name festlegen", Tester.festlegen("  Sternchen  "), true)
	failed += _check("Name bereinigt", Tester.spitzname(), "Sternchen")
	failed += _check("Nummer vergeben", Tester.nummer().length(), 8)
	var nummer := Tester.nummer()
	failed += _check("Name bleibt fest", Tester.festlegen("Anders"), false)
	failed += _check("Name unverändert", Tester.spitzname(), "Sternchen")
	failed += _check("Zu langer Name gekürzt", Tester.bereinigen("abcdefghijklmnopqrstuvwxyz"), "abcdefghijklmnopqrst")
	# Bleibt nach dem Neuladen (eigene Datei, nicht im Spielstand)
	Tester.neu_laden()
	failed += _check("Gespeichert", [Tester.spitzname(), Tester.nummer()], ["Sternchen", nummer])
	failed += _check("Noch nicht durchgespielt", [Tester.durchgespielt(), Tester.code()], [false, ""])
	var code := Tester.abschliessen("glutoase")
	failed += _check("Code-Form", code.length() == 13 and code.begins_with("AST-") and code[8] == "-", true)
	failed += _check("Durchgespielt", Tester.durchgespielt(), true)
	failed += _check("Zweites Ende, gleicher Code", Tester.abschliessen("gruenwacht"), code)
	# Codes und Nummern sind praktisch eindeutig: 2000 Stück ohne doppelte
	var gesehen := {}
	for i in 2000:
		gesehen["AST-%s-%s" % [Tester.zufall(4), Tester.zufall(4)]] = true
	failed += _check("Keine doppelten Codes", gesehen.size(), 2000)
	for zeichen in code.replace("AST-", "").replace("-", ""):
		if not zeichen in Tester.ZEICHEN:
			failed += _check("Nur eindeutige Zeichen", zeichen, "aus ZEICHEN")
	# Formular: ohne Vorlage kein Link, mit Vorlage alle Platzhalter ersetzt
	failed += _check("Noch kein Formular", Tester.formular_link("Feedback", "Kreuzweg"), "")
	GameData.get_file("demo")["formular_vorlage"] = "https://docs.google.com/forms/d/e/X/viewform?usp=pp_url&entry.1=SPITZNAME&entry.2=NUMMER&entry.3=ART&entry.4=CODE&entry.5=VERSION&entry.6=ORT"
	var link := Tester.formular_link("Demo durchgespielt", "Ende der Glutoase")
	failed += _check("Link ausgefüllt", link, "https://docs.google.com/forms/d/e/X/viewform?usp=pp_url&entry.1=Sternchen&entry.2=%s&entry.3=Demo%%20durchgespielt&entry.4=%s&entry.5=%s&entry.6=Ende%%20der%%20Glutoase" % [nummer, code, Tester.version().uri_encode()])
	GameData.get_file("demo")["formular_vorlage"] = ""
	# Im Godot-Editor (Prüfung) gibt es Werkzeuge und keine Spitznamen-Frage
	failed += _check("Werkzeuge im Editor", Tester.werkzeuge(), true)
	failed += _check("Keine Frage im Editor", Tester.spitzname_noetig(), false)
	var v: Dictionary = GameData.get_file("version")
	failed += _check("Version", Tester.version(), "%s %s · Entwicklung" % [v.nummer, v.stufe])
	failed += _check("Dankesliste lesbar", Tester.dankesliste() is Array, true)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Tester.datei))
	print("Tester: %s" % ("alles richtig" if failed == 0 else "%d Fehler" % failed))
	quit(failed)


func _check(what: String, got: Variant, want: Variant) -> int:
	if got == want:
		return 0
	print("FEHLER: %s – bekommen %s, erwartet %s" % [what, got, want])
	return 1
