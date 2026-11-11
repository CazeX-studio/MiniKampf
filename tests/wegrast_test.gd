extends SceneTree
## A12: Gasthäuser betreten. A12a Wegrast (Tür in Kreuzweg, Hanne und die Gäste), A12b Baumhaus-Gasthaus in Wipfelheim (Borko).
## Aufruf: Godot --headless --path . -s tests/wegrast_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _tick(w: WorldState, sekunden: float) -> void:
	var t := 0.0
	while t < sekunden:
		w.tick(0.1)
		t += 0.1


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	var w := WorldState.new()
	var p := w.add_player("a", "Test", "novize_m+m1", Vector2i(7, 28))
	p.dialog = {}
	var tuer: Dictionary = w.get_map("kreuzweg").exits.filter(func(e: Dictionary) -> bool: return e.karte == "wegrast")[0]
	_check(tuer.tuer, "Kreuzweg hat eine Tür ins Wegrast")
	# Vorbeilaufen: der Weg führt durch die Tür, aber das Ziel liegt dahinter
	w.apply_command("a", {type = "move", cell = Vector2i(11, 28)})
	_tick(w, 8.0)
	_check(p.map == "kreuzweg", "Wer an der Tür vorbeiläuft, bleibt draußen")
	# Zur Tür gehen: hinein
	w.apply_command("a", {type = "move", cell = tuer.rect.position})
	_tick(w, 8.0)
	_check(p.map == "wegrast", "Wer zur Tür geht, ist im Gasthaus")
	var innen := w.get_map("wegrast")
	_check(innen.title == "Gasthaus Wegrast" and not innen.baukasten.is_empty(), "Innenraum aus dem Baukasten")
	_check(w.npcs.hanne.map == "wegrast" and w.npc_visible(p, "hanne"), "Hanne steht drinnen hinter der Theke")
	_check(w.npc_visible(p, "gast_1") and not w.npc_visible(p, "gast_2"), "Tagsüber ein Gast, die anderen kommen abends")
	w.nacht = true
	_check(w.npc_visible(p, "gast_2") and w.npc_visible(p, "gast_3"), "Nachts ist das Wegrast voll")
	w.nacht = false
	# Hinaus
	var raus: Dictionary = innen.exits[0]
	w.apply_command("a", {type = "move", cell = raus.rect.position})
	_tick(w, 8.0)
	_check(p.map == "kreuzweg" and w.get_map("kreuzweg").is_walkable(p.cell) and not tuer.rect.has_point(p.cell),
			"Hinaus: wieder in Kreuzweg vor der Tür")
	_gasthaus_wipfelheim(w, p)
	Tageszeit.feste_stunde = -1.0
	print("Wegrast: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


## A12b: Baumhaus-Gasthaus in Wipfelheim, Tür an der rechten Seite bei den Stufen
func _gasthaus_wipfelheim(w: WorldState, p: PlayerState) -> void:
	w.change_map(p, "wipfelheim", Vector2i(16, 22))
	p.dialog = {}
	var tueren: Array = w.get_map("wipfelheim").exits.filter(func(e: Dictionary) -> bool: return e.karte == "gasthaus_wipfelheim")
	_check(tueren.size() == 1 and tueren[0].tuer, "Wipfelheim: Tür ins Baumhaus-Gasthaus")
	w.apply_command("a", {type = "move", cell = tueren[0].rect.position})
	_tick(w, 8.0)
	_check(p.map == "gasthaus_wipfelheim", "Zur Tür gegangen: im Baumhaus-Gasthaus")
	_check(w.npc_visible(p, "borko") and w.npc_visible(p, "gast_gw_3"), "Borko an der Kochstelle, ein Gast am Tisch")
	w.apply_command("a", {type = "move", cell = w.get_map("gasthaus_wipfelheim").exits[0].rect.position})
	_tick(w, 8.0)
	_check(p.map == "wipfelheim" and w.get_map("wipfelheim").is_walkable(p.cell), "Hinaus: wieder in Wipfelheim")
