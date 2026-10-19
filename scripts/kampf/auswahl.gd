extends Control
## Auswahl-Bildschirm der Kampf-Sandbox: bis zu 4 Klassen fürs Team, Start-Monster des Zähmers
## und die Gegner wählen. Danach startet der Kampf (scenes/kampf.tscn).

const SCREEN := Vector2(1280, 720)
const CARD_SIZE := Vector2(300, 124)

var _cards := {}
var _team_label: RichTextLabel
var _starter_buttons := {}
var _encounter_buttons := {}
var _starter_box: HBoxContainer
var _start: Button


func _ready() -> void:
	theme = Combat.make_theme()
	_build()
	_update()


func _build() -> void:
	add_child(Backdrop.new())
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.05, 0.78)
	shade.size = SCREEN
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var title := Label.new()
	title.text = "Kampf-Sandbox: Wähle bis zu 4 Klassen"
	title.position = Vector2(28, 10)
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color("f2c14e"))
	add_child(title)

	var grid := GridContainer.new()
	grid.columns = 4
	grid.position = Vector2(28, 52)
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	add_child(grid)
	for id in Sandbox.CLASS_ORDER:
		var card := _make_card(id)
		grid.add_child(card)
		_cards[id] = card

	# Untere Leiste: Team und Duette, Zähmer-Monster, Gegner, Start
	_team_label = RichTextLabel.new()
	_team_label.bbcode_enabled = true
	# Steht im freien zwölften Kartenplatz
	_team_label.position = Vector2(960, 318)
	_team_label.size = Vector2(296, 128)
	_team_label.add_theme_font_size_override("normal_font_size", 14)
	_team_label.add_theme_font_size_override("bold_font_size", 15)
	_team_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_team_label)

	_add_heading("Gegner", Vector2(28, 458))
	var encounters := GridContainer.new()
	encounters.columns = 3
	encounters.position = Vector2(28, 484)
	encounters.add_theme_constant_override("h_separation", 8)
	encounters.add_theme_constant_override("v_separation", 6)
	add_child(encounters)
	for id in Sandbox.ENCOUNTER_ORDER:
		var data: Dictionary = Sandbox.ENCOUNTERS[id]
		var button := _toggle("%s\n%s" % [data.name, data.info], Vector2(200, 48))
		button.add_theme_font_size_override("font_size", 11)
		button.pressed.connect(func() -> void:
			Sandbox.encounter = id
			_update())
		encounters.add_child(button)
		_encounter_buttons[id] = button

	_starter_box = HBoxContainer.new()
	_starter_box.position = Vector2(660, 484)
	_starter_box.add_theme_constant_override("separation", 8)
	add_child(_starter_box)
	for id in Sandbox.MONSTER_ORDER:
		var data: Dictionary = Sandbox.MONSTERS[id]
		var button := _toggle("%s\n%s\n%s" % [data.name, data.element, data.role], Vector2(88, 80))
		button.add_theme_font_size_override("font_size", 12)
		button.pressed.connect(func() -> void:
			Sandbox.starter = id
			_update())
		_starter_box.add_child(button)
		_starter_buttons[id] = button
	_add_heading("Start-Monster (Zähmer)", Vector2(660, 458))

	var random := Button.new()
	random.text = "Zufallsteam"
	random.position = Vector2(948, 484)
	random.size = Vector2(140, 80)
	random.add_theme_font_size_override("font_size", 17)
	random.pressed.connect(_random_team)
	add_child(random)

	_start = Button.new()
	_start.text = "Kampf starten!"
	_start.position = Vector2(1096, 484)
	_start.size = Vector2(162, 80)
	_start.add_theme_font_size_override("font_size", 19)
	_start.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/kampf.tscn"))
	add_child(_start)

	var menu := Button.new()
	menu.text = "Menü"
	menu.position = Vector2(1170, 8)
	menu.size = Vector2(96, 40)
	menu.add_theme_font_size_override("font_size", 16)
	menu.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/menu.tscn"))
	add_child(menu)

	var hint := Label.new()
	hint.text = "Karte antippen = ins Team nehmen oder wieder herausnehmen. Klassen-Paare aus derselben Region haben eine Duett-Fähigkeit.\nTanks stehen vorne, die anderen hinten. Am Ende zeigt die Auswertung Schaden, Heilung und abgewehrten Schaden pro Klasse."
	hint.position = Vector2(28, 590)
	hint.size = Vector2(1224, 60)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
	add_child(hint)


