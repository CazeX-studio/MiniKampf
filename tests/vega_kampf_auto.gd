extends Node
## Nur für Bildschirmfotos: Vegas Kampf-Animationen (Angriff, Parade, Sieg, Fallen) im echten Kampfbildschirm.
## Die Bilder landen im Ordner aus der Umgebungsvariable FOTO_ORDNER (sonst user://).

var _t := 0.0
var _step := 0
var _combat: Node
var _vega: FighterView


func _ready() -> void:
	BattleRequest.player_look = "vega"
	BattleRequest.prepare("wild:0", 10, 2, "")
	_combat = load("res://scenes/kampf.tscn").instantiate()
	add_child(_combat)


func _process(delta: float) -> void:
	_t += delta
	var plan: Array = [
		[1.5, func() -> void:
			for f: Fighter in _combat.state.heroes:
				_vega = _combat.view(f)
			_vega.parry_pose()],
		[1.62, func() -> void: _shot("parade")],
		[2.6, func() -> void: _vega.play("attack", 1.0, 10.0)],
		[2.95, func() -> void: _shot("angriff")],
		[3.5, func() -> void: _vega.cheer()],
		[3.7, func() -> void: _shot("sieg")],
		[4.0, func() -> void: _vega.shown = 0],
		[5.5, func() -> void:
			_shot("gefallen")
			get_tree().quit()],
	]
	while _step < plan.size() and _t >= plan[_step][0]:
		plan[_step][1].call()
		_step += 1


func _shot(name: String) -> void:
	var folder := OS.get_environment("FOTO_ORDNER")
	var path := (folder if folder != "" else ProjectSettings.globalize_path("user://")) + "/vega_kampf_%s.png" % name
	get_viewport().get_texture().get_image().save_png(path)
	print("Foto: ", path)
