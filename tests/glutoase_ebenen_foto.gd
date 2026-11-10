extends "res://scripts/welt/kreuzweg.gd"
## Fotos der Glutoase mit Ebenen (E3h3b): Oase, untere Treppe, Schmiedeviertel, obere Treppe, Hadrak. Ordner nach --

const STELLEN := [["oase", Vector2i(23, 38)], ["treppe_unten", Vector2i(23, 29)], ["schmiedeviertel", Vector2i(28, 20)],
		["treppe_oben", Vector2i(23, 13)], ["hadrak", Vector2i(24, 9)], ["aufzug", Vector2i(40, 33)]]


func _ready() -> void:
	SaveGame.path = "user://test_ebenen_foto.json"
	SaveGame.delete()
	super()
	await get_tree().create_timer(0.5).timeout
	var p := local_player()
	p.dialog = {}
	p.safe_time = 99.0
	p.progress.flags["klasse_bestaetigt"] = true
	for s: Array in STELLEN:
		state.change_map(p, "glutoase", s[1])
		p.dialog = {}
		await get_tree().create_timer(0.8).timeout
		_camera.reset_smoothing()
		await get_tree().create_timer(0.3).timeout
		get_viewport().get_texture().get_image().save_png(OS.get_cmdline_user_args()[0] + "/ebenen_%s.png" % s[0])
	SaveGame.delete()
	SaveGame.path = SaveGame.DEFAULT_PATH
	get_tree().quit()
