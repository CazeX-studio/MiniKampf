class_name Klassenwahl
extends Control
## Klassenwahl am Ende der ersten Stunde (design.md: „Klassenwahl-Bildschirm“):
## Alle 11 Klassen mit Rolle, Region, Lehrmeister, Mechanik, Diagramm aus fünf Werten, Ult-Vorschau,
## Knopf „Probestunde“. Man wählt eine. Die Wahl wird im Spielstand gemerkt, danach geht es zurück nach Kreuzweg.
## Texte und Werte: data/klassen.json und scripts/kampf/sandbox.gd.
## Bei einem Gesandten (region gesetzt) zeigt derselbe Bildschirm nur die Klassen seiner Region – zum Ansehen
## und für die Probestunde. Gewählt wird erst am Tag der Abreise bei Ye.

const SCREEN := Vector2(1280, 720)
const AXES: Array[String] = ["schaden", "schutz", "heilung", "unterstuetzung", "schwierigkeit"]
const AXIS_NAMES := {schaden = "Schaden", schutz = "Schutz", heilung = "Heilung", unterstuetzung = "Unterstützung", schwierigkeit = "Schwierigkeit"}
const MAX_VALUE := 5.0

## Region des Gesandten, dessen Klassen gezeigt werden ("" = Klassenwahl bei Ye mit allen Klassen)
static var region := ""

var _selected := ""
var _list_buttons := {}
var _title: Label
var _info: RichTextLabel
var _ult: RichTextLabel
var _diagram: Control
var _portrait: TextureRect
var _confirm: PanelContainer
var _confirm_text: Label


func _ready() -> void:
	theme = Combat.make_theme()
	Musik.play("stadt")
	_build()
	_select(_classes()[0])


func _build() -> void:
	add_child(Backdrop.new())
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.06, 0.82)
	shade.size = SCREEN
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var heading := Label.new()
	heading.text = "Wähle deinen Weg" if region == "" else "Klassen der Region %s" % region
	heading.position = Vector2(28, 12)
	heading.add_theme_font_size_override("font_size", 30)
	heading.add_theme_color_override("font_color", Color("f2c14e"))
	add_child(heading)

	var back := Button.new()
	back.text = "Zurück"
	back.position = Vector2(1150, 16)
	back.size = Vector2(110, 44)
	back.pressed.connect(func() -> void:
		region = ""
		get_tree().change_scene_to_file("res://scenes/kreuzweg.tscn"))
	add_child(back)

	# Links: alle Klassen
	var list := VBoxContainer.new()
	list.position = Vector2(28, 66)
	list.add_theme_constant_override("separation", 5)
	add_child(list)
	for id: String in _classes():
		var data: Dictionary = Sandbox.CLASSES[id]
		var button := Button.new()
		button.text = "%s  ·  %s" % [data.title, data.role]
		button.custom_minimum_size = Vector2(300, 52 if region == "" else 80)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_size_override("font_size", 17)
		button.add_theme_color_override("font_color", Sandbox.ROLE_COLORS[data.role].lightened(0.35))
		button.pressed.connect(_select.bind(id))
		list.add_child(button)
		_list_buttons[id] = button

	# Rechts: Einzelheiten der gewählten Klasse
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.05, 0.11, 0.92)
	style.border_color = Color(0.85, 0.72, 0.45, 0.7)
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	panel.add_theme_stylebox_override("panel", style)
	panel.position = Vector2(352, 66)
	panel.size = Vector2(900, 640)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	_portrait = TextureRect.new()
	_portrait.position = Vector2(372, 84)
	_portrait.size = Vector2(110, 140)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_portrait)

	_title = Label.new()
	_title.position = Vector2(500, 84)
	_title.add_theme_font_size_override("font_size", 30)
	_title.add_theme_color_override("font_color", Color("f2c14e"))
	add_child(_title)

	_info = RichTextLabel.new()
	_info.bbcode_enabled = true
	_info.position = Vector2(500, 130)
	_info.size = Vector2(730, 200)
	_info.add_theme_font_size_override("normal_font_size", 17)
	_info.add_theme_font_size_override("bold_font_size", 17)
	add_child(_info)

	_diagram = Control.new()
	_diagram.position = Vector2(372, 340)
	_diagram.size = Vector2(380, 290)
	_diagram.draw.connect(_draw_diagram)
	add_child(_diagram)

	_ult = RichTextLabel.new()
	_ult.bbcode_enabled = true
	_ult.position = Vector2(780, 350)
	_ult.size = Vector2(450, 220)
	_ult.add_theme_font_size_override("normal_font_size", 16)
	_ult.add_theme_font_size_override("bold_font_size", 17)
	add_child(_ult)

	var trial := Button.new()
	trial.text = "Probestunde"
	trial.position = Vector2(780, 630)
	trial.size = Vector2(200, 56)
	trial.add_theme_font_size_override("font_size", 18)
	trial.pressed.connect(_trial)
	add_child(trial)

	var choose := Button.new()
	choose.text = "Diese Klasse wählen"
	choose.position = Vector2(1000, 630)
	choose.size = Vector2(240, 56)
	choose.add_theme_font_size_override("font_size", 18)
	choose.add_theme_color_override("font_color", Color("f2c14e"))
	choose.pressed.connect(_ask_confirm)
	add_child(choose)
	if region != "":
		# Beim Gesandten wird nur geschaut und ausprobiert
		choose.visible = false
		trial.position.x = 1040
		var note := Label.new()
		note.text = "Wählen kannst du am Tag der Abreise bei Ye."
		note.position = Vector2(28, 660)
		note.add_theme_font_size_override("font_size", 15)
		note.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
		add_child(note)

	# Nachfrage vor der Wahl
	_confirm = PanelContainer.new()
	_confirm.add_theme_stylebox_override("panel", style)
	_confirm.position = Vector2(440, 260)
	_confirm.size = Vector2(400, 0)
	_confirm.visible = false
	_confirm.z_index = 10
	add_child(_confirm)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	_confirm.add_child(box)
	_confirm_text = Label.new()
	_confirm_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_confirm_text.add_theme_font_size_override("font_size", 22)
	box.add_child(_confirm_text)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	box.add_child(row)
	var yes := Button.new()
	yes.text = "Ja"
	yes.custom_minimum_size = Vector2(150, 50)
	yes.pressed.connect(_choose)
	row.add_child(yes)
	var no := Button.new()
	no.text = "Noch nicht"
	no.custom_minimum_size = Vector2(150, 50)
	no.pressed.connect(func() -> void: _confirm.visible = false)
	row.add_child(no)


