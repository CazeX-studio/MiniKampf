class_name Backdrop
extends Control
## Hintergrund des Kampfbildschirms: ein dunkles Gewölbe aus den 0x72-Kacheln
## mit Fackeln, Lava-Brunnen, Lichtflecken und schwebendem Staub (Octopath-Stimmung).

const TILE_PATH := "res://assets/0x72_dungeontileset_ii/%s.png"
## Kacheln sind 16 Pixel groß und werden 4-fach vergrößert.
const SCALE := 4.0
const TILE := 64.0
const WALL_TOP_Y := -16.0
const FLOOR_Y := 176.0
const COLUMNS := 20
const ROWS_FLOOR := 6
## Grundfarbe: Das Gewölbe liegt im Halbdunkel, Licht kommt von Fackeln und Lava.
const AMBIENT := Color(0.5, 0.47, 0.62)

## Wo Fackeln an der Wand hängen (Kachel-Spalte).
const TORCH_COLUMNS: Array[int] = [2, 6, 13, 17]
const FOUNTAIN_COLUMN := 10
const PILLAR_COLUMNS: Array[int] = [4, 8, 12, 16]

var _tex := {}
var _floor_pick: Array[String] = []
var _wall_pick: Array[String] = []
var _time := 0.0
var _lights: Node2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(1280, 720)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Fest eingestellter Zufall, damit der Boden jedes Mal gleich aussieht
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in COLUMNS * ROWS_FLOOR:
		var roll := rng.randf()
		_floor_pick.append("floor_1" if roll < 0.55 else "floor_%d" % rng.randi_range(2, 8))
	for i in COLUMNS * 2:
		var roll := rng.randf()
		var name := "wall_mid"
		if roll < 0.06:
			name = "wall_hole_1"
		elif roll < 0.1:
			name = "wall_hole_2"
		_wall_pick.append(name)

	_lights = Node2D.new()
	_lights.material = Fx.add_material()
	_lights.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_lights.draw.connect(_draw_lights)
	add_child(_lights)

	_add_dust()


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()
	_lights.queue_redraw()


func _t(name: String) -> Texture2D:
	if not _tex.has(name):
		_tex[name] = load(TILE_PATH % name)
	return _tex[name]


func _tile(name: String, col: int, y: float, tint := AMBIENT) -> void:
	draw_texture_rect(_t(name), Rect2(col * TILE, y, TILE, TILE), false, tint)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("07060c"))
	var frame3 := int(_time * 6.0) % 3

	# Boden: weiter hinten etwas dunkler, damit Tiefe entsteht
	for row in ROWS_FLOOR:
		var depth := 0.75 + 0.25 * float(row) / ROWS_FLOOR
		for col in COLUMNS:
			_tile(_floor_pick[row * COLUMNS + col], col, FLOOR_Y + row * TILE, AMBIENT * Color(depth, depth, depth))

	# Wand: oben die Mauerkrone, darunter zwei Reihen Mauer
	for col in COLUMNS:
		_tile("wall_top_mid", col, WALL_TOP_Y)
		for row in 2:
			_tile(_wall_pick[row * COLUMNS + col], col, WALL_TOP_Y + TILE * (row + 1))

	# Säulen in der Wand
	for col in PILLAR_COLUMNS:
		_tile("wall_column_top", col, WALL_TOP_Y)
		_tile("wall_column_mid", col, WALL_TOP_Y + TILE)
		_tile("wall_column_mid", col, WALL_TOP_Y + TILE * 2)
		_tile("wall_coulmn_base", col, FLOOR_Y)

	# Banner: blau bei den Helden, rot bei den Gegnern
	for col: int in [1, 7]:
		_tile("wall_banner_red", col, WALL_TOP_Y + TILE)
	for col: int in [14, 19]:
		_tile("wall_banner_blue", col, WALL_TOP_Y + TILE)

	# Lava-Brunnen in der Mitte (leuchtet selbst, darum heller)
	var lava := Color(1, 0.9, 0.85)
	_tile("wall_fountain_top", FOUNTAIN_COLUMN, WALL_TOP_Y)
	_tile("wall_fountain_mid_red_anim_f%d" % frame3, FOUNTAIN_COLUMN, WALL_TOP_Y + TILE, lava)
	_tile("wall_fountain_mid_red_anim_f%d" % frame3, FOUNTAIN_COLUMN, WALL_TOP_Y + TILE * 2, lava)
	_tile("wall_fountain_basin_red_anim_f%d" % frame3, FOUNTAIN_COLUMN, FLOOR_Y, lava)

	# Fackeln: Halter und flackernde Pixel-Flamme
	for col in TORCH_COLUMNS:
		_draw_torch(Vector2(col * TILE + TILE * 0.5, WALL_TOP_Y + TILE * 1.55), col)


