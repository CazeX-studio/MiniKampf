class_name FighterView
extends Control
## Zeichnet einen Kampfteilnehmer als einfache Form mit Leisten (Platzhalter-Grafik).
## Antippen (Maus oder Finger) meldet den Teilnehmer, z. B. um ihn als Ziel zu wählen.

signal tapped(fighter: Fighter)

const COL_BG := Color("232638")
const COL_HP := Color("4cc46a")
const COL_HP_LOW := Color("e0533d")
const COL_MANA := Color("4a8cf0")
const COL_BLOOD := Color("a8243a")
const COL_ULT := Color("f2c14e")
const COL_RES_OFF := Color("ff8a3d")
const COL_RES_DEF := Color("6fe0ff")

var fighter: Fighter
## Ist gerade am Zug (goldener Rahmen).
var active := false
## Kann gerade als Ziel gewählt werden (blinkender Rahmen).
var targetable := false

var _time := 0.0
var _box := StyleBoxFlat.new()


func setup(p_fighter: Fighter, p_size: Vector2) -> void:
	fighter = p_fighter
	size = p_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	_box.set_corner_radius_all(10)


func _process(delta: float) -> void:
	_time += delta
	modulate.a = 1.0 if fighter.is_alive() else 0.4
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tapped.emit(fighter)
		accept_event()


func center() -> Vector2:
	return position + size * 0.5


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var alive := fighter.is_alive()

	# Karte mit Rahmen
	_box.bg_color = COL_BG
	var pulse := 0.5 + 0.5 * sin(_time * 7.0)
	if active:
		_box.border_color = COL_ULT
		_box.set_border_width_all(4)
	elif targetable:
		_box.border_color = Color(0.4, 1.0, 1.0, 0.4 + 0.6 * pulse)
		_box.set_border_width_all(4)
	else:
		_box.border_color = Color(1, 1, 1, 0.15)
		_box.set_border_width_all(1)
	draw_style_box(_box, Rect2(Vector2.ZERO, size))

	# Form links
	var radius := minf(size.y * 0.3, 46.0)
	var shape_center := Vector2(radius + 14.0, size.y * 0.5)
	_draw_shape(shape_center, radius, fighter.color if alive else Color.DIM_GRAY)

	# Text und Leisten rechts
	var x0 := radius * 2.0 + 26.0
	var w := size.x - x0 - 10.0
	draw_string(font, Vector2(x0, 19), fighter.display_name, HORIZONTAL_ALIGNMENT_LEFT, w, 16, Color.WHITE)
	if fighter.is_hero:
		draw_string(font, Vector2(x0, 19), fighter.row_name(), HORIZONTAL_ALIGNMENT_RIGHT, w, 11, Color(1, 1, 1, 0.55))
	draw_string(font, Vector2(4, size.y - 6), fighter.class_title, HORIZONTAL_ALIGNMENT_CENTER, x0 - 8, 9, Color(1, 1, 1, 0.6))

	var hp_ratio := float(fighter.hp) / fighter.max_hp
	_draw_bar(Rect2(x0, 25, w, 15), hp_ratio, COL_HP if hp_ratio > 0.3 else COL_HP_LOW, "%d / %d" % [fighter.hp, fighter.max_hp])

	if not alive:
		draw_string(font, Vector2(x0, 62), "besiegt", HORIZONTAL_ALIGNMENT_LEFT, w, 15, Color.WHITE)
		return

	if fighter.is_hero:
		_draw_hero_details(font, x0, w)
	else:
		_draw_enemy_details(font, x0, w)


