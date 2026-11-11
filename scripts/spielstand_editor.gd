class_name SpielstandEditor
extends Control
## Spielstand-Editor (S5): an jede Stelle der Demo springen. Man wählt Klasse, Figur, Stufe, Geld, Tränke und einen
## Punkt der Geschichte; daraus entsteht ein Editor-Spielstand (spielstand_editor.json, der normale bleibt unberührt):
## Alle Aufträge davor gelten als erledigt (mit ihren Merkern), der gewählte läuft (oder sein Auftraggeber zeigt ein „!“),
## und man steht neben der Figur, bei der es weitergeht. Erweitert „Demo ab einem Akt“.

const SCREEN := Vector2(1280, 720)
const EDITOR_SAVE := "user://spielstand_editor.json"
## Klassen der Demo (Sternensängerin nur mit weiblicher Figur, Marco 09.11.)
const KLASSEN := ["archer", "tamer", "smith", "blade", "singer"]
const FIGUREN := [["Novizin (Kopf w1)", "novize_w+w1"], ["Novize (Kopf m1)", "novize_m+m1"]]
## Die Geschichte in Kreuzweg (für alle gleich)
const KREUZWEG := ["zu_ye", "erster_auftrag", "grundausbildung", "erster_gruppenkampf", "gesandte", "korb_fuer_die_wache",
		"leises_singen", "fest", "sternenfall", "abreise"]
const GLUTOASE := ["kochende_brunnen", "miras_lied", "fest_der_glut", "rivale_kael", "die_ketten", "miras_splitter"]
const GRUENWACHT_2 := ["veraenderte_tiere", "das_leere_grab", "der_urbaum", "die_wahrheit"]
## Vorschlag für die Stufe an jedem Punkt (wie im automatischen Durchlauf; Grünwacht ist das zweite Gebiet, Stufe 20–25)
const STUFEN := {zu_ye = 1, erster_auftrag = 1, grundausbildung = 2, erster_gruppenkampf = 3, gesandte = 4, korb_fuer_die_wache = 5,
		leises_singen = 6, fest = 7, sternenfall = 8, abreise = 10, nach_gruenwacht = 10, fenns_pruefung = 10, esches_monster = 10,
		tildas_unterricht = 11, bericht_ysolde = 11, nach_glutoase = 11, klasse_lernen = 10, kochende_brunnen = 12, miras_lied = 13,
		fest_der_glut = 14, rivale_kael = 15, die_ketten = 16, miras_splitter = 19, rueckkehr_gruenwacht = 20, veraenderte_tiere = 20,
		das_leere_grab = 21, der_urbaum = 22, die_wahrheit = 24}

static var klasse := "blade"
static var figur := 0
static var punkt := 0

var _punkte: ItemList
var _stufe: SpinBox
var _gold: SpinBox
var _heil: SpinBox
var _mana: SpinBox
var _gegenstand: OptionButton
var _gegenstand_zahl: SpinBox
var _extra := {}
var _extra_text: Label
var _hinweis: Label


## Die Punkte der Geschichte für eine Klasse, in der Reihenfolge, in der man sie spielt (S1b, Marco 07.11.):
## Bogenschütze und Zähmer lernen zuerst in Grünwacht, dann Glutoase, dann zurück; alle anderen beginnen in der Glutoase.
static func weg(k: String) -> Array:
	var liste: Array = KREUZWEG.duplicate()
	if k in ["archer", "tamer"]:
		liste.append("nach_gruenwacht")
		liste.append_array(["fenns_pruefung"] if k == "archer" else ["esches_monster", "tildas_unterricht"])
		liste.append_array(["bericht_ysolde", "nach_glutoase"])
		liste.append_array(GLUTOASE)
		liste.append("rueckkehr_gruenwacht")
	else:
		liste.append_array(["nach_glutoase", "klasse_lernen"])
		liste.append_array(GLUTOASE)
		liste.append("nach_gruenwacht")
	liste.append_array(GRUENWACHT_2)
	return liste


