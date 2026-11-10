class_name FaehigkeitenBaum
extends VBoxContainer
## Fähigkeiten-Baum wie in World of Warcraft (A8a, Alpha-Punkt 26): Jede Fähigkeit ist ein Feld mit Symbol und Stufe,
## die Reihen gehen von oben nach unten (frei ab Klassenstufe 1, 10, 20, 30), Linien führen von einer Fähigkeit zu der,
## die sie voraussetzt. Drüberfahren zeigt den Namen, Antippen zeigt unten die Beschreibung mit „Lernen“ und
## „Auf die Leiste“. Die Bilder liegen unter assets/faehigkeiten/<klasse>_<fähigkeit>.png, bis dahin malt das Spiel
## einen Platzhalter (Anfangsbuchstaben, Farbe nach Art).

const FELD := Vector2(76, 76)
const BILD := "res://assets/faehigkeiten/%s_%s.png"
const FARBE_AKTIV := Color("8a5a1c")
const FARBE_PASSIV := Color("2f5a7a")
const FARBE_GRUND := Color("4a6a3a")
const RAHMEN := Color("f2c14e")
const GESPERRT := Color(0.35, 0.35, 0.35)
const LINIE := Color(0.95, 0.8, 0.4, 0.8)

## Gewählte Fähigkeit (bleibt, wenn das Fenster neu gefüllt wird)
static var gewaehlt := ""

var _progress: Progress
var _klasse := ""
var _senden: Callable
var _neu: Callable
var _felder := {}
var _baum_flaeche: Control


## Baut den Baum. senden: Befehl an die Welt (wie im Spiel), neu: Fenster neu füllen.
func bauen(p: Progress, senden: Callable, neu: Callable) -> void:
	_progress = p
	_klasse = p.battle_class()
	_senden = senden
	_neu = neu
	add_theme_constant_override("separation", 6)
	var baum := Faehigkeiten.baum(_klasse)
	if gewaehlt != "_grund" and Faehigkeiten.eintrag(_klasse, gewaehlt).is_empty():
		gewaehlt = ""
	add_child(_text(GameData.text("faehigkeiten_kopf", [p.klassenstufe(), p.freie_punkte()]), 17, RAHMEN))
	_leiste_bauen()
	# Der Baum: Linien liegen hinter den Feldern (eigene Fläche, die nach dem Anordnen zeichnet)
	_baum_flaeche = Control.new()
	_baum_flaeche.mouse_filter = Control.MOUSE_FILTER_PASS
	_baum_flaeche.draw.connect(_linien_zeichnen)
	var spalte := VBoxContainer.new()
	spalte.add_theme_constant_override("separation", 10)
	_baum_flaeche.add_child(spalte)
	spalte.resized.connect(func() -> void:
		_baum_flaeche.custom_minimum_size = spalte.size
		_baum_flaeche.queue_redraw())
	add_child(_baum_flaeche)
	var grund: Dictionary = baum.get("grundreihe", {})
	if not grund.is_empty():
		var zeile := _reihe(spalte, GameData.text("faehigkeiten_grundreihe"), true)
		zeile.add_child(_feld({id = "_grund", name = grund.name, info = grund.get("info", ""), grund = true}))
	var reihen := {}
	for f: Dictionary in baum.get("faehigkeiten", []):
		var r := int(f.reihe)
		if not reihen.has(r):
			var frei := p.klassenstufe() >= Faehigkeiten.reihe_ab(r)
			reihen[r] = _reihe(spalte, GameData.text("faehigkeiten_reihe", [r, Faehigkeiten.reihe_ab(r)]), frei)
		reihen[r].add_child(_feld(f))
	_beschreibung_bauen()
	var preis := Faehigkeiten.preis_neu_verteilen(p)
	add_child(_knopf(GameData.text("faehigkeiten_neu_verteilen", [GameData.text("faehigkeiten_kostenlos") if preis == 0 else Geld.text(preis)]),
			260, func() -> void: _senden.call({type = "neu_verteilen"})))


## Bild einer Fähigkeit (null = noch keins, dann malt das Feld einen Platzhalter).
static func bild(klasse: String, id: String) -> Texture2D:
	var pfad := BILD % [klasse, id]
	return load(pfad) if ResourceLoader.exists(pfad) else null


