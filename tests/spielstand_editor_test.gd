extends SceneTree
## S5: Spielstand-Editor. Für jede Klasse und jeden Punkt der Geschichte entsteht ein Spielstand, in dem der gewählte
## Auftrag läuft, die Aufträge davor erledigt sind, der Wegweiser zeigt, wohin es geht, und man auf freiem Feld steht.
## Aufruf: Godot --headless --path . -s tests/spielstand_editor_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	if not ok:
		print("FEHLER  " + text)
		_failed += 1


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	var gezaehlt := 0
	for klasse: String in SpielstandEditor.KLASSEN:
		var weg := SpielstandEditor.weg(klasse)
		for i in weg.size():
			var ziel: String = weg[i]
			var world := SpielstandEditor.bauen(klasse, "novize_w+w1", i, 12, 500, {heiltrank = 4, manatrank = 2})
			var p: PlayerState = world.players["spieler"]
			var name := "%s, %d. %s" % [klasse, i + 1, ziel]
			var geber := str(GameData.quest(ziel).get("start_bei", ""))
			if p.progress.quests.has(ziel) or geber == "":
				_check(p.progress.quest_state(ziel) in ["aktiv", "fertig"], "%s: Auftrag läuft (%s)" % [name, p.progress.quest_state(ziel)])
			else:
				_check(world.npc_marker(p, geber) == "!" or not world.objective_place(p).is_empty(), "%s: %s bietet den Auftrag an" % [name, geber])
			if i > 0:
				_check(p.progress.quest_state(str(weg[i - 1])) == "abgegeben", "%s: Auftrag davor erledigt" % name)
			# Im Dungeon (Pilzhöhle, Vulkanschmiede) steht man am Eingang und kämpft sich durch, dort gibt es keinen Wegweiser
			_check(not world.objective_place(p).is_empty() or world.get_map(p.map).dungeon != "", "%s: Wegweiser zeigt, wohin es geht" % name)
			_check(world.is_walkable(p.cell, p.map), "%s: steht auf freiem Feld (%s %s)" % [name, p.map, p.cell])
			_check(p.progress.level == 12 and p.progress.gold == 500 and p.progress.item_count("heiltrank") == 4, "%s: Stufe, Geld, Tränke" % name)
			gezaehlt += 1
		# Nach dem Lehrmeister ist die Klasse gelernt (Körper der Klasse in der Welt)
		var w := SpielstandEditor.bauen(klasse, "novize_w+w1", weg.find("veraenderte_tiere"), 20, 0, {})
		_check(w.players["spieler"].progress.flags.has("klasse_gelernt"), "%s: in Grünwacht Teil 2 ist die Klasse gelernt" % klasse)
	print("ok      %d Punkte der Geschichte geprüft" % gezaehlt)
	_check(SpielstandEditor.weg("archer").find("nach_gruenwacht") < SpielstandEditor.weg("archer").find("nach_glutoase"), "Bogenschütze: erst Grünwacht, dann Glutoase")
	_check(SpielstandEditor.weg("blade").find("nach_glutoase") < SpielstandEditor.weg("blade").find("nach_gruenwacht"), "Klingentänzerin: erst Glutoase, dann Grünwacht")
	print("Spielstand-Editor: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
