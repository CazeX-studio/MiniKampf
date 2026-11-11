extends SceneTree
## A11: kleine Karte oben rechts und große Karte (Taste M).
## Aufruf: Godot --headless --path . -s tests/karte_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	var w := WorldState.new()
	var p := w.add_player("a", "Test", "novize_m+m1", Vector2i(11, 19))
	var daten := GameData.get_file("weltkarte")
	# Jede Karte der Welt steht auf der großen Karte
	for id: String in w.maps:
		_check(daten.karten.has(id), "%s steht auf der großen Karte (data/weltkarte.json)" % id)
	# Kleine Karte: ein Bildpunkt je Feld, Ausgänge gold
	var m := w.get_map("kreuzweg")
	var bild := Minikarte.bild_fuer(m)
	_check(bild.get_width() == m.size.x and bild.get_height() == m.size.y, "Kleine Karte: ein Bildpunkt je Feld")
	var ausgang: Rect2i = m.exits[0].rect
	_check(bild.get_image().get_pixelv(ausgang.position).is_equal_approx(Color("f2c14e")), "Ausgänge leuchten gold")
	# Ein Auftrag, der in Kreuzweg abgegeben wird, ist fertig: Dort steht ein „?“
	var alle := GameData.get_file("auftraege")
	for id: String in alle:
		var q = alle[id]
		if q is Dictionary and not q.get("neben", false) and w.npcs.has(str(q.get("abgeben_bei", ""))) \
				and w.npcs[str(q.abgeben_bei)].map == "kreuzweg" and w.npc_visible(p, str(q.abgeben_bei)):
			p.progress.quests[id] = "fertig"
			break
	var zeichen := Minikarte.zeichen_fuer(w, p)
	_check(zeichen.any(func(z: Dictionary) -> bool: return z.art in ["!", "?"]), "Leute mit Auftrag stehen als Punkt auf der Karte")
	# Große Karte: Wege zwischen den Gegenden
	var wege := Weltkarte.wege_fuer(w, daten)
	var hat := func(a: String, b: String) -> bool:
		return wege.any(func(x: Array) -> bool: return (x[0] == a and x[1] == b) or (x[0] == b and x[1] == a))
	for paar: Array in [["kreuzweg", "weg_gruenwacht"], ["kreuzweg", "aschensteppe"], ["waldboden", "wipfelheim"],
			["glutoase", "glutgrat"], ["glutoase", "vulkanschmiede"], ["waldboden", "pilzhoehle"]]:
		_check(hat.call(paar[0], paar[1]), "Weg %s – %s" % paar)
	# Was man weiß: hier, besucht, nebenan (???), verborgen
	_check(Weltkarte.bekannt(p, "kreuzweg", wege) == "hier", "Kreuzweg: Du bist hier")
	_check(Weltkarte.bekannt(p, "weg_gruenwacht", wege) == "nachbar", "Gleich nebenan: ???")
	_check(Weltkarte.bekannt(p, "wipfelheim", wege) == "", "Weit weg und nie betreten: verborgen")
	w.change_map(p, "weg_gruenwacht", Vector2i(30, 7))
	_check(Weltkarte.bekannt(p, "weg_gruenwacht", wege) == "hier" and Weltkarte.bekannt(p, "kreuzweg", wege) == "besucht",
			"Nach dem Betreten ist der Weg bekannt")
	_check(Weltkarte.bekannt(p, "waldboden", wege) == "nachbar", "… und der Waldboden dahinter zeigt sich als ???")
	Tageszeit.feste_stunde = -1.0
	print("Karten: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