## Baut den Spieler an diesem Punkt der Geschichte (ohne zu speichern). Gibt die Welt mit dem Spieler „spieler“ zurück.
static func bauen(k: String, look: String, index: int, stufe: int, gold: int, gegenstaende: Dictionary) -> WorldState:
	var world := WorldState.new()
	var p := world.add_player("spieler", "Du", look, WorldState.start_cell())
	p.figur_name = "Testfigur"
	var liste := weg(k)
	index = clampi(index, 0, liste.size() - 1)
	var ziel: String = liste[index]
	var fertig: Array = ["ankunft"]
	fertig.append_array(liste.slice(0, index))
	var nach_kreuzweg := index >= KREUZWEG.size()
	if nach_kreuzweg:
		# Kreuzweg ist ganz durch: auch die Nebenaufträge und Ye's Lektionen
		for id: String in GameData.get_file("auftraege"):
			if id == "nach_gruenwacht":
				break
			if not id in fertig:
				fertig.append(id)
		p.progress.flags["klasse"] = k
		p.progress.flags["klasse_gewaehlt"] = true
	# Die Klasse ist gelernt, sobald ihr Lehrmeister-Auftrag hinter einem liegt
	var lern_auftrag := {archer = "fenns_pruefung", tamer = "tildas_unterricht"}.get(k, "klasse_lernen") as String
	if lern_auftrag in fertig:
		if not "klasse_lernen" in fertig:
			fertig.append("klasse_lernen")
		if k == "tamer" and not "esches_monster" in fertig:
			fertig.append("esches_monster")
	p.progress.flags["angekommen"] = true
	# Merker, die nicht an einem Ziel hängen: Ye wartet nach dem ersten Auftrag am Tor; der Sternenfall-Punkt beginnt
	# nach dem Kampf gegen den Sternenfresser (der Kampf selbst kommt mitten im Gespräch mit Marv beim Fest)
	if index > liste.find("erster_auftrag"):
		p.progress.flags["ausbildung_morgen"] = true
	if index >= liste.find("sternenfall"):
		p.progress.flags["sternenfall"] = true
	if ziel == "sternenfall":
		for merker: String in ["nacht", "sternenfall_kampf_vorbei", "sternenfresser_besiegt"]:
			p.progress.flags[merker] = true
	for id: String in fertig:
		p.progress.quests[id] = "abgegeben"
		# Was der Auftrag sich gemerkt hat (z. B. tor_gruenwacht, klasse_gelernt, mira_entschieden)
		for goal: Dictionary in GameData.quest(id).get("ziele", []):
			if goal.get("art", "") == "gemerkt" and world.check(p, goal.get("nur_wenn", {})):
				p.progress.flags[str(goal.merken)] = true
	if p.progress.flags.has("klasse_gelernt") and k == "tamer" and not p.progress.flags.has("starter_gewaehlt"):
		p.progress.flags["starter_gewaehlt"] = true
	# Der Auftrag läuft; zeigt dann kein Wegweiser den Weg (z. B. Kämpfe bei Ye), nimmt man ihn wie im Spiel beim
	# Auftraggeber an (er zeigt ein „!“)
	p.progress.quests[ziel] = "aktiv"
	world._update_quests(p)
	if world.objective_place(p).is_empty() and GameData.quest(ziel).has("start_bei"):
		p.progress.quests.erase(ziel)
	# Stufe, Erfahrung, Geld und Gegenstände
	var tabelle := GameData.level_xp()
	stufe = clampi(stufe, 1, tabelle.size())
	p.progress.level = stufe
	p.progress.xp = int(tabelle[stufe - 1])
	if p.progress.flags.has("klasse_gelernt"):
		p.progress.klassen_xp = maxi(0, p.progress.xp - int(tabelle[mini(9, tabelle.size() - 1)]))
	p.progress.gold = gold
	# Nach dem Abschied von Ye hat man sein Empfehlungsschreiben (A15), sonst lassen die Stadtwachen einen nicht hinein
	if "abreise" in fertig:
		p.progress.add_item("empfehlungsschreiben", 1)
	for id: String in gegenstaende:
		if int(gegenstaende[id]) > 0:
			p.progress.add_item(id, int(gegenstaende[id]))
	world._update_quests(p)
	# Neben die Figur stellen, bei der es weitergeht
	var ort := world.objective_place(p)
	if not ort.is_empty():
		var feld: Vector2i = ort.feld
		var platz := feld
		for d: Vector2i in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, 1), Vector2i(-1, 1), Vector2i(0, 2)]:
			if world.is_walkable(feld + d, str(ort.karte)):
				platz = feld + d
				break
		world.change_map(p, str(ort.karte), platz)
	world.fix_position(p)
	return world


