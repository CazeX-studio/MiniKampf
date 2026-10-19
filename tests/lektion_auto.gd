extends Combat
## Eine Lektion der Grundausbildung mit echter Anzeige, der Computer spielt (für Bildschirmfotos).
## Erklär-Fenster werden nach kurzer Zeit automatisch bestätigt.
## Kampf wählen: Umgebungsvariable LEKTION (Standard: lektion_parieren).

var ki := KampfKI.new(3)
var _hint_time := 0.0


func _ready() -> void:
	var id := OS.get_environment("LEKTION") if OS.has_environment("LEKTION") else "lektion_parieren"
	var level := 8 if id == "sternenfall" else (5 if id.begins_with("probe:") else (4 if id == "gruppenkampf" else 3))
	BattleRequest.prepare(id, level, 2)
	super()


func _process(delta: float) -> void:
	super(delta)
	for child in get_children():
		if child is PanelContainer and child.z_index == 40:
			_hint_time += delta
			if _hint_time > float(OS.get_environment("HINWEIS_ZEIT")) if OS.has_environment("HINWEIS_ZEIT") else 1.5:
				_hint_time = 0.0
				var button: Button = child.find_children("*", "Button", true, false)[0]
				button.pressed.emit()


func choose_action(f: Fighter) -> Dictionary:
	# ECHT=1: echte Knöpfe zeigen (für Bildschirmfotos der Auswahl)
	if state.computer.has(f) or OS.has_environment("ECHT"):
		return await super(f)
	await _show_hint("erster_zug")
	_turn_label.text = "Du bist am Zug"
	await wait(0.5)
	return ki.choose(state.skills, f)


func react(attacker: Fighter, target: Fighter, duration: float) -> int:
	await super(attacker, target, duration)
	return ki.react_grade(0.4, 0.4)
