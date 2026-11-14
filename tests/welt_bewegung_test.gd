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
	_check(szene._figuren.size() == 7, "Sieben Richtungen nebeneinander (Kampf links/rechts, fünf Welt-Richtungen)")
	szene._schritt(1)
	_check(editor.bild_fuer_bild, "◀ ▶ schaltet auf Bild für Bild")
	editor.bild_fuer_bild = false
	editor.bild = 0
	# Teil U7: Novizen in fünf Welt-Richtungen, Blick aus der Bewegung auf dem Bildschirm
	var f := WorldCharacter.new()
	f.setup("novize_w+w1", "Probe")
	root.add_child(f)
	f.richtungen = true
	f.moving = true
	var faelle := [[Vector2(0, 1), "run_gerade_vorn", 1], [Vector2(1, 0.5), "run_vorn", 1], [Vector2(-1, 0), "run_welt_seite", -1],
			[Vector2(-1, -0.5), "run_hinten", -1], [Vector2(0, -1), "run_gerade_hinten", -1]]
	for fall: Array in faelle:
		f.blick_setzen(fall[0])
		await process_frame
		_check(f.aktuelle_anim == fall[1] and f.facing == fall[2], "Bewegung %s zeigt %s (ist %s)" % [fall[0], fall[1], f.aktuelle_anim])
		_check(f.bild_anzahl() == 8, "%s hat 8 Bilder" % fall[1])
	f.moving = false
	f.sitzt = true
	f.blick_setzen(Vector2(0, 1))
	await process_frame
	_check(f.aktuelle_anim == "sitzen_gerade_vorn", "Sitzen gerade von vorne (ist %s)" % f.aktuelle_anim)
	for anim: String in ["idle_gerade_vorn", "idle_welt_seite", "idle_gerade_hinten", "sitzen_welt_seite", "sitzen_gerade_hinten"]:
		_check(f.hat_bilder(anim), "Novizin hat Bilder %s" % anim)
	f.queue_free()
	print("Welt-Bewegungen: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
