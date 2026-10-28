extends Control
## Editor: Werkzeuge zum schnellen Testen (Baukasten, Vegas Animationen, Kampf-Sandbox) und die Demo ab einem Akt.
## Die Demo-Tests benutzen einen eigenen Spielstand (spielstand_editor.json), der normale Spielstand bleibt unberührt.

const SCREEN := Vector2(1280, 720)
const EDITOR_SAVE := "user://spielstand_editor.json"
## Stand am Ende von Akt 1 (wie im automatischen Durchlauf von Grünwacht)
const GRUENWACHT_LEVEL := 10
const GRUENWACHT_XP := 3030
const GRUENWACHT_GOLD := 190


func _ready() -> void:
	theme = Combat.make_theme()
	add_child(Backdrop.new())
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.05, 0.75)
	shade.size = SCREEN
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	# Wer aus einem Test zurückkommt, spielt wieder mit dem normalen Spielstand weiter
	SaveGame.path = SaveGame.DEFAULT_PATH
	BattleRequest.kampf_id = ""
	BattleRequest.result = {}

	_label("Editor", 52, Color("f2c14e"), Vector2(0, 40), SCREEN.x)
	_label("Zum schnellen Ausprobieren", 20, Color.WHITE, Vector2(0, 108), SCREEN.x)

	_label("Werkzeuge", 22, Color("f2c14e"), Vector2(40, 170), 400)
	_button("Baukasten-Testfeld\nNeue Karte aus Einzelbildern", Vector2(40, 210), func() -> void: _go("res://scenes/baukasten_test.tscn"))
	_button("Figuren-Animationen\nKleiner Testkampf", Vector2(450, 210), func() -> void: _go("res://scenes/vega_test.tscn"))
	_button("Kampf-Sandbox\nAlle 11 Klassen, Pilzhöhle", Vector2(860, 210), func() -> void: _go("res://scenes/auswahl.tscn"))

	_label("Demo testen (eigener Spielstand, dein normaler bleibt unberührt)", 22, Color("f2c14e"), Vector2(40, 380), 1200)
	_button("Akt Kreuzweg\nVon vorne, mit Figur erstellen", Vector2(40, 420), _start_kreuzweg)
	_button("Akt Grünwacht\nAls Bogenschütze", Vector2(450, 420), func() -> void: _start_gruenwacht("archer"))
	_button("Akt Grünwacht\nAls Monster-Zähmer", Vector2(860, 420), func() -> void: _start_gruenwacht("tamer"))

	# Eigene Figur für die Demo und die Animationen (die andere läuft als Begleiter mit)
	var figur := Button.new()
	figur.position = Vector2(40, 610)
	figur.size = Vector2(300, 50)
	figur.add_theme_font_size_override("font_size", 18)
	var zeigen := func() -> void: figur.text = "Figur: %s (wechseln)" % FigurWahl.NAMEN[FigurWahl.gewaehlt()]
	zeigen.call()
	figur.pressed.connect(func() -> void:
		FigurWahl.waehlen(FigurWahl.begleiter())
		zeigen.call())
	add_child(figur)

	var back := Button.new()
	back.text = "Zurück zum Menü"
	back.position = Vector2(540, 610)
	back.size = Vector2(200, 50)
	back.add_theme_font_size_override("font_size", 18)
	back.pressed.connect(func() -> void: _go("res://scenes/menu.tscn"))
	add_child(back)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
		_go("res://scenes/menu.tscn")


func _go(scene: String) -> void:
	get_tree().change_scene_to_file(scene)


## Kreuzweg von vorne, mit leerem Editor-Spielstand: erst „Figur erstellen“, dann geht es los.
func _start_kreuzweg() -> void:
	SaveGame.path = EDITOR_SAVE
	SaveGame.delete()
	FigurErstellen.zurueck_zu = "res://scenes/editor.tscn"
	_go("res://scenes/figur_erstellen.tscn")


## Grünwacht: Akt 1 gilt als geschafft, Klasse gewählt; der Abschied bei Ye wird durchgespielt,
## danach steht man auf dem Weg nach Grünwacht.
func _start_gruenwacht(klasse: String) -> void:
	SaveGame.path = EDITOR_SAVE
	SaveGame.delete()
	var world := WorldState.new()
	var p := world.add_player("spieler", "Du", "vega", WorldState.start_cell())
	for id: String in GameData.get_file("auftraege"):
		if id == "nach_gruenwacht":
			break
		p.progress.quests[id] = "abgegeben"
	p.progress.quests["abreise"] = "aktiv"
	p.progress.flags["klasse"] = klasse
	p.progress.flags["klasse_gewaehlt"] = true
	p.progress.flags["klasse_bestaetigt"] = true
	# Die Einleitung von Kreuzweg ist schon gesehen
	p.progress.flags["angekommen"] = true
	p.progress.level = GRUENWACHT_LEVEL
	p.progress.xp = GRUENWACHT_XP
	p.progress.gold = GRUENWACHT_GOLD
	world.start_dialog(p, "ye_tor")
	var steps := 0
	while p.in_dialog() and steps < 50:
		steps += 1
		if world.dialog_view(p).antworten.is_empty():
			world.apply_command("spieler", {type = "dialog_next"})
		else:
			world.apply_command("spieler", {type = "dialog_choose", index = 0})
	SaveGame.save(p)
	_go("res://scenes/kreuzweg.tscn")


func _label(text: String, font_size: int, color: Color, pos: Vector2, width: float) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 8)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if width >= SCREEN.x else HORIZONTAL_ALIGNMENT_LEFT
	label.size = Vector2(width, font_size + 16)
	label.position = pos
	add_child(label)


func _button(text: String, pos: Vector2, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = Vector2(380, 130)
	button.add_theme_font_size_override("font_size", 22)
	button.pressed.connect(action)
	add_child(button)
