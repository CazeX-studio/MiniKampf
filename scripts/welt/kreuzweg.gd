extends Node2D
## Kreuzweg-Demo (Lernprojekt 3): Stadt schräg von oben, Laufen, Gespräche mit Antworten,
## Aufträge, Gold, Tasche, Erfahrung und Stufen, Speichern.
## Dieses Skript ist nur die Anzeige: Es zeichnet den Zustand aus WorldState und
## schickt Befehle. Ein zweiter Spieler („Testgefährte“) läuft zur Probe mit,
## gesteuert über genau dieselben Befehle – so wie später echte Mitspieler über das Netz.
## Alle Texte stehen in res://data (siehe data/LIESMICH.md).

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

# Steuerung: Steuerknopf und Aktions-Knopf fürs Handy
const STICK_RADIUS := 70.0
const STICK_DEADZONE := 12.0
const STICK_HOME := Vector2(170, 560)
const NOTICE_SECONDS := 3.5
## NPCs stehen ruhiger als Spieler (langsamere Steh-Animation)
const NPC_IDLE_FPS := 2.0
const NIGHT_COLOR := Color(0.45, 0.5, 0.78)
## Farben der fünf Festlaternen (eine pro Region)
const LANTERN_COLORS: Array[Color] = [Color("b8b0ff"), Color("e0a060"), Color("ffb070"), Color("a8e088"), Color("ffb8d8")]

var state := WorldState.new()

var _ground: Node2D
var _objects: Node2D
var _characters := {}
## Sammelpunkt-Ziel ("punkt:0") -> Grafik
var _pickup_nodes := {}
## Schmuck-Grafik -> Bedingung, wann sie zu sehen ist
var _deco_nodes := {}
## Färbt die Welt nachts dunkelblau (Fest der fünf Wege)
var _night: CanvasModulate
var _flash_rect: ColorRect
var _camera: Camera2D
var _marker := Vector2.ZERO
var _marker_time := 0.0
var _bot_timer := 2.0
var _time := 0.0
## Beim "Neu beginnen" nicht mehr speichern
var _no_save := false

var _dialog: PanelContainer
var _dialog_name: Label
var _dialog_text: Label
var _dialog_answers: VBoxContainer
var _dialog_next: Button
var _dialog_shown := {}
var _info: Label
var _hud: Label
var _goal: Label
var _notices: VBoxContainer
var _panel: PanelContainer
var _panel_title: Label
var _panel_text: RichTextLabel
var _panel_mode := ""
var _shop_panel: PanelContainer
var _shop_box: VBoxContainer
## Was im Ladenfenster gerade angezeigt wird (zum Neuaufbau bei Änderungen)
var _shop_shown := ""
## Knöpfe, auf denen ein Antippen nicht als Laufen zählt
var _buttons: Array[Control] = []

var _steer_sent := Vector2.ZERO
var _touch_ui := false
var _stick_layer: Control
var _action_button: Button
var _stick_index := -1
var _stick_origin := Vector2.ZERO
var _stick_vec := Vector2.ZERO
var _stick_moved := false


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("1b2418"))
	state.notice.connect(_on_notice)
	state.progress_changed.connect(_on_progress_changed)
	state.battle_requested.connect(_on_battle_requested)
	state.effect_requested.connect(_on_effect)
	_night = CanvasModulate.new()
	add_child(_night)
	var local := state.add_player(LOCAL_ID, "Du", "elf_m", WorldState.start_cell())
	SaveGame.load_into(local)
	state.add_player(BOT_ID, "Testgefährte", "lizard_f", WorldState.start_cell() + Vector2i(-1, 0))

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
	for i in state.pickups.size():
		_add_pickup("punkt:%d" % i)
	for deco: Dictionary in state.decorations:
		_add_decoration(deco)
	for id: String in state.npcs:
		var npc: Dictionary = state.npcs[id]
		var view := WorldCharacter.new()
		view.setup(npc.look, npc.name, npc.tint, Color("f2c14e"))
		view.idle_fps = NPC_IDLE_FPS
		# Jeder NPC beginnt an einer anderen Stelle der Animation, damit nicht alle im Gleichtakt wippen
		view.time_offset(randf() * 4.0)
		view.position = cell_center(Vector2(npc.cell))
		view.facing = 1
		_objects.add_child(view)
		_characters["npc:" + id] = view

	_camera = Camera2D.new()
	_camera.zoom = Vector2(1.25, 1.25)
	_camera.position_smoothing_enabled = true
	add_child(_camera)
	_build_ui()
	_set_touch_ui(DisplayServer.is_touchscreen_available())
	_sync()
	_camera.reset_smoothing()
	# Zurück aus einem Kampf: Ergebnis verbuchen (Erfahrung, Aufträge)
	if not BattleRequest.result.is_empty():
		state.apply_command(LOCAL_ID, {type = "kampf_ergebnis", kampf = BattleRequest.result.kampf,
				gewonnen = BattleRequest.result.gewonnen, traenke_benutzt = BattleRequest.result.get("traenke_benutzt", 0)})
		BattleRequest.result = {}
	# Beim ersten Betreten der Stadt kommt die Einleitung
	state.apply_command(LOCAL_ID, {type = "start"})


