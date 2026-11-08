class_name KampfEditor
extends Control
## Kampf-Editor (S2): Gegner (frei gewählte Monster mit Stufe oder ein Kampf aus dem Spiel), eigene Gruppe mit Klasse und
## Stufe, Ort und Tageszeit wählen, dann selbst kämpfen oder einen Probe-Lauf machen: Der Kampf läuft 100-mal von selbst
## (Kampf-KI für alle, Paraden wie ein durchschnittlicher Spieler) und zeigt, wie oft man gewinnt.
## Die Auswahl bleibt gemerkt, solange das Spiel läuft (auch nach dem Kampf).

const SCREEN := Vector2(1280, 720)
const PROBE_ANZAHL := 100
## So viele Probe-Kämpfe pro Bild (damit das Bild nicht einfriert, auch im Browser)
const PROBE_PRO_BILD := 10
const STUFE_MAX := 30
const ORTE := ["kreuzwegfelder", "marktplatz_nacht", "waldweg", "wald", "wipfelheim", "tiefwurzel", "pilzhoehle",
		"aschensteppe", "aschensteppe_sand", "palmenrast", "sternenduene", "glutoase_stadt", "glutoase_schmiede",
		"glutgrat", "vulkanschmiede", "ankerkammer", "gewoelbe"]
const ORT_NAMEN := {kreuzwegfelder = "Kreuzwegfelder", marktplatz_nacht = "Marktplatz (Festnacht)", waldweg = "Weg nach Grünwacht",
		wald = "Wachtwald", wipfelheim = "Wipfelheim", tiefwurzel = "Tiefwurzel", pilzhoehle = "Pilzhöhle",
		aschensteppe = "Aschensteppe", aschensteppe_sand = "Aschensteppe (Dünen)", palmenrast = "Palmenrast",
		sternenduene = "Sternendüne", glutoase_stadt = "Stadt Glutoase", glutoase_schmiede = "Hadraks Schmiede",
		glutgrat = "Glutgrat", vulkanschmiede = "Vulkanschmiede", ankerkammer = "Ankerkammer", gewoelbe = "Gewölbe"}

## Gemerkte Auswahl: {art ("frei"/"spiel"), monster: [4 Kennungen, "" = leer], monster_stufe, kampf, gruppe: [{klasse, stufe}],
## computer, traenke, ort ("" = wie im Kampf), nacht}
static var auswahl := {}

var _monster_knoepfe: Array[OptionButton] = []
var _monster_ids: Array[String] = []
var _monster_stufe: SpinBox
var _kampf_knopf: OptionButton
var _kampf_ids: Array[String] = []
var _art: OptionButton
var _frei_box: Control
var _spiel_box: Control
var _klassen_knoepfe: Array[OptionButton] = []
var _klassen_ids: Array[String] = []
var _stufen: Array[SpinBox] = []
var _computer: CheckBox
var _traenke: SpinBox
var _ort: OptionButton
var _nacht: OptionButton
var _ergebnis: Label
var _probe_knopf: Button
var _probe_laeuft := false


