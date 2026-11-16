extends SceneTree
## P2 (Playtest 16.11.2026): „!“ nur, wenn man bei der Figur wirklich etwas annehmen kann. Lehrmeister und
## Klassen-Auftraggeber zeigen es nur der passenden Klasse (vorher hatte Fenn ein gelbes „!“ für alle).
## Geprüft für alle Klassen an jedem Punkt der Geschichte (Spielstand-Editor), in allen Gebieten.
## Aufruf: Godot --headless --path . -s tests/zeichen_klasse_test.gd

## Lehrmeister der Demo und ihre Klasse
const LEHRMEISTER := {fenn = "archer", tilda = "tamer", esche = "tamer", brakkus = "smith", samira = "blade", xavina = "singer"}

var _failed := 0
var _gezaehlt := 0


func _check(ok: bool, text: String) -> void:
	if not ok:
		print("FEHLER  " + text)
		_failed += 1


## Aufträge, für die diese Figur gerade ein „!“ zeigen darf (wie WorldState._marker)
func _angeboten(world: WorldState, p: PlayerState, npc: String) -> Array:
	var result := []
	var alle := GameData.get_file("auftraege")
	for id: String in alle:
		var q = alle[id]
		if q is Dictionary and q.get("start_bei", "") == npc and p.progress.quest_state(id) == "neu" \
				and (not q.has("voraussetzung") or p.progress.quest_state(str(q.voraussetzung)) == "abgegeben") \
				and world.check(p, q.get("start_wenn", {})):
			result.append(id)
	return result


## Welche Aufträge das Gespräch mit der Figur jetzt starten kann (alle Wege durch das Gespräch)
func _startbar(world: WorldState, p: PlayerState, dialog_id: String) -> Dictionary:
	var d := GameData.dialog(dialog_id)
	var knoten: Dictionary = d.get("knoten", {})
	var start := ""
	for entry: Dictionary in d.get("einstieg", []):
		if world.check(p, entry.get("wenn", {})):
			start = str(entry.knoten)
			break
	var gefunden := {}
	var offen: Array = [start] if start != "" else []
	var gesehen := {}
	while not offen.is_empty():
		var id: String = offen.pop_back()
		if gesehen.has(id) or not knoten.has(id):
			continue
		gesehen[id] = true
		var node: Dictionary = knoten[id]
		var aktionen: Array = node.get("aktionen", []).duplicate()
		if node.has("weiter"):
			offen.append(str(node.weiter))
		for a: Dictionary in node.get("antworten", []):
			if world.check(p, a.get("wenn", {})):
				aktionen.append_array(a.get("aktionen", []))
				if a.has("weiter"):
					offen.append(str(a.weiter))
		for a: Dictionary in aktionen:
			if a.has("auftrag_starten") and world.check(p, a.get("wenn", {})):
				gefunden[str(a.auftrag_starten)] = true
	return gefunden


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	for klasse: String in SpielstandEditor.KLASSEN:
		var weg := SpielstandEditor.weg(klasse)
		for i in weg.size():
			var world := SpielstandEditor.bauen(klasse, "novize_w+w1", i, 12, 500, {})
			var p: PlayerState = world.players["spieler"]
			var name := "%s, %d. %s" % [klasse, i + 1, weg[i]]
			for npc: String in world.npcs:
				var zeichen := world.npc_marker(p, npc)
				# Lehrmeister anderer Klassen: kein „!“ für Klassen-Aufträge
				if LEHRMEISTER.has(npc) and LEHRMEISTER[npc] != klasse and zeichen == "!":
					for id: String in _angeboten(world, p, npc):
						var sw: Dictionary = GameData.quest(id).get("start_wenn", {})
						_check(GameData.quest(id).has("neben") or sw.has("klasse") or not world.is_main_quest(id) \
								or id in ["fest_der_glut", "veraenderte_tiere"],
								"%s: %s zeigt „!“ für %s (gehört nicht zu dieser Klasse)" % [name, npc, id])
				if zeichen != "!":
					continue
				_gezaehlt += 1
				var startbar := _startbar(world, p, str(world.npcs[npc].dialog))
				var ok := false
				for id: String in _angeboten(world, p, npc):
					ok = ok or startbar.has(id)
				_check(ok, "%s: %s zeigt „!“, im Gespräch lässt sich aber nichts annehmen (angeboten: %s)" \
						% [name, npc, _angeboten(world, p, npc)])
	# Marcos Stelle: Klingentänzer kommt nach der Glutoase nach Grünwacht, Fenn hat kein „!“
	var weg := SpielstandEditor.weg("blade")
	for id: String in ["nach_gruenwacht", "veraenderte_tiere", "das_leere_grab"]:
		var w := SpielstandEditor.bauen("blade", "novize_w+w1", weg.find(id), 20, 500, {})
		var s: PlayerState = w.players["spieler"]
		_check(w.npc_marker(s, "fenn") == "", "Klingentänzer (%s): Fenn ohne „!“ (%s)" % [id, w.npc_marker(s, "fenn")])
		_check(w.npc_marker(s, "tilda") != "!" or _startbar(w, s, "tilda").size() > 0, "Klingentänzer (%s): Tilda ohne leeres „!“" % id)

	print("%d Zeichen geprüft" % _gezaehlt)
	print("\n%s" % ("ALLES OK" if _failed == 0 else "%d FEHLER" % _failed))
	quit(1 if _failed > 0 else 0)