func _reihe(eltern: Node, titel: String, frei: bool) -> HBoxContainer:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	var name := _text(titel, 13, Color("f3ead8") if frei else Color("808080"))
	name.custom_minimum_size = Vector2(120, 0)
	name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.add_child(name)
	eltern.add_child(box)
	return box


func _feld(f: Dictionary) -> Button:
	var b := Button.new()
	b.custom_minimum_size = FELD
	b.flat = true
	b.focus_mode = Control.FOCUS_NONE
	b.tooltip_text = "%s%s" % [f.name, " (passiv)" if f.get("passiv", false) else ""]
	var id: String = f.id
	b.draw.connect(func() -> void: _feld_zeichnen(b, f))
	b.pressed.connect(func() -> void:
		gewaehlt = id
		_neu.call())
	_felder[id] = b
	return b


## Ein Feld: Rahmen (gelb = gewählt), Bild oder Platzhalter, unten die Stufe. Gesperrte und ungelernte Felder sind blasser.
func _feld_zeichnen(b: Button, f: Dictionary) -> void:
	var r := Rect2(Vector2.ZERO, b.size)
	var grund := bool(f.get("grund", false))
	var stufe := 1 if grund else int(_progress.faehigkeiten.get(f.id, 0))
	var frei := grund or _progress.klassenstufe() >= Faehigkeiten.reihe_ab(int(f.get("reihe", 1)))
	var farbe := FARBE_GRUND if grund else (FARBE_PASSIV if f.get("passiv", false) else FARBE_AKTIV)
	if not frei:
		farbe = GESPERRT
	var tex := bild(_klasse, f.id)
	var innen := r.grow(-4)
	b.draw_rect(r, Color(0.05, 0.05, 0.08))
	if tex != null:
		b.draw_texture_rect(tex, innen, false, Color.WHITE if stufe > 0 else Color(0.55, 0.55, 0.55))
	else:
		b.draw_rect(innen, farbe if stufe > 0 else farbe.darkened(0.45))
		var kurz := ""
		for wort: String in str(f.name).split(" ", false):
			kurz += wort.substr(0, 1)
		var schrift := b.get_theme_default_font()
		b.draw_string(schrift, Vector2(0, r.size.y * 0.55), kurz.substr(0, 3), HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 24,
				Color(1, 1, 1, 0.9 if stufe > 0 else 0.5))
	b.draw_rect(r, RAHMEN if f.id == gewaehlt else Color(0.6, 0.5, 0.3, 0.7), false, 3.0 if f.id == gewaehlt else 1.5)
	if not grund:
		var text := "%d/%d" % [stufe, int(f.get("max", 5))]
		var schrift := b.get_theme_default_font()
		b.draw_rect(Rect2(r.size.x - 34, r.size.y - 18, 32, 16), Color(0, 0, 0, 0.7))
		b.draw_string(schrift, Vector2(r.size.x - 34, r.size.y - 5), text, HORIZONTAL_ALIGNMENT_CENTER, 32, 12, Color.WHITE)


## Linien von einer Fähigkeit zu der, die sie voraussetzt (unten an der einen, oben an der anderen)
func _linien_zeichnen() -> void:
	for f: Dictionary in Faehigkeiten.baum(_klasse).get("faehigkeiten", []):
		var braucht: Dictionary = f.get("braucht", {})
		for andere: String in braucht:
			if not _felder.has(andere) or not _felder.has(f.id):
				continue
			var von: Rect2 = _felder[andere].get_global_rect()
			var nach: Rect2 = _felder[f.id].get_global_rect()
			var ursprung := _baum_flaeche.get_global_rect().position
			var a := Vector2(von.get_center().x, von.end.y) - ursprung
			var b := Vector2(nach.get_center().x, nach.position.y) - ursprung
			var erfuellt := int(_progress.faehigkeiten.get(andere, 0)) >= int(braucht[andere])
			_baum_flaeche.draw_line(a, b, LINIE if erfuellt else Color(0.6, 0.6, 0.6, 0.5), 3.0)


