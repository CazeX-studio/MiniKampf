extends Node
## Bewegungs- und Effekt-Editor (S3a): ein Kampf, in dem man Held (Klasse und Aussehen) und Monster wählt und dann
## jede Bewegung, jede Fähigkeit und jeden Effekt einzeln abspielen kann, auch in Zeitlupe.
## Der Held fällt nicht um und hat immer Mana und volle Ult; das Monster hat sehr viel Leben.
## Die Bewegungen in der Welt kommen mit S3b.

const ZEITLUPEN: Array[float] = [1.0, 0.3, 0.1]
const AUSSEHEN := {"": "Standard der Klasse", "eigen": "Eigene Figur", "vega": "Vega", "kofi": "Kofi",
		"kael_kampf": "Kael", "ye_kampf": "Ye"}

## Gewählt (bleibt beim Neuladen der Szene)
static var klasse := "novize"
static var aussehen := ""
static var monster := "wiesenhoppler"
static var _zeitlupe := 0

var _kampf: Node
var _held: Fighter
var _gegner: Fighter
var _auf_monster := false
var _status: Label
var _bewegt_knopf: Button
var _faehigkeiten_box: GridContainer
var _fx_ablauf: OptionButton
var _fx_bild: OptionButton
var _ki: KampfKI


func _ready() -> void:
	Tageszeit.feste_stunde = 12.0
	var a := KampfEditor.standard()
	a.gruppe = [{klasse = klasse, stufe = 20}, {klasse = "", stufe = 1}, {klasse = "", stufe = 1}, {klasse = "", stufe = 1}]
	a.monster = [monster, "", "", ""]
	a.monster_stufe = 10
	a.traenke = 0
	var s := KampfEditor.setup_bauen(a)
	s.helden[0].aussehen = _aussehen_id()
	s.gegner_leben = 40.0
	s.kein_nochmal = true
	s.name = "Bewegungen und Effekte"
	BattleRequest.kampf_id = "bewegung"
	BattleRequest.setup = s
	BattleRequest.result = {}
	BattleRequest.reward = {}
	BattleRequest.group = {}
	BattleRequest.return_scene = "res://scenes/bewegung_editor.tscn"
	_kampf = load("res://scenes/kampf.tscn").instantiate()
	add_child(_kampf)
	Engine.time_scale = ZEITLUPEN[_zeitlupe]
	_knoepfe_bauen()


func _exit_tree() -> void:
	Engine.time_scale = 1.0
	Tageszeit.feste_stunde = -1.0
	BattleRequest.kampf_id = ""
	BattleRequest.result = {}


func _process(_delta: float) -> void:
	if not _finden():
		return
	# Der Held bleibt stehen, hat immer Mana, volle Ult und keine Abklingzeiten
	if _held.hp < _held.max_hp:
		_held.hp = _held.max_hp
	_held.mana = _held.max_mana
	_held.ult = 100.0
	_held.cooldowns.clear()
	if _gegner.hp < _gegner.max_hp / 4:
		_gegner.hp = _gegner.max_hp
	if _faehigkeiten_box.get_child_count() == 0:
		_faehigkeiten_fuellen()
	# Begleiter (Roboter, Zähmer-Monster) wartet auf eine Eingabe: das macht der Computer
	var dran: Fighter = _kampf._current
	if dran != null and dran != _held and not _kampf.state.enemies.has(dran) and not _kampf._grid_buttons().is_empty():
		if _ki == null:
			_ki = KampfKI.new(7)
		_kampf._cancel_targeting()
		_kampf._clear_actions()
		_kampf._action_chosen.emit(_ki.choose(_kampf.state.skills, dran))


func _finden() -> bool:
	if _held != null and is_instance_valid(_held) and _gegner != null:
		return true
	if not "state" in _kampf or _kampf.state == null or _kampf.state.heroes.is_empty() or _kampf.state.enemies.is_empty():
		return false
	# Mechaniker und Zähmer haben Begleiter (Roboter, Monster): der Held ist die Figur der gewählten Klasse
	_held = _kampf.state.heroes[0]
	for h: Fighter in _kampf.state.heroes:
		if h.klass == klasse:
			_held = h
			break
	# Begleiter spielt der Computer, nur der Held wartet auf die Knöpfe
	for h: Fighter in _kampf.state.heroes:
		if h != _held:
			_kampf.state.computer[h] = true
	_gegner = _kampf.state.enemies[0]
	return _kampf.has_view(_held) and _kampf.has_view(_gegner)


