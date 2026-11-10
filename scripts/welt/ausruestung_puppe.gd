class_name AusruestungPuppe
extends VBoxContainer
## Ausrüstung als Plätze mit Bildern (A8b, Alpha-Punkt 27): in der Mitte die eigene Figur, links Kopf, Körper und Schuhe,
## rechts Waffe und zwei Schmuckplätze, wie in klassischen Rollenspielen. Antippen zeigt darunter Name, Werte und
## „Ablegen“. Die Bilder sind die der Gegenstände (assets/gegenstaende/, sonst gezeichnet wie in der Tasche).

const LINKS := ["kopf", "koerper", "schuhe"]
const RECHTS := ["waffe", "schmuck1", "schmuck2"]
const PLATZ := 64.0

## Gewählter Platz (bleibt, wenn das Fenster neu gefüllt wird)
static var gewaehlt := ""

var _plaetze := {}


## look: Aussehen der eigenen Figur, senden: Befehl an die Welt, neu: Fenster neu füllen
func bauen(p: Progress, look: String, senden: Callable, neu: Callable) -> void:
	add_theme_constant_override("separation", 8)
	var angelegt: Dictionary = p.ausruestung
	var zeile := HBoxContainer.new()
	zeile.add_theme_constant_override("separation", 18)
	zeile.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(zeile)
	zeile.add_child(_spalte(LINKS, angelegt, neu))
	var figur := TextureRect.new()
	figur.texture = FighterView.einzelbild(look, "idle", 0)
	figur.custom_minimum_size = Vector2(150, 3 * PLATZ + 2 * 22)
	figur.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	figur.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	figur.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	zeile.add_child(figur)
	zeile.add_child(_spalte(RECHTS, angelegt, neu))
	# Beschreibung des gewählten Platzes
	if gewaehlt != "" and _plaetze.has(gewaehlt):
		var id := str(angelegt.get(gewaehlt, ""))
		var text := RichTextLabel.new()
		text.bbcode_enabled = true
		text.fit_content = true
		text.scroll_active = false
		text.add_theme_font_size_override("normal_font_size", 15)
		text.text = "%s: %s  [color=#a0a0a0]%s[/color]" % [Ausruestung.PLATZ_NAMEN[gewaehlt], Ausruestung.name_farbig(id), Ausruestung.werte_text(id)] \
				if id != "" else "%s: [color=#707070]%s[/color]" % [Ausruestung.PLATZ_NAMEN[gewaehlt], GameData.text("ausruestung_leer")]
		add_child(text)
		if id != "":
			var platz := gewaehlt
			var knopf := Button.new()
			knopf.text = GameData.text("ablegen")
			knopf.custom_minimum_size = Vector2(120, 30)
			knopf.focus_mode = Control.FOCUS_NONE
			knopf.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			knopf.pressed.connect(func() -> void:
				senden.call({type = "ablegen", platz = platz})
				neu.call())
			add_child(knopf)
	else:
		var hinweis := Label.new()
		hinweis.text = GameData.text("ausruestung_antippen")
		hinweis.add_theme_font_size_override("font_size", 14)
		hinweis.add_theme_color_override("font_color", Color("a0a0a0"))
		add_child(hinweis)


func _spalte(plaetze: Array, angelegt: Dictionary, neu: Callable) -> VBoxContainer:
	var spalte := VBoxContainer.new()
	spalte.add_theme_constant_override("separation", 4)
	for platz: String in plaetze:
		var feld := BagSlot.new()
		feld.custom_minimum_size = Vector2(PLATZ, PLATZ)
		feld.platz_name = Ausruestung.PLATZ_NAMEN[platz]
		feld.show_item(str(angelegt.get(platz, "")), 1, platz == gewaehlt)
		if str(angelegt.get(platz, "")) == "":
			feld.tooltip_text = Ausruestung.PLATZ_NAMEN[platz]
		var name := platz
		feld.picked.connect(func(_i: int) -> void:
			gewaehlt = name
			neu.call())
		spalte.add_child(feld)
		var unter := Label.new()
		unter.text = Ausruestung.PLATZ_NAMEN[platz]
		unter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		unter.add_theme_font_size_override("font_size", 12)
		unter.add_theme_color_override("font_color", Color("c8c8c8"))
		spalte.add_child(unter)
		_plaetze[platz] = feld
	return spalte