## Die feste Leiste: sechs Plätze mit Bild, Antippen nimmt die Fähigkeit herunter
func _leiste_bauen() -> void:
	add_child(_text(GameData.text("leiste_titel"), 14, Color("f3ead8")))
	var zeile := HBoxContainer.new()
	zeile.add_theme_constant_override("separation", 6)
	for i in _progress.leiste.size():
		var id := str(_progress.leiste[i])
		var f := Faehigkeiten.eintrag(_klasse, id)
		var platz := Button.new()
		platz.custom_minimum_size = Vector2(52, 52)
		platz.flat = true
		platz.focus_mode = Control.FOCUS_NONE
		platz.tooltip_text = str(f.get("name", "Leer"))
		var nummer := i
		platz.draw.connect(func() -> void:
			var r := Rect2(Vector2.ZERO, platz.size)
			platz.draw_rect(r, Color(0.05, 0.05, 0.08))
			if not f.is_empty():
				var tex := bild(_klasse, id)
				if tex != null:
					platz.draw_texture_rect(tex, r.grow(-3), false)
				else:
					platz.draw_rect(r.grow(-3), FARBE_AKTIV)
					platz.draw_string(platz.get_theme_default_font(), Vector2(0, r.size.y * 0.6), str(f.name).substr(0, 2),
							HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 18, Color.WHITE)
			platz.draw_rect(r, Color(0.6, 0.5, 0.3, 0.8), false, 1.5)
			platz.draw_string(platz.get_theme_default_font(), Vector2(3, 13), str(nummer + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, RAHMEN))
		platz.pressed.connect(func() -> void:
			if id != "":
				_senden.call({type = "leiste", faehigkeit = id, platz = nummer})
				_neu.call())
		zeile.add_child(platz)
	add_child(zeile)


## Beschreibung der gewählten Fähigkeit mit „Lernen“ und „Auf die Leiste“
func _beschreibung_bauen() -> void:
	var f := Faehigkeiten.eintrag(_klasse, gewaehlt)
	if gewaehlt == "_grund":
		var grund: Dictionary = Faehigkeiten.baum(_klasse).get("grundreihe", {})
		f = {name = grund.get("name", ""), info = grund.get("info", "")}
	if f.is_empty():
		add_child(_text(GameData.text("faehigkeiten_antippen"), 14, Color("c8c8c8")))
		return
	var stufe := int(_progress.faehigkeiten.get(gewaehlt, 0))
	var text := "[b]%s[/b]%s" % [f.name, " (passiv)" if f.get("passiv", false) else ""]
	if gewaehlt != "_grund":
		text += "  ·  Stufe %d / %d" % [stufe, int(f.get("max", 5))]
	var braucht: Dictionary = f.get("braucht", {})
	for andere: String in braucht:
		text += "  [color=#a0a0a0]braucht %s %d[/color]" % [Faehigkeiten.eintrag(_klasse, andere).get("name", andere), int(braucht[andere])]
	text += "\n[color=#c8c8c8]%s[/color]" % str(f.get("info", ""))
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.text = text
	label.add_theme_font_size_override("normal_font_size", 14)
	label.add_theme_font_size_override("bold_font_size", 15)
	add_child(label)
	if gewaehlt == "_grund":
		return
	var knoepfe := HBoxContainer.new()
	knoepfe.add_theme_constant_override("separation", 8)
	var grund_gegen := Faehigkeiten.grund_gegen(_progress, gewaehlt)
	var id := gewaehlt
	var lernen := _knopf(GameData.text("faehigkeiten_lernen") if grund_gegen == "" else grund_gegen, 200,
			func() -> void: _senden.call({type = "lernen", faehigkeit = id}))
	lernen.disabled = grund_gegen != ""
	knoepfe.add_child(lernen)
	if Faehigkeiten.fuer_leiste(_progress, id):
		var drauf: bool = id in _progress.leiste
		knoepfe.add_child(_knopf(GameData.text("leiste_runter" if drauf else "leiste_drauf"), 150,
				func() -> void: _senden.call({type = "leiste", faehigkeit = id, platz = -1})))
	add_child(knoepfe)


func _text(text: String, groesse: int, farbe: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", groesse)
	l.add_theme_color_override("font_color", farbe)
	return l


func _knopf(text: String, breite: float, aktion: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(breite, 32)
	b.add_theme_font_size_override("font_size", 14)
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(func() -> void:
		aktion.call()
		_neu.call())
	return b