func _exit_tree() -> void:
	if not _no_save:
		SaveGame.save(local_player())


func _process(delta: float) -> void:
	_time += delta
	_update_steer()
	_drive_bot(delta)
	state.tick(delta)
	_sync()
	_update_dialog()
	_update_shop()
	_marker_time = maxf(_marker_time - delta, 0.0)
	_ground.queue_redraw()


func local_player() -> PlayerState:
	return state.players[LOCAL_ID]


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
		view.moving = p.is_walking()
		view.facing = p.facing
	var local := local_player()
	_camera.position = cell_center(local.pos)
	# Sammelpunkte: Jeder sieht nur die, die er selbst noch nicht eingesammelt hat
	for target: String in _pickup_nodes:
		var node: Node2D = _pickup_nodes[target]
		node.visible = state.can_use(local, target)
		node.queue_redraw()
	# Schmuck (Festlaternen, Krater) und Nacht: je nachdem, wie weit der eigene Spieler ist
	for node: Node2D in _deco_nodes:
		node.visible = state.check(local, _deco_nodes[node])
		if node.visible:
			node.queue_redraw()
	var night_color := NIGHT_COLOR if local.progress.flags.has("nacht") else Color.WHITE
	_night.color = _night.color.lerp(night_color, 0.05)
	_info.text = "Spieler in Kreuzweg: %d" % state.players.size()
	for id: String in state.npcs:
		var npc_view: WorldCharacter = _characters["npc:" + id]
		npc_view.visible = state.npc_visible(local, id)
		npc_view.marker = state.npc_marker(local, id)
	var goal := state.objective(local)
	_goal.text = "Ziel: " + goal if goal != "" else ""
	_update_hud()


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
# PC: Klicken = hinlaufen, WASD/Pfeiltasten = laufen, E/Leertaste = reden bzw. weiter,
#     1–4 = Antwort wählen, J = Auftragsbuch, I = Tasche, Esc = Fenster schließen.
# Handy: Antippen = hinlaufen, Steuerknopf unten links (erscheint unter dem Daumen), Aktions-Knopf unten rechts.

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key: Key = event.physical_keycode
		var handled := true
		if key in [KEY_E, KEY_SPACE]:
			_action()
		elif key >= KEY_1 and key <= KEY_9:
			state.apply_command(LOCAL_ID, {type = "dialog_choose", index = key - KEY_1})
		elif key == KEY_J:
			_toggle_panel("auftraege")
		elif key == KEY_I:
			_toggle_panel("tasche")
		elif key == KEY_ESCAPE and local_player().shop != "":
			state.apply_command(LOCAL_ID, {type = "laden_zu"})
		elif key == KEY_ESCAPE and _panel.visible:
			_panel.visible = false
		else:
			handled = false
		if handled:
			get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		_touch(event)
		return
	if _dialog.visible:
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	# Finger-Berührungen kommen auch als Maus an; die werden schon in _touch behandelt
	if event.device == InputEvent.DEVICE_ID_EMULATION and _touch_ui:
		return
	_tap_at(get_global_mouse_position())


## E, Leertaste oder Aktions-Knopf: im Gespräch weiter, sonst das Nächste nebenan benutzen.
func _action() -> void:
	if local_player().in_dialog():
		state.apply_command(LOCAL_ID, {type = "dialog_next"})
	else:
		state.apply_command(LOCAL_ID, {type = "interact"})


