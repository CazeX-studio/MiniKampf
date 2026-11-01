extends "res://scripts/welt/kreuzweg.gd"
## Fotos der Stadt aus dem Baukasten: Ordner als Argument nach --

const STELLEN := [["ankunft", Vector2i(31, 62)], ["suedtor", Vector2i(32, 47)], ["marktplatz", Vector2i(31, 28)],
		["gilde", Vector2i(14, 46)], ["wegrast", Vector2i(12, 29)], ["bingo", Vector2i(36, 17)], ["bank", Vector2i(38, 9)],
		["hof", Vector2i(52, 31)], ["schmiede", Vector2i(44, 44)], ["nordtor", Vector2i(32, 5)],
		["ostor", Vector2i(58, 32)], ["nebeltor", Vector2i(4, 6)], ["sechstes", Vector2i(60, 54)], ["suedostweg", Vector2i(48, 48)]]


func _ready() -> void:
	SaveGame.delete()
	super()
	await get_tree().create_timer(0.5).timeout
	var p := local_player()
	p.dialog = {}
	p.safe_time = 99.0
	for s: Array in STELLEN:
		p.pos = Vector2(s[1])
		p.cell = s[1]
		await get_tree().create_timer(0.5).timeout
		_camera.reset_smoothing()
		await get_tree().create_timer(0.2).timeout
		get_viewport().get_texture().get_image().save_png(OS.get_cmdline_user_args()[0] + "/stadt_%s.png" % s[0])
	get_tree().quit()
