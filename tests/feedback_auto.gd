extends "res://scripts/welt/kreuzweg.gd"
## Nur für Bildschirmfotos (Rückmeldungen 22.10.): Wegweiser, Zeichen an Antworten, laufende Monster.

var _t := 0.0
var _step := 0


func _ready() -> void:
	SaveGame.delete()
	super()


func _process(delta: float) -> void:
	_t += delta
	var p := local_player()
	var plan: Array = [
		[0.5, func() -> void:
			for i in 3:
				state.apply_command(local_id, {type = "dialog_next"})],
		[2.5, func() -> void: state.apply_command(local_id, {type = "talk", npc = "schreiberin"})],
		[7.0, func() -> void:
			p.dialog = {}
			p.safe_time = 99.0
			var m: Dictionary = state.monsters[0]
			state.change_map(p, m.karte, Vector2i(Vector2(m.feld).round()) + Vector2i(3, 2))],
	]
	while _step < plan.size() and _t >= plan[_step][0]:
		plan[_step][1].call()
		_step += 1
	super(delta)


func _exit_tree() -> void:
	_no_save = true
	SaveGame.delete()
