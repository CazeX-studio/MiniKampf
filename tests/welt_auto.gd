extends "res://scripts/welt/kreuzweg.gd"
## Kreuzweg mit vorgetäuschten Eingaben für Bildschirmfotos:
## Taste W, Steuerknopf, Gespräch mit Ye (Antworten), Auftrag, Kräuter, Auftragsbuch.

var _t := 0.0
var _step := 0


func _ready() -> void:
	SaveGame.delete()
	super()
	_set_touch_ui(true)


func _process(delta: float) -> void:
	_t += delta
	var plan: Array = [
		[0.5, func() -> void: _key(KEY_W, true)],
		[1.2, func() -> void: _key(KEY_W, false)],
		[1.3, func() -> void: state.apply_command(LOCAL_ID, {type = "talk", npc = "ye"})],
		[5.0, func() -> void: _action()],
		[5.5, func() -> void: _action()],
		[7.0, func() -> void: state.apply_command(LOCAL_ID, {type = "dialog_choose", index = 2})],
		[8.0, func() -> void: state.apply_command(LOCAL_ID, {type = "dialog_choose", index = 0})],
		[9.0, func() -> void: _action()],
		[9.2, func() -> void: state.apply_command(LOCAL_ID, {type = "use", target = "punkt:1"})],
		[12.0, func() -> void: _toggle_panel("auftraege")],
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
