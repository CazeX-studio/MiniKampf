extends Control
## Bildschirm „Online spielen“ (Lernprojekt 4, A2a): Name wählen, dann mit der eigenen Figur und dem eigenen Spielstand
## auf den Online-Server (dasselbe Spiel wie allein). Ohne Figur erst „Figur erstellen“. Gastgeber werden (nur am PC)
## und Beitreten über eine Adresse bleiben zum Testen.

const SCREEN := Vector2(1280, 720)
const SETTINGS := "user://zusammen.json"

var _name: LineEdit
var _address: LineEdit
## Die eigene Figur (aus dem Spielstand oder gerade erstellt), "" = noch keine
var _figur := ""
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

	var title := _label("Online spielen", 44, Color("f2c14e"))
	title.position = Vector2(0, 50)
	title.size = Vector2(SCREEN.x, 60)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	var sub := _label("Dasselbe Spiel wie offline, mit bis zu 4 Spielern übers Internet. Du spielst mit deiner Figur und deinem Spielstand weiter.", 18, Color.WHITE)
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

	# Figur: die eigene aus dem Spielstand (oder gerade erstellt); ohne Figur erst „Figur erstellen“
	var look_title := _label("Deine Figur:", 20, Color.WHITE)
	look_title.position = Vector2(300, 250)
	add_child(look_title)
	_figur = eigene_figur()
	_look_label = _label("", 16, Color("cccccc"))
	_look_label.position = Vector2(470, 250)
	_look_label.size = Vector2(300, 24)
	add_child(_look_label)
	if _figur != "":
		_preview = WorldCharacter.new()
		_preview.setup(_figur, "")
		_preview.position = Vector2(620, 345)
		add_child(_preview)
		if _name.text == "":
			_name.text = eigener_name()
	else:
		_look_label.text = "Noch keine Figur."
		var erstellen := _small_button("Figur erstellen", Vector2(470, 285), func() -> void:
			_save_settings()
			FigurErstellen.zurueck_zu = "res://scenes/zusammen.tscn"
			FigurErstellen.weiter_zu = "res://scenes/zusammen.tscn"
			get_tree().change_scene_to_file("res://scenes/figur_erstellen.tscn"))
		erstellen.size = Vector2(220, 50)
		add_child(erstellen)

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

	_host_button = _big_button("Gastgeber werden\n(zum Testen)", Vector2(240, 480), _on_host)
	_join_button = _big_button("Beitreten\n(Adresse oben)", Vector2(520, 480), _on_join)
	_online_button = _big_button("Online spielen\n(übers Internet)", Vector2(800, 480), _on_online)
	_online_button.add_theme_color_override("font_color", Color("f2c14e"))
	if _figur == "":
		for k: Button in [_host_button, _join_button, _online_button]:
			k.disabled = true
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


## Die eigene Figur: gerade erstellt (Figur erstellen) oder aus dem Spielstand, "" = noch keine.
static func eigene_figur() -> String:
	if not FigurWahl.neue_figur.is_empty():
		return str(FigurWahl.neue_figur.aussehen)
	return str(SaveGame._read().get("figur", {}).get("aussehen", ""))


static func eigener_name() -> String:
	if not FigurWahl.neue_figur.is_empty():
		return str(FigurWahl.neue_figur.name)
	return str(SaveGame._read().get("figur", {}).get("name", ""))


func _player_name() -> String:
	var text := _name.text.strip_edges()
	return text if text != "" else "Novize"


func _on_host() -> void:
	_save_settings()
	var err := Netz.host(_player_name(), _figur)
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
	var err := Netz.join(address, _player_name(), _figur)
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
	_host_button.disabled = OS.has_feature("web") or _figur == ""
	_join_button.disabled = _figur == ""
	_online_button.disabled = _figur == ""


func _load_settings() -> Dictionary:
	if not FileAccess.file_exists(SETTINGS):
		return {}
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(SETTINGS))
	return data if data is Dictionary else {}


func _save_settings() -> void:
	var file := FileAccess.open(SETTINGS, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({name = _name.text.strip_edges(), adresse = _address.text.strip_edges()}))


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
