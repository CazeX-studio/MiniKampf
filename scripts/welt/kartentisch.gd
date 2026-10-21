class_name KartenTisch
extends Control
## Bildschirm für eine Partie Kreuzweg-Karten gegen eine Figur (Regeln in KartenSpiel, Karten in data/kartenspiel.json).
## Links die eigene Hand, rechts die des Gegners, in der Mitte die Sternentafel (3×3). Erst eine Karte antippen,
## dann ein Feld. Blaue Karten gehören dir, rote dem Gegner. Danach geht es zurück in die Welt.

## Gegen wen gespielt wird (Kennung aus kartenspiel.json → gegner) und mit welchen Karten
static var gegner := ""
static var deck: Array = []
## Ergebnis für die Welt: {gegner, gewonnen, unentschieden}. Leer = nichts zu melden.
static var ergebnis := {}
static var return_scene := "res://scenes/kreuzweg.tscn"

const SCREEN := Vector2(1280, 720)
const CARD := Vector2(120, 150)
const CELL := Vector2(132, 162)
const BOARD_POS := Vector2(442, 120)
const MINE := Color("4a7cff")
const THEIRS := Color("e05050")

var game: KartenSpiel
var _rng := RandomNumberGenerator.new()
var _selected := -1
var _info: Label
var _board_buttons: Array[Button] = []
var _hand_box: VBoxContainer
var _enemy_box: VBoxContainer
var _waiting := false
var _over := false
var _style := "schlau"


func _ready() -> void:
	theme = Combat.make_theme()
	Musik.play("nacht")
	var data: Dictionary = GameData.get_file("kartenspiel").get("gegner", {}).get(gegner, {})
	_style = data.get("spielweise", "schlau")
	_rng.randomize()
	# Wer anfängt, wird ausgelost (wie bei Triple Triad)
	game = KartenSpiel.new(deck, data.get("deck", []), _rng.randi() % 2)
	var bg := ColorRect.new()
	bg.color = Color("10121e")
	bg.size = SCREEN
	add_child(bg)
	var title := Label.new()
	title.text = "Kreuzweg-Karten gegen %s" % data.get("name", gegner)
	title.position = Vector2(0, 20)
	title.size = Vector2(SCREEN.x, 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("f2c14e"))
	add_child(title)
	# Die Sternentafel: neun leuchtende Felder
	var plate := Panel.new()
	plate.position = BOARD_POS - Vector2(14, 14)
	plate.size = CELL * 3 + Vector2(28, 28) - Vector2(12, 12)
	add_child(plate)
	for i in 9:
		var b := Button.new()
		b.position = BOARD_POS + Vector2(i % 3, i / 3) * CELL
		b.size = CARD
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect(_on_cell.bind(i))
		add_child(b)
		_board_buttons.append(b)
	_hand_box = VBoxContainer.new()
	_hand_box.position = Vector2(60, 90)
	add_child(_hand_box)
	_enemy_box = VBoxContainer.new()
	_enemy_box.position = Vector2(1100, 90)
	add_child(_enemy_box)
	_info = Label.new()
	_info.position = Vector2(0, 640)
	_info.size = Vector2(SCREEN.x, 40)
	_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_info.add_theme_font_size_override("font_size", 20)
	add_child(_info)
	_refresh()
	if game.turn == KartenSpiel.GEGNER:
		_after_move()


## Eine Karte als Text: Name und die vier Zahlen im Kreuz (oben, links/rechts, unten).
static func card_text(id: String) -> String:
	var v := KartenSpiel.values(id)
	return "%s\n\n   %d\n%d     %d\n   %d" % [KartenSpiel.card(id).name, v[0], v[3], v[1], v[2]]