func _add_heading(text: String, pos: Vector2) -> Label:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color("f2c14e"))
	add_child(label)
	return label


func _toggle(text: String, min_size: Vector2) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = min_size
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.add_theme_font_size_override("font_size", 14)
	return button


## Eine Karte pro Klasse: Bild, Name, Rolle, Region, Mechanik, Reaktion.
func _make_card(id: String) -> Button:
	var data: Dictionary = Sandbox.CLASSES[id]
	var card := Button.new()
	card.custom_minimum_size = CARD_SIZE
	card.pressed.connect(_toggle_class.bind(id))

	var portrait := TextureRect.new()
	portrait.texture = FighterView.portrait(id)
	portrait.self_modulate = FighterView.tint(id)
	portrait.flip_h = true
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.position = Vector2(6, 12)
	portrait.size = Vector2(48, 84)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(portrait)

	var name_label := _card_label("%s · %s" % [data.title, data.hero], Vector2(60, 6), 16, Color.WHITE)
	card.add_child(name_label)
	var role := _card_label("%s · %s" % [data.role, data.region], Vector2(60, 27), 12, Sandbox.ROLE_COLORS[data.role])
	card.add_child(role)
	var mechanic := _card_label(data.mechanic, Vector2(60, 44), 11, Color(1, 1, 1, 0.85))
	mechanic.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mechanic.clip_text = false
	card.add_child(mechanic)
	# Größe erst setzen, wenn das Label im Baum ist, sonst bricht der Text nicht um
	mechanic.set_deferred("size", Vector2(232, 52))
	var reaction := _card_label("Reaktion: " + data.reaction_text, Vector2(60, 100), 11, Color("8affc1"))
	card.add_child(reaction)
	return card


func _card_label(text: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.clip_text = true
	label.size = Vector2(236, 20)
	return label


func _toggle_class(id: String) -> void:
	if id in Sandbox.team:
		Sandbox.team.erase(id)
	elif Sandbox.team.size() < Sandbox.MAX_TEAM:
		Sandbox.team.append(id)
	_update()


func _random_team() -> void:
	var pool := Sandbox.CLASS_ORDER.duplicate()
	pool.shuffle()
	Sandbox.team.assign(pool.slice(0, Sandbox.MAX_TEAM))
	_update()


func _update() -> void:
	for id: String in _cards:
		var card: Button = _cards[id]
		var chosen := id in Sandbox.team
		var box := StyleBoxFlat.new()
		box.bg_color = Color(0.14, 0.12, 0.05, 0.97) if chosen else Color(0.06, 0.07, 0.15, 0.95)
		box.border_color = Color("f2c14e") if chosen else Color(0.85, 0.72, 0.45, 0.35)
		box.set_border_width_all(3 if chosen else 1)
		box.set_corner_radius_all(4)
		card.add_theme_stylebox_override("normal", box)
		card.add_theme_stylebox_override("hover", box)
		card.add_theme_stylebox_override("pressed", box)

	for id: String in _encounter_buttons:
		_encounter_buttons[id].add_theme_color_override("font_color", Color("f2c14e") if id == Sandbox.encounter else Color("f3ead8"))
		_encounter_buttons[id].modulate = Color.WHITE if id == Sandbox.encounter else Color(1, 1, 1, 0.6)
	var tamer := "tamer" in Sandbox.team
	for id: String in _starter_buttons:
		_starter_buttons[id].disabled = not tamer
		_starter_buttons[id].add_theme_color_override("font_color", Elements.color(Sandbox.MONSTERS[id].element) if id == Sandbox.starter else Color("f3ead8"))
		_starter_buttons[id].modulate = Color.WHITE if id == Sandbox.starter or not tamer else Color(1, 1, 1, 0.6)

	var text := "[b]Dein Team (%d/%d)[/b]\n" % [Sandbox.team.size(), Sandbox.MAX_TEAM]
	for id in Sandbox.team:
		var data: Dictionary = Sandbox.CLASSES[id]
		text += "[color=#%s]%s[/color] %s\n" % [Sandbox.ROLE_COLORS[data.role].to_html(false), data.role, data.title]
	var duets := Sandbox.active_duets(Sandbox.team)
	if not duets.is_empty():
		var names: Array[String] = []
		for duet in duets:
			names.append(duet.name)
		text += "[color=#ffa8e0]Duett: %s[/color]" % ", ".join(names)
	elif Sandbox.team.size() > 1:
		text += "[color=#888888]Kein Duett-Paar im Team[/color]"
	_team_label.text = text
	_start.disabled = Sandbox.team.is_empty()
