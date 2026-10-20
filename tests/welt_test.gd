extends SceneTree
## Prüft die Welt ohne Grafik: Steuerung, Gespräche mit Antworten, Aufträge, Gold, Tasche,
## Erfahrung und Stufen, Speichern und Laden.
## Aufruf: Godot --headless --path . --script res://tests/welt_test.gd

var _failed := 0


func _initialize() -> void:
	_test_steering()
	_test_building_blocks()
	print("Welt: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


func _test_steering() -> void:
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "elf_m", Vector2i(22, 38))

	# Nach oben steuern: Der Spieler läuft auf dem Bildschirm nach oben (Feld x und y werden kleiner)
	var start := p.pos
	world.apply_command("a", {type = "steer", dir = Vector2(0, -1)})
	_tick(world, 0.5)
	_check(p.pos.x < start.x and p.pos.y < start.y, "Steuern nach oben bewegt den Spieler")
	_check(p.is_walking(), "Spieler gilt beim Steuern als laufend")
	world.apply_command("a", {type = "steer", dir = Vector2.ZERO})
	var stop := p.pos
	_tick(world, 0.5)
	_check(p.pos == stop, "Loslassen hält den Spieler an")

	# Gegen ein Haus steuern: Der Spieler darf nie auf einem gesperrten Feld stehen
	world.apply_command("a", {type = "steer", dir = Vector2(1, -1)})
	var ok := true
	for i in 200:
		world.tick(0.05)
		if not world.is_walkable(p.cell):
			ok = false
	_check(ok, "Häuser und Bäume halten den Spieler auf")
	world.apply_command("a", {type = "steer", dir = Vector2.ZERO})

	# Neben Ye stellen und "Aktion": Das Gespräch beginnt
	var b := world.add_player("b", "Test 2", "elf_m", Vector2i(29, 16))
	world.apply_command("b", {type = "interact"})
	_tick(world, 0.1)
	_check(b.in_dialog(), "Aktions-Taste neben Ye startet das Gespräch")
	# Weit weg: nichts passiert
	world.apply_command("a", {type = "move", cell = Vector2i(6, 22)})
	_tick(world, 6.0)
	world.apply_command("a", {type = "interact"})
	_tick(world, 0.1)
	_check(not p.in_dialog(), "Aktions-Taste ohne etwas in der Nähe macht nichts")
	# Klicken zum Hinlaufen geht weiterhin
	world.apply_command("a", {type = "move", cell = Vector2i(22, 30)})
	_tick(world, 5.0)
	_check(p.cell == Vector2i(22, 30), "Klicken zum Hinlaufen funktioniert weiter")


