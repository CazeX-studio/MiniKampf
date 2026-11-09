extends Node2D
## Bewegungs-Editor in der Welt (S3b): Figur wählen (Novizen, Klassen-Körper, Baukasten-Figuren, Hauptfiguren,
## Monster), in jeder Richtung stehen, laufen, sitzen oder liegen lassen, langsamer abspielen oder anhalten und
## Bild für Bild weiterschalten. Links steht die Figur so groß wie im Spiel, rechts vergrößert.

const SCREEN := Vector2(1280, 720)
const TEMPI: Array[float] = [1.0, 0.3, 0.1]
const TEMPO_NAMEN: Array[String] = ["normal", "langsam", "sehr langsam"]
const GRUPPEN: Array[String] = ["Novizen", "Klassen-Körper", "Baukasten-Figuren", "Hauptfiguren", "Monster"]
## Hauptfiguren mit eigenen Welt-Bildern (fehlt ein Bild, fällt die Figur aus der Liste)
const HAUPTFIGUREN: Array[String] = ["vega", "kofi", "ye", "kael", "bingo", "marv", "mira", "tilda", "esche", "fenn",
		"ysolde", "samira", "xavina", "hadrak", "brakkus"]
## Richtungen: [Name, Blick (1 = nach rechts), Ansicht ("seite", "vorn", "hinten")]
const RICHTUNGEN: Array = [["Seite →", 1, "seite"], ["Seite ←", -1, "seite"], ["Vorne →", 1, "vorn"],
		["Vorne ←", -1, "vorn"], ["Hinten →", 1, "hinten"], ["Hinten ←", -1, "hinten"]]
const BEWEGUNGEN: Array[String] = ["Stehen", "Laufen", "Sitzen", "Liegen"]
## Größe der Figur im Spiel (wie in den Baukasten-Städten) und in der Vergrößerung
const GROESSE_SPIEL := 0.8
const GROESSE_NAH := 2.2

## Gewählt (bleibt beim Neuladen der Szene)
static var gruppe := 0
static var figur := ""
static var kopf := ""
static var richtung := 2
static var bewegung := 0
static var tempo := 0

var _figuren: Array[WorldCharacter] = []
var _figur_wahl: OptionButton
var _kopf_wahl: OptionButton
var _richtung_knoepfe: Array[Button] = []
var _bewegung_knoepfe: Array[Button] = []
var _halt_knopf: Button
var _info: Label
var _angehalten := false


func _ready() -> void:
	Tageszeit.feste_stunde = 12.0
	var boden := Node2D.new()
	boden.draw.connect(func() -> void: _boden_malen(boden))
	add_child(boden)
	_knoepfe_bauen()
	_gruppe_fuellen()


func _exit_tree() -> void:
	Tageszeit.feste_stunde = -1.0


## Wiese mit Rautenfeldern wie in der Welt, darauf zwei Fußpunkte
func _boden_malen(boden: Node2D) -> void:
	boden.draw_rect(Rect2(Vector2.ZERO, SCREEN), Color("4f7a3a"))
	var linie := Color(0.0, 0.0, 0.0, 0.12)
	for i in range(-20, 40):
		boden.draw_line(Vector2(i * 64, 0), Vector2(i * 64 + 1000, 500), linie, 1.0)
		boden.draw_line(Vector2(i * 64, 0), Vector2(i * 64 - 1000, 500), linie, 1.0)
	boden.draw_rect(Rect2(0, 500, SCREEN.x, SCREEN.y - 500), Color("1a1a24"))
	var schrift := ThemeDB.fallback_font
	boden.draw_string(schrift, Vector2(150, 40), "So groß wie im Spiel", HORIZONTAL_ALIGNMENT_CENTER, 300, 18, Color.WHITE)
	boden.draw_string(schrift, Vector2(700, 40), "Vergrößert", HORIZONTAL_ALIGNMENT_CENTER, 300, 18, Color.WHITE)


## Mögliche Figuren der gewählten Gruppe: Name im Spiel -> Anzeigename
func figuren_liste(nummer: int) -> Dictionary:
	var liste := {}
	match GRUPPEN[nummer]:
		"Novizen", "Klassen-Körper", "Baukasten-Figuren":
			var koerper := FigurTeile.koerper_liste()
			var namen: Array = koerper.keys()
			namen.sort()
			for k: String in namen:
				var art := "Baukasten-Figuren" if k.begins_with("grund_") else ("Novizen" if k.begins_with("novize_") else "Klassen-Körper")
				if art == GRUPPEN[nummer]:
					liste[k] = str(koerper[k])
		"Hauptfiguren":
			for h: String in HAUPTFIGUREN:
				if FighterView.is_own_sprite(h):
					liste[h] = h.capitalize()
		"Monster":
			for m: String in KampfEditor.monster_liste():
				liste[m] = KampfEditor.monster_name(m)
	return liste


## Köpfe, die auf den Körper passen (leer = Figur ohne wählbaren Kopf)
func koepfe_liste(koerper: String) -> Array:
	if not FigurTeile.koerper_liste().has(koerper):
		return []
	var liste: Array = FigurTeile.koepfe(koerper).keys()
	liste.sort()
	var standard := FigurTeile.standardkopf(koerper)
	if standard != "" and liste.has(standard):
		liste.erase(standard)
		liste.push_front(standard)
	return liste


