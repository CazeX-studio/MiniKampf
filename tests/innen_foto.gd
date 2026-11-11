extends "res://scripts/welt/kreuzweg.gd"
## A12: Fotos von Gasthäusern außen und innen. Aufruf: ... res://tests/innen_foto.tscn -- <Ordner> <karte:x:y:name> ...
## Ohne Stellen: das Wegrast außen und innen.

func _ready() -> void:
	SaveGame.delete()
	super()
	await get_tree().create_timer(0.5).timeout
	var p := local_player()
	p.dialog = {}
	var args := OS.get_cmdline_user_args()
	var stellen: Array = args.slice(1) if args.size() > 1 else ["kreuzweg:10:30:wegrast_aussen", "wegrast:6:8:wegrast_innen"]
	for s: String in stellen:
		var t := s.split(":")
		state.change_map(p, t[0], Vector2i(int(t[1]), int(t[2])))
		p.dialog = {}
		await get_tree().create_timer(1.0).timeout
		_camera.reset_smoothing()
		await get_tree().create_timer(0.3).timeout
		get_viewport().get_texture().get_image().save_png(args[0] + "/%s.png" % t[3])
	get_tree().quit()
