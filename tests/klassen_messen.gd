extends SceneTree
## E4-Vorarbeit: Was bringt jede Fähigkeit aus dem Baum? Spielt Kämpfe ohne Grafik durch (wie tests/boss_messen.gd).
## Gruppe: die Klasse auf der Stufe, dazu zwei Novizen vom Computer. Gegner: frei gewählte Monster auf einer Stufe.
## Je Klasse: „nur Grundangriff“ (Stufe 3), dann jede Fähigkeit einzeln dazu (Stufe 3, auf der Leiste, samt dem, was sie
## braucht), zum Schluss „alles“ (jede Fähigkeit Stufe 2). Der Computer wählt zufällig unter dem, was auf der Leiste liegt.
## Aufruf: Godot --headless --path . -s tests/klassen_messen.gd -- [anzahl] [stufe] [monster_stufe] [monster,monster,…] [klasse] [allein] [ohne] [rudel] [wachstum]
## Mit „ohne“ als siebtem Wort kommt die Gegenprobe dazu: alles gelernt, nur je eine Fähigkeit fehlt.
## Ausgabe je Zeile: Siege in %, Leben der Gruppe am Ende (nur Siege), Züge je Sieg, Schaden der Klasse je 10 Züge.
## Boss-Messung (12.11.): Statt der Monster-Liste „kampf:<kennung>“ (ein Kampf aus dem Spiel, z. B. kampf:kettenschmied).
## Zusätzliche Wörter an beliebiger Stelle: „leben=3“ (Leben der Gegner mal 3, für einen dicken Einzelgegner) und
## „nur=partner,kaefig“ (nur diese Fähigkeiten einzeln und in der Gegenprobe, spart Zeit) und
## „spielweise=wahllos|klug|beide“ (klug: KampfKI.klug, Schutz und Schwächen nur, wenn sie etwas bringen).

const KLASSEN := ["archer", "tamer", "smith", "blade", "singer"]

var _rudel: Array = []
## Kampf aus dem Spiel statt freier Monster ("" = freie Monster)
var _kampf := ""
## Leben der Gegner mal diesen Wert
var _leben := 1.0
var _spielweisen: Array = ["wahllos"]
## Nur diese Fähigkeiten einzeln messen (Kennungen, mit „nur=a,b“), leer = alle
var _nur_faehigkeiten: Array = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := PackedStringArray()
	for wort: String in OS.get_cmdline_user_args():
		if wort.begins_with("leben="):
			_leben = float(wort.trim_prefix("leben="))
		elif wort.begins_with("spielweise="):
			var w := wort.trim_prefix("spielweise=")
			_spielweisen = ["wahllos", "klug"] if w == "beide" else [w]
		elif wort.begins_with("nur="):
			_nur_faehigkeiten = Array(wort.trim_prefix("nur=").split(","))
		else:
			args.append(wort)
	var anzahl := int(str(args[0])) if args.size() > 0 else 40
	var stufe := int(str(args[1])) if args.size() > 1 else 20
	var monster_stufe := int(str(args[2])) if args.size() > 2 else 20
	var monster: Array = Array(str(args[3] if args.size() > 3 else "wiesenhoppler,knollenkaefer").split(","))
	if str(monster[0]).begins_with("kampf:"):
		_kampf = str(monster[0]).trim_prefix("kampf:")
		monster = [_kampf]
	var nur: String = args[4] if args.size() > 4 else ""
	var allein := args.size() > 5 and args[5] == "allein"
	var ohne := args.size() > 6 and args[6] == "ohne"
	# Achtes Wort: das Rudel des Zähmers, mit + getrennt (z. B. glutwelpe oder glutwelpe+moosling), sonst alle drei Start-Monster
	_rudel = Array(str(args[7]).split("+")) if args.size() > 7 and args[7] != "alle" else []
	# Neuntes Wort: Wachstum der Zähmer-Monster zum Ausprobieren (Sandbox.zaehmer_monster_wachstum, z. B. 1.0 für früher)
	if args.size() > 8:
		Sandbox.zaehmer_monster_wachstum = float(str(args[8]))
	if nur == "liste":
		print(", ".join(KampfEditor.monster_liste()))
		quit(0)
		return
	while monster.size() < 4:
		monster.append("")
	for klasse: String in KLASSEN:
		if nur != "" and nur != "alle" and nur != klasse:
			continue
		var baum: Array = Faehigkeiten.baum(klasse).get("faehigkeiten", [])
		var grund := ""
		for f: Dictionary in baum:
			if f.get("grundangriff", false):
				grund = str(f.id)
		var gegner_text := "Kampf " + _kampf if _kampf != "" else "Gegner %s Stufe %d" % [
				",".join(monster.filter(func(m: String) -> bool: return m != "")), monster_stufe]
		print("## %s (Stufe %d, %s%s, %d Kämpfe%s; Spalten: %s)" % [klasse, stufe, gegner_text, ", Leben ×%s" % _leben if _leben != 1.0 else "",
				anzahl, ", allein" if allein else "", " | ".join(_spielweisen)])
		_messen(klasse, stufe, monster_stufe, monster, allein, anzahl, "nur Grundangriff", {grund: 3}, [])
		var alles := {grund: 2}
		var leiste_alles: Array = []
		for f: Dictionary in baum:
			if f.get("grundangriff", false) or f.get("bald", false):
				continue
			var gelernt := {grund: 3, str(f.id): 3}
			for b: String in (f.get("braucht", {}) as Dictionary):
				gelernt[b] = maxi(int(gelernt.get(b, 0)), int(f.braucht[b]))
			var passiv: bool = f.get("passiv", false)
			alles[str(f.id)] = 2
			if not passiv:
				leiste_alles.append(str(f.id))
			if not _nur_faehigkeiten.is_empty() and not str(f.id) in _nur_faehigkeiten:
				continue
			_messen(klasse, stufe, monster_stufe, monster, allein, anzahl, "%s%s (R%d)" % [f.name, " [passiv]" if passiv else "", int(f.reihe)],
					gelernt, [] if passiv else [str(f.id)])
		_messen(klasse, stufe, monster_stufe, monster, allein, anzahl, "alles auf Stufe 2", alles, leiste_alles)
		# Gegenprobe: alles gelernt, nur diese eine Fähigkeit fehlt (zeigt, was sie im fertigen Baum noch ausmacht)
		if ohne:
			for f: Dictionary in baum:
				if f.get("grundangriff", false) or f.get("bald", false):
					continue
				if not _nur_faehigkeiten.is_empty() and not str(f.id) in _nur_faehigkeiten:
					continue
				var rest := alles.duplicate()
				rest.erase(str(f.id))
				# Was diese Fähigkeit braucht, fällt mit weg
				for g: Dictionary in baum:
					if (g.get("braucht", {}) as Dictionary).has(str(f.id)):
						rest.erase(str(g.id))
				_messen(klasse, stufe, monster_stufe, monster, allein, anzahl, "alles OHNE %s" % f.name, rest,
						leiste_alles.filter(func(id: String) -> bool: return rest.has(id)))
	quit(0)


