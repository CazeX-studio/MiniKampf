extends SceneTree
## Ebenen (E3h3b): Die Glutoase steigt zur Schmiede hin an, Treppen gleitend, Antippen trifft auf jeder Stufe das
## richtige Feld, Teile stehen auf ihrer Stufe. Andere Karten bleiben flach.
## Aufruf: Godot --headless --path . -s tests/ebenen_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	var world := WorldState.new()
	var h: Hoehen = world.get_map("glutoase").hoehen
	_check(h != null and world.get_map("kreuzweg").hoehen == null and world.get_map("wipfelheim").hoehen == null,
			"Nur die Glutoase hat Ebenen")
	_check(h.stufe_feld(Vector2i(23, 40)) == 0 and h.stufe_feld(Vector2i(10, 20)) == 1 and h.stufe_feld(Vector2i(25, 5)) == 2,
			"Oase unten, Schmiedeviertel in der Mitte, Hadraks Schmiede oben")
	# Treppen: von vorne nach hinten gleichmäßig höher
	var vorher := -1.0
	var gleitend := true
	for i in 21:
		var y := 29.0 - i * 0.25
		var px := h.px(Vector2(22.5, y))
		gleitend = gleitend and px >= vorher and px - vorher <= h.stufe * 0.5 + 0.01
		vorher = px
	_check(gleitend and h.px(Vector2(22.5, 28.5)) == 0.0 and h.px(Vector2(22.5, 25.5)) == h.stufe, "Untere Treppe steigt gleichmäßig an")
	_check(h.px(Vector2(22.5, 12.5)) == h.stufe and h.px(Vector2(22.5, 9.5)) == h.stufe * 2, "Obere Treppe führt auf Stufe 2")
	# Antippen: Mitte jedes begehbaren Feldes führt zurück auf dieses Feld
	var m := world.get_map("glutoase")
	var falsch: Array = []
	for y in m.size.y:
		for x in m.size.x:
			var c := Vector2i(x, y)
			if not m.is_walkable(c):
				continue
			var mitte := Vector2(c) + Vector2(0.5, 0.5)
			var p := BaukastenBoden.cell_to_screen(mitte) - Vector2(0, h.px(mitte))
			if h.feld_bei(p) != c and not (c.x in [22, 23] and c.y in [10, 11, 26, 27]):
				falsch.append(c)
	_check(falsch.size() < 4, "Antippen trifft das Feld (%d Ausnahmen, z. B. %s)" % [falsch.size(), falsch.slice(0, 3)])
	# Teile stehen auf ihrer Stufe
	var teile := GameData.get_file("baukasten_teile")
	var hadrak := {}
	for o: Dictionary in m.baukasten.objekte:
		if o.teil == "go_hadraks_schmiede":
			hadrak = o
	var flach := BaukastenBoden.teil_bauen(hadrak, teile)
	var hoch := BaukastenBoden.teil_bauen(hadrak, teile, h.teil_px(BaukastenBoden.grundflaeche(hadrak, teile)))
	_check(is_equal_approx(flach.node.position.y - hoch.node.position.y, h.stufe * 2), "Hadraks Schmiede steht zwei Stufen höher")
	flach.node.free()
	hoch.node.free()
	print("Ebenen: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
