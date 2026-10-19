extends Node2D
## Kreuzweg-Demo (Lernprojekt 3, Gerüst): Stadt schräg von oben, Laufen per Maus/Touch,
## Ausbilder Ye mit einem kurzen Gespräch.
## Dieses Skript ist nur die Anzeige: Es zeichnet den Zustand aus WorldState und
## schickt Befehle. Ein zweiter Spieler („Testgefährte“) läuft zur Probe mit,
## gesteuert über genau dieselben Befehle – so wie später echte Mitspieler über das Netz.

const TILE_W := 64.0
const TILE_H := 32.0
const LOCAL_ID := "spieler"
const BOT_ID := "gefaehrte"

const TILE_COLORS := {
	WorldState.Tile.GRASS: [Color("3f6b3a"), Color("456f3d")],
	WorldState.Tile.ROAD: [Color("8a7556"), Color("837052")],
	WorldState.Tile.PLAZA: [Color("9d9585"), Color("948c7c")],
	WorldState.Tile.OVERGROWN: [Color("2f4d2a"), Color("3a5a2e")],
}

var state := WorldState.new()

var _ground: Node2D
var _objects: Node2D
var _characters := {}
var _camera: Camera2D
var _marker := Vector2.ZERO
var _marker_time := 0.0
var _bot_timer := 2.0

var _dialog: PanelContainer
var _dialog_name: Label
var _dialog_text: Label
var _dialog_lines: Array = []
var _dialog_index := 0
var _info: Label


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("1b2418"))
	state.dialog_started.connect(_on_dialog_started)
	state.add_player(LOCAL_ID, "Du", "elf_m", Vector2i(11, 19))
	state.add_player(BOT_ID, "Testgefährte", "lizard_f", Vector2i(10, 20))

	_ground = Node2D.new()
	_ground.z_index = -10
	_ground.draw.connect(_draw_ground)
	add_child(_ground)

	# Alles, was steht, wird nach Tiefe sortiert (wer weiter unten steht, ist vorne)
	_objects = Node2D.new()
	_objects.y_sort_enabled = true
	add_child(_objects)
	for b: Dictionary in state.buildings:
		_add_building(b)
	for prop: Dictionary in state.props:
		_add_prop(prop)
	for id: String in state.npcs:
		var npc: Dictionary = state.npcs[id]
		var view := WorldCharacter.new()
		view.setup(npc.look, npc.name, npc.tint, Color("f2c14e"))
		view.position = cell_center(Vector2(npc.cell))
		view.facing = 1
		_objects.add_child(view)
		_characters["npc:" + id] = view

	_camera = Camera2D.new()
	_camera.zoom = Vector2(1.25, 1.25)
	_camera.position_smoothing_enabled = true
	add_child(_camera)
	_build_ui()
	_sync()
	_camera.reset_smoothing()


func _process(delta: float) -> void:
	_drive_bot(delta)
	state.tick(delta)
	_sync()
	_marker_time = maxf(_marker_time - delta, 0.0)
	_ground.queue_redraw()


## Überträgt den Zustand der Spieler auf ihre Figuren.
func _sync() -> void:
	for id: String in state.players:
		var p: PlayerState = state.players[id]
		if not _characters.has(id):
			var view := WorldCharacter.new()
			var is_local := id == LOCAL_ID
			view.setup(p.look, p.display_name, Color.WHITE, Color("8affc1") if is_local else Color.WHITE)
			_objects.add_child(view)
			_characters[id] = view
		var view: WorldCharacter = _characters[id]
		view.position = cell_center(p.pos)
		view.moving = p.is_moving()
		view.facing = p.facing
	var local: PlayerState = state.players[LOCAL_ID]
	_camera.position = cell_center(local.pos)
	_info.text = "Spieler in Kreuzweg: %d" % state.players.size()


## Der Testgefährte läuft ab und zu irgendwohin (wie ein Mitspieler).
func _drive_bot(delta: float) -> void:
	_bot_timer -= delta
	if _bot_timer > 0.0:
		return
	_bot_timer = randf_range(3.0, 6.0)
	for i in 20:
		var cell := Vector2i(randi_range(3, 18), randi_range(3, 18))
		if state.is_walkable(cell):
			state.apply_command(BOT_ID, {type = "move", cell = cell})
			return


# --- Umrechnung Feld <-> Bildschirm (schräg von oben) --------------------------

func cell_to_screen(c: Vector2) -> Vector2:
	return Vector2((c.x - c.y) * TILE_W * 0.5, (c.x + c.y) * TILE_H * 0.5)


