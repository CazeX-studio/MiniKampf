class_name Erinnerung
extends Control
## Erinnerungs-Szene (Grünwacht Schritt 6): Ein Splitter zeigt etwas aus der Vergangenheit. Kein Kampf, nur ein Bild
## in blassen Farben, Figuren, die sich bewegen, und Text. Weiter mit Tippen, E, Leertaste oder Enter.
## Was gezeigt wird, steht in data/erinnerungen.json (Figuren und Schritte, siehe data/LIESMICH.md).

## Welche Erinnerung gezeigt wird (vor dem Szenenwechsel setzen, z. B. "rowan")
static var id := ""
## Wohin es danach zurückgeht
static var return_scene := "res://scenes/kreuzweg.tscn"

const SCREEN := Vector2(1280, 720)
## Erinnerungen sind blass: alle Figuren bekommen diesen Farbton
const MEMORY_TINT := Color(0.78, 0.82, 0.95)
const MOVE_SECONDS := 1.4

var _data := {}
var _step := -1
var _figures := {}
var _busy := false
var _time := 0.0
var _backdrop: Control
var _arrow: Line2D
var _fade: ColorRect
var _text: Label
var _who: Label
var _hint: Label


func _ready() -> void:
	theme = Combat.make_theme()
	Musik.play("nacht")
	_data = GameData.get_file("erinnerungen").get(id, {})
	_backdrop = Control.new()
	_backdrop.size = SCREEN
	_backdrop.draw.connect(_draw_backdrop)
	add_child(_backdrop)
	var stage := Node2D.new()
	stage.y_sort_enabled = true
	add_child(stage)
	var figures: Dictionary = _data.get("figuren", {})
	for fid: String in figures:
		var f: Dictionary = figures[fid]
		var view := WorldCharacter.new()
		view.setup(f.get("aussehen", "elf_m"), f.get("name", ""), Color(f.get("farbe", "ffffff")) * MEMORY_TINT, Color("e8e4d8"))
		view.scale = Vector2(1.6, 1.6)
		view.position = Vector2(float(f.pos[0]), float(f.pos[1]))
		view.facing = int(f.get("blick", 1))
		view.visible = f.get("sichtbar", false)
		stage.add_child(view)
		_figures[fid] = view
	_arrow = Line2D.new()
	_arrow.width = 3.0
	_arrow.default_color = Color(1, 0.95, 0.8)
	_arrow.visible = false
	add_child(_arrow)
	# Leichter Schleier über allem: Erinnerungen sind blass und an den Rändern unscharf
	var veil := Control.new()
	veil.size = SCREEN
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	veil.draw.connect(func() -> void:
		veil.draw_rect(Rect2(Vector2.ZERO, SCREEN), Color(0.85, 0.88, 1.0, 0.12))
		for i in 6:
			var w := 40.0 + i * 18.0
			veil.draw_rect(Rect2(Vector2.ZERO, Vector2(w, SCREEN.y)), Color(0.9, 0.92, 1.0, 0.04))
			veil.draw_rect(Rect2(Vector2(SCREEN.x - w, 0), Vector2(w, SCREEN.y)), Color(0.9, 0.92, 1.0, 0.04)))
	add_child(veil)

	var panel := PanelContainer.new()
	panel.position = Vector2(140, 560)
	panel.size = Vector2(1000, 130)
	add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	_who = Label.new()
	_who.add_theme_font_size_override("font_size", 18)
	_who.add_theme_color_override("font_color", Color("f2c14e"))
	box.add_child(_who)
	_text = Label.new()
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.custom_minimum_size = Vector2(970, 0)
	_text.add_theme_font_size_override("font_size", 21)
	box.add_child(_text)
	_hint = Label.new()
	_hint.text = "Weiter: tippen, E oder Leertaste"
	_hint.position = Vector2(140, 696)
	_hint.add_theme_font_size_override("font_size", 13)
	_hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	add_child(_hint)
	var title := Label.new()
	title.text = _data.get("titel", "Erinnerung")
	title.position = Vector2(40, 24)
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(0.9, 0.92, 1.0, 0.8))
	add_child(title)

	_fade = ColorRect.new()
	_fade.size = SCREEN
	_fade.color = Color(1, 1, 1, 1)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade)
	create_tween().tween_property(_fade, "color:a", 0.0, 1.2)
	next_step()


