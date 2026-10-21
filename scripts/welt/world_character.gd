class_name WorldCharacter
extends Node2D
## Anzeige einer Figur in der Stadt (Spieler oder NPC): Pixel-Figur, Schatten, Name.
## Liest nur Daten, die Spiellogik steht in WorldState.

const SPRITE_PATH := "res://assets/0x72_dungeontileset_ii/%s_%s_anim_f%d.png"
const SCALE := 3.0

var moving := false
var facing := 1
## Zeichen über dem Kopf: "!" = neuer Auftrag, "?" = hier etwas erledigen, "" = nichts
var marker := ""
## Gehört das Zeichen zu einem Nebenauftrag? Dann ist es blau statt gelb.
var marker_side := false
const MARKER_COLOR := Color("ffd34d")
const MARKER_SIDE_COLOR := Color("5ab8ff")
## Wie schnell die Steh-Animation läuft (Bilder pro Sekunde). NPCs stehen ruhiger als Spieler.
var idle_fps := 6.0

var _frames := {}
var _sprite: Sprite2D
var _time := 0.0
var _head_y := 0.0
var _label: Label
var _bubble: PanelContainer
var _bubble_time := 0.0


func setup(look: String, p_name: String, tint := Color.WHITE, name_color := Color.WHITE) -> void:
	for anim: String in ["idle", "run"]:
		var frames: Array[Texture2D] = []
		var i := 0
		while ResourceLoader.exists(SPRITE_PATH % [look, anim, i]):
			frames.append(load(SPRITE_PATH % [look, anim, i]))
			i += 1
		_frames[anim] = frames
	_sprite = Sprite2D.new()
	_sprite.texture = _frames.idle[0]
	_sprite.scale = Vector2(SCALE, SCALE)
	_sprite.centered = true
	_sprite.offset = Vector2(0, -_sprite.texture.get_height() * 0.5)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.self_modulate = tint
	add_child(_sprite)

	var label := Label.new()
	_label = label
	label.text = p_name
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", name_color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 5)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(160, 20)
	_head_y = -_sprite.texture.get_height() * SCALE - 24
	label.position = Vector2(-80, _head_y)
	add_child(label)


func _process(delta: float) -> void:
	_time += delta
	if _bubble != null:
		_bubble_time -= delta
		_bubble.modulate.a = clampf(_bubble_time, 0.0, 1.0)
		_bubble.position = Vector2(-_bubble.size.x * 0.5, _head_y - _bubble.size.y - 4)
		if _bubble_time <= 0.0:
			_bubble.queue_free()
			_bubble = null
	var anim := "run" if moving and _frames.run.size() > 0 else "idle"
	var frames: Array = _frames[anim]
	_sprite.texture = frames[int(_time * (12.0 if anim == "run" else idle_fps)) % frames.size()]
	_sprite.flip_h = facing < 0
	queue_redraw()


func _draw() -> void:
	# Schatten unter den Füßen
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2.ZERO, 18.0, Color(0, 0, 0, 0.35))
	draw_set_transform_matrix(Transform2D.IDENTITY)
	if marker != "":
		var font := ThemeDB.fallback_font
		var bob := sin(_time * 2.5) * 1.5
		var pos := Vector2(-20, _head_y - 6 + bob)
		draw_string_outline(font, pos, marker, HORIZONTAL_ALIGNMENT_CENTER, 40, 30, 7, Color.BLACK)
		draw_string(font, pos, marker, HORIZONTAL_ALIGNMENT_CENTER, 40, 30, MARKER_SIDE_COLOR if marker_side else MARKER_COLOR)


## Animation an einer anderen Stelle beginnen lassen (damit nicht alle Figuren gleichzeitig wippen).
func time_offset(seconds: float) -> void:
	_time += seconds


## Namensschild ein- oder ausblenden (weit entfernte NPCs zeigen keinen Namen, damit es übersichtlich bleibt).
func set_name_alpha(alpha: float) -> void:
	_label.modulate.a = alpha


## Sprechblase über dem Kopf (Chat beim Zusammenspielen), verschwindet nach ein paar Sekunden.
func say(text: String, seconds := 6.0) -> void:
	if _bubble != null:
		_bubble.queue_free()
	_bubble = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.92)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(6)
	_bubble.add_theme_stylebox_override("panel", style)
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color("1b1b24"))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(minf(220.0, 14.0 + text.length() * 7.5), 0)
	_bubble.add_child(label)
	add_child(_bubble)
	_bubble.reset_size()
	_bubble.position = Vector2(-_bubble.size.x * 0.5, _head_y - _bubble.size.y - 4)
	_bubble_time = seconds


## Farbe des Namensschilds ändern (z. B. Gruppenmitglieder hellblau).
func set_name_color(color: Color) -> void:
	_label.add_theme_color_override("font_color", color)