## Richtung aus Tasten und Steuerknopf; wird nur bei Änderung als Befehl geschickt.
func _update_steer() -> void:
	var dir := Vector2.ZERO
	if not local_player().in_dialog():
		if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
			dir.x -= 1.0
		if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
			dir.x += 1.0
		if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
			dir.y -= 1.0
		if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
			dir.y += 1.0
		dir = dir.normalized()
		if _stick_vec != Vector2.ZERO:
			dir = _stick_vec
	if dir != _steer_sent:
		_steer_sent = dir
		state.apply_command(LOCAL_ID, {type = "steer", dir = dir})


func _touch(event: InputEvent) -> void:
	if not _touch_ui:
		_set_touch_ui(true)
	if event is InputEventScreenTouch:
		if event.pressed:
			if _dialog.visible or _on_buttons(event.position):
				return
			if _stick_index == -1 and _in_stick_zone(event.position):
				_stick_index = event.index
				_stick_origin = event.position
				_stick_moved = false
				_stick_vec = Vector2.ZERO
			else:
				_tap_at(_to_world(event.position))
		elif event.index == _stick_index:
			# Kurz angetippt ohne zu ziehen: wie ein normales Antippen (hinlaufen)
			if not _stick_moved and not _dialog.visible:
				_tap_at(_to_world(event.position))
			_stick_index = -1
			_stick_vec = Vector2.ZERO
		_stick_layer.queue_redraw()
	elif event is InputEventScreenDrag and event.index == _stick_index:
		var offset: Vector2 = event.position - _stick_origin
		if offset.length() > STICK_DEADZONE:
			_stick_moved = true
		_stick_vec = (offset / STICK_RADIUS).limit_length(1.0) if _stick_moved else Vector2.ZERO
		_stick_layer.queue_redraw()


func _in_stick_zone(pos: Vector2) -> bool:
	return pos.x < 1280.0 * 0.45 and pos.y > 720.0 * 0.4


func _on_buttons(pos: Vector2) -> bool:
	for c in _buttons:
		if c.visible and c.get_global_rect().has_point(pos):
			return true
	return false