func _gruppe_fuellen() -> void:
	var liste := figuren_liste(gruppe)
	_figur_wahl.clear()
	for id: String in liste:
		_figur_wahl.add_item(str(liste[id]))
	var ids: Array = liste.keys()
	if not ids.has(figur):
		figur = ids[0] if not ids.is_empty() else ""
		kopf = ""
	_figur_wahl.select(maxi(0, ids.find(figur)))
	_koepfe_fuellen()


func _koepfe_fuellen() -> void:
	var liste := koepfe_liste(figur)
	_kopf_wahl.clear()
	for k: String in liste:
		_kopf_wahl.add_item("Kopf " + k)
	_kopf_wahl.disabled = liste.is_empty()
	if liste.is_empty():
		_kopf_wahl.add_item("(eigener Kopf)")
		kopf = ""
	elif not liste.has(kopf):
		kopf = liste[0]
	_kopf_wahl.select(maxi(0, liste.find(kopf)))
	figur_bauen()


## Name der Figur fürs Spiel: Körper mit Kopf („novize_w+w1“), Monster mit ihrem Bild
func look() -> String:
	if GRUPPEN[gruppe] == "Monster":
		return str(FighterView.LOOKS.get(figur, {sprite = figur}).sprite)
	return figur + "+" + kopf if kopf != "" else figur


func figur_bauen() -> void:
	for f in _figuren:
		f.queue_free()
	_figuren.clear()
	if figur == "":
		return
	var farbe: Color = FighterView.LOOKS.get(figur, {}).get("tint", Color.WHITE) if GRUPPEN[gruppe] == "Monster" else Color.WHITE
	for groesse: float in [GROESSE_SPIEL, GROESSE_NAH]:
		var f := WorldCharacter.new()
		f.setup(look(), str(_figur_wahl.get_item_text(_figur_wahl.selected)), farbe, Color("f2c14e"))
		f.scale = Vector2(groesse, groesse)
		f.position = Vector2(300, 400) if groesse == GROESSE_SPIEL else Vector2(850, 470)
		if groesse == GROESSE_NAH:
			f.set_name_alpha(0.0)
		add_child(f)
		_figuren.append(f)
	_anwenden()


## Richtung, Bewegung und Tempo auf beide Figuren legen; Knöpfe ohne Bilder ausgrauen
func _anwenden() -> void:
	if _figuren.is_empty():
		return
	var f0 := _figuren[0]
	for i in RICHTUNGEN.size():
		var ansicht: String = RICHTUNGEN[i][2]
		_richtung_knoepfe[i].disabled = ansicht != "seite" and not f0.hat_bilder("idle_" + ansicht)
	if _richtung_knoepfe[richtung].disabled:
		richtung = 0
	_bewegung_knoepfe[3].disabled = not f0.hat_bilder("liegen")
	if _bewegung_knoepfe[bewegung].disabled:
		bewegung = 0
	for i in RICHTUNGEN.size():
		_richtung_knoepfe[i].button_pressed = i == richtung
	for i in BEWEGUNGEN.size():
		_bewegung_knoepfe[i].button_pressed = i == bewegung
	var ansicht: String = RICHTUNGEN[richtung][2]
	for f in _figuren:
		# Seitenansicht: Figuren nur mit Welt-Bildern (Baukasten) haben keine, sie zeigen dann schräg von vorne
		f.richtungen = ansicht != "seite" or not f.hat_bilder("idle")
		f.hinten = ansicht == "hinten"
		f.facing = RICHTUNGEN[richtung][1]
		f.moving = bewegung == 1
		f.sitzt = bewegung == 2
		f.liegt = bewegung == 3
		f.tempo = TEMPI[tempo]
		f.angehalten = _angehalten
	# Beide Figuren auf dasselbe Bild bringen
	_figuren[1].time_offset(_figuren[0]._time - _figuren[1]._time)


func _process(_delta: float) -> void:
	if _figuren.is_empty():
		_info.text = ""
		return
	var i := _figuren[0].bild_info()
	_info.text = "Figur: %s\nBilder: %s, Bild %d von %d\nTempo: %s%s" % [look(), i.anim, i.bild, i.von, TEMPO_NAMEN[tempo],
			" (angehalten)" if _angehalten else ""]


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.physical_keycode:
			KEY_ESCAPE:
				get_tree().change_scene_to_file("res://scenes/editor.tscn")
			KEY_SPACE:
				_halt_umschalten()
			KEY_RIGHT:
				_schritt(1)
			KEY_LEFT:
				_schritt(-1)


func _halt_umschalten() -> void:
	_angehalten = not _angehalten
	_halt_knopf.text = "Weiter abspielen" if _angehalten else "Anhalten"
	_anwenden()


## Bild für Bild: hält an und schaltet beide Figuren gleich weiter
func _schritt(schritte: int) -> void:
	if not _angehalten:
		_halt_umschalten()
	for f in _figuren:
		f.bild_weiter(schritte)