## Aussehen für den Kampf: "" = Klassenfigur, "eigen" = eigene Figur in Klassenkleidung (wie im Spiel)
static func _aussehen_id() -> String:
	if aussehen == "":
		return "novize" if klasse == "novize" else ""
	if aussehen == "eigen":
		var eigene := FigurWahl.gewaehlt()
		return eigene if klasse == "novize" else FigurTeile.mit_klasse(eigene, klasse)
	return aussehen


func _knoepfe_bauen() -> void:
	var ebene := CanvasLayer.new()
	ebene.layer = 50
	add_child(ebene)
	# Breite Leiste unten (über der Kampf-Leiste, die im Editor nicht gebraucht wird): vier Spalten
	var panel := PanelContainer.new()
	panel.theme = Combat.make_theme()
	panel.position = Vector2(4, 512)
	panel.size = Vector2(1272, 204)
	ebene.add_child(panel)
	var spalten := HBoxContainer.new()
	spalten.add_theme_constant_override("separation", 14)
	panel.add_child(spalten)

	var figur := _spalte(spalten, "Figur", 220)
	var klassen: Array = Sandbox.CLASSES.keys()
	figur.add_child(_auswahl(klassen.map(func(k: String) -> String: return str(Sandbox.CLASSES[k].title)), klassen.find(klasse),
			func(i: int) -> void:
				klasse = klassen[i]
				get_tree().reload_current_scene()))
	var looks: Array = AUSSEHEN.keys()
	figur.add_child(_auswahl(looks.map(func(k: String) -> String: return str(AUSSEHEN[k])), looks.find(aussehen),
			func(i: int) -> void:
				aussehen = looks[i]
				get_tree().reload_current_scene()))
	var monster_ids := KampfEditor.monster_liste()
	figur.add_child(_auswahl(monster_ids.map(func(m: String) -> String: return KampfEditor.monster_name(m)), monster_ids.find(monster),
			func(i: int) -> void:
				monster = monster_ids[i]
				get_tree().reload_current_scene()))
	var zeit := _klein("Tempo: %s" % _tempo_text())
	zeit.pressed.connect(func() -> void:
		_zeitlupe = (_zeitlupe + 1) % ZEITLUPEN.size()
		Engine.time_scale = ZEITLUPEN[_zeitlupe]
		zeit.text = "Tempo: %s" % _tempo_text())
	figur.add_child(zeit)

	var bewegt := _spalte(spalten, "Bewegungen", 330)
	var raster := GridContainer.new()
	raster.columns = 3
	raster.add_theme_constant_override("h_separation", 4)
	raster.add_theme_constant_override("v_separation", 4)
	bewegt.add_child(raster)
	_bewegt_knopf = _klein("Für: Held", 106)
	_bewegt_knopf.pressed.connect(func() -> void:
		_auf_monster = not _auf_monster
		_bewegt_knopf.text = "Für: Monster" if _auf_monster else "Für: Held")
	raster.add_child(_bewegt_knopf)
	var bewegungen: Array = [
		["Stehen", func(v: FighterView, _f: Fighter) -> void:
			v.shown = -1
			v._set_anim("idle")],
		["Laufen", func(v: FighterView, _f: Fighter) -> void: v.play("run", 1.2)],
		["Angriff", func(_v: FighterView, f: Fighter) -> void: _kampf.lunge(f, _gegner if f == _held else _held, 0.6)],
		["Getroffen", func(v: FighterView, _f: Fighter) -> void: v.hit_react()],
		["Abwehr", func(v: FighterView, _f: Fighter) -> void: v.parry_pose()],
		["Wirken", func(v: FighterView, _f: Fighter) -> void: v.cast_hop()],
		["Sieg", func(v: FighterView, _f: Fighter) -> void: v.cheer()],
		["Fallen", func(v: FighterView, _f: Fighter) -> void: v.shown = 0],
	]
	for b: Array in bewegungen:
		var knopf := _klein(b[0], 106)
		var aktion: Callable = b[1]
		knopf.pressed.connect(func() -> void:
			if not _finden():
				return
			var f := _gegner if _auf_monster else _held
			aktion.call(_kampf.view(f), f))
		raster.add_child(knopf)

	var faeh := _spalte(spalten, "Fähigkeiten (wenn der Held am Zug ist)", 420)
	var rollen := ScrollContainer.new()
	rollen.custom_minimum_size = Vector2(420, 120)
	rollen.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	faeh.add_child(rollen)
	_faehigkeiten_box = GridContainer.new()
	_faehigkeiten_box.columns = 3
	_faehigkeiten_box.add_theme_constant_override("h_separation", 4)
	_faehigkeiten_box.add_theme_constant_override("v_separation", 4)
	rollen.add_child(_faehigkeiten_box)
	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size = Vector2(410, 0)
	_status.add_theme_font_size_override("font_size", 13)
	_status.add_theme_color_override("font_color", Color("8affc1"))
	faeh.add_child(_status)

	var effekte := _spalte(spalten, "Effekte", 230)
	var namen: Dictionary = GameData.get_file("fx_namen")
	var ablaeufe: Array = namen.get("ablaeufe", [])
	_fx_ablauf = _auswahl(ablaeufe, 0, func(_i: int) -> void: pass)
	effekte.add_child(_fx_ablauf)
	var ablauf_los := _klein("Ablauf abspielen")
	ablauf_los.pressed.connect(func() -> void:
		if _finden() and _fx_ablauf.selected >= 0:
			FaehigkeitFx.spielen(_kampf, ablaeufe[_fx_ablauf.selected], _held, _gegner, 0))
	effekte.add_child(ablauf_los)
	var bilder: Array = namen.get("bilder", [])
	_fx_bild = _auswahl(bilder, 0, func(_i: int) -> void: pass)
	effekte.add_child(_fx_bild)
	var bild_los := _klein("Bildfolge abspielen")
	bild_los.pressed.connect(func() -> void:
		if _finden() and _fx_bild.selected >= 0:
			var ziel: FighterView = _kampf.view(_held if _auf_monster else _gegner)
			FxBild.spawn(_kampf._field, bilder[_fx_bild.selected], ziel.center(), 0.7))
	effekte.add_child(bild_los)
	var zurueck := _klein("Zurück zum Editor")
	zurueck.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/editor.tscn"))
	effekte.add_child(zurueck)


