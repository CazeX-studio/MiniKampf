extends "res://scripts/welt/baukasten_test.gd"
## Baukasten-Testfeld: läuft ein paar Stellen ab und macht Bildschirmfotos (Nacht, Tag, Raster, hinter einem Haus).
## Aufruf mit Grafik: Godot --path . res://tests/baukasten_auto.tscn -- <Ordner für die Fotos>

var _t := 0.0
var _step := 0
var _dir := "user://"


func _ready() -> void:
	super()
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_dir = args[0]


func _process(delta: float) -> void:
	_t += delta
	var plan: Array = [
		[0.6, func() -> void: _foto("nacht")],
		[0.8, func() -> void: _set_night(false)],
		[1.4, func() -> void: _foto("tag")],
		[1.6, func() -> void: _toggle_grid()],
		[2.2, func() -> void: _foto("raster")],
		[2.4, func() -> void:
			_toggle_grid()
			_set_night(true)
			place_player(Vector2i(6, 22))],
		[3.4, func() -> void: _foto("hinter_haus")],
		[3.6, func() -> void: place_player(Vector2i(20, 3))],
		[4.6, func() -> void: _foto("torbogen")],
		[4.8, func() -> void: place_player(Vector2i(4, 20))],
		[5.8, func() -> void: _foto("sechstes_tor")],
		[6.0, func() -> void:
			_toggle_grid()
			place_player(Vector2i(20, 34))],
		[7.0, func() -> void: _foto("raster_bruecke")],
		[7.2, func() -> void:
			_toggle_grid()
			walk_to(Vector2i(21, 43))],
		[11.0, func() -> void:
			print("Nach dem Klick-Weg: ", Vector2i(_pos.floor()))
			_foto("bruecke")
			get_tree().quit()],
	]
	while _step < plan.size() and _t >= plan[_step][0]:
		plan[_step][1].call()
		_step += 1
	super(delta)


func _foto(name: String) -> void:
	var path := _dir.path_join("baukasten_%s.png" % name)
	get_viewport().get_texture().get_image().save_png(path)
	print("Foto: ", path)
