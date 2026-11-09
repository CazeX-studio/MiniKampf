extends SceneTree
## Bewegungs-Editor in der Welt (S3b): Jede Figur jeder Gruppe in jeder Richtung und Bewegung zeigen und
## Bild für Bild weiterschalten (Fehler zeigen sich als SCRIPT ERROR). Dazu: Novizen, Klassen-Körper und
## Baukasten-Figuren haben alle vier Richtungen, Bild für Bild landet wirklich auf dem nächsten Bild.
## Aufruf: Godot --headless --path . -s tests/welt_bewegung_editor_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var skript: GDScript = load("res://scripts/welt/welt_bewegung_editor.gd")
	skript.gruppe = 0
	skript.figur = ""
	change_scene_to_file("res://scenes/welt_bewegung_editor.tscn")
	await create_timer(0.3).timeout
	var ed: Node = current_scene
	var anzahl := {}
	for g in skript.GRUPPEN.size():
		ed._figur_wahl.get_parent().get_child(1).select(g)
		ed._figur_wahl.get_parent().get_child(1).item_selected.emit(g)
		var liste: Dictionary = ed.figuren_liste(g)
		anzahl[skript.GRUPPEN[g]] = liste.size()
		var ohne_richtung: Array = []
		var schritt_fehler: Array = []
		for i in liste.size():
			ed._figur_wahl.select(i)
			ed._figur_wahl.item_selected.emit(i)
			for r in skript.RICHTUNGEN.size():
				if ed._richtung_knoepfe[r].disabled:
					if g < 3 and not ohne_richtung.has(skript.figur):
						ohne_richtung.append(skript.figur)
					continue
				ed._richtung_knoepfe[r].pressed.emit()
				for b in skript.BEWEGUNGEN.size():
					if ed._bewegung_knoepfe[b].disabled:
						continue
					ed._bewegung_knoepfe[b].pressed.emit()
					await process_frame
					var vorher: Dictionary = ed._figuren[0].bild_info()
					ed._schritt(1)
					await process_frame
					var nachher: Dictionary = ed._figuren[0].bild_info()
					var erwartet: int = vorher.bild % vorher.von + 1
					if nachher.bild != erwartet or ed._figuren[1].bild_info().bild != nachher.bild:
						schritt_fehler.append("%s %s %s" % [skript.figur, skript.RICHTUNGEN[r][0], nachher.anim])
					ed._halt_umschalten()
		_check(liste.size() > 0, "%s: %d Figuren" % [skript.GRUPPEN[g], liste.size()])
		if g < 3:
			_check(ohne_richtung.is_empty(), "%s: alle haben vorne und hinten %s" % [skript.GRUPPEN[g], ohne_richtung])
		_check(schritt_fehler.is_empty(), "%s: Bild für Bild geht weiter %s" % [skript.GRUPPEN[g], schritt_fehler.slice(0, 5)])
	_check(anzahl["Novizen"] == 2 and anzahl["Baukasten-Figuren"] == 8 and anzahl["Hauptfiguren"] >= 10,
			"Gruppen vollständig %s" % anzahl)
	# Kopf wechseln: Figur wird mit dem neuen Kopf gebaut
	ed._figur_wahl.get_parent().get_child(1).item_selected.emit(0)
	ed._kopf_wahl.item_selected.emit(1)
	_check(ed.look() == "%s+%s" % [skript.figur, ed.koepfe_liste(skript.figur)[1]], "Kopf wählen: " + ed.look())
	# Beim Austausch von Bildblättern dürfen keine alten .import-Dateien liegen bleiben (sonst fehlt ein Bild im Spiel)
	var waisen: Array = []
	for ordner: String in ["res://assets/figuren", "res://assets/teile/koerper"]:
		for datei: String in DirAccess.get_files_at(ordner):
			if datei.ends_with(".png.import") and not FileAccess.file_exists(ordner + "/" + datei.trim_suffix(".import")):
				waisen.append(datei)
	_check(waisen.is_empty(), "Keine .import-Dateien ohne Bild %s" % waisen.slice(0, 5))
	print("FERTIG: %s" % ("alles gut" if _failed == 0 else "%d Fehler" % _failed))
	quit(1 if _failed > 0 else 0)
