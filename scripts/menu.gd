extends Control
## Startmenü: Auswahl zwischen den Lernprojekten.

const SCREEN := Vector2(1280, 720)


func _ready() -> void:
	theme = Combat.make_theme()
	Musik.play("stadt")
	add_child(Backdrop.new())
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.05, 0.7)
	shade.size = SCREEN
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var title := Label.new()
	title.text = "Asterfall"
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color("f2c14e"))
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 10)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(SCREEN.x, 90)
	title.position = Vector2(0, 90)
	add_child(title)
	var sub := Label.new()
	sub.text = "Arbeitstitel · Lernprojekte von CazeX Studio"
	sub.add_theme_font_size_override("font_size", 20)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.size = Vector2(SCREEN.x, 30)
	sub.position = Vector2(0, 180)
	add_child(sub)

	_add_button("Kampf-Sandbox\nAlle 11 Klassen, Pilzhöhle, Auswertung", Vector2(40, 300), "res://scenes/auswahl.tscn")
	_add_button("Kreuzweg-Demo\nDie erste Stunde als Novize", Vector2(450, 300), "res://scenes/kreuzweg.tscn")
	_add_button("Zusammen spielen\nMit bis zu 4 Spielern in Kreuzweg", Vector2(860, 300), "res://scenes/zusammen.tscn")
	_add_button("Baukasten-Testfeld\nRautenansicht aus Einzelbildern", Vector2(40, 470), "res://scenes/baukasten_test.tscn")

	# Server ohne Grafik: Godot --headless --path . -- --server
	if "--server" in OS.get_cmdline_user_args():
		_start_server.call_deferred()
	else:
		# Wer ins Menü zurückkommt (z. B. vom Abspann), spielt wieder allein
		Netz.stop()

	# Musik an/aus (überall auch mit Taste M)
	var music := Button.new()
	music.position = Vector2(540, 470)
	music.size = Vector2(200, 50)
	music.add_theme_font_size_override("font_size", 18)
	music.text = "Musik: an (M)" if Musik.enabled else "Musik: aus (M)"
	music.pressed.connect(func() -> void:
		Musik.toggle()
		music.text = "Musik: an (M)" if Musik.enabled else "Musik: aus (M)")
	add_child(music)
	var volume := Musik.make_slider(220.0)
	volume.position = Vector2(470, 535)
	add_child(volume)


func _start_server() -> void:
	if Netz.serve() != OK:
		print("Netz: Server konnte nicht starten (Port %d belegt?)" % Netz.PORT)
		get_tree().quit(1)


func _add_button(text: String, pos: Vector2, scene: String) -> void:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = Vector2(380, 140)
	button.add_theme_font_size_override("font_size", 22)
	button.pressed.connect(func() -> void: get_tree().change_scene_to_file(scene))
	add_child(button)