func _process(delta: float) -> void:
	_time += delta
	_backdrop.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	var go := false
	if event is InputEventKey and event.pressed and not event.echo:
		go = event.physical_keycode in [KEY_E, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		go = true
	if go:
		get_viewport().set_input_as_handled()
		next_step()


## Nächster Schritt der Erinnerung (wartet, bis Bewegungen und Pfeile fertig sind).
func next_step() -> void:
	if _busy:
		return
	_step += 1
	var steps: Array = _data.get("schritte", [])
	if _step >= steps.size():
		_finish()
		return
	var step: Dictionary = steps[_step]
	_who.text = step.get("wer", "")
	_text.text = step.get("text", "")
	for fid: String in step.get("zeigen", []):
		if _figures.has(fid):
			var view: WorldCharacter = _figures[fid]
			view.visible = true
			view.modulate.a = 0.0
			create_tween().tween_property(view, "modulate:a", 1.0, 0.6)
	for fid: String in step.get("verschwinden", []):
		if _figures.has(fid):
			create_tween().tween_property(_figures[fid], "modulate:a", 0.0, 0.8)
	var looks: Dictionary = step.get("blick", {})
	for fid: String in looks:
		if _figures.has(fid):
			_figures[fid].facing = int(looks[fid])
	var moves: Dictionary = step.get("bewegen", {})
	if not moves.is_empty():
		_busy = true
		var tween := create_tween().set_parallel(true)
		for fid: String in moves:
			if not _figures.has(fid):
				continue
			var view: WorldCharacter = _figures[fid]
			var to := Vector2(float(moves[fid][0]), float(moves[fid][1]))
			view.moving = true
			view.facing = 1 if to.x > view.position.x else -1
			tween.tween_property(view, "position", to, MOVE_SECONDS)
		tween.chain().tween_callback(func() -> void:
			for fid: String in moves:
				if _figures.has(fid):
					_figures[fid].moving = false
			_busy = false)
	var shot: Array = step.get("pfeil", [])
	if shot.size() == 2 and _figures.has(shot[0]) and _figures.has(shot[1]):
		_shoot(_figures[shot[0]].position + Vector2(0, -40), _figures[shot[1]].position + Vector2(0, -30))


## Ein Pfeil fliegt (eine helle Linie, die sich nach vorne schiebt).
func _shoot(from: Vector2, to: Vector2) -> void:
	_busy = true
	_arrow.visible = true
	_arrow.points = PackedVector2Array([from, from])
	var tween := create_tween()
	tween.tween_method(func(t: float) -> void:
		var tip := from.lerp(to, t)
		_arrow.points = PackedVector2Array([tip - (to - from).normalized() * 40.0, tip]), 0.0, 1.0, 0.45)
	tween.tween_interval(0.3)
	tween.tween_callback(func() -> void:
		_arrow.visible = false
		_busy = false)


## Ende: Das Bild wird weiß, dann zurück in die Welt.
func _finish() -> void:
	_busy = true
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", 1.0, 1.0)
	tween.tween_callback(func() -> void:
		id = ""
		get_tree().change_scene_to_file(return_scene))


## Hintergrund: Nacht am sechsten Weg (oder was die Erinnerung unter "ort" nennt), in blassen Farben.
func _draw_backdrop() -> void:
	for i in 14:
		var t := float(i) / 13.0
		_backdrop.draw_rect(Rect2(0, i * 30.0, SCREEN.x, 31), Color("161a2c").lerp(Color("3a4058"), t))
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	for i in 60:
		var star := Vector2(rng.randf_range(0, SCREEN.x), rng.randf_range(0, 320))
		var twinkle := 0.5 + 0.5 * sin(_time * 1.5 + i)
		_backdrop.draw_rect(Rect2(star, Vector2(2, 2)), Color(0.9, 0.92, 1.0, 0.3 + 0.5 * twinkle))
	# Hügel und Waldsilhouetten
	for i in 8:
		_backdrop.draw_circle(Vector2(i * 190.0 - 30.0, 430), 150, Color("272c3e"))
	for i in 22:
		var x := float(i * 61 % 1300)
		var h := 60.0 + float((i * 37) % 70)
		_backdrop.draw_colored_polygon(PackedVector2Array([Vector2(x - 22, 420), Vector2(x, 420 - h), Vector2(x + 22, 420)]), Color("1f2433"))
	_backdrop.draw_rect(Rect2(0, 420, SCREEN.x, 300), Color("2c3242"))
	# Der Weg: von rechts (Wald) nach links in die Dunkelheit
	_backdrop.draw_colored_polygon(PackedVector2Array([Vector2(1280, 470), Vector2(1280, 560), Vector2(0, 520), Vector2(0, 480)]), Color("5a5a64"))
	for i in 18:
		var x := float(i * 72)
		_backdrop.draw_rect(Rect2(x, 490 + sin(i) * 6.0, 26, 3), Color("6e6e78"))
