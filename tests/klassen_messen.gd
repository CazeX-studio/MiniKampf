extends SceneTree
## E4-Vorarbeit: Was bringt jede Fähigkeit aus dem Baum? Spielt Kämpfe ohne Grafik durch (wie tests/boss_messen.gd).
## Gruppe: die Klasse auf der Stufe, dazu zwei Novizen vom Computer. Gegner: frei gewählte Monster auf einer Stufe.
## Je Klasse: „nur Grundangriff“ (Stufe 3), dann jede Fähigkeit einzeln dazu (Stufe 3, auf der Leiste, samt dem, was sie
## braucht), zum Schluss „alles“ (jede Fähigkeit Stufe 2). Der Computer wählt zufällig unter dem, was auf der Leiste liegt.
## Aufruf: Godot --headless --path . -s tests/klassen_messen.gd -- [anzahl] [stufe] [monster_stufe] [monster,monster,…] [klasse] [allein] [ohne] [rudel] [wachstum]
## Mit „ohne“ als siebtem Wort kommt die Gegenprobe dazu: alles gelernt, nur je eine Fähigkeit fehlt.
## Ausgabe je Zeile: Siege in %, Leben der Gruppe am Ende (nur Siege), Züge je Sieg.

const KLASSEN := ["archer", "tamer", "smith", "blade", "singer"]

var _rudel: Array = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var anzahl := int(args[0]) if args.size() > 0 else 40
	var stufe := int(args[1]) if args.size() > 1 else 20
	var monster_stufe := int(args[2]) if args.size() > 2 else 20
	var monster: Array = Array((args[3] if args.size() > 3 else "wiesenhoppler,knollenkaefer").split(","))
	var nur := args[4] if args.size() > 4 else ""
	var allein := args.size() > 5 and args[5] == "allein"
	var ohne := args.size() > 6 and args[6] == "ohne"
	# Achtes Wort: das Rudel des Zähmers, mit + getrennt (z. B. glutwelpe oder glutwelpe+moosling), sonst alle drei Start-Monster
	_rudel = Array(args[7].split("+")) if args.size() > 7 and args[7] != "alle" else []
	# Neuntes Wort: Wachstum der Zähmer-Monster zum Ausprobieren (Sandbox.zaehmer_monster_wachstum, z. B. 1.0 für früher)
	if args.size() > 8:
		Sandbox.zaehmer_monster_wachstum = float(args[8])
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
		print("## %s (Stufe %d, Gegner %s Stufe %d, %d Kämpfe%s)" % [klasse, stufe, ",".join(monster.filter(func(m: String) -> bool: return m != "")),
				monster_stufe, anzahl, ", allein" if allein else ""])
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
			_messen(klasse, stufe, monster_stufe, monster, allein, anzahl, "%s%s (R%d)" % [f.name, " [passiv]" if passiv else "", int(f.reihe)],
					gelernt, [] if passiv else [str(f.id)])
			alles[str(f.id)] = 2
			if not passiv:
				leiste_alles.append(str(f.id))
		_messen(klasse, stufe, monster_stufe, monster, allein, anzahl, "alles auf Stufe 2", alles, leiste_alles)
		# Gegenprobe: alles gelernt, nur diese eine Fähigkeit fehlt (zeigt, was sie im fertigen Baum noch ausmacht)
		if ohne:
			for f: Dictionary in baum:
				if f.get("grundangriff", false) or f.get("bald", false):
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
	a.monster = monster
	a.monster_stufe = monster_stufe
	a.gruppe = [{klasse = klasse, stufe = stufe}, {klasse = "" if allein else "novize", stufe = stufe},
			{klasse = "" if allein else "novize", stufe = stufe}, {klasse = "", stufe = 1}]
	var s := KampfEditor.setup_bauen(a)
	var held: Dictionary = s.helden[0]
	held["faehigkeiten"] = gelernt
	held["leiste"] = leiste
	if klasse == "tamer" and not _rudel.is_empty():
		held["monster"] = _rudel
	var siege := 0
	var leben := 0.0
	var zuege := 0
	for i in anzahl:
		var e := ProbeKampf.einmal(root, s, 100 + i)
		if e.gewonnen:
			siege += 1
			leben += float(e.leben)
			zuege += int(e.zuege)
	print("  %-34s %3d %%   Leben %3d %%   Züge %3d" % [titel, roundi(100.0 * siege / anzahl), roundi(100.0 * leben / maxi(1, siege)),
			zuege / maxi(1, siege)])