func _draw_torch(base: Vector2, seed_value: int) -> void:
	var p := SCALE
	draw_rect(Rect2(base.x - p, base.y, p * 2, p * 5), Color("3a2a1e"))
	draw_rect(Rect2(base.x - p * 2, base.y, p * 4, p), Color("5b4330"))
	var flicker := int(_time * 9.0 + seed_value * 3) % 3
	var heights: Array[int] = [4, 5, 3]
	var h := heights[flicker]
	for i in h:
		var w := 3 if i < 2 else (2 if i < h - 1 else 1)
		var color := Color("ffe9a8") if i < 1 else (Color("ffb347") if i < 3 else Color("ff6a2a"))
		var sway := p if i == h - 1 and flicker == 1 else 0.0
		draw_rect(Rect2(base.x - w * p * 0.5 + sway, base.y - (i + 1) * p, w * p, p), color)


## Lichtflecken (werden addiert und hellen die Szene auf).
func _draw_lights() -> void:
	var glow := Fx.glow_texture()
	for col in TORCH_COLUMNS:
		var pos := Vector2(col * TILE + TILE * 0.5, WALL_TOP_Y + TILE * 1.4)
		var flicker := 0.85 + 0.15 * sin(_time * 11.0 + col) * sin(_time * 7.3 + col * 2.0)
		var r := 150.0 * flicker
		_lights.draw_texture_rect(glow, Rect2(pos - Vector2(r, r), Vector2(r, r) * 2.0), false, Color(1.0, 0.55, 0.2, 0.32 * flicker))
		_lights.draw_texture_rect(glow, Rect2(pos - Vector2(26, 26), Vector2(52, 52)), false, Color(1.0, 0.8, 0.4, 0.6 * flicker))
	# Lava-Brunnen: rotes Glühen
	var lava_pos := Vector2(FOUNTAIN_COLUMN * TILE + TILE * 0.5, FLOOR_Y - 10)
	var pulse := 0.9 + 0.1 * sin(_time * 2.0)
	_lights.draw_texture_rect(glow, Rect2(lava_pos - Vector2(220, 200) * pulse, Vector2(440, 400) * pulse), false, Color(1.0, 0.25, 0.1, 0.35))
	# Lichtkegel, in denen die Kämpfer stehen
	_lights.draw_texture_rect(glow, Rect2(Vector2(640, 150), Vector2(640, 430)), false, Color(1.0, 0.75, 0.5, 0.22))
	_lights.draw_texture_rect(glow, Rect2(Vector2(0, 150), Vector2(640, 430)), false, Color(0.6, 0.45, 1.0, 0.2))


## Schwebender Staub im Licht.
func _add_dust() -> void:
	var dust := CPUParticles2D.new()
	dust.material = Fx.add_material()
	dust.amount = 45
	dust.lifetime = 9.0
	dust.preprocess = 9.0
	dust.position = Vector2(640, 330)
	dust.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	dust.emission_rect_extents = Vector2(640, 220)
	dust.direction = Vector2(0.3, -1)
	dust.spread = 40.0
	dust.gravity = Vector2.ZERO
	dust.initial_velocity_min = 4.0
	dust.initial_velocity_max = 12.0
	dust.scale_amount_min = 2.0
	dust.scale_amount_max = 4.0
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1, 0.85, 0.6, 0))
	ramp.add_point(0.3, Color(1, 0.85, 0.6, 0.45))
	ramp.add_point(0.7, Color(1, 0.85, 0.6, 0.35))
	ramp.set_color(ramp.get_point_count() - 1, Color(1, 0.85, 0.6, 0))
	dust.color_ramp = ramp
	add_child(dust)
