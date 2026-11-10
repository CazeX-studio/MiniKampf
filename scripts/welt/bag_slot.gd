class_name BagSlot
extends Control
## Ein Kästchen der Tasche: zeigt einen Gegenstand mit Bild und Anzahl.
## Gegenstände lassen sich per Ziehen und Ablegen in ein anderes Kästchen verschieben (Maus oder Finger).
## Das Bild ist assets/gegenstaende/<Gegenstand>.png (oder "datei" unter "bild" in data/gegenstaende.json);
## gibt es keins, wird es gezeichnet: "bild": {"form": "trank", "farbe": "d94848"}.

## Ein Gegenstand wurde von Kästchen "from" auf Kästchen "to" gezogen.
signal moved(from: int, to: int)
## Ein Kästchen wurde angeklickt (zeigt die Beschreibung).
signal picked(index: int)

const SIZE := 52.0

var index := 0
var item_id := ""
var count := 0
var selected := false


## Geladene Symbole: Gegenstand -> Bild (null = keins)
static var _icons := {}


## Gürtelplatz: leer zeigt er die leere Lederschlaufe, man kann nichts hineinziehen
var belt := false
## Ausrüstungsplatz (A8b): nicht ziehen, leer steht der Name des Platzes blass im Kästchen
var platz_name := ""


func _init() -> void:
	custom_minimum_size = Vector2(SIZE, SIZE)
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Gemalte Symbole weich verkleinern (die gezeichneten Platzhalter sehen damit genauso aus)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS


func show_item(id: String, amount: int, is_selected: bool) -> void:
	item_id = id
	count = amount
	selected = is_selected
	tooltip_text = GameData.item_name(id) if id != "" else ""
	queue_redraw()


## Infofenster wie im UI-Entwurf: Bild im Kästchen, Name, Beschreibung und Preis.
func _make_custom_tooltip(_for_text: String) -> Object:
	if item_id == "":
		return null
	var item := GameData.item(item_id)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	box.add_child(head)
	var icon := BagSlot.new()
	icon.show_item(item_id, 1, false)
	head.add_child(icon)
	var title := Label.new()
	title.text = item.get("name", item_id)
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color("f2c14e"))
	head.add_child(title)
	var text := Label.new()
	text.text = item.get("beschreibung", "")
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(260, 0)
	text.add_theme_font_size_override("font_size", 15)
	box.add_child(text)
	if int(item.get("preis", 0)) > 0:
		var price := Label.new()
		price.text = "Wert: %s" % Geld.text(int(item.preis))
		price.add_theme_font_size_override("font_size", 13)
		price.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
		box.add_child(price)
	return box


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and (item_id != "" or platz_name != ""):
		picked.emit(index)


func _get_drag_data(_at_position: Vector2) -> Variant:
	if item_id == "" or belt or platz_name != "":
		return null
	# Vorschau unter dem Mauszeiger: dasselbe Bild etwas durchsichtig
	var preview := BagSlot.new()
	preview.show_item(item_id, count, false)
	preview.modulate.a = 0.8
	var holder := Control.new()
	holder.add_child(preview)
	preview.position = -Vector2(SIZE, SIZE) * 0.5
	set_drag_preview(holder)
	return {tasche = index}


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return not belt and platz_name == "" and data is Dictionary and data.has("tasche")


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	moved.emit(int(data.tasche), index)


func _draw() -> void:
	# Kästchen aus dem UI-Set: normal oder golden leuchtend, wenn ausgewählt
	draw_style_box(UiStil.feld_stil(selected), Rect2(Vector2.ZERO, size))
	if item_id == "":
		if platz_name != "":
			draw_string(ThemeDB.fallback_font, Vector2(0, size.y * 0.58), platz_name, HORIZONTAL_ALIGNMENT_CENTER, size.x, 12, Color(1, 1, 1, 0.35))
		if belt and icon_texture("guertel_platz") != null:
			draw_texture_rect(icon_texture("guertel_platz"), Rect2(Vector2(9, 9), size - Vector2(18, 18)), false, Color(1, 1, 1, 0.35))
		return
	var tex := icon_texture(item_id)
	if tex != null:
		# Gemaltes Symbol, weich verkleinert mit etwas Rand im Kästchen
		var rect := Rect2(Vector2(5, 5), size - Vector2(10, 10))
		draw_texture_rect(tex, rect, false)
	else:
		var look: Dictionary = GameData.item(item_id).get("bild", {})
		draw_icon(self, size * 0.5 + Vector2(0, -2), str(look.get("form", "")), Color(str(look.get("farbe", "c8c8c8"))))
	if count > 1:
		var font := ThemeDB.fallback_font
		var text := str(count)
		var pos := Vector2(size.x - 4 - font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x, size.y - 4)
		draw_string_outline(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, 4, Color.BLACK)
		draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)