func _to_world(screen_pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * screen_pos


## Antippen / Klicken auf eine Stelle der Welt: hinlaufen, mit dem NPC dort reden oder etwas einsammeln.
func _tap_at(world: Vector2) -> void:
	if _panel.visible:
		_panel.visible = false
		return
	# NPC angetippt? Dann hinlaufen und reden
	for id: String in state.npcs:
		if not state.npc_visible(local_player(), id):
			continue
		var npc_pos := cell_center(Vector2(state.npcs[id].cell))
		if absf(world.x - npc_pos.x) < 30.0 and world.y > npc_pos.y - 90.0 and world.y < npc_pos.y + 12.0:
			state.apply_command(LOCAL_ID, {type = "talk", npc = id})
			_show_marker(npc_pos)
			return
	# Sammelpunkt angetippt? Dann hinlaufen und einsammeln
	for target: String in _pickup_nodes:
		var node: Node2D = _pickup_nodes[target]
		if node.visible and (world - (node.position + Vector2(0, -12))).length() < 26.0:
			state.apply_command(LOCAL_ID, {type = "use", target = target})
			_show_marker(node.position)
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



## Ein Sammelpunkt (z. B. Silberkraut): kleine leuchtende Pflanze.
func _add_pickup(target: String) -> void:
	var node := Node2D.new()
	node.position = cell_center(Vector2(state.target_cell(target)))
	node.draw.connect(func() -> void: _draw_pickup(node))
	_objects.add_child(node)
	_pickup_nodes[target] = node


func _draw_pickup(node: Node2D) -> void:
	var glow := 0.5 + 0.5 * sin(_time * 3.0 + node.position.x)
	node.draw_circle(Vector2(0, -10), 16.0, Color(0.8, 1.0, 0.9, 0.12 + 0.12 * glow))
	for i in 3:
		var angle := -PI / 2 + (i - 1) * 0.6
		var tip := Vector2(0, -2) + Vector2.from_angle(angle) * 16.0
		node.draw_line(Vector2(0, -2), tip, Color("9fe8c8"), 3.0)
		node.draw_circle(tip, 3.5, Color(0.85, 1.0, 0.95, 0.7 + 0.3 * glow))


# --- Oberfläche -----------------------------------------------------------------

func _build_ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	var root := Control.new()
	root.size = Vector2(1280, 720)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = Combat.make_theme()
	ui.add_child(root)

	var hint := _label("Laufen: antippen / WASD / Steuerknopf · Reden: E oder Leertaste", 14, Color.WHITE)
	hint.position = Vector2(16, 10)
	root.add_child(hint)
	_hud = _label("", 18, Color("f2c14e"))
	_hud.position = Vector2(16, 32)
	root.add_child(_hud)
	_goal = _label("", 17, Color("9fe8ff"))
	_goal.position = Vector2(16, 56)
	root.add_child(_goal)
	_info = _label("", 13, Color("8affc1"))
	_info.position = Vector2(16, 82)
	root.add_child(_info)

	var x := 1170.0
	for info: Array in [["Menü", 96, _go_menu], ["Tasche (I)", 120, _toggle_panel.bind("tasche")],
			["Aufträge (J)", 140, _toggle_panel.bind("auftraege")], [GameData.text("neu_beginnen"), 140, _restart]]:
		var button := Button.new()
		button.text = info[0]
		button.size = Vector2(info[1], 44)
		x -= 0.0 if info[0] == "Menü" else info[1] + 8.0
		button.position = Vector2(x, 12)
		button.add_theme_font_size_override("font_size", 15)
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(info[2])
		root.add_child(button)
		_buttons.append(button)


	# Handy: Steuerknopf (unten links, erscheint unter dem Daumen) und Aktions-Knopf (unten rechts)
	_stick_layer = Control.new()
	_stick_layer.size = Vector2(1280, 720)
	_stick_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stick_layer.draw.connect(_draw_stick)
	root.add_child(_stick_layer)
	_action_button = Button.new()
	_action_button.text = "Reden"
	_action_button.position = Vector2(1100, 560)
	_action_button.size = Vector2(150, 120)
	_action_button.add_theme_font_size_override("font_size", 22)
	_action_button.focus_mode = Control.FOCUS_NONE
	_action_button.pressed.connect(_action)
	root.add_child(_action_button)
	_buttons.append(_action_button)

	# Gesprächsfenster mit Antwort-Knöpfen
	_dialog = _framed_panel()
	_dialog.position = Vector2(120, 440)
	_dialog.size = Vector2(960, 260)
	_dialog.visible = false
	root.add_child(_dialog)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	_dialog.add_child(box)
	_dialog_name = _label("", 20, Color("f2c14e"))
	box.add_child(_dialog_name)
	_dialog_text = Label.new()
	_dialog_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialog_text.custom_minimum_size = Vector2(920, 54)
	_dialog_text.add_theme_font_size_override("font_size", 19)
	box.add_child(_dialog_text)
	_dialog_answers = VBoxContainer.new()
	_dialog_answers.add_theme_constant_override("separation", 4)
	box.add_child(_dialog_answers)
	_dialog_next = Button.new()
	_dialog_next.text = GameData.text("weiter")
	_dialog_next.custom_minimum_size = Vector2(160, 44)
	_dialog_next.size_flags_horizontal = Control.SIZE_SHRINK_END
	_dialog_next.add_theme_font_size_override("font_size", 17)
	_dialog_next.focus_mode = Control.FOCUS_NONE
	_dialog_next.pressed.connect(func() -> void: state.apply_command(LOCAL_ID, {type = "dialog_next"}))
	box.add_child(_dialog_next)

	# Fenster für Auftragsbuch und Tasche
	_panel = _framed_panel()
	_panel.position = Vector2(340, 90)
	_panel.size = Vector2(600, 440)
	_panel.visible = false
	root.add_child(_panel)
	_buttons.append(_panel)
	var panel_box := VBoxContainer.new()
	_panel.add_child(panel_box)
	_panel_title = _label("", 22, Color("f2c14e"))
	panel_box.add_child(_panel_title)
	_panel_text = RichTextLabel.new()
	_panel_text.bbcode_enabled = true
	_panel_text.custom_minimum_size = Vector2(570, 330)
	_panel_text.add_theme_font_size_override("normal_font_size", 16)
	_panel_text.add_theme_font_size_override("bold_font_size", 17)
	panel_box.add_child(_panel_text)
	var close := Button.new()
	close.text = "Schließen"
	close.custom_minimum_size = Vector2(140, 40)
	close.size_flags_horizontal = Control.SIZE_SHRINK_END
	close.focus_mode = Control.FOCUS_NONE
	close.pressed.connect(func() -> void: _panel.visible = false)
	panel_box.add_child(close)

	# Lichtblitz über allem (Sternenfall)
	_flash_rect = ColorRect.new()
	_flash_rect.size = Vector2(1280, 720)
	_flash_rect.color = Color(1, 1, 1, 0)
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_flash_rect)

	# Ladenfenster (Kaufen und Verkaufen)
	_shop_panel = _framed_panel()
	_shop_panel.position = Vector2(290, 130)
	_shop_panel.size = Vector2(700, 0)
	_shop_panel.visible = false
	root.add_child(_shop_panel)
	_buttons.append(_shop_panel)
	_shop_box = VBoxContainer.new()
	_shop_box.add_theme_constant_override("separation", 6)
	_shop_panel.add_child(_shop_box)

	# Kurze Meldungen oben in der Mitte („+30 Gold“, „Neuer Auftrag …“), über allen Fenstern
	_notices = VBoxContainer.new()
	_notices.position = Vector2(390, 80)
	_notices.size = Vector2(500, 0)
	_notices.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_notices)


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 5)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _framed_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.05, 0.11, 0.95)
	style.border_color = Color(0.85, 0.72, 0.45, 0.8)
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(14)
	panel.add_theme_stylebox_override("panel", style)
	return panel