func _test_building_blocks() -> void:
	var world := WorldState.new()
	var p := world.add_player("a", "Test", "elf_m", WorldState.start_cell())
	var notices: Array[String] = []
	world.notice.connect(func(_id: String, text: String) -> void: notices.append(text))

	# Ankunft: Einleitung am Stadttor, danach der erste Auftrag
	world.apply_command("a", {type = "start"})
	_check(p.in_dialog() and world.dialog_view(p).wer == "Erzähler", "Beim Betreten kommt die Einleitung")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	_check(not p.in_dialog(), "Einleitung endet")
	_check(p.progress.quest_state("ankunft") == "aktiv", "Auftrag „Ankunft in Kreuzweg“ läuft")
	_check(world.objective(p) == "Bei Schreiberin Lene anmelden", "Ziel-Hinweis zeigt die Anmeldung")
	_check(world.npc_marker(p, "schreiberin") == "?" and world.npc_marker(p, "ye") == "", "Zeichen ? über der Gildenschreiberin")
	world.apply_command("a", {type = "start"})
	_check(not p.in_dialog(), "Die Einleitung kommt nur einmal")

	# Ye vor der Anmeldung: schickt einen zur Gilde
	_talk(world, p, "ye")
	_check(world.dialog_view(p).text.contains("Gilde eintragen"), "Ye schickt Unangemeldete zur Gilde")
	world.apply_command("a", {type = "dialog_next"})

	# Anmeldung bei der Gildenschreiberin (mit Nachfrage)
	_talk(world, p, "schreiberin")
	_check(world.dialog_view(p).antworten.size() == 2, "Schreiberin fragt, ob sie dich eintragen soll")
	world.apply_command("a", {type = "dialog_choose", index = 1})
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("ankunft") == "abgegeben" and p.progress.quest_state("zu_ye") == "aktiv", "Angemeldet, weiter zu Ye")
	_check(not "Auftrag erfüllt: Ankunft in Kreuzweg – zurück zum Auftraggeber!" in notices, "Keine überflüssige Meldung bei sofortiger Abgabe")
	world.apply_command("a", {type = "dialog_next"})
	_check(world.npc_marker(p, "ye") == "?", "Zeichen ? über Ye")

	# Bei Ye melden, Fragen stellen, ersten Auftrag annehmen
	_talk(world, p, "ye")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	_check(world.dialog_view(p).antworten.size() == 3, "Ye fragt nach Fragen (drei Antworten)")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(world.dialog_view(p).text.contains("Schild hoch"), "Antwort 1: Schild hoch, Schild runter")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_choose", index = 2})
	world.apply_command("a", {type = "dialog_choose", index = 1})
	_check(p.progress.quest_state("erster_auftrag") == "neu", "„Später“ nimmt den Auftrag nicht an")
	world.apply_command("a", {type = "dialog_next"})
	_check(world.npc_marker(p, "ye") == "!", "Zeichen ! über Ye, solange sein Auftrag offen ist")
	_talk(world, p, "ye")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("erster_auftrag") == "aktiv", "Erster Auftrag angenommen")
	world.apply_command("a", {type = "dialog_next"})

	# Schmiedin Bescheid sagen, drei Kräuter sammeln
	_check(world.npc_marker(p, "schmiedin") == "?", "Zeichen ? über der Schmiedin")
	_talk(world, p, "schmiedin")
	world.apply_command("a", {type = "dialog_next"})
	_check(p.progress.flags.has("schmiedin_bescheid") and world.npc_marker(p, "schmiedin") == "", "Schmiedin weiß Bescheid")
	for i in world.pickups.size():
		world.apply_command("a", {type = "use", target = "punkt:%d" % i})
		_tick(world, 10.0)
	_check(p.progress.item_count("kraut") == 3, "Drei Silberkräuter in der Tasche")
	_check(not world.can_use(p, "punkt:0"), "Ein eingesammeltes Kraut ist für diesen Spieler weg")
	_check(p.progress.quest_state("erster_auftrag") == "fertig", "Auftrag ist erfüllt")
	_check(world.objective(p) == "Zurück zu Ausbilder Ye" and world.npc_marker(p, "ye") == "?", "Ziel: zurück zu Ye")

	# Abgeben: Belohnung, Stufe 2
	_talk(world, p, "ye")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("erster_auftrag") == "abgegeben", "Auftrag ist abgegeben")
	_check(p.progress.gold == 25 and p.progress.item_count("heiltrank") == 1 and p.progress.item_count("kraut") == 0,
		"Belohnung: 25 Gold und ein Heiltrank, die Kräuter sind weg")
	_check(p.progress.xp == 100 and p.progress.level == 2, "100 Erfahrung = Stufe 2")
	_check(notices.any(func(n: String) -> bool: return n.begins_with("Stufe 2 erreicht!") and n.contains("Leben +7")), "Meldung „Stufe 2 erreicht!“ mit neuen Werten kommt")
	_check(notices.any(func(n: String) -> bool: return n.contains("Werte (C)")), "Tipp zu den Werten kommt")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	_check(not p.in_dialog() and world.objective(p) == "", "Alles erledigt, kein offenes Ziel")

	# Grundausbildung: Ye steht jetzt am Stadttor
	_check(not world.npc_visible(p, "ye") and world.npc_visible(p, "ye_tor"), "Ye ist von der Gilde ans Stadttor gegangen")
	_check(world.npc_marker(p, "ye_tor") == "!", "Zeichen ! über Ye am Tor")
	var battles: Array[String] = []
	world.battle_requested.connect(func(_id: String, kampf: String) -> void: battles.append(kampf))
	_talk(world, p, "ye_tor")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("grundausbildung") == "aktiv", "Grundausbildung angenommen")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(battles.back() == "grundausbildung" and not p.in_dialog(), "Ye startet den langen Übungskampf")
	# Verlieren zählt nicht, gewinnen schon
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "grundausbildung", gewonnen = false})
	_check(not world.goal_done(p, {art = "kampf", kampf = "grundausbildung"}), "Übungskampf verloren: noch nicht bestanden")
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "grundausbildung", gewonnen = true})
	_check(p.progress.quest_state("grundausbildung") == "fertig", "Übungskampf gewonnen: Grundausbildung bestanden")
	var xp_before := p.progress.xp
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "grundausbildung", gewonnen = true})
	_check(p.progress.xp == xp_before, "Erfahrung gibt es nur beim ersten Sieg")
	_talk(world, p, "ye_tor")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("grundausbildung") == "abgegeben", "Grundausbildung abgegeben")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("erster_gruppenkampf") == "aktiv" and battles.back() == "gruppenkampf", "Gruppenkampf beginnt")
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "gruppenkampf", gewonnen = true})
	_check(world.npc_marker(p, "ye_tor") == "?", "Zurück zu Ye nach dem Gruppenkampf")
	_talk(world, p, "ye_tor")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("erster_gruppenkampf") == "abgegeben", "Gruppenkampf abgegeben")
	_check(p.progress.xp == 700 and p.progress.level == 5, "Nach der Grundausbildung: Stufe 5 (700 Erfahrung)")
	_check(p.progress.item_count("heiltrank") == 3 and p.progress.gold == 75, "Belohnungen: 3 Heiltränke, 75 Gold")
	world.apply_command("a", {type = "dialog_next"})
	_check(not p.in_dialog() and world.objective(p) == "", "Grundausbildung vorbei, kein offenes Ziel")

	# Marv: erst nach der Grundausbildung da, spricht einen von sich aus an
	_check(world.npc_visible(p, "marv"), "Marv ist nach der Grundausbildung in der Stadt")
	world.apply_command("a", {type = "move", cell = Vector2i(22, 32)})
	_tick(world, 10.0)
	_check(p.in_dialog() and world.dialog_view(p).wer == "Marv", "Marv spricht dich an, wenn du vorbeikommst")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	world.apply_command("a", {type = "dialog_choose", index = 1})
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	_check(not p.in_dialog() and p.progress.quest_state("marvs_traum") == "aktiv", "Marvs Auftrag läuft")
	_check(world.npc_marker(p, "bingo") == "?", "Zeichen ? über Bingo")
	world.apply_command("a", {type = "move", cell = Vector2i(22, 28)})
	_tick(world, 3.0)
	_check(not p.in_dialog(), "Marv spricht einen nur einmal von selbst an")

	# Bingo: Laden öffnen, kaufen, verkaufen, Sternentafel zu teuer
	_talk(world, p, "bingo")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(not p.in_dialog() and p.shop == "bingo", "Bingos Laden ist offen")
	var gold := p.progress.gold
	world.apply_command("a", {type = "kaufen", gegenstand = "heiltrank"})
	_check(p.progress.gold == gold - 15 and p.progress.item_count("heiltrank") == 4, "Heiltrank für 15 Gold gekauft")
	world.apply_command("a", {type = "kaufen", gegenstand = "sternentafel"})
	_check(p.progress.item_count("sternentafel") == 0 and p.progress.gold == gold - 15, "Sternentafel ist zu teuer")
	world.apply_command("a", {type = "verkaufen", gegenstand = "heiltrank"})
	_check(p.progress.gold == gold - 15 + 7 and p.progress.item_count("heiltrank") == 3, "Heiltrank für 7 Gold verkauft")
	world.apply_command("a", {type = "laden_zu"})
	_check(p.shop == "", "Laden geschlossen")
	_talk(world, p, "bingo")
	world.apply_command("a", {type = "dialog_choose", index = 1})
	_check(p.progress.quest_state("marvs_traum") == "fertig", "Nach der Sternentafel gefragt")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_choose", index = 0})
	world.apply_command("a", {type = "dialog_next"})
	_check(world.npc_marker(p, "marv") == "?", "Zurück zu Marv")
	_talk(world, p, "marv")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("marvs_traum") == "abgegeben" and world.dialog_view(p).text.contains("Zeit"), "Marv hat Zeit")
	world.apply_command("a", {type = "dialog_next"})

	# Gesandte der fünf Regionen: Lene vergibt den Auftrag, eine Probestunde ist Pflicht
	for envoy: String in ["gesandte_arkanum", "gesandte_messinghafen", "gesandte_glutoase", "gesandte_gruenwacht", "gesandte_nebelinseln"]:
		_check(world.npc_visible(p, envoy), envoy + " ist in der Stadt")
	_check(world.npc_marker(p, "schreiberin") == "!", "Zeichen ! über Lene")
	_talk(world, p, "schreiberin")
	world.apply_command("a", {type = "dialog_choose", index = 1})
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("gesandte") == "aktiv", "Auftrag „Die Gesandten“ läuft")
	world.apply_command("a", {type = "dialog_next"})
	_talk(world, p, "gesandte_glutoase")
	_check(world.dialog_view(p).antworten.size() == 3, "Glutoase: Klassen ansehen, Region, Später")
	var envoy_scenes: Array[String] = []
	world.scene_requested.connect(func(_id: String, scene: String) -> void: envoy_scenes.append(scene))
	world.apply_command("a", {type = "dialog_choose", index = 1})
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(envoy_scenes == ["klassenwahl:Glutoase"] and not p.in_dialog(), "Nalia zeigt die Klassen der Glutoase")
	# Die Probestunde startet im Klassen-Bildschirm, das Ergebnis kommt wie jeder Kampf zur Welt
	var xp_start := p.progress.xp
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "probe:singer", gewonnen = true})
	_check(p.progress.quest_state("gesandte") == "fertig" and p.progress.xp == xp_start + 40, "Pflicht-Probestunde geschafft (+40)")
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "probe:archer", gewonnen = true})
	_check(p.progress.xp == xp_start + 80, "Weitere Probestunden sind freiwillig (+40)")
	_check(world.npc_marker(p, "schreiberin") == "?", "Zurück zu Lene")
	_talk(world, p, "schreiberin")
	world.apply_command("a", {type = "dialog_choose", index = 1})
	_check(p.progress.quest_state("gesandte") == "abgegeben" and p.progress.level == 6, "Gesandte abgegeben, Stufe 6")
	_check(world.dialog_view(p).wer == "Lene", "Gesandte heißen jetzt mit Namen (z. B. Nalia) und Lene redet weiter")

	# Der zugewachsene Weg: Korb zur Wache, die Wache schickt einen weg, Mira spricht einen an
	world.apply_command("a", {type = "dialog_next"})
	_check(world.dialog_view(p).antworten.size() == 3, "Lene bittet um den Korb")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("korb_fuer_die_wache") == "aktiv" and p.progress.item_count("essenskorb") == 1, "Korb in der Tasche")
	world.apply_command("a", {type = "dialog_next"})
	_check(world.npc_marker(p, "wache") == "?", "Zeichen ? über der Wache")
	_check(not world.npc_visible(p, "mira"), "Mira ist noch nicht da")
	_talk(world, p, "wache")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(p.progress.quest_state("korb_fuer_die_wache") == "abgegeben" and p.progress.item_count("essenskorb") == 0, "Korb abgegeben")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	world.apply_command("a", {type = "dialog_next"})
	_check(world.dialog_view(p).text.contains("Geh zurück"), "Die Wache schickt dich weg")
	world.apply_command("a", {type = "dialog_next"})
	_check(p.progress.quest_state("leises_singen") == "aktiv" and world.npc_visible(p, "mira"), "Ein leises Singen … Mira ist da")
	_tick(world, 0.2)
	_check(p.in_dialog() and world.dialog_view(p).text == "Hörst du sie auch?", "Mira: „Hörst du sie auch?“")
	world.apply_command("a", {type = "dialog_choose", index = 1})
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_choose", index = 0})
	world.apply_command("a", {type = "dialog_next"})
	_check(p.progress.quest_state("leises_singen") == "abgegeben", "Mira getroffen")
	world.apply_command("a", {type = "dialog_next"})
	_check(not p.in_dialog() and not world.npc_visible(p, "mira"), "Mira ist wieder fort")
	_check(p.progress.level == 7, "Nach dem zugewachsenen Weg: Stufe 7")
	_talk(world, p, "wache")
	_check(world.dialog_view(p).text.contains("Befehl der Fünf"), "Die Wache lässt niemanden durch")
	world.apply_command("a", {type = "dialog_next"})

	# Nacht des Sternenfalls: Fest, Marv, Sternenfall, Kampf, Ren
	var effects: Array[String] = []
	world.effect_requested.connect(func(_id: String, effect: String) -> void: effects.append(effect))
	_check(world.npc_marker(p, "schreiberin") == "!", "Lene lädt zum Fest ein (!)")
	_talk(world, p, "schreiberin")
	world.apply_command("a", {type = "dialog_choose", index = 1})
	world.apply_command("a", {type = "dialog_choose", index = 0})
	world.apply_command("a", {type = "dialog_next"})
	_check(p.progress.flags.has("nacht") and p.progress.quest_state("fest") == "aktiv", "Es wird Nacht, das Fest beginnt")
	_check(not world.npc_visible(p, "gesandte_glutoase") and not world.npc_visible(p, "marv") and world.npc_visible(p, "marv_fest"),
		"Die Gesandten sind abgereist, Marv ist auf dem Fest")
	world.apply_command("a", {type = "move", cell = Vector2i(22, 26)})
	_tick(world, 10.0)
	_check(p.in_dialog() and world.dialog_view(p).wer == "Marv", "Marv spricht dich auf dem Fest an")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	world.apply_command("a", {type = "dialog_choose", index = 1})
	_check(p.progress.quest_state("fest") == "abgegeben", "Marv hat nach der Sternentafel gefragt")
	world.apply_command("a", {type = "dialog_next"})
	_check(effects == ["sternenfall"] and p.progress.quest_state("sternenfall") == "aktiv", "Der Sternenfall beginnt (Lichtblitz)")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(battles.back() == "sternenfall" and not p.in_dialog(), "Kampf gegen den Sternenfresser beginnt")
	_check(not world.npc_visible(p, "marv_fest"), "Marv ist weg (in Sicherheit)")
	# Niederlage: Ren rettet die Gruppe
	world.apply_command("a", {type = "kampf_ergebnis", kampf = "sternenfall", gewonnen = false})
	_check(world.npc_visible(p, "ren"), "Ren ist da")
	_tick(world, 0.2)
	_check(p.in_dialog() and world.dialog_view(p).text.contains("knapp"), "Ren rettet die Gruppe (Niederlage)")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_choose", index = 0})
	world.apply_command("a", {type = "dialog_next"})
	_check(not p.in_dialog() and p.progress.quest_state("sternenfall") == "abgegeben" and not world.npc_visible(p, "ren"),
		"Ren ist wieder verschwunden")
	_check(p.progress.level == 8 and not p.progress.flags.has("erfolg:schild_hoch"), "Stufe 8, aber kein Erfolg bei Niederlage")

	# Abreise: Lene, Marv verabschiedet sich, Ye öffnet die Klassenwahl, Abspann
	var scenes: Array[String] = []
	world.scene_requested.connect(func(_id: String, scene: String) -> void: scenes.append(scene))
	_check(world.npc_marker(p, "schreiberin") == "!", "Lene hat Neuigkeiten (!)")
	world.apply_command("a", {type = "talk", npc = "schreiberin"})
	_tick(world, 10.0)
	world.apply_command("a", {type = "dialog_choose", index = 0})
	world.apply_command("a", {type = "dialog_next"})
	_check(not p.progress.flags.has("nacht") and p.progress.quest_state("abreise") == "aktiv", "Es ist Morgen, die Abreise steht an")
	_check(not world.npc_visible(p, "gesandte_arkanum") and not world.npc_visible(p, "marv") and world.npc_visible(p, "marv_abschied"),
		"Gesandte bleiben fort, Marv wartet zum Abschied")
	world.apply_command("a", {type = "move", cell = Vector2i(22, 32)})
	_tick(world, 10.0)
	_check(p.in_dialog() and world.dialog_view(p).text.contains("Du gehst"), "Marv will dich nicht gehen lassen")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	world.apply_command("a", {type = "dialog_next"})
	_talk(world, p, "schreiberin")
	_check(world.dialog_view(p).text.contains("Ye wartet am Stadttor") and not p.progress.flags.has("nacht"),
		"Am Morgen lädt Lene nicht nochmal zum Fest ein")
	world.apply_command("a", {type = "dialog_next"})
	_talk(world, p, "ye_tor")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(scenes == ["klassenwahl"] and not p.in_dialog(), "Ye öffnet die Klassenwahl")
	# Auf dem Klassenwahl-Bildschirm wird gewählt (dort landet die Wahl im Spielstand)
	p.progress.flags["klasse"] = "singer"
	p.progress.flags["klasse_gewaehlt"] = "ja"
	_talk(world, p, "ye_tor")
	var farewell: String = world.dialog_view(p).text
	_check(farewell.contains("Sternensängerin") and farewell.contains("in die Glutoase") and farewell.contains("Hohe Sängerin Xavina"),
		"Ye nennt Klasse, Region und Lehrmeister")
	world.apply_command("a", {type = "dialog_choose", index = 0})
	world.apply_command("a", {type = "dialog_choose", index = 0})
	_check(scenes.back() == "abspann" and p.progress.quest_state("abreise") == "abgegeben", "Abreise: Abspann")
	_check(p.progress.level == 9, "Am Ende der ersten Stunde: Stufe 9 (nach Niederlage gegen den Boss)")

	# Sieg (eigene Welt): Erfolg, und Ren klaut den Splitter
	var w2 := WorldState.new()
	var q := w2.add_player("q", "Sieger", "elf_m", Vector2i(24, 28))
	q.progress.flags = {"nacht": true, "sternenfall": true}
	q.progress.quests = {"sternenfall": "aktiv"}
	var achievements: Array[String] = []
	w2.notice.connect(func(_id: String, text: String) -> void: achievements.append(text))
	w2.apply_command("q", {type = "kampf_ergebnis", kampf = "sternenfall", gewonnen = true})
	_check(q.progress.flags.has("erfolg:schild_hoch") and "Erfolg freigeschaltet: Schild hoch, Schild runter" in achievements,
		"Sieg: Erfolg „Schild hoch, Schild runter“")
	w2.tick(0.1)
	_check(q.in_dialog() and w2.dialog_view(q).text.contains("Nicht schlecht"), "Ren klaut den Splitter (Sieg)")
	var battle := GameData.battle("probe:kunoichi")
	_check(battle.klasse == "kunoichi" and battle.name == "Probestunde: Kunoichi" and battle.hinweise.erster_zug.contains("Siegel"),
		"Probestunde-Vorlage füllt Klasse, Name und Erklärung")

	# Stufen bis 10, nicht weiter
	p.progress.add_xp(100000)
	_check(p.progress.level == 10 and p.progress.xp_range().y == -1, "Höchststufe ist 10")

	# Speichern und Laden
	SaveGame.save(p)
	var copy := PlayerState.new("b", "Kopie", "elf_m", Vector2i(0, 0))
	_check(SaveGame.load_into(copy), "Spielstand lässt sich laden")
	_check(copy.progress.to_dict() == p.progress.to_dict() and copy.cell == p.cell, "Geladener Stand ist gleich")
	# Entscheidungen (z. B. Urbaum) bleiben im Spielstand, auch wenn danach normal gespeichert wird
	SaveGame.set_flag("pilzhoehle_urbaum", "retten")
	var again := PlayerState.new("d", "Wieder", "elf_m", Vector2i(0, 0))
	SaveGame.load_into(again)
	SaveGame.save(again)
	_check(SaveGame.get_flag("pilzhoehle_urbaum") == "retten", "Gespeicherte Entscheidung bleibt erhalten")
	SaveGame.delete()
	_check(SaveGame.get_flag("pilzhoehle_urbaum") == "", "Neu beginnen löscht auch die Entscheidung")
	_check(not SaveGame.load_into(PlayerState.new("c", "Neu", "elf_m", Vector2i(0, 0))), "Gelöschter Spielstand ist weg")


func _tick(world: WorldState, seconds: float) -> void:
	var t := 0.0
	while t < seconds:
		world.tick(0.05)
		t += 0.05


func _check(condition: bool, text: String) -> void:
	if not condition:
		_failed += 1
		print("FEHLER: " + text)


## Zum NPC laufen und warten, bis das Gespräch beginnt.
func _talk(world: WorldState, p: PlayerState, npc: String) -> void:
	world.apply_command(p.id, {type = "talk", npc = npc})
	_tick(world, 15.0)
