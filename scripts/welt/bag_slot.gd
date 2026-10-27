class_name BagSlot
extends Control
## Ein Kästchen der Tasche: zeigt einen Gegenstand mit Bild und Anzahl.
## Gegenstände lassen sich per Ziehen und Ablegen in ein anderes Kästchen verschieben (Maus oder Finger).
## Das Bild kommt aus data/gegenstaende.json unter "bild": {"form": "trank", "farbe": "d94848"}.

## Ein Gegenstand wurde von Kästchen "from" auf Kästchen "to" gezogen.
signal moved(from: int, to: int)
## Ein Kästchen wurde angeklickt (zeigt die Beschreibung).
signal picked(index: int)

const SIZE := 52.0
const SLOT := preload("res://assets/ui/feld.png")
const SLOT_SELECTED := preload("res://assets/ui/feld_aktiv.png")

static var _styles := {}

var index := 0
var item_id := ""
var count := 0
var selected := false


func _init() -> void:
	custom_minimum_size = Vector2(SIZE, SIZE)
	mouse_filter = Control.MOUSE_FILTER_STOP


func show_item(id: String, amount: int, is_selected: bool) -> void:
	item_id = id
	count = amount
	selected = is_selected
	tooltip_text = GameData.item_name(id) if id != "" else ""
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and item_id != "":
		picked.emit(index)


func _get_drag_data(_at_position: Vector2) -> Variant:
	if item_id == "":
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
	return data is Dictionary and data.has("tasche")


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	moved.emit(int(data.tasche), index)


static func _slot_style(is_selected: bool) -> StyleBoxTexture:
	if not _styles.has(is_selected):
		var style := StyleBoxTexture.new()
		style.texture = SLOT_SELECTED if is_selected else SLOT
		style.set_texture_margin_all(12)
		_styles[is_selected] = style
	return _styles[is_selected]


func _draw() -> void:
	# Kästchen aus dem UI-Set: normal oder golden leuchtend, wenn ausgewählt
	draw_style_box(_slot_style(selected), Rect2(Vector2.ZERO, size))
	if item_id == "":
		return
	var look: Dictionary = GameData.item(item_id).get("bild", {})
	draw_icon(self, size * 0.5 + Vector2(0, -2), str(look.get("form", "")), Color(str(look.get("farbe", "c8c8c8"))))
	if count > 1:
		var font := ThemeDB.fallback_font
		var text := str(count)
		var pos := Vector2(size.x - 4 - font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x, size.y - 4)
		draw_string_outline(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, 4, Color.BLACK)
		draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)


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
		_:
			# Unbekannt: kleines Säckchen
			node.draw_circle(c + Vector2(0, 4), 12.0, color)
			node.draw_rect(Rect2(c + Vector2(-5, -12), Vector2(10, 6)), color.darkened(0.2))
