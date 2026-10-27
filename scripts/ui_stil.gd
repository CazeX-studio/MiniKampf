class_name UiStil
## Bausteine aus dem Asterfall-UI-Set (assets/ui/), die über das Theme hinausgehen:
## Symbole, Banner an Fenstertiteln und Meldungen mit farbigem Rahmen.

const PFAD := "res://assets/ui/%s.png"
const BANNER := preload("res://assets/ui/banner.png")

## Meldungs-Rahmen: Name der Farbe -> Bild. Rechts sitzen Ranken, darum dort mehr Rand.
const MELDUNG_RAHMEN := {gold = "meldung_gold", gruen = "meldung_gruen", lila = "meldung_lila"}

static var _rahmen := {}


## Eines der 12 Symbole (gold, kristall, trank, schwert, schild, wirbel, tasche, schluessel,
## zahnrad, ausrufe, frage, pfeil) oder ein anderes Bild aus assets/ui/.
static func symbol(name: String) -> Texture2D:
	var path := PFAD % ("symbol_" + name)
	return load(path if ResourceLoader.exists(path) else PFAD % name)


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