func cell_center(c: Vector2) -> Vector2:
	return cell_to_screen(c + Vector2(0.5, 0.5))


func screen_to_cell(p: Vector2) -> Vector2i:
	var x := (p.x / (TILE_W * 0.5) + p.y / (TILE_H * 0.5)) * 0.5
	var y := (p.y / (TILE_H * 0.5) - p.x / (TILE_W * 0.5)) * 0.5
	return Vector2i(floori(x), floori(y))


# --- Eingabe --------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if _dialog.visible:
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	var world := get_global_mouse_position()
	# NPC angetippt? Dann hinlaufen und reden
	for id: String in state.npcs:
		var npc_pos := cell_center(Vector2(state.npcs[id].cell))
		if absf(world.x - npc_pos.x) < 30.0 and world.y > npc_pos.y - 90.0 and world.y < npc_pos.y + 12.0:
			state.apply_command(LOCAL_ID, {type = "talk", npc = id})
			_show_marker(npc_pos)
			return
	var cell := screen_to_cell(world)
	if state.is_walkable(cell):
		state.apply_command(LOCAL_ID, {type = "move", cell = cell})
		_show_marker(cell_center(Vector2(cell)))


func _show_marker(pos: Vector2) -> void:
	_marker = pos
	_marker_time = 0.6


# --- Zeichnen -------------------------------------------------------------------

func _draw_ground() -> void:
	for y in WorldState.SIZE.y:
		for x in WorldState.SIZE.x:
			var cell := Vector2i(x, y)
			var colors: Array = TILE_COLORS[state.tile_at(cell)]
			var color: Color = colors[(x + y) % 2]
			var top := cell_to_screen(Vector2(cell))
			var diamond := PackedVector2Array([
				top,
				top + Vector2(TILE_W * 0.5, TILE_H * 0.5),
				top + Vector2(0, TILE_H),
				top + Vector2(-TILE_W * 0.5, TILE_H * 0.5),
			])
			_ground.draw_colored_polygon(diamond, color)
			_ground.draw_polyline(diamond + PackedVector2Array([top]), Color(0, 0, 0, 0.08), 1.0)
	# Wohin getippt wurde
	if _marker_time > 0.0:
		var r := 22.0 * (1.0 - _marker_time / 0.6) + 6.0
		_ground.draw_set_transform(_marker, 0.0, Vector2(1.0, 0.5))
		_ground.draw_arc(Vector2.ZERO, r, 0, TAU, 24, Color(1, 0.9, 0.5, _marker_time / 0.6), 3.0)
		_ground.draw_set_transform_matrix(Transform2D.IDENTITY)


## Ein Haus als einfacher Block (Platzhalter), mit Namensschild.
func _add_building(b: Dictionary) -> void:
	var rect: Rect2i = b.rect
	var node := Node2D.new()
	# Sortierpunkt: die vorderste Ecke unten
	node.position = cell_to_screen(Vector2(rect.end))
	node.draw.connect(func() -> void: _draw_block(node, rect, b.height, b.color, b.name))
	_objects.add_child(node)


func _draw_block(node: Node2D, rect: Rect2i, height: float, color: Color, label: String) -> void:
	var base := node.position
	var a := cell_to_screen(Vector2(rect.position)) - base
	var b := cell_to_screen(Vector2(rect.end.x, rect.position.y)) - base
	var c := Vector2.ZERO
	var d := cell_to_screen(Vector2(rect.position.x, rect.end.y)) - base
	var up := Vector2(0, -height)
	node.draw_colored_polygon(PackedVector2Array([d, c, c + up, d + up]), color.darkened(0.25))
	node.draw_colored_polygon(PackedVector2Array([c, b, b + up, c + up]), color.darkened(0.45))
	node.draw_colored_polygon(PackedVector2Array([a + up, b + up, c + up, d + up]), color.lightened(0.15))
	node.draw_polyline(PackedVector2Array([a + up, b + up, c + up, d + up, a + up]), Color(0, 0, 0, 0.35), 1.5)
	# Tür an der linken Vorderseite
	var door := (d + c) * 0.5
	node.draw_rect(Rect2(door + Vector2(-8, -24), Vector2(16, 24)), Color("2a1c14"))
	var font := ThemeDB.fallback_font
	var title_pos := (a + c) * 0.5 + up + Vector2(-90, -8)
	node.draw_string_outline(font, title_pos, label, HORIZONTAL_ALIGNMENT_CENTER, 180, 14, 5, Color.BLACK)
	node.draw_string(font, title_pos, label, HORIZONTAL_ALIGNMENT_CENTER, 180, 14, Color("f3ead8"))


