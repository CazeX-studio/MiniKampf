class_name WorldCharacter
extends Node2D
## Anzeige einer Figur in der Stadt (Spieler oder NPC): Pixel-Figur, Schatten, Name.
## Liest nur Daten, die Spiellogik steht in WorldState.

const SCALE := 3.0
## Eigene Figuren (assets/figuren/) sind größer gezeichnet und werden nur 2-fach vergrößert
const OWN_SCALE := 2.0

var moving := false
var facing := 1
## Laufbilder in vier Richtungen benutzen (wenn die Figur sie hat): schräg nach vorne oder nach hinten,
## links/rechts über facing. Vorerst nur im Baukasten-Testfeld eingeschaltet.
var richtungen := false
## Läuft bzw. schaut die Figur nach hinten (vom Betrachter weg)?
var hinten := false
## Zeichen über dem Kopf: "!" = neuer Auftrag, "?" = hier etwas erledigen, "" = nichts
var marker := ""
## Gehört das Zeichen zu einem Nebenauftrag? Dann ist es blau statt gelb.
var marker_side := false
const MARKER_COLOR := Color("ffd34d")
const MARKER_SIDE_COLOR := Color("5ab8ff")
const BUBBLE := preload("res://assets/ui/sprechblase.png")
## Wie schnell die Steh-Animation läuft (Bilder pro Sekunde). NPCs stehen ruhiger als Spieler.
var idle_fps := 6.0

var _frames := {}
var _sprite: Sprite2D
## Vergrößerung für Pixel-Bilder; fein gezeichnete Bilder werden um FighterView.fein_faktor kleiner gezeigt
var _base_scale := 1.0
var _time := 0.0
var _head_y := 0.0
var _label: Label
## Name, Zeichen und Sprechblase liegen über allem (auch über Häusern und Bäumen), damit man sie immer sieht
var _overlay: Node2D
var _bubble: PanelContainer
var _bubble_time := 0.0


func setup(look: String, p_name: String, tint := Color.WHITE, name_color := Color.WHITE) -> void:
	for anim: String in ["idle", "run", "idle_vorn", "run_vorn", "idle_hinten", "run_hinten"]:
		var frames: Array[Texture2D] = []
		var i := 0
		while ResourceLoader.exists(FighterView.sprite_path(look, anim, i)):
			frames.append(load(FighterView.sprite_path(look, anim, i)))
			i += 1
		_frames[anim] = frames
	_sprite = Sprite2D.new()
	_sprite.texture = _frames.idle[0]
	# Eigene Figuren: im Verhältnis wie im Kampf (Vega hat dort 3.0, in der Welt 2.0)
	var scale_factor: float = FighterView.look_data(look).scale * OWN_SCALE / 3.0 if FighterView.is_own_sprite(look) else SCALE
	_base_scale = scale_factor
	scale_factor /= FighterView.fein_faktor(_sprite.texture)
	_sprite.scale = Vector2(scale_factor, scale_factor)
	_sprite.centered = true
	_sprite.offset = Vector2(0, -_sprite.texture.get_height() * 0.5)
	_sprite.texture_filter = FighterView.filter_fuer(_sprite.texture)
	_sprite.self_modulate = tint
	add_child(_sprite)
	_overlay = Node2D.new()
	_overlay.z_index = 20
	_overlay.draw.connect(_draw_overlay)
	add_child(_overlay)

	var label := Label.new()
	_label = label
	label.text = p_name
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", name_color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 5)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(160, 20)
	_head_y = -_sprite.texture.get_height() * _sprite.scale.y - 24
	label.position = Vector2(-80, _head_y)
	_overlay.add_child(label)


func _process(delta: float) -> void:
	_time += delta
	if _bubble != null:
		_bubble_time -= delta
		_bubble.modulate.a = clampf(_bubble_time, 0.0, 1.0)
		_bubble.position = Vector2(-18, _head_y - _bubble.size.y + 6)
		if _bubble_time <= 0.0:
			_bubble.queue_free()
			_bubble = null
	var anim := "run" if moving and _frames.run.size() > 0 else "idle"
	var fps := 12.0 if anim == "run" else idle_fps
	if richtungen:
		var gerichtet := anim + ("_hinten" if hinten else "_vorn")
		if _frames[gerichtet].size() > 0:
			anim = gerichtet
			# Die Richtungsbilder haben 6 statt 4 Bilder pro Bewegung
			fps = 10.0 if moving else idle_fps
	var frames: Array = _frames[anim]
	_sprite.texture = frames[int(_time * fps) % frames.size()]
	_sprite.offset = Vector2(0, -_sprite.texture.get_height() * 0.5)
	# Fein gezeichnete Bilder (z. B. Vega aus Marcos Bildblättern): gleich groß, aber weich verkleinert
	var groesse := _base_scale / FighterView.fein_faktor(_sprite.texture)
	_sprite.scale = Vector2(groesse, groesse)
	_sprite.texture_filter = FighterView.filter_fuer(_sprite.texture)
	_sprite.flip_h = facing < 0
	queue_redraw()
	_overlay.queue_redraw()


func _draw() -> void:
	# Schatten unter den Füßen
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2.ZERO, 18.0, Color(0, 0, 0, 0.35))
	draw_set_transform_matrix(Transform2D.IDENTITY)


func _draw_overlay() -> void:
	if marker != "":
		var font := ThemeDB.fallback_font
		var bob := sin(_time * 2.5) * 1.5
		var pos := Vector2(-20, _head_y - 6 + bob)
		_overlay.draw_string_outline(font, pos, marker, HORIZONTAL_ALIGNMENT_CENTER, 40, 30, 7, Color.BLACK)
		_overlay.draw_string(font, pos, marker, HORIZONTAL_ALIGNMENT_CENTER, 40, 30, MARKER_SIDE_COLOR if marker_side else MARKER_COLOR)


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
	# Pergament-Sprechblase aus dem UI-Set, die Spitze unten links zeigt auf den Kopf
	var style := StyleBoxTexture.new()
	style.texture = BUBBLE
	style.texture_margin_left = 22
	style.texture_margin_right = 14
	style.texture_margin_top = 12
	style.texture_margin_bottom = 26
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 22
	_bubble.add_theme_stylebox_override("panel", style)
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color("1b1b24"))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(minf(220.0, 14.0 + text.length() * 7.5), 0)
	_bubble.add_child(label)
	_overlay.add_child(_bubble)
	_bubble.reset_size()
	_bubble.position = Vector2(-18, _head_y - _bubble.size.y + 6)
	_bubble_time = seconds


## Farbe des Namensschilds ändern (z. B. Gruppenmitglieder hellblau).
func set_name_color(color: Color) -> void:
	_label.add_theme_color_override("font_color", color)
