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
		[0.9, func() -> void:
			set_stufe(1)
			place_player(Vector2i(34, 37))],
		[1.3, func() -> void: _foto("krater_frisch")],
		[1.5, func() -> void: set_stufe(2)],
		[1.9, func() -> void:
			_foto("krater_spaet")
			set_stufe(0)
			place_player(Vector2i(32, 48))],
		[2.45, func() -> void: _set_night(false)],
		[2.9, func() -> void: _foto("tag")],
		[3.1, func() -> void: _toggle_grid()],
		[3.7, func() -> void: _foto("raster")],
		[3.9, func() -> void:
			_toggle_grid()
			_set_night(true)
			place_player(Vector2i(11, 32))],
		[4.9, func() -> void: _foto("hinter_haus")],
		[5.1, func() -> void: place_player(Vector2i(31, 3))],
		[6.1, func() -> void: _foto("torbogen")],
		[6.3, func() -> void: place_player(Vector2i(4, 32))],
		[7.3, func() -> void: _foto("sechstes_tor")],
		[7.5, func() -> void:
			_toggle_grid()
			place_player(Vector2i(31, 53))],
		[8.5, func() -> void: _foto("raster_bruecke")],
		[8.7, func() -> void:
			_toggle_grid()
			walk_to(Vector2i(32, 62))],
		[13.5, func() -> void:
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
