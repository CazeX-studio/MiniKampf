extends SceneTree
## A20: Wann kommt ein Ladebildschirm, welches Bild, gibt es alle Bilder und Tipps.

var _failed := 0


func _initialize() -> void:
	# Region bzw. Dungeon je Karte
	_check(Ladebildschirm.ort_von("kreuzweg") == "Kreuzweg", "Kreuzweg gehört zur Region Kreuzweg")
	_check(Ladebildschirm.ort_von("palmenrast") == "Glutoase", "Palmenrast gehört zur Glutoase")
	_check(Ladebildschirm.ort_von("pilzhoehle") == "pilzhoehle", "Dungeon zählt für sich")
	_check(Ladebildschirm.ort_von("wegrast") == "", "Innenräume zeigen keinen Ladebildschirm")
	# Bildwahl
	_check(Ladebildschirm.bild_waehlen(true, "") == "gruppe", "Allererster Start ohne Klasse: Gruppenbild")
	var eigene := 0
	for i in 200:
		if Ladebildschirm.bild_waehlen(false, "smith") == "schmied":
			eigene += 1
	_check(eigene > 110, "Nach der Klassenwahl meist die eigene Szene (%d von 200)" % eigene)
	# Alle Bilder und Klassen-Szenen vorhanden
	var daten: Dictionary = GameData.get_file("ladebildschirm")
	for bild: String in daten.bilder:
		_check(ResourceLoader.exists(Ladebildschirm.ORDNER % bild), "Bild fehlt: %s" % bild)
	for klasse: String in daten.klassen:
		_check(str(daten.klassen[klasse]) in daten.bilder, "Klassen-Szene in der Liste: %s" % klasse)
		_check(Sandbox.CLASSES.has(klasse), "Klasse gibt es: %s" % klasse)
	_check(daten.tipps.size() >= 5, "Genug Tipps")
	# Ohne Bildschirm (Prüfungen) kommt nichts, die Region wird trotzdem gemerkt
	_check(not Ladebildschirm.pruefen(root, "glutoase", "Glutoase"), "Ohne Bildschirm kein Ladebildschirm")
	_check(not Ladebildschirm.pruefen(root, "palmenrast", "Palmenrast"), "Gleiche Region: keiner")
	print("Ladebildschirm: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(1 if _failed > 0 else 0)


func _check(condition: bool, text: String) -> void:
	if not condition:
		_failed += 1
		print("FEHLER: " + text)