func _messen(klasse: String, stufe: int, monster_stufe: int, monster: Array, allein: bool, anzahl: int, titel: String,
		gelernt: Dictionary, leiste: Array) -> void:
	var a := KampfEditor.standard()
	if _kampf != "":
		a.art = "spiel"
		a.kampf = _kampf
	a.monster = monster
	a.monster_stufe = monster_stufe
	a.gruppe = [{klasse = klasse, stufe = stufe}, {klasse = "" if allein else "novize", stufe = stufe},
			{klasse = "" if allein else "novize", stufe = stufe}, {klasse = "", stufe = 1}]
	var s := KampfEditor.setup_bauen(a)
	if s.is_empty():
		print("  Kampf oder Monster nicht gefunden.")
		return
	s["gegner_leben"] = float(s.get("gegner_leben", 1.0)) * _leben
	var held: Dictionary = s.helden[0]
	held["faehigkeiten"] = gelernt
	held["leiste"] = leiste
	if klasse == "tamer" and not _rudel.is_empty():
		held["monster"] = _rudel
	var zeile := "  %-34s" % titel
	for weise: String in _spielweisen:
		KampfKI.klug = weise == "klug"
		var siege := 0
		var leben := 0.0
		var zuege := 0
		var alle_zuege := 0
		var schaden := 0
		for i in anzahl:
			var e := ProbeKampf.einmal(root, s, 100 + i)
			alle_zuege += int(e.zuege)
			schaden += int(e.schaden)
			if e.gewonnen:
				siege += 1
				leben += float(e.leben)
				zuege += int(e.zuege)
		zeile += "  | %3d %%  Leben %3d %%  Züge %3d  Schaden %3d" % [roundi(100.0 * siege / anzahl), roundi(100.0 * leben / maxi(1, siege)),
				zuege / maxi(1, siege), roundi(10.0 * schaden / maxi(1, alle_zuege))]
	KampfKI.klug = false
	print(zeile)