func _knoepfe_bauen() -> void:
	var ebene := CanvasLayer.new()
	ebene.layer = 50
	add_child(ebene)
	var panel := PanelContainer.new()
	panel.theme = Combat.make_theme()
	panel.position = Vector2(4, 512)
	panel.size = Vector2(1272, 204)
	ebene.add_child(panel)
	var spalten := HBoxContainer.new()
	spalten.add_theme_constant_override("separation", 14)
	panel.add_child(spalten)

	var wahl := _spalte(spalten, "Figur", 230)
	wahl.add_child(_auswahl(GRUPPEN, gruppe, func(i: int) -> void:
		gruppe = i
		_gruppe_fuellen()))
	_figur_wahl = _auswahl([], 0, func(i: int) -> void:
		figur = figuren_liste(gruppe).keys()[i]
		_koepfe_fuellen())
	wahl.add_child(_figur_wahl)
	_kopf_wahl = _auswahl([], 0, func(i: int) -> void:
		kopf = koepfe_liste(figur)[i]
		figur_bauen())
	wahl.add_child(_kopf_wahl)

	var richt := _spalte(spalten, "Richtung", 230)
	var raster := GridContainer.new()
	raster.columns = 2
	raster.add_theme_constant_override("h_separation", 4)
	raster.add_theme_constant_override("v_separation", 4)
	richt.add_child(raster)
	for i in RICHTUNGEN.size():
		var knopf := _klein(RICHTUNGEN[i][0], 110)
		knopf.toggle_mode = true
		var nummer := i
		knopf.pressed.connect(func() -> void:
			richtung = nummer
			_anwenden())
		raster.add_child(knopf)
		_richtung_knoepfe.append(knopf)

	var beweg := _spalte(spalten, "Bewegung", 230)
	var raster2 := GridContainer.new()
	raster2.columns = 2
	raster2.add_theme_constant_override("h_separation", 4)
	raster2.add_theme_constant_override("v_separation", 4)
	beweg.add_child(raster2)
	for i in BEWEGUNGEN.size():
		var knopf := _klein(BEWEGUNGEN[i], 110)
		knopf.toggle_mode = true
		var nummer := i
		knopf.pressed.connect(func() -> void:
			bewegung = nummer
			_anwenden())
		raster2.add_child(knopf)
		_bewegung_knoepfe.append(knopf)
	var zeit := _klein("Tempo: %s" % TEMPO_NAMEN[tempo])
	zeit.pressed.connect(func() -> void:
		tempo = (tempo + 1) % TEMPI.size()
		zeit.text = "Tempo: %s" % TEMPO_NAMEN[tempo]
		_anwenden())
	beweg.add_child(zeit)

	var bild := _spalte(spalten, "Bild für Bild (Leertaste, Pfeiltasten)", 300)
	_halt_knopf = _klein("Anhalten", 300)
	_halt_knopf.pressed.connect(_halt_umschalten)
	bild.add_child(_halt_knopf)
	var zeile := HBoxContainer.new()
	zeile.add_theme_constant_override("separation", 4)
	var zurueck_bild := _klein("◀ Bild zurück", 148)
	zurueck_bild.pressed.connect(func() -> void: _schritt(-1))
	zeile.add_child(zurueck_bild)
	var vor_bild := _klein("Bild vor ▶", 148)
	vor_bild.pressed.connect(func() -> void: _schritt(1))
	zeile.add_child(vor_bild)
	bild.add_child(zeile)
	_info = Label.new()
	_info.add_theme_font_size_override("font_size", 13)
	_info.add_theme_color_override("font_color", Color("8affc1"))
	bild.add_child(_info)

	var ende := _spalte(spalten, "", 200)
	var zurueck := _klein("Zurück zum Editor", 200)
	zurueck.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/editor.tscn"))
	ende.add_child(zurueck)
	var kampf := _klein("Bewegungen im Kampf", 200)
	kampf.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/bewegung_editor.tscn"))
	ende.add_child(kampf)


## Eine Spalte der Leiste mit Überschrift
func _spalte(eltern: Node, titel: String, breite: float) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.custom_minimum_size = Vector2(breite, 0)
	var l := Label.new()
	l.text = titel
	l.add_theme_font_size_override("font_size", 15)
	l.add_theme_color_override("font_color", Color("f2c14e"))
	box.add_child(l)
	eltern.add_child(box)
	return box


func _auswahl(eintraege: Array, gewaehlt: int, aktion: Callable) -> OptionButton:
	var k := OptionButton.new()
	for e in eintraege:
		k.add_item(str(e))
	if not eintraege.is_empty():
		k.select(maxi(0, gewaehlt))
	k.custom_minimum_size = Vector2(220, 32)
	k.clip_text = true
	k.fit_to_longest_item = false
	k.add_theme_font_size_override("font_size", 14)
	k.focus_mode = Control.FOCUS_NONE
	k.item_selected.connect(aktion)
	return k


func _klein(text: String, breite := 220.0) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(breite, 32)
	b.add_theme_font_size_override("font_size", 14)
	b.focus_mode = Control.FOCUS_NONE
	b.clip_text = true
	return b
