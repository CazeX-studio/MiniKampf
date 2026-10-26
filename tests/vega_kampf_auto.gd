extends Node
## Nur für Bildschirmfotos: Vegas Kampf-Animationen im echten Kampfbildschirm (Fernangriff, Parade beim Treffer,
## Sieg und Fallen) und der Sieg-Bildschirm mit Belohnung.
## Die Bilder landen im Ordner aus der Umgebungsvariable FOTO_ORDNER (sonst user://).

var _t := 0.0
var _step := 0
var _combat: Node
var _vega: FighterView
var _enemy: Fighter


func _ready() -> void:
	BattleRequest.player_look = "vega"
	BattleRequest.prepare("wild:0", 10, 2, "")
	BattleRequest.reward = {erfahrung = 120, gold = 20, karte = "", stufen = [11]}
	_combat = load("res://scenes/kampf.tscn").instantiate()
	add_child(_combat)


func _process(delta: float) -> void:
	_t += delta
	var plan: Array = [
		[1.5, func() -> void:
			for f: Fighter in _combat.state.heroes:
				_vega = _combat.view(f)
			_enemy = _combat.state.enemies[0]
			_vega.parry_pose()
			_vega.hit_react()],
		[1.75, func() -> void: _shot("parade")],
		[2.6, func() -> void: _combat.lunge(_vega.fighter, _enemy, 0.25)],
		[2.75, func() -> void: _shot("angriff_ausholen")],
		[3.02, func() -> void: _shot("angriff_geschoss")],
		[4.0, func() -> void: _vega.cheer()],
		[4.4, func() -> void: _shot("sieg")],
		[5.0, func() -> void: _combat._show_end_screen(true)],
		[5.3, func() -> void: _shot("auswertung")],
		[5.4, func() -> void: _vega.shown = 0],
		[6.6, func() -> void:
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
