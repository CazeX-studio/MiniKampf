class_name Abspann
extends Control
## Abspann von Akt 1 (Ende der Kreuzweg-Demo): Abreise. Danach geht es mit demselben Spielstand weiter nach Grünwacht
## (Entscheidung 21.10.: In dieser Demo ist Grünwacht für alle die erste Region).

const SCREEN := Vector2(1280, 720)
## "" = Ende von Akt 1 (Kreuzweg), "gruenwacht" = Ende der Region Grünwacht (Rückblick auf die Entscheidungen)
static var variante := ""


func _ready() -> void:
	theme = Combat.make_theme()
	Musik.play("nacht")
	var bg := ColorRect.new()
	bg.color = Color("0b0d1a")
	bg.size = SCREEN
	add_child(bg)

	var klasse := SaveGame.get_flag("klasse")
	var data: Dictionary = Sandbox.CLASSES.get(klasse, {title = "Novize", region = "die Welt"})
	var extra: Dictionary = GameData.get_file("klassen").get(klasse, {})

	var box := VBoxContainer.new()
	box.position = Vector2(140, 150)
	box.size = Vector2(1000, 0)
	box.add_theme_constant_override("separation", 22)
	add_child(box)
	if variante == "gruenwacht":
		_gruenwacht(box)
		return
	box.add_child(_label("Ende von Akt 1", 44, Color("f2c14e")))
	var journey := "Dein Weg führt hinaus in die Welt."
	if extra.has("lehrmeister"):
		var wohin: String = GameData.get_file("klassen").get("wohin", {}).get(data.region, "nach " + str(data.region))
		journey = "Dein Weg führt %s, zu %s." % [wohin, extra.lehrmeister]
	box.add_child(_label("Du verlässt Kreuzweg als %s.\n%s" % [data.title, journey], 24, Color.WHITE))
	box.add_child(_label("Hinter dir bleibt die Statue der Fünf zurück – und eine sechste Straße, die niemand benutzt.", 19, Color(1, 1, 1, 0.7)))
	if data.region != "Grünwacht":
		box.add_child(_label("%s ist in dieser Demo noch nicht gebaut. Deine Reise beginnt deshalb in Grünwacht." % data.region, 19, Color(1, 1, 1, 0.7)))
	box.add_child(_label("Die Reise geht weiter: Folge der Weststraße nach Grünwacht.", 22, Color("8affc1")))

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	box.add_child(row)
	var go := Button.new()
	go.text = "Weiter nach Grünwacht"
	go.custom_minimum_size = Vector2(300, 60)
	go.add_theme_font_size_override("font_size", 20)
	go.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/kreuzweg.tscn"))
	row.add_child(go)
	var menu := Button.new()
	menu.text = "Zum Menü"
	menu.custom_minimum_size = Vector2(240, 60)
	menu.add_theme_font_size_override("font_size", 20)
	menu.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/menu.tscn"))
	row.add_child(menu)
	var again := Button.new()
	again.text = "Neu beginnen"
	again.custom_minimum_size = Vector2(240, 60)
	again.add_theme_font_size_override("font_size", 20)
	again.pressed.connect(func() -> void:
		SaveGame.delete()
		get_tree().change_scene_to_file("res://scenes/kreuzweg.tscn"))
	row.add_child(again)


## Ende der Region Grünwacht: Rückblick auf die eigenen Entscheidungen, dann zurück nach Wipfelheim.
func _gruenwacht(box: VBoxContainer) -> void:
	box.position.y = 90
	box.add_child(_label("Ende von Grünwacht", 44, Color("a8e088")))
	var flags: Dictionary = SaveGame.read_progress().get("flags", {})
	var lines: PackedStringArray = []
	for entry: Array in GameData.get_file("texte").get("rueckblick_gruenwacht", []):
		if flags.has(entry[0]):
			lines.append("• " + str(entry[1]))
	box.add_child(_label("\n".join(lines), 20, Color.WHITE))
	box.add_child(_label(GameData.text("ende_gruenwacht"), 21, Color(1, 1, 1, 0.75)))
	box.add_child(_label(GameData.text("ende_gruenwacht_weiter"), 20, Color("8affc1")))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	box.add_child(row)
	for info: Array in [["Zurück nach Wipfelheim", "res://scenes/kreuzweg.tscn"], ["Zum Menü", "res://scenes/menu.tscn"]]:
		var button := Button.new()
		button.text = info[0]
		button.custom_minimum_size = Vector2(280, 60)
		button.add_theme_font_size_override("font_size", 20)
		var target: String = info[1]
		button.pressed.connect(func() -> void:
			variante = ""
			get_tree().change_scene_to_file(target))
		row.add_child(button)


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(1000, 0)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