## Gemaltes Symbol eines Gegenstands (assets/gegenstaende/, erstellt mit tools/gegenstand_bilder.py), null = keins.
static func icon_texture(id: String) -> Texture2D:
	# Festhalten, damit ein nur gezeichnetes Bild (draw_texture) nicht gleich wieder freigegeben wird
	if not _icons.has(id):
		var datei: String = GameData.item(id).get("bild", {}).get("datei", id)
		var path := "res://assets/gegenstaende/%s.png" % datei
		_icons[id] = load(path) if ResourceLoader.exists(path) else null
	return _icons[id]


## Kleines gezeichnetes Bild eines Gegenstands (Platzhalter, bis es echte Grafiken gibt).
static func draw_icon(node: CanvasItem, c: Vector2, form: String, color: Color) -> void:
	var dark := color.darkened(0.45)
	match form:
		"trank":
			node.draw_circle(c + Vector2(0, 5), 12.0, dark)
			node.draw_circle(c + Vector2(0, 5), 10.5, color)
			node.draw_rect(Rect2(c + Vector2(-4, -15), Vector2(8, 10)), Color("cfe6ef"))
			node.draw_rect(Rect2(c + Vector2(-5, -18), Vector2(10, 4)), Color("8a5a32"))
			node.draw_circle(c + Vector2(-4, 1), 3.0, Color(1, 1, 1, 0.55))
		"kraut":
			node.draw_line(c + Vector2(0, 16), c + Vector2(0, -6), dark, 2.0)
			for side: float in [-1.0, 1.0]:
				node.draw_colored_polygon(PackedVector2Array([c + Vector2(0, 6), c + Vector2(side * 14, -2),
						c + Vector2(side * 12, -10), c + Vector2(0, -2)]), color)
			node.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -2), c + Vector2(-6, -12), c + Vector2(0, -18), c + Vector2(6, -12)]), color.lightened(0.2))
		"splitter":
			var points := PackedVector2Array([c + Vector2(0, -18), c + Vector2(10, -2), c + Vector2(4, 17), c + Vector2(-9, 3)])
			node.draw_circle(c, 17.0, Color(color, 0.25))
			node.draw_colored_polygon(points, color)
			node.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -18), c + Vector2(10, -2), c + Vector2(0, 0)]), color.lightened(0.4))
		"wabe":
			for offset: Vector2 in [Vector2(-7, -6), Vector2(7, -6), Vector2(0, 6)]:
				var hexagon := PackedVector2Array()
				for i in 6:
					hexagon.append(c + offset + Vector2.from_angle(PI / 6.0 + i * PI / 3.0) * 8.0)
				node.draw_colored_polygon(hexagon, color)
				node.draw_polyline(hexagon + PackedVector2Array([hexagon[0]]), dark, 1.5)
		"schleuder":
			node.draw_line(c + Vector2(0, 17), c + Vector2(0, 0), color, 4.0)
			node.draw_line(c + Vector2(0, 0), c + Vector2(-10, -14), color, 4.0)
			node.draw_line(c + Vector2(0, 0), c + Vector2(10, -14), color, 4.0)
			node.draw_line(c + Vector2(-10, -14), c + Vector2(0, -4), Color("e8d8b0"), 1.5)
			node.draw_line(c + Vector2(10, -14), c + Vector2(0, -4), Color("e8d8b0"), 1.5)
		"korb":
			node.draw_arc(c + Vector2(0, -2), 12.0, PI, TAU, 16, dark, 3.0)
			node.draw_circle(c + Vector2(-5, -2), 5.0, Color("f2c14e"))
			node.draw_circle(c + Vector2(5, -3), 5.0, Color("e8c890"))
			node.draw_colored_polygon(PackedVector2Array([c + Vector2(-15, 0), c + Vector2(15, 0), c + Vector2(11, 15), c + Vector2(-11, 15)]), color)
			node.draw_line(c + Vector2(-13, 6), c + Vector2(13, 6), dark, 1.5)
		"buerste":
			node.draw_rect(Rect2(c + Vector2(-14, -8), Vector2(28, 10)), color)
			for i in 7:
				node.draw_line(c + Vector2(-12 + i * 4, 2), c + Vector2(-12 + i * 4, 12), Color("e8d8b0"), 2.0)
		"laterne":
			node.draw_circle(c, 15.0, Color(color, 0.3))
			node.draw_rect(Rect2(c + Vector2(-8, -9), Vector2(16, 20)), color)
			node.draw_rect(Rect2(c + Vector2(-10, -12), Vector2(20, 4)), dark)
			node.draw_rect(Rect2(c + Vector2(-10, 10), Vector2(20, 4)), dark)
			node.draw_arc(c + Vector2(0, -12), 5.0, PI, TAU, 8, dark, 2.0)
		"fleisch":
			node.draw_line(c + Vector2(6, 6), c + Vector2(15, 15), Color("efe6d0"), 4.0)
			node.draw_circle(c + Vector2(-2, -2), 12.0, color)
			node.draw_circle(c + Vector2(-5, -5), 5.0, color.lightened(0.25))
		"tafel":
			node.draw_rect(Rect2(c + Vector2(-16, -14), Vector2(32, 28)), dark)
			for x in 3:
				for y in 3:
					node.draw_rect(Rect2(c + Vector2(-13 + x * 9, -11 + y * 8), Vector2(7, 6)), color)
		"ruestung":
			# Brustpanzer: Rumpf mit Schulterstücken
			node.draw_rect(Rect2(c + Vector2(-10, -10), Vector2(20, 24)), dark)
			node.draw_rect(Rect2(c + Vector2(-9, -9), Vector2(18, 22)), color)
			node.draw_rect(Rect2(c + Vector2(-16, -12), Vector2(9, 8)), color.lightened(0.15))
			node.draw_rect(Rect2(c + Vector2(7, -12), Vector2(9, 8)), color.lightened(0.15))
			node.draw_line(c + Vector2(0, -8), c + Vector2(0, 12), dark, 2.0)
		"schwert", "dolch":
			# Klinge schräg von unten links nach oben rechts, Parierstange und Griff
			var laenge := 26.0 if form == "schwert" else 16.0
			var spitze := c + Vector2(laenge * 0.55, -laenge * 0.55)
			var ansatz := c + Vector2(-4, 4)
			node.draw_line(ansatz, spitze, dark, 6.0 if form == "schwert" else 4.5)
			node.draw_line(ansatz, spitze, color, 4.0 if form == "schwert" else 3.0)
			node.draw_line(c + Vector2(-10, -2), c + Vector2(2, 10), Color("8a6a2c"), 4.0)
			node.draw_line(ansatz, c + Vector2(-12, 12), Color("6e4a2c"), 4.0)
		"pfeil":
			# Pfeil schräg mit farbiger Spitze und Federn
			node.draw_line(c + Vector2(-13, 13), c + Vector2(10, -10), Color("8a6a44"), 3.0)
			node.draw_colored_polygon(PackedVector2Array([c + Vector2(15, -15), c + Vector2(6, -11), c + Vector2(11, -6)]), color)
			node.draw_line(c + Vector2(-13, 13), c + Vector2(-16, 6), Color("e8e8e8"), 2.0)
			node.draw_line(c + Vector2(-13, 13), c + Vector2(-6, 16), Color("e8e8e8"), 2.0)
		"kappe":
			node.draw_circle(c + Vector2(0, 4), 13.0, dark)
			node.draw_circle(c + Vector2(0, 4), 11.5, color)
			node.draw_rect(Rect2(c + Vector2(-15, 4), Vector2(30, 5)), color.darkened(0.2))
		"stiefel":
			for x: float in [-8.0, 7.0]:
				node.draw_rect(Rect2(c + Vector2(x - 4, -12), Vector2(8, 22)), dark)
				node.draw_rect(Rect2(c + Vector2(x - 3, -11), Vector2(6, 20)), color)
				node.draw_rect(Rect2(c + Vector2(x - 3, 6), Vector2(11, 6)), color.darkened(0.15))
		"kette":
			node.draw_arc(c + Vector2(0, -4), 12.0, 0.2, PI - 0.2, 16, dark, 2.0)
			node.draw_circle(c + Vector2(0, 10), 6.0, dark)
			node.draw_circle(c + Vector2(0, 10), 4.5, color)
		"garn":
			# Spule mit aufgewickeltem Garn und losem Faden
			node.draw_rect(Rect2(c + Vector2(-12, -14), Vector2(24, 5)), Color("8a6a44"))
			node.draw_rect(Rect2(c + Vector2(-12, 9), Vector2(24, 5)), Color("8a6a44"))
			node.draw_rect(Rect2(c + Vector2(-9, -9), Vector2(18, 18)), color)
			for i in 4:
				node.draw_line(c + Vector2(-9, -6 + i * 4), c + Vector2(9, -4 + i * 4), dark, 1.0)
			node.draw_line(c + Vector2(9, 4), c + Vector2(15, 14), color, 1.5)
		"flasche":
			# Schlanke Flasche mit Korken (Öl)
			node.draw_rect(Rect2(c + Vector2(-8, -4), Vector2(16, 20)), dark)
			node.draw_rect(Rect2(c + Vector2(-7, -3), Vector2(14, 18)), color)
			node.draw_rect(Rect2(c + Vector2(-3, -13), Vector2(6, 10)), Color("cfe6ef"))
			node.draw_rect(Rect2(c + Vector2(-4, -17), Vector2(8, 5)), Color("8a5a32"))
			node.draw_rect(Rect2(c + Vector2(-5, 0), Vector2(3, 10)), Color(1, 1, 1, 0.4))
		"leder":
			# Ausgebreitete Tierhaut
			var haut := PackedVector2Array([c + Vector2(-15, -10), c + Vector2(-6, -14), c + Vector2(0, -10), c + Vector2(6, -14),
					c + Vector2(15, -10), c + Vector2(12, 2), c + Vector2(15, 12), c + Vector2(4, 15), c + Vector2(-4, 15),
					c + Vector2(-15, 12), c + Vector2(-12, 2)])
			node.draw_colored_polygon(haut, color)
			node.draw_polyline(haut + PackedVector2Array([haut[0]]), dark, 1.5)
			node.draw_circle(c + Vector2(-3, -1), 4.0, color.lightened(0.15))
		"pilz":
			# Zwei Pilze mit Hut und Stiel
			for p: Array in [[Vector2(-6, 2), 10.0], [Vector2(7, 6), 7.0]]:
				var fuss: Vector2 = c + p[0]
				var r: float = p[1]
				node.draw_rect(Rect2(fuss + Vector2(-r * 0.3, 0), Vector2(r * 0.6, r * 1.1)), Color("efe6d0"))
				node.draw_arc(fuss, r, PI, TAU, 12, dark, 2.0)
				node.draw_colored_polygon(PackedVector2Array([fuss + Vector2(-r, 0), fuss + Vector2(-r * 0.7, -r * 0.7),
						fuss + Vector2(0, -r), fuss + Vector2(r * 0.7, -r * 0.7), fuss + Vector2(r, 0)]), color)
				node.draw_circle(fuss + Vector2(-r * 0.3, -r * 0.5), r * 0.18, Color(1, 1, 1, 0.7))
		"feder":
			# Feder schräg: Kiel und Fahne
			var spitze := c + Vector2(12, -15)
			var ende := c + Vector2(-11, 14)
			var quer := (spitze - ende).normalized().orthogonal()
			node.draw_colored_polygon(PackedVector2Array([ende.lerp(spitze, 0.25), spitze + quer * 2.0,
					ende.lerp(spitze, 0.6) + quer * 7.0, ende.lerp(spitze, 0.3) + quer * 4.0]), color)
			node.draw_colored_polygon(PackedVector2Array([ende.lerp(spitze, 0.25), spitze - quer * 2.0,
					ende.lerp(spitze, 0.6) - quer * 6.0, ende.lerp(spitze, 0.3) - quer * 3.0]), color.darkened(0.15))
			node.draw_line(ende, spitze, dark, 1.5)
		"fell":
			# Fellstück mit Zotteln
			node.draw_circle(c + Vector2(-4, 0), 11.0, color)
			node.draw_circle(c + Vector2(6, 3), 9.0, color)
			for i in 6:
				var a := float(i) / 6.0 * TAU
				node.draw_line(c + Vector2.from_angle(a) * 9.0, c + Vector2.from_angle(a) * 15.0, dark, 2.0)
			node.draw_circle(c + Vector2(-6, -3), 3.0, color.lightened(0.25))
		"stein":
			node.draw_circle(c + Vector2(0, 3), 11.0, dark)
			node.draw_circle(c + Vector2(-1, 1), 10.0, color)
			node.draw_circle(c + Vector2(-4, -2), 3.5, color.lightened(0.3))
		_:
			# Unbekannt: kleines Säckchen
			node.draw_circle(c + Vector2(0, 4), 12.0, color)
			node.draw_rect(Rect2(c + Vector2(-5, -12), Vector2(10, 6)), color.darkened(0.2))
