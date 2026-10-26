extends "res://scripts/welt/kreuzweg.gd"
## Nur für Bildschirmfotos: die eigene Spielfigur Vega in der Stadt (neben Ye) und im Kampf als Novize.
## Die Bilder landen im Ordner aus der Umgebungsvariable FOTO_ORDNER (sonst user://).

var _t := 0.0
var _step := 0


func _ready() -> void:
	SaveGame.delete()
	super()
	_no_save = true


func _process(delta: float) -> void:
	_t += delta
	var p := local_player()
	var plan: Array = [
		[0.5, func() -> void:
			p.dialog = {}
			p.progress.flags["angekommen"] = true],
		[3.0, func() -> void:
			get_viewport().get_texture().get_image().save_png(_path("welt"))
			print("Foto: ", _path("welt"))],
		[3.2, func() -> void:
			var helper: Node = load("res://tests/foto_helfer.gd").new()
			helper.path = _path("kampf")
			helper.wait = 3.0
			get_tree().root.add_child(helper)
			BattleRequest.player_look = p.look
			BattleRequest.prepare("wild:0", 10, 2, "")
			get_tree().change_scene_to_file("res://scenes/kampf.tscn")
			set_process(false)],
	]
	while _step < plan.size() and _t >= plan[_step][0]:
		plan[_step][1].call()
		_step += 1
	super(delta)


static func _path(name: String) -> String:
	var folder := OS.get_environment("FOTO_ORDNER")
	return (folder if folder != "" else ProjectSettings.globalize_path("user://")) + "/vega_%s.png" % name
