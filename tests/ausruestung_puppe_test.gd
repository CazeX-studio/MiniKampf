extends SceneTree
## Ausrüstung als Plätze (A8b): sechs Plätze mit den angelegten Teilen, Antippen wählt den Platz, „Ablegen“ schickt
## den Befehl. Aufruf: Godot --headless --path . -s tests/ausruestung_puppe_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var p := Progress.new()
	var gesendet: Array = []
	var neu := [0]
	AusruestungPuppe.gewaehlt = ""
	var puppe := AusruestungPuppe.new()
	root.add_child(puppe)
	puppe.bauen(p, "novize_w+w1", func(b: Dictionary) -> void: gesendet.append(b), func() -> void: neu[0] += 1)
	await process_frame
	_check(puppe._plaetze.size() == 6, "Sechs Plätze")
	_check(puppe._plaetze.waffe.item_id == "kurzschwert" and puppe._plaetze.schmuck1.item_id == "", "Waffe angelegt, Schmuck leer")
	puppe._plaetze.waffe.picked.emit(0)
	_check(AusruestungPuppe.gewaehlt == "waffe" and neu[0] == 1, "Antippen wählt die Waffe")
	puppe.queue_free()
	puppe = AusruestungPuppe.new()
	root.add_child(puppe)
	puppe.bauen(p, "novize_w+w1", func(b: Dictionary) -> void: gesendet.append(b), func() -> void: neu[0] += 1)
	await process_frame
	for b in puppe.find_children("*", "Button", true, false):
		if (b as Button).text == GameData.text("ablegen"):
			(b as Button).pressed.emit()
	_check(gesendet.size() == 1 and gesendet[0] == {type = "ablegen", platz = "waffe"}, "Ablegen schickt den Befehl")
	AusruestungPuppe.gewaehlt = ""
	puppe.queue_free()
	print("Ausrüstung: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