func _ready() -> void:
	theme = Combat.make_theme()
	add_child(Backdrop.new())
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.05, 0.8)
	shade.size = SCREEN
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	# Nach einem Kampf aus dem Editor: Uhr wieder normal
	Tageszeit.feste_stunde = -1.0
	BattleRequest.kampf_id = ""
	BattleRequest.result = {}
	if auswahl.is_empty():
		auswahl = standard()

	_text("Kampf-Editor", 40, Color("f2c14e"), Vector2(0, 14), SCREEN.x, true)

	# Spalte 1: Gegner
	_text("Gegner", 22, Color("f2c14e"), Vector2(30, 76), 400)
	_art = _auswahl_knopf(["Monster frei wählen", "Kampf aus dem Spiel"], Vector2(30, 112), Vector2(400, 44))
	_art.select(0 if auswahl.art == "frei" else 1)
	_art.item_selected.connect(func(_i: int) -> void: _art_zeigen())
	_frei_box = Control.new()
	add_child(_frei_box)
	_monster_ids = monster_liste()
	var monster_namen: Array = ["—"]
	for id in _monster_ids:
		monster_namen.append(monster_name(id))
	for i in 4:
		var k := _auswahl_knopf(monster_namen, Vector2(30, 168 + i * 52), Vector2(400, 44), _frei_box)
		var id: String = auswahl.monster[i]
		k.select(_monster_ids.find(id) + 1 if id != "" else 0)
		_monster_knoepfe.append(k)
	_text("Stufe der Monster", 18, Color.WHITE, Vector2(30, 384), 220, false, _frei_box)
	_monster_stufe = _zahl(1, STUFE_MAX, int(auswahl.monster_stufe), Vector2(260, 378), _frei_box)
	_spiel_box = Control.new()
	add_child(_spiel_box)
	var kampf_namen: Array = []
	for id: String in GameData.get_file("kaempfe"):
		var data: Variant = GameData.get_file("kaempfe")[id]
		if data is Dictionary and data.has("name") and (data.has("wellen") or data.has("phasen")):
			_kampf_ids.append(id)
			kampf_namen.append(str(data.name))
	_kampf_knopf = _auswahl_knopf(kampf_namen, Vector2(30, 168), Vector2(400, 44), _spiel_box)
	_kampf_knopf.select(maxi(0, _kampf_ids.find(str(auswahl.kampf))))
	var hinweis := _text("Gegner, Stufe und Regeln wie im Spiel (auch Bosse und Dungeons). Ye's Lernkämpfe und der Sternenfresser sind für Novizen gebaut.",
			16, Color(1, 1, 1, 0.7), Vector2(30, 222), 400, false, _spiel_box)
	hinweis.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hinweis.size.y = 90
	_art_zeigen()

	# Spalte 2: eigene Gruppe
	_text("Deine Gruppe", 22, Color("f2c14e"), Vector2(470, 76), 400)
	_klassen_ids.assign(Sandbox.CLASSES.keys())
	for i in 4:
		var namen: Array = [] if i == 0 else ["—"]
		for id in _klassen_ids:
			namen.append(str(Sandbox.CLASSES[id].title))
		var k := _auswahl_knopf(namen, Vector2(470, 112 + i * 52), Vector2(260, 44))
		var held: Dictionary = auswahl.gruppe[i]
		var stelle := _klassen_ids.find(str(held.klasse))
		k.select(stelle if i == 0 else stelle + 1)
		_klassen_knoepfe.append(k)
		_stufen.append(_zahl(1, STUFE_MAX, int(held.stufe), Vector2(740, 112 + i * 52)))
	_text("Stufe", 16, Color(1, 1, 1, 0.7), Vector2(740, 84), 120)
	_computer = CheckBox.new()
	_computer.text = "Mitstreiter steuert der Computer"
	_computer.button_pressed = bool(auswahl.computer)
	_computer.position = Vector2(470, 322)
	_computer.add_theme_font_size_override("font_size", 17)
	add_child(_computer)
	_text("Heiltränke", 18, Color.WHITE, Vector2(470, 384), 160)
	_traenke = _zahl(0, 20, int(auswahl.traenke), Vector2(640, 378))

	# Spalte 3: Ort und Zeit
	_text("Ort", 22, Color("f2c14e"), Vector2(910, 76), 340)
	var ort_namen: Array = ["Wie im Kampf"]
	for o in ORTE:
		ort_namen.append(ORT_NAMEN[o])
	_ort = _auswahl_knopf(ort_namen, Vector2(910, 112), Vector2(340, 44))
	_ort.select(ORTE.find(str(auswahl.ort)) + 1 if str(auswahl.ort) != "" else 0)
	_nacht = _auswahl_knopf(["Tag", "Nacht"], Vector2(910, 168), Vector2(340, 44))
	_nacht.select(1 if auswahl.nacht else 0)

	# Unten: Kämpfen, Probe-Lauf, Ergebnis
	var los := _knopf("Kämpfen!", Vector2(30, 460), Vector2(300, 64), _kaempfen)
	los.add_theme_font_size_override("font_size", 24)
	_probe_knopf = _knopf("Probe-Lauf (%d Kämpfe)" % PROBE_ANZAHL, Vector2(350, 460), Vector2(340, 64), _probe_lauf)
	_knopf("Zurück zum Editor", Vector2(1010, 640), Vector2(240, 54), func() -> void:
		get_tree().change_scene_to_file("res://scenes/editor.tscn"))
	_ergebnis = _text("", 19, Color("8affc1"), Vector2(30, 540), 960)
	_ergebnis.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE and not _probe_laeuft:
		get_tree().change_scene_to_file("res://scenes/editor.tscn")


static func standard() -> Dictionary:
	return {art = "frei", monster = ["wiesenhoppler", "knollenkaefer", "", ""], monster_stufe = 5, kampf = "",
			gruppe = [{klasse = "novize", stufe = 5}, {klasse = "", stufe = 5}, {klasse = "", stufe = 5}, {klasse = "", stufe = 5}],
			computer = true, traenke = 3, ort = "", nacht = false}


