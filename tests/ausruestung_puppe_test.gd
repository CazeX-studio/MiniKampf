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
	# P4: Die gewählte Waffe zeigt ihre Werte Zeile für Zeile
	var texte := ""
	for t in puppe.find_children("*", "RichTextLabel", true, false):
		texte += (t as RichTextLabel).get_parsed_text()
	_check(texte.contains("Waffenkraft") and texte.contains("Waffen-Tempo") and texte.contains("Gewöhnlich"), "Gewählte Waffe zeigt ihre Werte (%s)" % texte.replace("\n", " | "))
	AusruestungPuppe.gewaehlt = ""
	puppe.queue_free()
	# P4: Infofenster beim Drüberfahren zeigt Werte und in der Tasche den Vergleich mit dem Angelegten
	var feld := BagSlot.new()
	root.add_child(feld)
	feld.show_item("kurzschwert", 1, false)
	BagSlot.angelegt_jetzt = {}
	var fenster: Control = feld._make_custom_tooltip("")
	root.add_child(fenster)
	await process_frame
	texte = ""
	for t in fenster.find_children("*", "RichTextLabel", true, false):
		texte += (t as RichTextLabel).get_parsed_text()
	_check(texte.contains("Waffenkraft") and texte.contains("Waffe"), "Infofenster zeigt die Werte der Waffe (%s)" % texte.replace("\n", " | "))
	fenster.queue_free()
	var andere := ""
	for id: String in GameData.get_file("gegenstaende"):
		if Ausruestung.platz_fuer(id, p.ausruestung) == "waffe" and id != "kurzschwert" and Ausruestung.teil(id).has("waffenkraft"):
			andere = id
			break
	if andere != "":
		BagSlot.angelegt_jetzt = p.ausruestung
		feld.show_item(andere, 1, false)
		fenster = feld._make_custom_tooltip("")
		root.add_child(fenster)
		await process_frame
		texte = ""
		for t in fenster.find_children("*", "RichTextLabel", true, false):
			texte += (t as RichTextLabel).get_parsed_text()
		_check(texte.contains("Vergleich") or texte.contains("gleich gut"), "In der Tasche: Vergleich mit dem Kurzschwert (%s)" % andere)
		fenster.queue_free()
	BagSlot.angelegt_jetzt = {}
	feld.queue_free()
	# P5: Ziehen zwischen Tasche und Ausrüstung
	var waffen_platz := BagSlot.new()
	waffen_platz.platz_name = "Waffe"
	waffen_platz.platz_id = "waffe"
	var kopf_platz := BagSlot.new()
	kopf_platz.platz_name = "Kopf"
	kopf_platz.platz_id = "kopf"
	var tasche := BagSlot.new()
	root.add_child(waffen_platz)
	root.add_child(kopf_platz)
	root.add_child(tasche)
	var aus_tasche := {tasche = 3, id = "kurzschwert"}
	_check(waffen_platz._can_drop_data(Vector2.ZERO, aus_tasche), "Waffe aus der Tasche passt auf den Waffenplatz")
	_check(not kopf_platz._can_drop_data(Vector2.ZERO, aus_tasche), "Waffe passt nicht auf den Kopf")
	var angelegt_gezogen := []
	waffen_platz.anlegen_gezogen.connect(func(g: String) -> void: angelegt_gezogen.append(g))
	waffen_platz._drop_data(Vector2.ZERO, aus_tasche)
	_check(angelegt_gezogen == ["kurzschwert"], "Hineinziehen legt die Waffe an")
	waffen_platz.show_item("kurzschwert", 1, false)
	var gezogen: Variant = waffen_platz._get_drag_data(Vector2.ZERO)
	_check(gezogen is Dictionary and gezogen.get("ausruestung", "") == "waffe", "Angelegte Waffe lässt sich herausziehen")
	_check(tasche._can_drop_data(Vector2.ZERO, gezogen) and not kopf_platz._can_drop_data(Vector2.ZERO, gezogen), "Nur die Tasche nimmt sie")
	var abgelegt := []
	tasche.ablegen_gezogen.connect(func(platz: String) -> void: abgelegt.append(platz))
	tasche._drop_data(Vector2.ZERO, gezogen)
	_check(abgelegt == ["waffe"], "In die Tasche ziehen legt die Waffe ab")
	for f in [waffen_platz, kopf_platz, tasche]:
		f.queue_free()
	# P4: Summe aus der Ausrüstung mit allen Werten
	var liste := Ausruestung.summe_liste(Ausruestung.START)
	var namen := []
	for z: Array in liste:
		namen.append(z[0])
	_check("Waffenkraft" in namen and "Verteidigung" in namen and "Widerstand" in namen and "Waffen-Tempo" in namen, "Summe zeigt alle Grundwerte (%s)" % [namen])
	var mit_bonus := {waffe = "kurzschwert"}
	for id: String in GameData.get_file("gegenstaende"):
		if not Ausruestung.teil(id).get("boni", {}).is_empty() and Ausruestung.teil(id).get("platz", "") == "schmuck":
			mit_bonus["schmuck1"] = id
			var b: Dictionary = Ausruestung.teil(id).boni
			var gefunden := false
			for z: Array in Ausruestung.summe_liste(mit_bonus):
				for wert: String in b:
					gefunden = gefunden or z[0] == Ausruestung.BONUS_NAMEN.get(wert, wert) or wert in ["zauberkraft", "verteidigung", "widerstand"]
			_check(gefunden, "Summe zeigt die Bonus-Werte von %s" % id)
			break
	print("Ausrüstung: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
