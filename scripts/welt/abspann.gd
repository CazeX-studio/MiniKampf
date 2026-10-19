extends Control
## Abspann der Kreuzweg-Demo: Abreise in die Region der gewählten Klasse.

const SCREEN := Vector2(1280, 720)


func _ready() -> void:
	theme = Combat.make_theme()
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
	box.add_child(_label("Ende der Kreuzweg-Demo", 44, Color("f2c14e")))
	var journey := "Dein Weg führt hinaus in die Welt."
	if extra.has("lehrmeister"):
		var wohin: String = GameData.get_file("klassen").get("wohin", {}).get(data.region, "nach " + str(data.region))
		journey = "Dein Weg führt %s, zu %s." % [wohin, extra.lehrmeister]
	box.add_child(_label("Du verlässt Kreuzweg als %s.\n%s" % [data.title, journey], 24, Color.WHITE))
	box.add_child(_label("Hinter dir bleibt die Statue der Fünf zurück – und eine sechste Straße, die niemand benutzt.", 19, Color(1, 1, 1, 0.7)))
	box.add_child(_label("Danke fürs Spielen! Die Reise geht weiter …", 22, Color("8affc1")))

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	box.add_child(row)
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


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(1000, 0)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
