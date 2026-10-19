class_name Fx
extends Node2D
## Kurze Licht-Effekte im Octopath-Stil: Glühen, Hieb, Funken, Ring.
## Alles wird "additiv" gezeichnet, also hellt es auf wie echtes Licht.

enum Kind { GLOW, SLASH, SPARKS, RING }

## Pixelgröße der Funken (passt zur 4-fach vergrößerten Pixel-Art).
const PIXEL := 4.0

static var _glow_texture: Texture2D
static var _add_material: CanvasItemMaterial

var kind: Kind
var color: Color
var radius: float
var life: float
var age := 0.0
var _sparks: Array[Dictionary] = []


## Weicher, runder Lichtfleck (wird für alle Leuchteffekte benutzt).
static func glow_texture() -> Texture2D:
	if _glow_texture == null:
		var gradient := Gradient.new()
		gradient.set_color(0, Color(1, 1, 1, 1))
		gradient.set_color(1, Color(1, 1, 1, 0))
		gradient.add_point(0.35, Color(1, 1, 1, 0.45))
		var texture := GradientTexture2D.new()
		texture.gradient = gradient
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5, 0.5)
		texture.fill_to = Vector2(1.0, 0.5)
		texture.width = 128
		texture.height = 128
		_glow_texture = texture
	return _glow_texture


## Material, das Licht addiert statt es zu überdecken.
static func add_material() -> CanvasItemMaterial:
	if _add_material == null:
		_add_material = CanvasItemMaterial.new()
		_add_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return _add_material


static func spawn(parent: Node, p_kind: Kind, pos: Vector2, p_color: Color, p_radius: float, p_life: float) -> Fx:
	var fx := Fx.new()
	fx.kind = p_kind
	fx.color = p_color
	fx.radius = p_radius
	fx.life = p_life
	fx.position = pos
	fx.z_index = 8
	parent.add_child(fx)
	return fx


## Eigener Zufall nur für die Optik, damit Effekte den Zufall der Spielregeln nicht verändern.
static var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	material = Fx.add_material()
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	if kind == Kind.SPARKS:
		for i in 14:
			var angle := _rng.randf() * TAU
			_sparks.append({dir = Vector2.RIGHT.rotated(angle), speed = _rng.randf_range(0.5, 1.0)})


func _process(delta: float) -> void:
	age += delta
	if age >= life:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t := age / life
	match kind:
		Kind.GLOW:
			# Schnell aufleuchten, langsam verglühen
			var a := minf(t * 6.0, 1.0) * (1.0 - t)
			var r := radius * (0.8 + 0.4 * t)
			draw_texture_rect(Fx.glow_texture(), Rect2(-r, -r, r * 2.0, r * 2.0), false, Color(color, a))
		Kind.SLASH:
			# Ein heller Hieb-Bogen, der sich öffnet und verblasst
			var sweep := lerpf(0.4, 2.4, minf(t * 2.5, 1.0))
			var a := 1.0 - t
			for i in 3:
				var w := (14.0 - i * 4.0) * (1.0 - t * 0.6)
				draw_arc(Vector2.ZERO, radius - i * 3.0, -PI * 0.5 - sweep * 0.5, -PI * 0.5 + sweep * 0.5, 16, Color(color, a * (0.35 + i * 0.3)), w)
		Kind.SPARKS:
			var a := 1.0 - t
			for s in _sparks:
				var p: Vector2 = s.dir * radius * s.speed * (1.0 - pow(1.0 - t, 3.0))
				p = (p / PIXEL).round() * PIXEL
				draw_rect(Rect2(p - Vector2(PIXEL, PIXEL) * 0.5, Vector2(PIXEL, PIXEL)), Color(color, a))
		Kind.RING:
			var r := radius * (0.3 + 0.7 * sqrt(t))
			draw_arc(Vector2.ZERO, r, 0, TAU, 40, Color(color, 1.0 - t), 10.0 * (1.0 - t) + 1.0)