## Schmuck in der Stadt (Festlaternen, Krater des Sternenfalls).
func _add_decoration(deco: Dictionary) -> void:
	var node := Node2D.new()
	node.position = cell_center(Vector2(deco.cell))
	var index := _deco_nodes.size()
	var art: String = deco.art
	node.draw.connect(func() -> void: _draw_decoration(node, art, index))
	_objects.add_child(node)
	_deco_nodes[node] = deco.cond


func _draw_decoration(node: Node2D, art: String, index: int) -> void:
	match art:
		"festlaterne":
			var color: Color = LANTERN_COLORS[index % LANTERN_COLORS.size()]
			var flicker := 0.85 + 0.15 * sin(_time * 5.0 + index)
			node.draw_circle(Vector2(0, -58), 26.0, Color(color, 0.18 * flicker))
			node.draw_rect(Rect2(-2, -50, 4, 50), Color("3a2a1a"))
			node.draw_rect(Rect2(-7, -66, 14, 16), Color(color.lightened(0.3), flicker))
			node.draw_rect(Rect2(-8, -68, 16, 3), Color("3a2a1a"))
		"krater":
			node.draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
			node.draw_circle(Vector2.ZERO, 34.0, Color(0.1, 0.08, 0.15, 0.85))
			node.draw_arc(Vector2.ZERO, 34.0, 0, TAU, 32, Color(0.95, 0.9, 1.0, 0.5 + 0.3 * sin(_time * 3.0)), 3.0)
			node.draw_set_transform_matrix(Transform2D.IDENTITY)
			node.draw_circle(Vector2(0, -4), 5.0, Color(0.95, 0.9, 1.0, 0.8))


## Besondere Effekte: Beim Sternenfall wird es kurz taghell und das Bild wackelt.
func _on_effect(player_id: String, effect: String) -> void:
	if player_id != LOCAL_ID or effect != "sternenfall":
		return
	_flash_rect.color = Color(1, 1, 1, 0.9)
	var tween := create_tween()
	tween.tween_property(_flash_rect, "color:a", 0.0, 1.6)
	var shake := create_tween()
	for i in 8:
		shake.tween_property(_camera, "offset", Vector2(randf_range(-10, 10), randf_range(-8, 8)), 0.05)
	shake.tween_property(_camera, "offset", Vector2.ZERO, 0.05)


func _go_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


## Spielstand löschen und von vorn beginnen.
func _restart() -> void:
	_no_save = true
	SaveGame.delete()
	get_tree().reload_current_scene()


## Steuerknopf und Aktions-Knopf nur auf Geräten mit Touchscreen zeigen.
func _set_touch_ui(on: bool) -> void:
	_touch_ui = on
	_action_button.visible = on
	_stick_layer.queue_redraw()