## Eine Spalte der Leiste mit Überschrift
func _spalte(eltern: Node, titel: String, breite: float) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.custom_minimum_size = Vector2(breite, 0)
	box.add_child(_ueberschrift(titel))
	eltern.add_child(box)
	return box


func _tempo_text() -> String:
	return ["normal", "langsam", "sehr langsam"][_zeitlupe]


## Knöpfe für alle Fähigkeiten der Klasse. Ausgeführt werden sie wirklich, sobald der Held am Zug ist.
func _faehigkeiten_fuellen() -> void:
	for ab: Dictionary in _kampf.state.skills.abilities(_held):
		var knopf := _klein(str(ab.name), 136)
		knopf.tooltip_text = str(ab.get("info", ""))
		var faehigkeit := ab
		knopf.pressed.connect(func() -> void: _faehigkeit(faehigkeit))
		_faehigkeiten_box.add_child(knopf)


func _faehigkeit(ab: Dictionary) -> void:
	if _kampf._current != _held or _kampf._grid_buttons().is_empty():
		_status.text = "Warte, bis der Held am Zug ist (Knöpfe unten), dann noch einmal drücken."
		return
	var gewaehlt := ab.duplicate()
	if gewaehlt.target == "choice":
		var wahl: Dictionary = gewaehlt.choices[0]
		gewaehlt.choice = wahl.id
		gewaehlt.target = wahl.get("then", gewaehlt.get("then", "none"))
	var ziel: Fighter = null
	if gewaehlt.target != "none":
		var ziele: Array[Fighter] = _kampf.state.skills.valid_targets(_held, gewaehlt)
		if ziele.is_empty():
			_status.text = "%s: gerade kein passendes Ziel." % ab.name
			return
		ziel = ziele[0]
	_status.text = ""
	_kampf._cancel_targeting()
	_kampf._clear_actions()
	_kampf._action_chosen.emit({ab = gewaehlt, target = ziel})


func _ueberschrift(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 15)
	l.add_theme_color_override("font_color", Color("f2c14e"))
	return l


func _auswahl(eintraege: Array, gewaehlt: int, aktion: Callable) -> OptionButton:
	var k := OptionButton.new()
	for e in eintraege:
		k.add_item(str(e))
	k.select(maxi(0, gewaehlt))
	k.custom_minimum_size = Vector2(210, 32)
	k.clip_text = true
	k.fit_to_longest_item = false
	k.add_theme_font_size_override("font_size", 14)
	k.focus_mode = Control.FOCUS_NONE
	k.item_selected.connect(aktion)
	return k


func _klein(text: String, breite := 210.0) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(breite, 32)
	b.add_theme_font_size_override("font_size", 14)
	b.focus_mode = Control.FOCUS_NONE
	b.clip_text = true
	return b
