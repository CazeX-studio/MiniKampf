extends "res://scripts/welt/kreuzweg.gd"
## A12a: Fotos vom Gasthaus Wegrast von außen und innen. Ordner als Argument nach --

func _ready() -> void:
	SaveGame.delete()
	super()
	await get_tree().create_timer(0.5).timeout
	var p := local_player()
	p.dialog = {}
	for s: Array in [["kreuzweg", Vector2i(10, 30), "aussen"], ["wegrast", Vector2i(6, 8), "innen"]]:
		state.change_map(p, s[0], s[1])
		p.dialog = {}
		await get_tree().create_timer(1.0).timeout
		_camera.reset_smoothing()
		await get_tree().create_timer(0.3).timeout
		get_viewport().get_texture().get_image().save_png(OS.get_cmdline_user_args()[0] + "/wegrast_%s.png" % s[2])
	get_tree().quit()
