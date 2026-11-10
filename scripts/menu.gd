extends Control
## Startmenü: nur „Offline“ und „Online“, beide dasselbe Spiel mit demselben Spielstand (A2a, Marco 08.11.);
## in der Werkstatt dazu der Editor. Feedback gibt es im Spiel oben rechts, die Dankesliste im Abspann am Ende der Demo.

const SCREEN := Vector2(1280, 720)
const LOGO_GROSS := Rect2(140, 110, 1000, 400)
const LOGO_KLEIN := Rect2(330, 24, 620, 248)

## Der Titelbildschirm kommt nur beim Spielstart, nicht bei der Rückkehr ins Menü
static var titel_gesehen := false

var _logo: TextureRect
var _inhalt: Control
var _hinweis: Label
var _titel_offen := false


func _ready() -> void:
	theme = Combat.make_theme()
	Musik.play("stadt")
	add_child(Backdrop.new())
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.05, 0.7)
	shade.size = SCREEN
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	_inhalt = Control.new()
	_inhalt.size = SCREEN
	add_child(_inhalt)
	_logo = TextureRect.new()
	_logo.texture = load("res://assets/ui/logo.png")
	_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_logo.position = LOGO_KLEIN.position
	_logo.size = LOGO_KLEIN.size
	add_child(_logo)

	# Neues Spiel (noch kein Spielstand): erst die Figur erstellen (geprüft beim Drücken, der Spielstand-Pfad wird unten gesetzt)
	# Editor nur in der Werkstatt-Fassung und im Godot-Editor (S1)
	var mit_editor := Tester.werkzeuge()
	var x := 40.0 if mit_editor else 245.0
	_add_button(GameData.text("menu_offline"), Vector2(x, 300), "",
			func() -> String: return "res://scenes/kreuzweg.tscn" if SaveGame.exists() else "res://scenes/figur_erstellen.tscn")
	_add_button(GameData.text("menu_online"), Vector2(x + 410.0, 300), "res://scenes/zusammen.tscn")
	if mit_editor:
		_add_button("Editor\nTesten: Baukasten, Vega, Sandbox, Akte", Vector2(860, 300), "res://scenes/editor.tscn")
	_version_zeigen()

	# Server ohne Grafik: Godot --headless --path . -- --server
	if "--server" in OS.get_cmdline_user_args():
		_start_server.call_deferred()
	else:
		# Wer ins Menü zurückkommt (z. B. vom Abspann), spielt wieder allein und mit dem normalen Spielstand
		Netz.stop()
		SaveGame.path = SaveGame.DEFAULT_PATH
		FigurErstellen.zurueck_zu = "res://scenes/menu.tscn"

	# Musik an/aus (überall auch mit Taste M)
	var music := Button.new()
	music.position = Vector2(540, 470)
	music.size = Vector2(200, 50)
	music.add_theme_font_size_override("font_size", 18)
	music.text = "Musik: an (M)" if Musik.enabled else "Musik: aus (M)"
	music.pressed.connect(func() -> void:
		Musik.toggle()
		music.text = "Musik: an (M)" if Musik.enabled else "Musik: aus (M)")
	_inhalt.add_child(music)
	var volume := Musik.make_slider(220.0)
	volume.position = Vector2(470, 535)
	_inhalt.add_child(volume)
	var ult := Button.new()
	ult.position = Vector2(540, 575)
	ult.size = Vector2(200, 44)
	ult.add_theme_font_size_override("font_size", 16)
	ult.text = "Ult: kurz" if Musik.ist_ult_kurz() else "Ult: filmisch"
	ult.pressed.connect(func() -> void:
		Musik.ult_umschalten()
		ult.text = "Ult: kurz" if Musik.ist_ult_kurz() else "Ult: filmisch")
	_inhalt.add_child(ult)

	if not titel_gesehen and not "--server" in OS.get_cmdline_user_args():
		_titel_zeigen()


