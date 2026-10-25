extends Combat
## Nur für Bildschirmfotos: Lektion 3 der Grundausbildung (Paradeschule) mit echter Anzeige.
## Erklär-Fenster werden automatisch bestätigt, beim Anhalten wird nach kurzer Zeit die Leertaste gedrückt.

var _hint_time := 0.0
var _frozen_since := 0


func _ready() -> void:
	BattleRequest.prepare("grundausbildung", 3, 2)
	BattleRequest.setup["start_welle"] = 2
	super()


func _process(delta: float) -> void:
	super(delta)
	for child in get_children():
		if child is PanelContainer and child.z_index == 40:
			_hint_time += 0.1
			if _hint_time > 1.5:
				_hint_time = 0.0
				child.find_children("*", "Button", true, false)[0].pressed.emit()
	if _guided_frozen:
		if _frozen_since == 0:
			_frozen_since = Time.get_ticks_msec()
		elif Time.get_ticks_msec() - _frozen_since > 2500:
			_frozen_since = 0
			var key := InputEventKey.new()
			key.keycode = KEY_SPACE
			key.pressed = true
			Input.parse_input_event(key)