func _draw_stick() -> void:
	if not _touch_ui:
		return
	var active := _stick_index != -1
	var center := _stick_origin if active else STICK_HOME
	_stick_layer.draw_circle(center, STICK_RADIUS, Color(0, 0, 0, 0.35 if active else 0.18))
	_stick_layer.draw_arc(center, STICK_RADIUS, 0, TAU, 48, Color(1, 0.9, 0.6, 0.7 if active else 0.3), 3.0)
	var knob := center + _stick_vec * STICK_RADIUS
	_stick_layer.draw_circle(knob, 30.0, Color(1, 0.9, 0.6, 0.75 if active else 0.3))


# --- Gespräch, Anzeige oben, Meldungen, Fenster --------------------------------

## Zeigt das Gespräch des eigenen Spielers so, wie es im Zustand steht.
func _update_dialog() -> void:
	var view := state.dialog_view(local_player())
	if view == _dialog_shown:
		return
	_dialog_shown = view
	_dialog.visible = not view.is_empty()
	_action_button.text = "Weiter" if _dialog.visible else "Reden"
	if view.is_empty():
		return
	_dialog_name.text = view.wer
	_dialog_text.text = view.text
	for child in _dialog_answers.get_children():
		child.queue_free()
	var answers: Array = view.antworten
	for i in answers.size():
		var button := Button.new()
		button.text = "%d. %s" % [i + 1, answers[i]]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(920, 38)
		button.add_theme_font_size_override("font_size", 17)
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(func() -> void: state.apply_command(LOCAL_ID, {type = "dialog_choose", index = i}))
		_dialog_answers.add_child(button)
	_dialog_next.visible = answers.is_empty()
	# Viele Antworten: Fenster wächst nach oben, damit es nicht aus dem Bild ragt
	_place_dialog.call_deferred()


## Ladenfenster: wird neu aufgebaut, sobald sich Laden, Gold oder Tasche ändern.
func _update_shop() -> void:
	var p := local_player()
	var key := "" if p.shop == "" else "%s|%d|%s" % [p.shop, p.progress.gold, str(p.progress.items)]
	if key == _shop_shown:
		return
	_shop_shown = key
	_shop_panel.visible = p.shop != ""
	for child in _shop_box.get_children():
		child.queue_free()
	if p.shop == "":
		return
	var shop: Dictionary = GameData.get_file("laeden").get(p.shop, {})
	var title := _label("%s  ·  %d Gold" % [shop.get("name", p.shop), p.progress.gold], 22, Color("f2c14e"))
	_shop_box.add_child(title)
	_shop_box.add_child(_label(GameData.text("laden_kaufen"), 17, Color("9fe8ff")))
	for ware in state.shop_wares(p.shop):
		var item := GameData.item(ware.gegenstand)
		var row := _shop_row("%s – %s" % [item.get("name", ware.gegenstand), item.get("beschreibung", "")],
				"%s · %d Gold" % [GameData.text("laden_kaufen"), ware.preis])
		row.button.pressed.connect(func() -> void: state.apply_command(LOCAL_ID, {type = "kaufen", gegenstand = ware.gegenstand}))
		if p.progress.gold < ware.preis:
			row.button.modulate = Color(1, 1, 1, 0.5)
		_shop_box.add_child(row.box)
	_shop_box.add_child(_label(GameData.text("laden_verkaufen"), 17, Color("9fe8ff")))
	var any := false
	for item_id: String in p.progress.items:
		var price := state.sell_price(p.shop, item_id)
		if price <= 0:
			continue
		any = true
		var row := _shop_row("%d × %s" % [p.progress.items[item_id], GameData.item_name(item_id)],
				"%s · %d Gold" % [GameData.text("laden_verkaufen"), price])
		row.button.pressed.connect(func() -> void: state.apply_command(LOCAL_ID, {type = "verkaufen", gegenstand = item_id}))
		_shop_box.add_child(row.box)
	if not any:
		_shop_box.add_child(_label(GameData.text("laden_nichts_verkaufen"), 15, Color(1, 1, 1, 0.6)))
	var close := Button.new()
	close.text = GameData.text("schliessen")
	close.custom_minimum_size = Vector2(140, 40)
	close.size_flags_horizontal = Control.SIZE_SHRINK_END
	close.focus_mode = Control.FOCUS_NONE
	close.pressed.connect(func() -> void: state.apply_command(LOCAL_ID, {type = "laden_zu"}))
	_shop_box.add_child(close)
	_shop_panel.reset_size()


