extends Control
## Bildschirm „Zusammen spielen“ (Lernprojekt 4): Name und Figur wählen,
## dann Gastgeber werden (nur am PC) oder bei einem Gastgeber beitreten.

const SCREEN := Vector2(1280, 720)
const SETTINGS := "user://zusammen.json"

var _name: LineEdit
var _address: LineEdit
var _look := 0
var _preview: WorldCharacter
var _look_label: Label
var _status: Label
var _host_button: Button
var _join_button: Button
var _online_button: Button


func _ready() -> void:
	theme = Combat.make_theme()
	Musik.play("stadt")
	add_child(Backdrop.new())
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.05, 0.75)
	shade.size = SCREEN
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var title := _label("Zusammen spielen", 44, Color("f2c14e"))
	title.position = Vector2(0, 50)
	title.size = Vector2(SCREEN.x, 60)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	var sub := _label("Bis zu 4 Spieler gleichzeitig in Kreuzweg. Jeder behält seinen eigenen Fortschritt.", 18, Color.WHITE)
	sub.position = Vector2(0, 110)
	sub.size = Vector2(SCREEN.x, 30)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(sub)

	var saved := _load_settings()

	# Name
	var name_label := _label("Dein Name:", 20, Color.WHITE)
	name_label.position = Vector2(300, 175)
	add_child(name_label)
	_name = LineEdit.new()
	_name.position = Vector2(470, 168)
	_name.size = Vector2(300, 44)
	_name.max_length = 16
	_name.placeholder_text = "z. B. Marco"
	_name.text = saved.get("name", "")
	add_child(_name)

	# Figur
	var look_title := _label("Deine Figur:", 20, Color.WHITE)
	look_title.position = Vector2(300, 250)
	add_child(look_title)
	_look = maxi(Netz.LOOKS.find(saved.get("figur", "vega")), 0)
	var prev := _small_button("<", Vector2(470, 245), func() -> void: _change_look(-1))
	add_child(prev)
	var next := _small_button(">", Vector2(690, 245), func() -> void: _change_look(1))
	add_child(next)
	_look_label = _label("", 16, Color("cccccc"))
	_look_label.position = Vector2(530, 335)
	_look_label.size = Vector2(150, 24)
	_look_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_look_label)
	_change_look(0)

	# Adresse des Gastgebers
	var address_label := _label("Adresse des Gastgebers:", 20, Color.WHITE)
	address_label.position = Vector2(300, 385)
	add_child(address_label)
	_address = LineEdit.new()
	_address.position = Vector2(560, 378)
	_address.size = Vector2(300, 44)
	_address.placeholder_text = "localhost"
	_address.text = saved.get("adresse", "localhost")
	add_child(_address)
	var hint := _label("„localhost“ = Gastgeber auf demselben Gerät. Sonst die Adresse, die beim Gastgeber angezeigt wird.", 14, Color("aaaaaa"))
	hint.position = Vector2(300, 428)
	add_child(hint)

	_host_button = _big_button("Gastgeber werden", Vector2(240, 480), _on_host)
	_join_button = _big_button("Beitreten\n(Adresse oben)", Vector2(520, 480), _on_join)
	_online_button = _big_button("Online-Server\n(übers Internet)", Vector2(800, 480), _on_online)
	if OS.has_feature("web"):
		# Im Browser kann man nur beitreten (Gastgeber geht nur mit der PC-Version)
		_host_button.disabled = true
		_host_button.text = "Gastgeber werden\n(nur am PC)"

	_status = _label("", 18, Color("9fe8ff"))
	_status.position = Vector2(0, 600)
	_status.size = Vector2(SCREEN.x, 60)
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_status)

	var back := _small_button("Zurück", Vector2(20, 20), func() -> void:
		Netz.stop()
		get_tree().change_scene_to_file("res://scenes/menu.tscn"))
	back.size = Vector2(120, 44)
	add_child(back)

	# Wer hierher zurückkommt, weil die Verbindung weg ist, bekommt einen Hinweis
	if not Netz.online() and get_tree().has_meta("netz_meldung"):
		_status.text = get_tree().get_meta("netz_meldung")
		get_tree().remove_meta("netz_meldung")
	elif Netz.online():
		Netz.stop()


func _change_look(step: int) -> void:
	_look = posmod(_look + step, Netz.LOOKS.size())
	if _preview != null:
		_preview.queue_free()
	_preview = WorldCharacter.new()
	_preview.setup(Netz.LOOKS[_look], "")
	_preview.position = Vector2(605, 320)
	add_child(_preview)
	_look_label.text = "%d / %d" % [_look + 1, Netz.LOOKS.size()]


func _player_name() -> String:
	var text := _name.text.strip_edges()
	return text if text != "" else "Novize"


func _on_host() -> void:
	_save_settings()
	var err := Netz.host(_player_name(), Netz.LOOKS[_look])
	if err != OK:
		_status.text = "Gastgeber geht nicht (Fehler %d). Läuft schon ein anderes Spiel als Gastgeber?" % err
		return
	get_tree().change_scene_to_file("res://scenes/kreuzweg.tscn")


func _on_join() -> void:
	_connect(_address.text, "Verbinde mit %s …" % (_address.text if _address.text != "" else "localhost"))


## Online-Server im Internet (geht auch im Browser und am Handy).
func _on_online() -> void:
	_connect(Netz.ONLINE_ADDRESS, "Verbinde mit dem Online-Server … Wenn er geschlafen hat, wacht er jetzt auf (bis zu einer Minute).")


func _connect(address: String, waiting_text: String) -> void:
	_save_settings()
	var err := Netz.join(address, _player_name(), Netz.LOOKS[_look])
	if err != OK:
		_status.text = "Die Adresse stimmt nicht (Fehler %d)." % err
		return
	_status.text = waiting_text
	_host_button.disabled = true
	_join_button.disabled = true
	_online_button.disabled = true
	var node := Netz._node()
	node.connected.connect(_on_connected, CONNECT_ONE_SHOT)
	node.connection_failed.connect(_on_failed, CONNECT_ONE_SHOT)


func _on_connected() -> void:
	if Netz._node().connection_failed.is_connected(_on_failed):
		Netz._node().connection_failed.disconnect(_on_failed)
	get_tree().change_scene_to_file("res://scenes/kreuzweg.tscn")


func _on_failed() -> void:
	if Netz._node().connected.is_connected(_on_connected):
		Netz._node().connected.disconnect(_on_connected)
	_status.text = "Keine Verbindung. Stimmt die Adresse, und ist der Gastgeber schon in Kreuzweg?"
	_host_button.disabled = OS.has_feature("web")
	_join_button.disabled = false
	_online_button.disabled = false


func _load_settings() -> Dictionary:
	if not FileAccess.file_exists(SETTINGS):
		return {}
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(SETTINGS))
	return data if data is Dictionary else {}


func _save_settings() -> void:
	var file := FileAccess.open(SETTINGS, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({name = _name.text.strip_edges(), figur = Netz.LOOKS[_look], adresse = _address.text.strip_edges()}))


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 6)
	return label


func _small_button(text: String, pos: Vector2, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = Vector2(50, 50)
	button.add_theme_font_size_override("font_size", 20)
	button.pressed.connect(action)
	return button


func _big_button(text: String, pos: Vector2, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = Vector2(250, 90)
	button.add_theme_font_size_override("font_size", 22)
	button.pressed.connect(action)
	add_child(button)
	return button
