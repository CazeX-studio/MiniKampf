class_name UiStil
## Bausteine aus dem Asterfall-UI-Set (assets/ui/), die über das Theme hinausgehen:
## Symbole, Banner an Fenstertiteln und Meldungen mit farbigem Rahmen.

const PFAD := "res://assets/ui/%s.png"
const BANNER := preload("res://assets/ui/banner.png")

## Meldungs-Rahmen: Name der Farbe -> Bild. Rechts sitzen Ranken, darum dort mehr Rand.
const MELDUNG_RAHMEN := {gold = "meldung_gold", gruen = "meldung_gruen", lila = "meldung_lila"}

const RUF_LEISTE := preload("res://assets/ui/ruf_leiste.png")
const RUF_FELD := preload("res://assets/ui/ruf_feld.png")
const TRENNLINIE := preload("res://assets/ui/trennlinie.png")
## Ränder der 11 Felder in ruf_leiste.png (x in Pixeln, das erste Feld ist etwas breiter)
const RUF_ZELLEN: Array[int] = [18, 48, 72, 96, 120, 144, 168, 192, 217, 241, 265, 289]
## Element (wie in Elements) -> Symbol
const ELEMENT_SYMBOLE := {
	"Feuer": "feuer", "Erde": "erde", "Pflanze": "pflanze", "Blitz": "blitz", "Wasser": "wasser", "Wind": "wind",
	"Licht": "licht", "Schatten": "schatten", "Sternenkraft": "sternenkraft",
}

static var _rahmen := {}
static var _symbole := {}


## Ruf-Leiste aus dem UI-Set mit 0 bis 11 grünen Feldern (die Mitte, 5–6 Felder, ist neutral).
static func ruf_leiste(gefuellt: int) -> Control:
	var leiste := Control.new()
	leiste.custom_minimum_size = Vector2(RUF_LEISTE.get_size())
	leiste.mouse_filter = Control.MOUSE_FILTER_IGNORE
	leiste.draw.connect(func() -> void:
		leiste.draw_texture(RUF_LEISTE, Vector2.ZERO)
		for i in clampi(gefuellt, 0, RUF_ZELLEN.size() - 1):
			var x0 := RUF_ZELLEN[i] + 1
			var x1 := RUF_ZELLEN[i + 1] - 1
			leiste.draw_texture_rect(RUF_FELD, Rect2(x0, 6, x1 - x0, 18), false))
	return leiste


## Goldene Trennlinie mit Diamant, mittig.
static func trennlinie() -> TextureRect:
	var linie := TextureRect.new()
	linie.texture = TRENNLINIE
	linie.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	linie.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return linie


## Symbol eines Elements ("" wenn es keins gibt).
static func element_symbol(element: String) -> Texture2D:
	return symbol(ELEMENT_SYMBOLE[element]) if ELEMENT_SYMBOLE.has(element) else null


## Rahmen fürs Bild der eigenen Figur (Werte).
static func bilderrahmen() -> StyleBoxTexture:
	if not _felder.has("bilderrahmen"):
		var style := StyleBoxTexture.new()
		style.texture = load(PFAD % "bilderrahmen")
		style.set_texture_margin_all(18)
		style.set_content_margin_all(8)
		_felder["bilderrahmen"] = style
	return _felder["bilderrahmen"]
static var _felder := {}


## Füllung einer Leiste aus dem UI-Set: "rot", "blau" oder "gruen".
static func fuellung(farbe: String) -> StyleBoxTexture:
	var key := "fuellung_" + farbe
	if not _felder.has(key):
		var style := StyleBoxTexture.new()
		style.texture = load(PFAD % key)
		style.texture_margin_left = 6
		style.texture_margin_right = 6
		style.texture_margin_top = 5
		style.texture_margin_bottom = 5
		_felder[key] = style
	return _felder[key]


## Kästchen aus dem UI-Set (Tasche, Zugleiste): normal oder golden leuchtend.
static func feld_stil(aktiv: bool) -> StyleBoxTexture:
	if not _felder.has(aktiv):
		var style := StyleBoxTexture.new()
		style.texture = load(PFAD % ("feld_aktiv" if aktiv else "feld"))
		style.set_texture_margin_all(12)
		style.set_content_margin_all(5)
		_felder[aktiv] = style
	return _felder[aktiv]


## Eines der 12 Symbole (gold, kristall, trank, schwert, schild, wirbel, tasche, schluessel,
## zahnrad, ausrufe, frage, pfeil) oder ein anderes Bild aus assets/ui/.
static func symbol(name: String) -> Texture2D:
	# Festhalten, damit ein nur gezeichnetes Bild (draw_texture) nicht gleich wieder freigegeben wird
	if not _symbole.has(name):
		var path := PFAD % ("symbol_" + name)
		_symbole[name] = load(path if ResourceLoader.exists(path) else PFAD % name)
	return _symbole[name]


## Symbol mitten im Text eines RichTextLabel (BBCode).
static func bild(name: String, groesse: int = 20) -> String:
	return "[img=%d]%s[/img]" % [groesse, symbol(name).resource_path]


## Fenstertitel mit dem roten Banner, das oben links über den Rahmen hängt.
static func titel_mit_banner(titel: Control) -> HBoxContainer:
	var reihe := HBoxContainer.new()
	reihe.add_theme_constant_override("separation", 10)
	reihe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var halter := Control.new()
	halter.custom_minimum_size = Vector2(42, 46)
	halter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var banner := TextureRect.new()
	banner.texture = BANNER
	banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	banner.position = Vector2(-6, -18)
	banner.size = Vector2(44, 75)
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	halter.add_child(banner)
	reihe.add_child(halter)
	titel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	reihe.add_child(titel)
	return reihe


## Kurze Meldung im Rahmen (gold, gruen oder lila), links ein Symbol (leer = ohne).
static func meldung(text: String, farbe: String, symbol_name: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _meldung_rahmen(farbe))
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var reihe := HBoxContainer.new()
	reihe.add_theme_constant_override("separation", 10)
	panel.add_child(reihe)
	if symbol_name != "":
		var icon := TextureRect.new()
		icon.texture = symbol(symbol_name)
		icon.custom_minimum_size = Vector2(32, 32)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		reihe.add_child(icon)
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 19)
	label.add_theme_color_override("font_color", Color("fff6dc"))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(minf(label.get_theme_font("font").get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 19).x + 4, 400), 0)
	reihe.add_child(label)
	return panel


static func _meldung_rahmen(farbe: String) -> StyleBoxTexture:
	if not _rahmen.has(farbe):
		var style := StyleBoxTexture.new()
		style.texture = load(PFAD % MELDUNG_RAHMEN.get(farbe, "meldung_gold"))
		style.texture_margin_left = 14
		style.texture_margin_top = 16
		style.texture_margin_right = 34
		style.texture_margin_bottom = 16
		style.content_margin_left = 14
		style.content_margin_top = 8
		style.content_margin_right = 34
		style.content_margin_bottom = 8
		_rahmen[farbe] = style
	return _rahmen[farbe]
