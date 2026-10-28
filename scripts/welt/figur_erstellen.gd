class_name FigurErstellen
extends Control
## Figur erstellen (Projekt 11, Schritt 5): Zu Beginn eines neuen Spiels Körper (männlich/weiblich) und Kopf wählen und
## einen Namen eingeben. Die Figur wird als „Körper+Kopf“ gespeichert (z. B. „novize_w+mira“, siehe FigurTeile).
## Später kommen Frisuren dazu (Ideen-Parkplatz in design.md).

const SCREEN := Vector2(1280, 720)
const KOERPER: Array[String] = ["novize_m", "novize_w"]
const KOERPER_NAMEN := {"novize_m": "Männlich", "novize_w": "Weiblich"}
const NAME_LAENGE := 16
## Vorschau: Bewegung, Überschrift
const VORSCHAU: Array = [["idle_vorn", "In der Welt"], ["run_vorn", "Laufen"], ["idle", "Im Kampf"], ["attack", "Angriff"]]
const BILDER_PRO_SEKUNDE := 7.0

## Wohin „Zurück“ führt (der Editor setzt das auf sich selbst)
static var zurueck_zu := "res://scenes/menu.tscn"

var _koerper := "novize_m"
var _kopf := ""
var _name_feld: LineEdit
var _los: Button
var _kopf_text: Label
var _koerper_knoepfe := {}
var _vorschau: Array[Sprite2D] = []
var _bilder: Array = []
var _zeit := 0.0


func _ready() -> void:
	theme = Combat.make_theme()
	add_child(Backdrop.new())
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.05, 0.7)
	shade.size = SCREEN
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	_kopf = FigurTeile.koepfe(_koerper).keys()[0]

	var titel := _label("Figur erstellen", 44, Color("f2c14e"), Vector2(0, 24), SCREEN.x)
	titel.add_theme_color_override("font_outline_color", Color.BLACK)
	titel.add_theme_constant_override("outline_size", 8)
	_label("Alle beginnen als Novize. Kleidung und Waffe kommen später mit der Klasse.", 18, Color.WHITE, Vector2(0, 84), SCREEN.x)

	# Vorschau: vier Bewegungen nebeneinander
	for i in VORSCHAU.size():
		var x := 110.0 + i * 190.0
		_label(VORSCHAU[i][1], 18, Color("cfd8e3"), Vector2(x - 80, 470), 160)
		var bild := Sprite2D.new()
		bild.position = Vector2(x, 450)
		bild.centered = false
		add_child(bild)
		_vorschau.append(bild)

	# Rechts: Auswahl
	var panel := PanelContainer.new()
	panel.position = Vector2(860, 140)
	panel.custom_minimum_size = Vector2(380, 0)
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)

	box.add_child(_ueberschrift("Körper"))
	var reihe := HBoxContainer.new()
	reihe.add_theme_constant_override("separation", 8)
	box.add_child(reihe)
	for k: String in KOERPER:
		var knopf := _knopf(KOERPER_NAMEN[k], Vector2(170, 44))
		knopf.toggle_mode = true
		knopf.pressed.connect(func() -> void: _waehle_koerper(k))
		reihe.add_child(knopf)
		_koerper_knoepfe[k] = knopf

	box.add_child(_ueberschrift("Kopf"))
	var kopf_reihe := HBoxContainer.new()
	kopf_reihe.add_theme_constant_override("separation", 8)
	box.add_child(kopf_reihe)
	var links := _knopf("◀", Vector2(54, 44))
	links.pressed.connect(func() -> void: _blaettern(-1))
	kopf_reihe.add_child(links)
	_kopf_text = Label.new()
	_kopf_text.custom_minimum_size = Vector2(230, 44)
	_kopf_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_kopf_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_kopf_text.add_theme_font_size_override("font_size", 22)
	kopf_reihe.add_child(_kopf_text)
	var rechts := _knopf("▶", Vector2(54, 44))
	rechts.pressed.connect(func() -> void: _blaettern(1))
	kopf_reihe.add_child(rechts)

	box.add_child(_ueberschrift("Name"))
	_name_feld = LineEdit.new()
	_name_feld.max_length = NAME_LAENGE
	_name_feld.placeholder_text = "Wie heißt du?"
	_name_feld.custom_minimum_size = Vector2(0, 48)
	_name_feld.add_theme_font_size_override("font_size", 22)
	_name_feld.text_changed.connect(func(_t: String) -> void: _pruefen())
	_name_feld.text_submitted.connect(func(_t: String) -> void: _starten())
	box.add_child(_name_feld)

	_los = _knopf("Los geht's", Vector2(0, 56))
	_los.add_theme_font_size_override("font_size", 24)
	_los.pressed.connect(_starten)
	box.add_child(_los)
	var zurueck := _knopf("Zurück", Vector2(0, 44))
	zurueck.pressed.connect(func() -> void: get_tree().change_scene_to_file(zurueck_zu))
	box.add_child(zurueck)

	_waehle_koerper(_koerper)
	_pruefen()
	_name_feld.grab_focus.call_deferred()


func _process(delta: float) -> void:
	_zeit += delta
	for i in _vorschau.size():
		var bilder: Array = _bilder[i]
		if bilder.is_empty():
			continue
		var textur: Texture2D = bilder[int(_zeit * BILDER_PRO_SEKUNDE) % bilder.size()]
		var bild := _vorschau[i]
		bild.texture = textur
		# Füße unten in der Mitte, alle Bilder gleich groß wie im Spiel (fein gezeichnet, also weich verkleinert)
		var groesse := 1.15 * 3.0 / FighterView.fein_faktor(textur)
		bild.scale = Vector2(groesse, groesse)
		bild.texture_filter = FighterView.filter_fuer(textur)
		bild.offset = Vector2(-textur.get_width() * 0.5, -textur.get_height())


## Das gewählte Aussehen, so wie es gespeichert wird.
func aussehen() -> String:
	return "%s+%s" % [_koerper, _kopf]


func _waehle_koerper(k: String) -> void:
	_koerper = k
	for name: String in _koerper_knoepfe:
		_koerper_knoepfe[name].button_pressed = name == k
	_aktualisieren()


func _blaettern(schritt: int) -> void:
	var ids: Array = FigurTeile.koepfe(_koerper).keys()
	_kopf = ids[(ids.find(_kopf) + schritt + ids.size()) % ids.size()]
	_aktualisieren()


func _aktualisieren() -> void:
	_kopf_text.text = FigurTeile.koepfe(_koerper)[_kopf].name
	_bilder.clear()
	for v: Array in VORSCHAU:
		var bilder: Array = []
		var i := 0
		while ResourceLoader.exists(FighterView.sprite_path(_koerper, v[0], i)):
			bilder.append(FighterView.einzelbild(aussehen(), v[0], i))
			i += 1
		_bilder.append(bilder)


func _pruefen() -> void:
	_los.disabled = _name_feld.text.strip_edges() == ""


func _starten() -> void:
	var name := _name_feld.text.strip_edges()
	if name == "":
		return
	FigurWahl.neue_figur = {aussehen = aussehen(), name = name}
	get_tree().change_scene_to_file("res://scenes/kreuzweg.tscn")


func _label(text: String, size: int, color: Color, pos: Vector2, width: float) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.position = pos
	l.size = Vector2(width, size + 16)
	add_child(l)
	return l


func _ueberschrift(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 20)
	l.add_theme_color_override("font_color", Color("f2c14e"))
	return l


func _knopf(text: String, groesse: Vector2) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = groesse
	b.add_theme_font_size_override("font_size", 20)
	b.focus_mode = Control.FOCUS_NONE
	return b