func _titel_zeigen() -> void:
	_titel_offen = true
	_inhalt.visible = false
	_logo.position = LOGO_GROSS.position
	_logo.size = LOGO_GROSS.size
	_logo.modulate.a = 0.0
	create_tween().tween_property(_logo, "modulate:a", 1.0, 1.0)
	_hinweis = Label.new()
	_hinweis.text = "Taste drücken oder klicken"
	_hinweis.add_theme_font_size_override("font_size", 24)
	_hinweis.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hinweis.size = Vector2(SCREEN.x, 36)
	_hinweis.position = Vector2(0, 560)
	add_child(_hinweis)
	var blinken := _hinweis.create_tween().set_loops()
	blinken.tween_property(_hinweis, "modulate:a", 0.35, 0.9)
	blinken.tween_property(_hinweis, "modulate:a", 1.0, 0.9)


func _input(event: InputEvent) -> void:
	if not _titel_offen or not event.is_pressed() or event.is_echo():
		return
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventScreenTouch:
		get_viewport().set_input_as_handled()
		titel_schliessen()


## Vom Titel zum Menü: das Logo rückt nach oben, die Knöpfe blenden ein
func titel_schliessen() -> void:
	_titel_offen = false
	titel_gesehen = true
	_hinweis.queue_free()
	_inhalt.modulate.a = 0.0
	_inhalt.visible = true
	var uebergang := create_tween().set_parallel()
	uebergang.tween_property(_logo, "modulate:a", 1.0, 0.2)
	uebergang.tween_property(_logo, "position", LOGO_KLEIN.position, 0.4).set_trans(Tween.TRANS_SINE)
	uebergang.tween_property(_logo, "size", LOGO_KLEIN.size, 0.4).set_trans(Tween.TRANS_SINE)
	uebergang.tween_property(_inhalt, "modulate:a", 1.0, 0.4)


func _start_server() -> void:
	if Netz.serve() != OK:
		print("Netz: Server konnte nicht starten (Port %d belegt?)" % Netz.PORT)
		get_tree().quit(1)


## Version und Tester unten rechts (S1)
func _version_zeigen() -> void:
	var label := Label.new()
	var text := "Version " + Tester.version()
	if Tester.spitzname() != "":
		text += "\n" + GameData.text("tester_info", [Tester.spitzname(), Tester.nummer()])
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	label.size = Vector2(600, 60)
	label.position = Vector2(SCREEN.x - 616, SCREEN.y - 70)
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_inhalt.add_child(label)


## Dankesliste der Tester und Feedback-Knopf
func _danke_zeigen() -> void:
	var namen := Tester.dankesliste()
	var text := GameData.text("danke_leer") if namen.is_empty() else " · ".join(PackedStringArray(namen))
	Tester.hinweis_fenster(self, GameData.text("danke_titel"), text,
			[[GameData.text("feedback_titel"), func() -> void: Tester.feedback(self, "Menü")]])


## ziel_von: wenn gesetzt, bestimmt es erst beim Drücken, wohin es geht (statt scene).
## aktion: statt eines Szenenwechsels etwas anderes tun.
func _add_button(text: String, pos: Vector2, scene: String, ziel_von := Callable(), aktion := Callable()) -> void:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = Vector2(380, 140)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.add_theme_font_size_override("font_size", 22)
	button.pressed.connect(func() -> void:
		if aktion.is_valid():
			aktion.call()
			return
		var ziel: String = ziel_von.call() if ziel_von.is_valid() else scene
		# Vor dem ersten Spielen in der Demo: Spitzname des Testers (S1)
		if Tester.spitzname_noetig() and ziel != "res://scenes/editor.tscn":
			Tester.spitzname_fenster(self, func() -> void: get_tree().change_scene_to_file(ziel))
			return
		get_tree().change_scene_to_file(ziel))
	_inhalt.add_child(button)
