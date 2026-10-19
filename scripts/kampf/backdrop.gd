class_name Backdrop
extends Control
## Hintergrund des Kampfbildschirms: ein dunkles Gewölbe aus den 0x72-Kacheln
## mit Fackeln, Lava-Brunnen, Lichtflecken und schwebendem Staub (Octopath-Stimmung).
## Andere Stile: "wiese" (vor dem Stadttor von Kreuzweg, Tag), "wiese_nacht" und "marktplatz_nacht" (Sternenfall).

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
## "gewoelbe", "wiese" oder "wiese_nacht" (vor dem Einhängen setzen)
var style := "gewoelbe"  # oder "wiese", "wiese_nacht", "marktplatz_nacht"
var _stars: Array[Vector2] = []


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
	for i in 70:
		_stars.append(Vector2(rng.randf_range(0, 1280), rng.randf_range(0, 150)))

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
	if style != "gewoelbe":
		_draw_meadow(style != "wiese", style == "marktplatz_nacht")
		return
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
	if style != "gewoelbe":
		_draw_meadow_lights(style != "wiese")
		return
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


## Wiese vor dem Stadttor von Kreuzweg: Himmel, Hügel, Stadtmauer mit Tor, Gras.
func _draw_meadow(night: bool, plaza := false) -> void:
	# Himmel als Farbverlauf in Streifen
	var sky_top := Color("0b1030") if night else Color("6fa8dc")
	var sky_low := Color("2a2550") if night else Color("f6d8a8")
	for i in 12:
		var t := float(i) / 11.0
		draw_rect(Rect2(0, i * 14.0, 1280, 15), sky_top.lerp(sky_low, t))
	if night:
		for s in _stars:
			var twinkle := 0.5 + 0.5 * sin(_time * 2.0 + s.x)
			draw_rect(Rect2(s, Vector2(2, 2)), Color(1, 1, 0.9, 0.4 + 0.6 * twinkle))
		draw_circle(Vector2(1060, 58), 22, Color("f4f0d0"))
		draw_circle(Vector2(1070, 52), 20, sky_top.lerp(sky_low, 0.3))
	# Hügel in der Ferne
	var hill := Color("27304a") if night else Color("6f9a64")
	for i in 7:
		draw_circle(Vector2(i * 220.0 - 40.0, 190), 120, hill)
	if plaza:
		_draw_plaza()
		return
	# Stadtmauer von Kreuzweg mit Tor (im Hintergrund)
	var wall := Color("3a3a52") if night else Color("a89e8a")
	var wall_dark := wall.darkened(0.25)
	draw_rect(Rect2(0, 110, 1280, 66), wall)
	for x in range(0, 1280, 32):
		draw_rect(Rect2(x, 100, 18, 12), wall)
	draw_rect(Rect2(0, 168, 1280, 8), wall_dark)
	draw_rect(Rect2(560, 92, 160, 84), wall_dark)
	draw_rect(Rect2(600, 120, 80, 56), Color("1c140e") if night else Color("4a3626"))
	for tower_x: float in [540.0, 720.0]:
		draw_rect(Rect2(tower_x, 70, 40, 106), wall)
		draw_rect(Rect2(tower_x - 4, 62, 48, 10), wall_dark)
	# Wiese: Streifen in Grüntönen, weiter vorne heller
	var grass_far := Color("1d3a2a") if night else Color("5f9a4a")
	var grass_near := Color("2b5034") if night else Color("7fbf5c")
	for row in 22:
		var t := float(row) / 21.0
		draw_rect(Rect2(0, 176 + row * 16.0, 1280, 17), grass_far.lerp(grass_near, t))
	# Grasbüschel und Blumen (fester Zufall aus _floor_pick)
	for i in _floor_pick.size():
		var x := float((i * 97) % 1280)
		var y := 190.0 + float((i * 53) % 330)
		var tuft := (grass_near if night else Color("4f8a3c")).darkened(0.15)
		draw_rect(Rect2(x, y, 4, 8), tuft)
		draw_rect(Rect2(x + 5, y + 2, 4, 6), tuft)
		if i % 9 == 0 and not night:
			draw_rect(Rect2(x + 2, y - 4, 4, 4), Color("ffe680") if i % 2 == 0 else Color("f2a0c8"))


## Marktplatz von Kreuzweg bei Nacht (Sternenfall): Häuser mit Lichtern, Festlaternen, Pflaster.
func _draw_plaza() -> void:
	var house_colors: Array[Color] = [Color("3a3048"), Color("2f2a40"), Color("41354e")]
	for i in 9:
		var x := i * 150.0 - 30.0
		var h := 70.0 + float((i * 37) % 40)
		var house := house_colors[i % house_colors.size()]
		draw_rect(Rect2(x, 176 - h, 130, h), house)
		draw_colored_polygon(PackedVector2Array([Vector2(x - 8, 176 - h), Vector2(x + 65, 176 - h - 40), Vector2(x + 138, 176 - h)]), house.darkened(0.3))
		for w in 2:
			var flicker := 0.7 + 0.3 * sin(_time * 3.0 + i + w)
			draw_rect(Rect2(x + 22 + w * 60, 176 - h + 22, 22, 22), Color(1.0, 0.8, 0.45, 0.8 * flicker))
	# Pflaster: Reihen aus Steinen, versetzt
	for row in 22:
		var y := 176 + row * 16.0
		var shade := Color("33324a").lerp(Color("4a465e"), float(row) / 21.0)
		draw_rect(Rect2(0, y, 1280, 17), shade)
		var offset := 0.0 if row % 2 == 0 else 24.0
		for x in range(0, 1300, 48):
			draw_rect(Rect2(x + offset, y, 2, 16), shade.darkened(0.25))
	# Festlaternen der fünf Regionen
	var lantern_colors: Array[Color] = [Color("b8b0ff"), Color("e0a060"), Color("ffb070"), Color("a8e088"), Color("ffb8d8")]
	for i in 5:
		var x := 120.0 + i * 260.0
		draw_rect(Rect2(x - 2, 120, 4, 60), Color("1c1620"))
		draw_rect(Rect2(x - 8, 104, 16, 18), lantern_colors[i])


## Licht auf der Wiese: Sonne bzw. Mond und Glühwürmchen.
func _draw_meadow_lights(night: bool) -> void:
	var glow := Fx.glow_texture()
	if night:
		_lights.draw_texture_rect(glow, Rect2(Vector2(960, -40), Vector2(200, 200)), false, Color(0.9, 0.9, 1.0, 0.35))
		_lights.draw_texture_rect(glow, Rect2(Vector2(0, 150), Vector2(1280, 430)), false, Color(0.5, 0.45, 1.0, 0.12))
	else:
		_lights.draw_texture_rect(glow, Rect2(Vector2(-200, -250), Vector2(700, 600)), false, Color(1.0, 0.9, 0.6, 0.35))
		_lights.draw_texture_rect(glow, Rect2(Vector2(640, 150), Vector2(640, 430)), false, Color(1.0, 0.85, 0.6, 0.15))


## Schwebender Staub im Licht (draußen: Pollen bei Tag, Glühwürmchen bei Nacht).
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
	var tone := Color(1, 0.85, 0.6) if style == "gewoelbe" else (Color(0.8, 1.0, 0.5) if style == "wiese_nacht" else Color(1, 1, 0.85))
	ramp.set_color(0, Color(tone, 0))
	ramp.add_point(0.3, Color(tone, 0.45))
	ramp.add_point(0.7, Color(tone, 0.35))
	ramp.set_color(ramp.get_point_count() - 1, Color(tone, 0))
	dust.color_ramp = ramp
	add_child(dust)
