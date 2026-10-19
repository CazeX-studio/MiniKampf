extends Combat
## Die echte Kampf-Anzeige, aber der Computer spielt (zum Zuschauen und für Bildschirmfotos).
## Start: Godot --path . res://tests/anzeige_auto.tscn

var ki := KampfKI.new(7)


func _ready() -> void:
	Sandbox.team = ["tamer", "archer", "kunoichi", "singer"]
	Sandbox.encounter = "pilzbosse"
	super()


func choose_action(f: Fighter) -> Dictionary:
	_turn_label.text = "%s (%s) ist am Zug" % [f.display_name, f.class_title]
	await wait(0.4)
	return ki.choose(state.skills, f)


func react(attacker: Fighter, target: Fighter, duration: float) -> bool:
	await super(attacker, target, duration)
	return ki.react()


func choose_option(title: String, options: Array[Dictionary]) -> String:
	_turn_label.text = title
	await wait(1.0)
	return ki.choose_option(options)