func _ready() -> void:
	theme = Combat.make_theme()
	add_child(Backdrop.new())
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.05, 0.8)
	shade.size = SCREEN
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	if klasse == "singer" and FIGUREN[figur][1].begins_with("novize_m"):
		figur = 0
	var titel := _label("Spielstand-Editor", 34, Color("f2c14e"))
	titel.position = Vector2(30, 14)
	_label_unter("An jede Stelle der Demo springen. Dein normaler Spielstand bleibt unberührt.", Vector2(30, 62))

	# Links: Werte
	var links := VBoxContainer.new()
	links.position = Vector2(30, 100)
	links.custom_minimum_size = Vector2(420, 0)
	links.add_theme_constant_override("separation", 6)
	add_child(links)
	links.add_child(_klein_label("Klasse"))
	var klassen_wahl := OptionButton.new()
	for k: String in KLASSEN:
		klassen_wahl.add_item(str(Sandbox.CLASSES[k].title))
	klassen_wahl.select(KLASSEN.find(klasse))
	klassen_wahl.item_selected.connect(func(i: int) -> void:
		klasse = KLASSEN[i]
		punkt = mini(punkt, weg(klasse).size() - 1)
		get_tree().reload_current_scene())
	links.add_child(_breit(klassen_wahl))
	links.add_child(_klein_label("Figur"))
	var figur_wahl := OptionButton.new()
	for f: Array in FIGUREN:
		figur_wahl.add_item(str(f[0]))
	figur_wahl.select(figur)
	figur_wahl.item_selected.connect(func(i: int) -> void:
		figur = i
		if klasse == "singer" and i == 1:
			_hinweis.text = "Die Sternensängerin gibt es vorerst nur für weibliche Figuren."
			figur = 0
			figur_wahl.select(0))
	links.add_child(_breit(figur_wahl))
	var zeile := GridContainer.new()
	zeile.columns = 2
	zeile.add_theme_constant_override("h_separation", 12)
	links.add_child(zeile)
	_stufe = _zahl(1, GameData.max_level(), 1)
	_gold = _zahl(0, 1000000, 50)
	_gold.value = 1000
	_heil = _zahl(0, 99, 1)
	_heil.value = 5
	_mana = _zahl(0, 99, 1)
	_mana.value = 3
	for paar: Array in [["Stufe", _stufe], ["Geld (Bronze)", _gold], ["Heiltränke", _heil], ["Manatränke", _mana]]:
		zeile.add_child(_klein_label(str(paar[0])))
		zeile.add_child(paar[1])
	links.add_child(_klein_label("Weitere Gegenstände"))
	var reihe := HBoxContainer.new()
	links.add_child(reihe)
	_gegenstand = OptionButton.new()
	var ids: Array = GameData.get_file("gegenstaende").keys().filter(func(id: String) -> bool:
		return GameData.get_file("gegenstaende")[id] is Dictionary)
	ids.sort()
	for id: String in ids:
		_gegenstand.add_item(GameData.item_name(id))
		_gegenstand.set_item_metadata(_gegenstand.item_count - 1, id)
	_gegenstand.custom_minimum_size = Vector2(240, 36)
	_gegenstand.clip_text = true
	_gegenstand.fit_to_longest_item = false
	_gegenstand.focus_mode = Control.FOCUS_NONE
	reihe.add_child(_gegenstand)
	_gegenstand_zahl = _zahl(1, 99, 1)
	_gegenstand_zahl.custom_minimum_size = Vector2(80, 36)
	reihe.add_child(_gegenstand_zahl)
	reihe.add_child(_knopf("Dazu", 80, func() -> void:
		var id: String = _gegenstand.get_item_metadata(_gegenstand.selected)
		_extra[id] = int(_extra.get(id, 0)) + int(_gegenstand_zahl.value)
		_extra_zeigen()))
	_extra_text = Label.new()
	_extra_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_extra_text.custom_minimum_size = Vector2(420, 40)
	_extra_text.add_theme_font_size_override("font_size", 14)
	links.add_child(_extra_text)
	_extra_zeigen()

	# Rechts: Punkte der Geschichte
	var rechts := VBoxContainer.new()
	rechts.position = Vector2(480, 100)
	add_child(rechts)
	rechts.add_child(_klein_label("Wo soll es losgehen? (dieser Auftrag läuft, alle davor sind erledigt)"))
	_punkte = ItemList.new()
	_punkte.custom_minimum_size = Vector2(770, 470)
	_punkte.add_theme_font_size_override("font_size", 16)
	var liste := weg(klasse)
	for i in liste.size():
		_punkte.add_item("%2d.  %s  –  %s%s" % [i + 1, _abschnitt(i, liste), GameData.quest(str(liste[i])).get("titel", liste[i]),
				" (nach dem Kampf, zu Ren)" if liste[i] == "sternenfall" else ""])
	_punkte.item_selected.connect(func(i: int) -> void:
		punkt = i
		_stufe.value = int(STUFEN.get(liste[i], 10)))
	rechts.add_child(_punkte)
	punkt = clampi(punkt, 0, liste.size() - 1)
	_punkte.select(punkt)
	_punkte.ensure_current_is_visible()
	_stufe.value = int(STUFEN.get(liste[punkt], 10))

	_hinweis = _label_unter("", Vector2(30, 640))
	_hinweis.size = Vector2(700, 40)
	var los := _knopf("Spielstand bauen und spielen", 330, _starten)
	los.position = Vector2(920, 600)
	los.add_theme_color_override("font_color", Color("f2c14e"))
	add_child(los)
	var zurueck := _knopf("Zurück", 140, func() -> void: get_tree().change_scene_to_file("res://scenes/editor.tscn"))
	zurueck.position = Vector2(760, 600)
	add_child(zurueck)