func _draw_hero_details(font: Font, x0: float, w: float) -> void:
	match fighter.klass:
		"ritualist":
			_draw_bar(Rect2(x0, 44, w, 11), float(fighter.blood) / Fighter.MAX_BLOOD, COL_BLOOD, "Blut %d" % fighter.blood)
		_:
			_draw_bar(Rect2(x0, 44, w, 11), float(fighter.mana) / fighter.max_mana, COL_MANA, "Mana %d" % fighter.mana)

	var status: Array[String] = []
	if fighter.klass == "singer":
		_draw_pips(Vector2(x0, 64), fighter.res_off, COL_RES_OFF)
		_draw_pips(Vector2(x0 + w * 0.5 + 4, 64), fighter.res_def, COL_RES_DEF)
	if fighter.shield > 0:
		status.append("Schild %d" % fighter.shield)
	if fighter.taunt > 0:
		status.append("Bann %d" % fighter.taunt)
	if fighter.fortress:
		status.append("FESTUNG")
	if fighter.charged:
		status.append("GESPANNT")
	if fighter.atk_buff_turns > 0:
		status.append("Angriff+")
	if fighter.def_buff_turns > 0:
		status.append("Abwehr+")
	var status_y := 80.0 if fighter.klass == "singer" else 70.0
	draw_string(font, Vector2(x0, status_y), "  ".join(status), HORIZONTAL_ALIGNMENT_LEFT, w, 11, Color("ffe08a"))

	# Ult-Leiste
	var ult_ratio := fighter.ult / Fighter.MAX_ULT
	var ult_color := COL_ULT
	if fighter.ult_ready():
		ult_color = COL_ULT.lerp(Color.WHITE, 0.5 + 0.5 * sin(_time * 8.0))
	var ult_text := "ULT bereit!" if fighter.ult_ready() else "ULT %d %%" % int(fighter.ult)
	_draw_bar(Rect2(x0, size.y - 16, w, 11), ult_ratio, ult_color, ult_text)


func _draw_enemy_details(font: Font, x0: float, w: float) -> void:
	var y := 58.0
	if fighter.enraged:
		draw_string(font, Vector2(x0, y), "WUT!", HORIZONTAL_ALIGNMENT_LEFT, w, 13, COL_HP_LOW)
		y += 16
	if fighter.intent != "":
		draw_multiline_string(font, Vector2(x0, y), fighter.intent, HORIZONTAL_ALIGNMENT_LEFT, w, 12, -1, Color("ffd36b"))


func _draw_bar(rect: Rect2, ratio: float, color: Color, text: String) -> void:
	draw_rect(rect, Color(0, 0, 0, 0.5))
	draw_rect(Rect2(rect.position, Vector2(rect.size.x * clampf(ratio, 0, 1), rect.size.y)), color)
	if text != "":
		var font_size := 11 if rect.size.y < 14 else 12
		var text_color := Color.BLACK if ratio > 0.5 and color.v > 0.9 else Color.WHITE
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(4, rect.size.y - 2), text, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 6, font_size, text_color)


## Fünf Punkte für ein Sternbild der Sternensängerin.
func _draw_pips(origin: Vector2, filled: int, color: Color) -> void:
	for i in Fighter.MAX_RES:
		var c := origin + Vector2(6 + i * 13, 0)
		if i < filled:
			draw_circle(c, 5, color)
		else:
			draw_arc(c, 5, 0, TAU, 12, Color(color, 0.5), 1.5)


func _draw_shape(c: Vector2, r: float, color: Color) -> void:
	match fighter.shape:
		Fighter.Shape.SQUARE:
			draw_rect(Rect2(c - Vector2(r, r) * 0.85, Vector2(r, r) * 1.7), color)
		Fighter.Shape.TRIANGLE:
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, r * 0.8), c + Vector2(-r, r * 0.8)]), color)
		Fighter.Shape.FANG:
			draw_colored_polygon(PackedVector2Array([c + Vector2(-r, -r * 0.7), c + Vector2(r, -r * 0.7), c + Vector2(0, r)]), color)
		Fighter.Shape.DIAMOND:
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, -r), c + Vector2(r * 0.75, 0), c + Vector2(0, r), c + Vector2(-r * 0.75, 0)]), color)
		Fighter.Shape.STAR:
			var points := PackedVector2Array()
			for i in 10:
				var radius := r if i % 2 == 0 else r * 0.45
				points.append(c + Vector2.UP.rotated(TAU * i / 10.0) * radius)
			draw_colored_polygon(points, color)
		Fighter.Shape.HEXAGON:
			var points := PackedVector2Array()
			for i in 6:
				points.append(c + Vector2.RIGHT.rotated(TAU * i / 6.0) * r)
			draw_colored_polygon(points, color)
		_:
			draw_circle(c, r * 0.9, color)
	# Augen, damit die Formen ein bisschen lebendig wirken
	var eye_dir := 1.0 if fighter.is_hero else -1.0
	draw_circle(c + Vector2(eye_dir * r * 0.25, -r * 0.1), r * 0.1, Color.BLACK)
