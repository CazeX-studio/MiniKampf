extends "res://scripts/welt/kreuzweg.gd"
## Fotos von Grünwacht aus dem Baukasten: Ordner als Argument nach --

const STELLEN := [["rast", "weg_gruenwacht", Vector2i(30, 7)], ["waldweg", "weg_gruenwacht", Vector2i(14, 9)],
		["aufzug", "waldboden", Vector2i(20, 19)], ["urbaum", "waldboden", Vector2i(18, 28)], ["wald", "waldboden", Vector2i(36, 18)],
		["gasthaus", "wipfelheim", Vector2i(12, 24)], ["halle", "wipfelheim", Vector2i(26, 23)], ["fenn", "wipfelheim", Vector2i(26, 6)],
		["stall", "wipfelheim", Vector2i(41, 22)], ["labor", "wipfelheim", Vector2i(24, 35)],
		["hoehle", "pilzhoehle", Vector2i(27, 11)], ["koenigin", "pilzhoehle", Vector2i(13, 12)]]


func _ready() -> void:
	SaveGame.delete()
	super()
	await get_tree().create_timer(0.5).timeout
	var p := local_player()
	p.dialog = {}
	p.safe_time = 9999.0
	for s: Array in STELLEN:
		p.map = s[1]
		p.pos = Vector2(s[2])
		p.cell = s[2]
		await get_tree().create_timer(0.8).timeout
		_camera.reset_smoothing()
		await get_tree().create_timer(0.3).timeout
		get_viewport().get_texture().get_image().save_png(OS.get_cmdline_user_args()[0] + "/gw_%s.png" % s[0])
	get_tree().quit()