## Farbe einer Karte: Fläche in der Farbe des Besitzers, heller Rand (Gold = ausgewählt), weiße Schrift.
static func style_card(b: Button, color: Color, border: Color, font_size: int) -> void:
	for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		var box := StyleBoxFlat.new()
		box.bg_color = color.darkened(0.35) if state != "hover" else color.darkened(0.2)
		box.border_color = border
		box.set_border_width_all(3)
		box.set_corner_radius_all(6)
		b.add_theme_stylebox_override(state, box)
	for state: String in ["font_color", "font_disabled_color", "font_hover_color", "font_pressed_color"]:
		b.add_theme_color_override(state, Color.WHITE)
	b.add_theme_font_size_override("font_size", font_size)


func _small_card(id: String, color: Color, index: int, mine: bool) -> Button:
	var b := Button.new()
	b.text = card_text(id)
	b.custom_minimum_size = Vector2(110, 96) if not mine else Vector2(120, 96)
	b.focus_mode = Control.FOCUS_NONE
	style_card(b, color, Color("f2c14e") if mine and index == _selected else color.lightened(0.4), 13)
	b.disabled = not mine or _over or _waiting
	if mine:
		b.pressed.connect(func() -> void:
			_selected = index
			_refresh())
	return b


func _refresh() -> void:
	for child in _hand_box.get_children():
		child.queue_free()
	for child in _enemy_box.get_children():
		child.queue_free()
	for i in game.hands[KartenSpiel.SPIELER].size():
		_hand_box.add_child(_small_card(game.hands[KartenSpiel.SPIELER][i], MINE, i, true))
	for i in game.hands[KartenSpiel.GEGNER].size():
		_enemy_box.add_child(_small_card(game.hands[KartenSpiel.GEGNER][i], THEIRS, i, false))
	for i in 9:
		var cell: Dictionary = game.board[i]
		var b := _board_buttons[i]
		if cell.is_empty():
			# Freies Feld der Sternentafel: leuchtet leicht
			b.text = ""
			style_card(b, Color("2a3060"), Color("6070c0") if _selected >= 0 else Color("3a4070"), 15)
		else:
			b.text = card_text(cell.karte)
			var owner_color := MINE if cell.besitzer == KartenSpiel.SPIELER else THEIRS
			# Gerade umgedrehte Karten haben einen weißen Rand
			style_card(b, owner_color, Color.WHITE if i in game.last_flips else owner_color.lightened(0.4), 15)
	var mine := game.score(KartenSpiel.SPIELER)
	var theirs := game.score(KartenSpiel.GEGNER)
	if _over:
		_info.text = "%s  (%d : %d) – tippe irgendwo, um zurückzugehen" % ["Gewonnen!" if mine > theirs else ("Unentschieden." if mine == theirs else "Verloren."), mine, theirs]
	elif _waiting:
		_info.text = "Der Gegner überlegt … (%d : %d)" % [mine, theirs]
	elif _selected < 0:
		_info.text = "Tippe eine deiner Karten an (links). (%d : %d)" % [mine, theirs]
	else:
		_info.text = "Und jetzt ein freies Feld auf der Sternentafel. (%d : %d)" % [mine, theirs]


func _on_cell(cell: int) -> void:
	if _over:
		_leave()
		return
	if _waiting or _selected < 0 or not game.place(KartenSpiel.SPIELER, _selected, cell):
		return
	_selected = -1
	_after_move()


## Danach ist der Gegner dran (nach dem eigenen Zug oder wenn er anfängt).
func _after_move() -> void:
	if game.finished():
		_finish()
		return
	_waiting = true
	_refresh()
	await get_tree().create_timer(0.7).timeout
	var move := game.computer_move(_style, _rng)
	game.place(KartenSpiel.GEGNER, move.x, move.y)
	_waiting = false
	if game.finished():
		_finish()
		return
	_refresh()


func _finish() -> void:
	_over = true
	var mine := game.score(KartenSpiel.SPIELER)
	var theirs := game.score(KartenSpiel.GEGNER)
	ergebnis = {gegner = gegner, gewonnen = mine > theirs, unentschieden = mine == theirs}
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if _over and ((event is InputEventMouseButton and event.pressed) or (event is InputEventKey and event.pressed)):
		_leave()


func _leave() -> void:
	gegner = ""
	get_tree().change_scene_to_file(return_scene)