## Alle Monster zum Auswählen, nach Namen sortiert (ohne Teile von Bossen, die allein keinen Sinn ergeben)
static func monster_liste() -> Array[String]:
	var ids: Array[String] = []
	for id: String in Sandbox.ENEMIES:
		var data: Dictionary = Sandbox.ENEMIES[id]
		if id.begins_with("_") or data.get("passive", false) or data.get("trainer", false):
			continue
		ids.append(id)
	ids.sort_custom(func(a: String, b: String) -> bool: return monster_name(a).naturalnocasecmp_to(monster_name(b)) < 0)
	return ids


static func monster_name(id: String) -> String:
	var data: Dictionary = Sandbox.ENEMIES.get(id, {})
	var element := str(data.get("element", ""))
	return "%s (%s)" % [data.get("name", id), element] if element != "" else str(data.get("name", id))


## Liest die Knöpfe in die gemerkte Auswahl
func _merken() -> void:
	auswahl.art = "frei" if _art.selected == 0 else "spiel"
	for i in 4:
		var s := _monster_knoepfe[i].selected
		auswahl.monster[i] = _monster_ids[s - 1] if s > 0 else ""
	auswahl.monster_stufe = int(_monster_stufe.value)
	auswahl.kampf = _kampf_ids[_kampf_knopf.selected] if _kampf_knopf.selected >= 0 and not _kampf_ids.is_empty() else ""
	for i in 4:
		var s := _klassen_knoepfe[i].selected
		var klasse := _klassen_ids[s] if i == 0 else (_klassen_ids[s - 1] if s > 0 else "")
		auswahl.gruppe[i] = {klasse = klasse, stufe = int(_stufen[i].value)}
	auswahl.computer = _computer.button_pressed
	auswahl.traenke = int(_traenke.value)
	auswahl.ort = ORTE[_ort.selected - 1] if _ort.selected > 0 else ""
	auswahl.nacht = _nacht.selected == 1


## Baut den Kampf (BattleState.setup) aus einer Auswahl. Leer, wenn etwas fehlt (keine Monster, kein Kampf).
static func setup_bauen(a: Dictionary) -> Dictionary:
	var helden: Array = []
	for i in 4:
		var held: Dictionary = a.gruppe[i]
		var klasse := str(held.klasse)
		if klasse == "":
			continue
		var stufe := int(held.stufe)
		var spec := {klasse = klasse, name = "Du" if helden.is_empty() else str(Sandbox.CLASSES[klasse].title), stufe = stufe,
				aussehen = "novize" if klasse == "novize" else ""}
		if klasse != "novize":
			spec["macht"] = BattleRequest.hero_power(stufe)
		if klasse == "tamer":
			spec["monster"] = []
		if helden.is_empty():
			spec["traenke"] = int(a.traenke)
		elif a.computer:
			spec["computer"] = true
		helden.append(spec)
	if helden.is_empty():
		return {}
	var data := {}
	var id := "editor"
	if a.art == "spiel":
		id = str(a.kampf)
		data = GameData.battle(id).duplicate(true)
		if data.is_empty():
			return {}
	else:
		var gegner: Array = (a.monster as Array).filter(func(m: String) -> bool: return m != "")
		if gegner.is_empty():
			return {}
		data = {name = "Kampf-Editor", wellen = [gegner], gegner_stufe = int(a.monster_stufe), hintergrund = "kreuzwegfelder"}
		# Bosse aus Dungeons bringen ihre Regeln mit
		for m: String in gegner:
			if m in ["sporenkoenigin", "wurzelmutter", "vorbote"]:
				data["dungeon"] = "pilzhoehle"
			elif m.begins_with("hammerbruder") or m.begins_with("kettenschmied"):
				data["dungeon"] = "vulkanschmiede"
	var phasen: Array = data.get("phasen", [])
	var wellen: Array = data.get("wellen", [])
	if not phasen.is_empty():
		wellen = phasen.map(func(ph: Dictionary) -> Array: return ph.gegner)
	# Lernkämpfe erlauben nur bestimmte Novizen-Fähigkeiten: mit anderen Klassen in der Gruppe gilt das nicht
	if helden.any(func(h: Dictionary) -> bool: return h.klasse != "novize"):
		data.erase("erlaubt")
		data.erase("zuerst")
		data.erase("ziel_paraden")
	var s := BattleRequest._make_setup(id, data, helden, phasen, wellen)
	if str(a.ort) != "":
		s.hintergrund = a.ort
	s["kein_nochmal"] = false
	return s