## Eine Zeile im Laden: Text links, Knopf rechts. Gibt {box, button} zurück.
func _shop_row(text: String, button_text: String) -> Dictionary:
	var box := HBoxContainer.new()
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(470, 0)
	label.add_theme_font_size_override("font_size", 15)
	box.add_child(label)
	var button := Button.new()
	button.text = button_text
	button.custom_minimum_size = Vector2(190, 40)
	button.add_theme_font_size_override("font_size", 15)
	button.focus_mode = Control.FOCUS_NONE
	box.add_child(button)
	return {box = box, button = button}


func _update_hud() -> void:
	var progress := local_player().progress
	var xp_span := progress.xp_range()
	var xp_text := GameData.text("hud_max") if xp_span.y < 0 else GameData.text("hud_erfahrung", [progress.xp, xp_span.y])
	_hud.text = GameData.text("hud", [progress.level, xp_text, progress.gold])
	if _panel.visible:
		_fill_panel()


func _on_notice(player_id: String, text: String) -> void:
	if player_id != LOCAL_ID:
		return
	var label := _label(text, 20, Color("fff3b0"))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(500, 0)
	_notices.add_child(label)
	var tween := create_tween()
	tween.tween_interval(NOTICE_SECONDS)
	tween.tween_property(label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(label.queue_free)


## Automatisch speichern, sobald sich der Fortschritt des eigenen Spielers ändert.
func _on_progress_changed(player_id: String) -> void:
	if player_id == LOCAL_ID and not _no_save:
		SaveGame.save(local_player())


func _toggle_panel(mode: String) -> void:
	if _panel.visible and _panel_mode == mode:
		_panel.visible = false
		return
	_panel_mode = mode
	_panel.visible = true
	_fill_panel()


func _fill_panel() -> void:
	var p := local_player()
	var lines: PackedStringArray = []
	if _panel_mode == "auftraege":
		_panel_title.text = GameData.text("auftragsbuch")
		for id: String in p.progress.quests:
			var q := GameData.quest(id)
			if q.is_empty():
				continue
			var quest_state: String = p.progress.quests[id]
			var color := "8affc1" if quest_state == "fertig" else ("a0a0a0" if quest_state == "abgegeben" else "ffffff")
			lines.append("[b][color=#%s]%s[/color][/b]  (%s)" % [color, q.get("titel", id), GameData.text("stand_" + quest_state)])
			if quest_state != "abgegeben":
				lines.append(q.get("beschreibung", ""))
				for goal: Dictionary in q.get("ziele", []):
					lines.append("  • " + state.goal_text(p, goal))
			lines.append("")
		if lines.is_empty():
			lines.append(GameData.text("auftragsbuch_leer"))
		# Erfolge
		var achievements := GameData.get_file("erfolge")
		var unlocked: PackedStringArray = []
		for id: String in achievements:
			if id != "hinweis" and p.progress.flags.has("erfolg:" + id):
				unlocked.append("[color=#f2c14e]★ %s[/color] – %s" % [achievements[id].name, achievements[id].beschreibung])
		if not unlocked.is_empty():
			lines.append("[b]%s[/b]" % GameData.text("erfolge"))
			lines.append_array(unlocked)
	else:
		_panel_title.text = GameData.text("tasche")
		lines.append("[b]Gold: %d[/b]" % p.progress.gold)
		lines.append("")
		for id: String in p.progress.items:
			var item := GameData.item(id)
			lines.append("[b]%d × %s[/b] – %s" % [p.progress.items[id], item.get("name", id), item.get("beschreibung", "")])
		if p.progress.items.is_empty():
			lines.append(GameData.text("tasche_leer"))
	_panel_text.text = "\n".join(lines)


## Ein Kampf beginnt (z. B. eine Lektion bei Ye): speichern und zum Kampfbildschirm wechseln.
func _on_battle_requested(player_id: String, kampf_id: String) -> void:
	if player_id != LOCAL_ID:
		return
	var progress := local_player().progress
	if BattleRequest.prepare(kampf_id, progress.level, progress.item_count("heiltrank")):
		SaveGame.save(local_player())
		get_tree().change_scene_to_file.call_deferred("res://scenes/kampf.tscn")


func _place_dialog() -> void:
	_dialog.reset_size()
	_dialog.position.y = minf(440.0, 710.0 - _dialog.size.y)
