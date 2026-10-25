extends "res://scripts/welt/kreuzweg.gd"
## Nur für Bildschirmfotos: blaue Wegweiser der Nebenaufträge und das Auftragsbuch mit Reitern.

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
			p.dialog = {}
			p.progress.flags["angekommen"] = true
			p.progress.quests = {"ankunft": "abgegeben", "zu_ye": "aktiv", "dunkelheit_spielen": "aktiv", "fuenf_farben": "aktiv"}],
		[3.0, func() -> void: _toggle_panel("auftraege")],
		[5.0, func() -> void:
			_quest_tab = "fertig"
			_fill_panel()],
	]
	while _step < plan.size() and _t >= plan[_step][0]:
		plan[_step][1].call()
		_step += 1
	super(delta)


func _exit_tree() -> void:
	_no_save = true
	SaveGame.delete()
