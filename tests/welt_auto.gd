extends "res://scripts/welt/kreuzweg.gd"
## Kreuzweg mit vorgetäuschten Eingaben (Taste W, dann Steuerknopf) für Bildschirmfotos.

var _t := 0.0
var _phase := 0


func _ready() -> void:
	super()
	_set_touch_ui(true)


func _process(delta: float) -> void:
	_t += delta
	if _phase == 0 and _t > 0.5:
		_phase = 1
		_key(KEY_W, true)
	elif _phase == 1 and _t > 1.5:
		_phase = 2
		_key(KEY_W, false)
		var touch := InputEventScreenTouch.new()
		touch.index = 0
		touch.position = Vector2(200, 560)
		touch.pressed = true
		Input.parse_input_event(touch)
	elif _phase == 2 and _t > 1.7:
		_phase = 3
		var drag := InputEventScreenDrag.new()
		drag.index = 0
		drag.position = Vector2(260, 530)
		Input.parse_input_event(drag)
	super(delta)


func _key(code: Key, pressed: bool) -> void:
	var key := InputEventKey.new()
	key.physical_keycode = code
	key.keycode = code
	key.pressed = pressed
	Input.parse_input_event(key)
