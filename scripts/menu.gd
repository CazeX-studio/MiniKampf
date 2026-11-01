extends Control
## Startmenü: Demo spielen, zusammen spielen oder Werkzeuge zum Testen (Editor).

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
	_add_button("Kreuzweg-Demo\nDie erste Stunde als Novize", Vector2(40, 300), "",
			func() -> String: return "res://scenes/kreuzweg.tscn" if SaveGame.exists() else "res://scenes/figur_erstellen.tscn")
	_add_button("Zusammen spielen\nMit bis zu 4 Spielern in Kreuzweg", Vector2(450, 300), "res://scenes/zusammen.tscn")
	_add_button("Editor\nTesten: Baukasten, Vega, Sandbox, Akte", Vector2(860, 300), "res://scenes/editor.tscn")

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


## ziel_von: wenn gesetzt, bestimmt es erst beim Drücken, wohin es geht (statt scene).
func _add_button(text: String, pos: Vector2, scene: String, ziel_von := Callable()) -> void:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = Vector2(380, 140)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.add_theme_font_size_override("font_size", 22)
	button.pressed.connect(func() -> void:
		get_tree().change_scene_to_file(ziel_von.call() if ziel_von.is_valid() else scene))
	_inhalt.add_child(button)