## Die Klassen, die dieser Bildschirm zeigt (alle oder nur die der Region des Gesandten).
func _classes() -> Array:
	var order: Array = GameData.get_file("klassen").get("reihenfolge", Sandbox.CLASS_ORDER)
	if region == "":
		return order
	return order.filter(func(id: String) -> bool: return Sandbox.CLASSES[id].region == region)


func _select(id: String) -> void:
	_selected = id
	for other: String in _list_buttons:
		_list_buttons[other].modulate = Color.WHITE if other == id else Color(1, 1, 1, 0.65)
	var data: Dictionary = Sandbox.CLASSES[id]
	var extra: Dictionary = GameData.get_file("klassen").get(id, {})
	_title.text = data.title
	_portrait.texture = FighterView.portrait(id)
	_portrait.self_modulate = FighterView.tint(id)
	_info.text = "\n".join([
		"[color=#%s]%s[/color]  ·  %s" % [Sandbox.ROLE_COLORS[data.role].lightened(0.3).to_html(false), data.role, data.region],
		"[b]Lehrmeister:[/b] %s" % extra.get("lehrmeister", "?"),
		"[b]Mechanik:[/b] %s" % data.mechanic,
		"[b]Reaktion:[/b] %s" % data.reaction_text,
	])
	_ult.text = "[b][color=#f2c14e]Ult-Vorschau[/color][/b]\n%s" % extra.get("ult_vorschau", data.ult)
	_diagram.queue_redraw()


## Fünfeck-Diagramm mit den fünf Werten der Klasse.
func _draw_diagram() -> void:
	if _selected == "":
		return
	var values: Dictionary = GameData.get_file("klassen").get(_selected, {}).get("werte", {})
	var center := Vector2(190, 150)
	var radius := 105.0
	var font := ThemeDB.fallback_font
	var points := PackedVector2Array()
	for i in AXES.size():
		var dir := Vector2.UP.rotated(TAU * i / AXES.size())
		# Hilfslinien
		_diagram.draw_line(center, center + dir * radius, Color(1, 1, 1, 0.2), 1.0)
		var value := clampf(float(values.get(AXES[i], 0)) / MAX_VALUE, 0.0, 1.0)
		points.append(center + dir * radius * maxf(value, 0.04))
		var label_pos := center + dir * (radius + 22.0) + Vector2(-60, 6)
		_diagram.draw_string(font, label_pos, str(AXIS_NAMES[AXES[i]]),
				HORIZONTAL_ALIGNMENT_CENTER, 120, 14, Color(1, 1, 1, 0.85))
	for ring in [0.2, 0.4, 0.6, 0.8, 1.0]:
		var outline := PackedVector2Array()
		for i in AXES.size() + 1:
			outline.append(center + Vector2.UP.rotated(TAU * i / AXES.size()) * radius * ring)
		_diagram.draw_polyline(outline, Color(1, 1, 1, 0.12), 1.0)
	_diagram.draw_colored_polygon(points, Color(Sandbox.CLASSES[_selected].color, 0.45))
	points.append(points[0])
	_diagram.draw_polyline(points, Sandbox.CLASSES[_selected].color.lightened(0.3), 2.5)


## Probestunde direkt von hier: danach zurück zur Klassenwahl.
func _trial() -> void:
	var progress: Dictionary = SaveGame.read_progress()
	var level := int(progress.get("level", 1))
	var potions := int(progress.get("items", {}).get("heiltrank", 0))
	if BattleRequest.prepare("probe:" + _selected, level, potions):
		BattleRequest.return_scene = "res://scenes/klassenwahl.tscn"
		get_tree().change_scene_to_file("res://scenes/kampf.tscn")


## Klasse gewählt: im Spielstand merken und zurück zu Ye.
func _choose() -> void:
	SaveGame.set_flag("klasse", _selected)
	SaveGame.set_flag("klasse_gewaehlt", "ja")
	get_tree().change_scene_to_file("res://scenes/kreuzweg.tscn")


func _ask_confirm() -> void:
	_confirm_text.text = "Willst du %s werden?" % Sandbox.CLASSES[_selected].title
	_confirm.visible = true