func _kaempfen() -> void:
	_merken()
	var s := setup_bauen(auswahl)
	if s.is_empty():
		_ergebnis.text = "Bitte mindestens ein Monster (oder einen Kampf) und eine Klasse wählen."
		return
	Tageszeit.feste_stunde = 23.0 if auswahl.nacht else 12.0
	BattleRequest.kampf_id = "editor"
	BattleRequest.setup = s
	BattleRequest.result = {}
	BattleRequest.reward = {}
	BattleRequest.group = {}
	BattleRequest.used_before = 0
	BattleRequest.return_scene = "res://scenes/kampf_editor.tscn"
	get_tree().change_scene_to_file("res://scenes/kampf.tscn")


## Probe-Lauf: PROBE_ANZAHL Kämpfe ohne Grafik, ein paar pro Bild, dann die Auswertung.
func _probe_lauf() -> void:
	if _probe_laeuft:
		return
	_merken()
	var s := setup_bauen(auswahl)
	if s.is_empty():
		_ergebnis.text = "Bitte mindestens ein Monster (oder einen Kampf) und eine Klasse wählen."
		return
	_probe_laeuft = true
	_probe_knopf.disabled = true
	var ergebnisse: Array[Dictionary] = []
	for i in PROBE_ANZAHL:
		ergebnisse.append(ProbeKampf.einmal(self, s, i + 1))
		if i % PROBE_PRO_BILD == PROBE_PRO_BILD - 1:
			_ergebnis.text = "Probe-Lauf: %d / %d …" % [i + 1, PROBE_ANZAHL]
			await get_tree().process_frame
	_ergebnis.text = auswertung(ergebnisse)
	_probe_knopf.disabled = false
	_probe_laeuft = false


## Text zum Probe-Lauf: Siege, Züge, übriges Leben
static func auswertung(ergebnisse: Array[Dictionary]) -> String:
	var siege := 0
	var zuege := 0
	var leben := 0.0
	for e in ergebnisse:
		zuege += int(e.zuege)
		if e.gewonnen:
			siege += 1
			leben += float(e.leben)
	var n := maxi(1, ergebnisse.size())
	var text := "Probe-Lauf: %d von %d Kämpfen gewonnen (%d %%). Im Schnitt %d Züge." % [siege, ergebnisse.size(),
			roundi(100.0 * siege / n), roundi(float(zuege) / n)]
	if siege > 0:
		text += " Nach einem Sieg bleiben der Gruppe im Schnitt %d %% Leben." % roundi(100.0 * leben / siege)
	text += "\nDer Computer spielt alle Helden; Paraden wie ein durchschnittlicher Spieler (je 35 % perfekt und normal)."
	return text


func _art_zeigen() -> void:
	_frei_box.visible = _art.selected == 0
	_spiel_box.visible = _art.selected == 1


func _auswahl_knopf(eintraege: Array, pos: Vector2, groesse: Vector2, eltern: Node = self) -> OptionButton:
	var k := OptionButton.new()
	for e in eintraege:
		k.add_item(str(e))
	k.position = pos
	k.size = groesse
	k.add_theme_font_size_override("font_size", 17)
	k.fit_to_longest_item = false
	k.clip_text = true
	eltern.add_child(k)
	return k


func _zahl(von: int, bis: int, wert: int, pos: Vector2, eltern: Node = self) -> SpinBox:
	var z := SpinBox.new()
	z.min_value = von
	z.max_value = bis
	z.value = clampi(wert, von, bis)
	z.position = pos
	z.size = Vector2(130, 44)
	z.get_line_edit().add_theme_font_size_override("font_size", 18)
	eltern.add_child(z)
	return z


func _knopf(text: String, pos: Vector2, groesse: Vector2, aktion: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = groesse
	b.add_theme_font_size_override("font_size", 19)
	b.pressed.connect(aktion)
	add_child(b)
	return b


func _text(text: String, groesse: int, farbe: Color, pos: Vector2, breite: float, mitte := false, eltern: Node = self) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.size = Vector2(breite, groesse + 14)
	l.add_theme_font_size_override("font_size", groesse)
	l.add_theme_color_override("font_color", farbe)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if mitte else HORIZONTAL_ALIGNMENT_LEFT
	eltern.add_child(l)
	return l
