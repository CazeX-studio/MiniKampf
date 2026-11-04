extends SceneTree
## D20b: Ye mit Regenschirm (eigene Bilder, Porträts) und seine neuen Sprüche.
## Aufruf: Godot --headless --path . -s tests/ye_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _alle_texte(daten: Variant) -> String:
	if daten is Dictionary:
		return " ".join((daten as Dictionary).values().map(_alle_texte))
	if daten is Array:
		return " ".join((daten as Array).map(_alle_texte))
	return str(daten)


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	for anim: String in ["idle_vorn", "run_vorn", "idle_hinten", "run_hinten", "schirm_vorn"]:
		_check(ResourceLoader.exists(FighterView.sprite_path("ye", anim, 3)), "Ye: Bilder %s" % anim)
	for stimmung: String in ["ruhig", "laechelnd", "wuetend", "traurig", "ueberrascht"]:
		_check(ResourceLoader.exists("res://assets/portraets/ye_%s.png" % stimmung), "Porträt %s" % stimmung)
	_check(WorldState.portraet({wer = "Ye", stimmung = "traurig"}).ends_with("ye_traurig.png"), "Porträt passt zur Stimmung")
	_check(WorldState.portraet({wer = "Ye", stimmung = "gibts_nicht"}).ends_with("ye_ruhig.png"), "Unbekannte Stimmung: ruhig")
	_check(WorldState.portraet({wer = "Marta"}) == "", "Ohne Porträt kein Bild")

	var world := WorldState.new()
	_check(world.npcs.ye.look == "ye" and world.npcs.ye_tor.look == "ye", "Ye trägt in der Welt seinen Schirm")
	var texte := _alle_texte(GameData.get_file("dialoge")) + _alle_texte(GameData.get_file("kaempfe"))
	_check(not texte.contains("Schild hoch"), "Der alte Spruch ist überall ersetzt")
	for spruch: String in ["Nicht nachdenken. Deine Hände wissen es vor dir.", "Jede Klasse hat eine Schwäche. Wer alle kennt, hat keine.",
			"Nachtschicht. Irgendwer muss ja auf die Laterne aufpassen.", "Du redest schneller, als du kämpfst. Das ist eine Leistung."]:
		_check(texte.contains(spruch), "Spruch da: %s" % spruch)

	var p := world.add_player("a", "Test", "novize_m+m1", Vector2i(29, 60))
	p.progress.flags["ausbildung_morgen"] = true
	p.progress.quests = {"grundausbildung": "abgegeben", "erster_gruppenkampf": "abgegeben", "marvs_traum": "aktiv"}
	world.start_dialog(p, "ye_tor")
	_check(world.dialog_view(p).antworten.size() == 2, "Tagsüber: Ye fragt, ob man Marv kennt")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(world.dialog_view(p).text.contains("Das ist eine Leistung") and world.dialog_view(p).stimmung == "laechelnd", "Ye über Marv, mit Lächeln")
	world.apply_command("a", {type = "dialog_next"})
	world.nacht = true
	world.start_dialog(p, "ye_tor")
	_check(world.dialog_view(p).text.begins_with("Nachtschicht"), "Nachts: Ye hat Nachtschicht")
	world.nacht = false
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_choose", index = 1})

	p.progress.quests["abreise"] = "aktiv"
	world.start_dialog(p, "ye_tor")
	world.apply_command("a", {type = "dialog_choose", index = 1})
	_check(world.dialog_view(p).text.contains("Wer alle kennt, hat keine"), "Frage nach der besten Klasse")
	world.apply_command("a", {type = "dialog_next"})
	_check(world.dialog_view(p).antworten.size() == 3, "Danach wieder die Wahl")

	# Paradeschule: Ye kommentiert die Übungsversuche, einmal wird sein Schirm kurz zum Schwert
	var kampf := BattleState.new(null, [] as Array[String], "", 1)
	kampf.setup = {paradeschule = true}
	kampf.parry_attempts = 3
	kampf._ye_sagt(BattleState.REACT_NONE)
	kampf.parry_attempts = 4
	kampf._ye_sagt(BattleState.REACT_PERFECT)
	var log_text := "\n".join(kampf._events.map(func(e: Dictionary) -> String: return str(e.get("text", ""))))
	_check(log_text.contains("Zu langsam. Noch mal.") and log_text.contains("Nicht schlecht. Für einen Anfänger.")
			and log_text.contains("ein Schwert"), "Ye kommentiert die Paraden")
	Tageszeit.feste_stunde = -1.0
	print("Ye: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