func _add_prop(prop: Dictionary) -> void:
	var node := Node2D.new()
	node.position = cell_center(Vector2(prop.cell))
	var kind: String = prop.kind
	node.draw.connect(func() -> void: _draw_prop(node, kind))
	_objects.add_child(node)


func _draw_prop(node: Node2D, kind: String) -> void:
	match kind:
		"tree":
			node.draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.45))
			node.draw_circle(Vector2.ZERO, 20.0, Color(0, 0, 0, 0.3))
			node.draw_set_transform_matrix(Transform2D.IDENTITY)
			node.draw_rect(Rect2(-4, -26, 8, 26), Color("5a3a22"))
			node.draw_circle(Vector2(0, -44), 24.0, Color("2f5a2a"))
			node.draw_circle(Vector2(-8, -52), 14.0, Color("3c6e33"))
		"bush":
			node.draw_circle(Vector2(0, -10), 16.0, Color("26401f"))
			node.draw_circle(Vector2(10, -14), 10.0, Color("30502a"))
		"lantern":
			# Ye's Laterne an der Wand der Gilde (Hinweis auf den Klassenlosen)
			node.draw_circle(Vector2(0, -60), 14.0, Color(1.0, 0.8, 0.4, 0.25))
			node.draw_rect(Rect2(-5, -66, 10, 12), Color("f2c14e"))
			node.draw_rect(Rect2(-1, -74, 2, 8), Color("3a3a3a"))


# --- Oberfläche -----------------------------------------------------------------

func _build_ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	var root := Control.new()
	root.size = Vector2(1280, 720)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = Combat.make_theme()
	ui.add_child(root)

	var hint := Label.new()
	hint.text = "Kreuzweg-Demo · Boden antippen = laufen · Ausbilder Ye antippen = reden"
	hint.position = Vector2(16, 12)
	hint.add_theme_font_size_override("font_size", 18)
	hint.add_theme_color_override("font_outline_color", Color.BLACK)
	hint.add_theme_constant_override("outline_size", 6)
	root.add_child(hint)

	_info = Label.new()
	_info.position = Vector2(16, 40)
	_info.add_theme_font_size_override("font_size", 14)
	_info.add_theme_color_override("font_color", Color("8affc1"))
	_info.add_theme_color_override("font_outline_color", Color.BLACK)
	_info.add_theme_constant_override("outline_size", 5)
	root.add_child(_info)

	var menu := Button.new()
	menu.text = "Menü"
	menu.position = Vector2(1170, 12)
	menu.size = Vector2(96, 44)
	menu.add_theme_font_size_override("font_size", 16)
	menu.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/menu.tscn"))
	root.add_child(menu)

	_dialog = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.05, 0.11, 0.95)
	style.border_color = Color(0.85, 0.72, 0.45, 0.8)
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(14)
	_dialog.add_theme_stylebox_override("panel", style)
	_dialog.position = Vector2(140, 520)
	_dialog.size = Vector2(1000, 180)
	_dialog.visible = false
	root.add_child(_dialog)
	var box := VBoxContainer.new()
	_dialog.add_child(box)
	_dialog_name = Label.new()
	_dialog_name.add_theme_font_size_override("font_size", 20)
	_dialog_name.add_theme_color_override("font_color", Color("f2c14e"))
	box.add_child(_dialog_name)
	_dialog_text = Label.new()
	_dialog_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialog_text.custom_minimum_size = Vector2(960, 70)
	_dialog_text.add_theme_font_size_override("font_size", 19)
	box.add_child(_dialog_text)
	var next := Button.new()
	next.text = "Weiter"
	next.custom_minimum_size = Vector2(160, 44)
	next.size_flags_horizontal = Control.SIZE_SHRINK_END
	next.add_theme_font_size_override("font_size", 17)
	next.pressed.connect(_next_line)
	box.add_child(next)


func _on_dialog_started(player_id: String, _npc_id: String, lines: Array) -> void:
	# Nur Gespräche des eigenen Spielers werden hier angezeigt
	if player_id != LOCAL_ID or lines.is_empty():
		return
	_dialog_lines = lines
	_dialog_index = 0
	_dialog.visible = true
	_show_line()


func _show_line() -> void:
	var line: Dictionary = _dialog_lines[_dialog_index]
	_dialog_name.text = line.who
	_dialog_text.text = line.text


func _next_line() -> void:
	_dialog_index += 1
	if _dialog_index >= _dialog_lines.size():
		_dialog.visible = false
		return
	_show_line()
