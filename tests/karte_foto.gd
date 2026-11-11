extends "res://scripts/welt/kreuzweg.gd"
## A11: Fotos der kleinen Karte oben rechts (Kreuzweg, Waldboden, Glutoase) und der großen Karte (Taste M).
## Ordner als Argument nach --

const STELLEN := [["kreuzweg", Vector2i(30, 30)], ["waldboden", Vector2i(20, 20)], ["glutoase", Vector2i(22, 40)]]


func _ready() -> void:
	SaveGame.delete()
	super()
	await get_tree().create_timer(0.5).timeout
	var p := local_player()
	p.dialog = {}
	p.safe_time = 9999.0
	for s: Array in STELLEN:
		state.change_map(p, s[0], s[1])
		p.dialog = {}
		await get_tree().create_timer(1.0).timeout
		_camera.reset_smoothing()
		await get_tree().create_timer(0.3).timeout
		get_viewport().get_texture().get_image().save_png(OS.get_cmdline_user_args()[0] + "/karte_klein_%s.png" % s[0])
	_toggle_weltkarte()
	await get_tree().create_timer(0.5).timeout
	get_viewport().get_texture().get_image().save_png(OS.get_cmdline_user_args()[0] + "/karte_gross.png")
	get_tree().quit()
