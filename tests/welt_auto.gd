extends "res://scripts/welt/kreuzweg.gd"
## Kreuzweg mit vorgetäuschten Eingaben für Bildschirmfotos:
## Einleitung, Anmeldung in der Gilde, Ye, erster Auftrag, Auftragsbuch.

var _t := 0.0
var _step := 0


func _ready() -> void:
	SaveGame.delete()
	super()
	_set_touch_ui(true)


func _process(delta: float) -> void:
	_t += delta
	var next := func() -> void: state.apply_command(LOCAL_ID, {type = "dialog_next"})
	var choose := func(i: int) -> void: state.apply_command(LOCAL_ID, {type = "dialog_choose", index = i})
	var plan: Array = [
		[1.5, next], [2.0, next], [2.5, next],
		[3.0, func() -> void: _key(KEY_W, true)],
		[3.6, func() -> void: _key(KEY_W, false)],
		[4.5, func() -> void: state.apply_command(LOCAL_ID, {type = "talk", npc = "schreiberin"})],
		[9.5, choose.bind(0)],
		[10.5, next],
		[11.0, func() -> void: state.apply_command(LOCAL_ID, {type = "talk", npc = "ye"})],
		[13.0, next], [13.5, next],
		[15.0, choose.bind(2)],
		[16.0, choose.bind(0)],
		[16.5, next],
		[17.0, func() -> void: _toggle_panel("auftraege")],
	]
	while _step < plan.size() and _t >= plan[_step][0]:
		plan[_step][1].call()
		_step += 1
	super(delta)


func _key(code: Key, pressed: bool) -> void:
	var key := InputEventKey.new()
	key.physical_keycode = code
	key.keycode = code
	key.pressed = pressed
	Input.parse_input_event(key)


func _exit_tree() -> void:
	_no_save = true
	SaveGame.delete()