## Abschnitt eines Punkts für die Liste (Kreuzweg, Glutoase, Grünwacht).
static func _abschnitt(i: int, liste: Array) -> String:
	var id: String = liste[i]
	if i < KREUZWEG.size():
		return "Kreuzweg"
	if id in GLUTOASE or id in ["nach_glutoase"] or (id == "klasse_lernen"):
		return "Glutoase"
	return "Grünwacht"


func _extra_zeigen() -> void:
	if _extra.is_empty():
		_extra_text.text = "(keine)"
		return
	var teile: PackedStringArray = []
	for id: String in _extra:
		teile.append("%d× %s" % [_extra[id], GameData.item_name(id)])
	_extra_text.text = ", ".join(teile)


func _starten() -> void:
	var gegenstaende := _extra.duplicate()
	gegenstaende["heiltrank"] = int(gegenstaende.get("heiltrank", 0)) + int(_heil.value)
	gegenstaende["manatrank"] = int(gegenstaende.get("manatrank", 0)) + int(_mana.value)
	var world := bauen(klasse, str(FIGUREN[figur][1]), punkt, int(_stufe.value), int(_gold.value), gegenstaende)
	SaveGame.path = EDITOR_SAVE
	SaveGame.delete()
	SaveGame.save(world.players["spieler"])
	get_tree().change_scene_to_file("res://scenes/kreuzweg.tscn")


# --- Bausteine -------------------------------------------------------------------

func _label(text: String, groesse: int, farbe: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", groesse)
	l.add_theme_color_override("font_color", farbe)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 6)
	add_child(l)
	return l


func _label_unter(text: String, pos: Vector2) -> Label:
	var l := _label(text, 16, Color.WHITE)
	l.position = pos
	return l


func _klein_label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 15)
	l.add_theme_color_override("font_color", Color("f2c14e"))
	return l


func _breit(o: OptionButton) -> OptionButton:
	o.custom_minimum_size = Vector2(420, 36)
	o.focus_mode = Control.FOCUS_NONE
	return o


func _zahl(von: float, bis: float, schritt: float) -> SpinBox:
	var s := SpinBox.new()
	s.min_value = von
	s.max_value = bis
	s.step = schritt
	s.custom_minimum_size = Vector2(160, 36)
	return s


func _knopf(text: String, breite: float, aktion: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(breite, 44)
	b.size = Vector2(breite, 44)
	b.add_theme_font_size_override("font_size", 17)
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(aktion)
	return b
