extends SceneTree
## S3b: Der Bewegungs-Editor in der Welt kennt alle Gruppen, und jede Figur lässt sich in allen Richtungen aufbauen.
## Aufruf: Godot --headless --path . -s tests/welt_bewegung_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var editor := load("res://scripts/welt/welt_bewegung_editor.gd")
	var gezaehlt := 0
	for g in editor.GRUPPEN.size():
		editor.gruppe = g
		var figuren: Array = editor._figuren_der_gruppe()
		_check(not figuren.is_empty(), "%s: %d Figuren" % [editor.GRUPPEN[g], figuren.size()])
		for f: String in figuren:
			editor.figur = f
			editor.kopf = ""
			var look: String = editor.aussehen()
			var view := WorldCharacter.new()
			view.setup(look, look)
			if not view.hat_bilder("idle") or not view.hat_bilder("run"):
				_check(false, "%s hat Bilder zum Stehen und Laufen" % look)
			view.free()
			gezaehlt += 1
	_check(gezaehlt > 40, "Alle %d Figuren lassen sich aufbauen" % gezaehlt)
	editor.gruppe = 1
	editor.figur = "bogen_m"
	editor.kopf = ""
	_check(str(editor.aussehen()).begins_with("bogen_m+m"), "Klassen-Körper mit passendem Kopf: %s" % editor.aussehen())
	# Die Szene selbst baut sich auf (vier Richtungen) und blättert Bild für Bild
	editor.gruppe = 0
	editor.figur = ""
	var szene: Node = load("res://scenes/welt_bewegung.tscn").instantiate()
	root.add_child(szene)
	await process_frame
	await process_frame
	_check(szene._figuren.size() == 4, "Vier Richtungen nebeneinander")
	szene._schritt(1)
	_check(editor.bild_fuer_bild, "◀ ▶ schaltet auf Bild für Bild")
	editor.bild_fuer_bild = false
	editor.bild = 0
	print("Welt-Bewegungen: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
