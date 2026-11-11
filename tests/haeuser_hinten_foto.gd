extends Node2D
## Fotos: jedes Haus mit Bild von hinten zweimal nebeneinander (links vorne, rechts hinten), mit der Grundfläche
## als gelbe Raute. So sieht man, ob das Bild von hinten gleich groß ist und auf seinen Feldern steht
## (GRAFIK_AUFTRAG.md Teil J). Ein Foto pro Haus: hinten_<teil>.png.
## Aufruf mit Grafik: Godot --path . res://tests/haeuser_hinten_foto.tscn -- <Ordner für die Fotos>

var _teile: Dictionary
var _namen: Array = []
var _rauten: Array = []
var _cam: Camera2D
var _i := -1
var _n := 0
var _ordner := "user://"


func _ready() -> void:
	_teile = JSON.parse_string(FileAccess.get_file_as_string("res://data/baukasten_teile.json"))
	RenderingServer.set_default_clear_color(Color("3b4a3a"))
	for k: String in _teile.objekte:
		if _teile.objekte[k].has("bild_hinten"):
			_namen.append(k)
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_ordner = args[0]
	_cam = Camera2D.new()
	add_child(_cam)
	_naechstes()


func _naechstes() -> void:
	_i += 1
	for c in get_children():
		if c != _cam:
			c.queue_free()
	_rauten.clear()
	if _i >= _namen.size():
		get_tree().quit()
		return
	var k: String = _namen[_i]
	var x := 0
	var flaeche := Rect2()
	for hinten: bool in [false, true]:
		var o := {teil = k, feld = [x, -x], hinten = hinten}
		var t := BaukastenBoden.teil_bauen(o, _teile)
		if t.is_empty():
			continue
		add_child(t.node)
		_rauten.append(BaukastenBoden.grundflaeche(o, _teile))
		flaeche = t.bild if flaeche.size == Vector2.ZERO else flaeche.merge(t.bild)
		x += int(t.rect.size.x + t.rect.size.y) + 1
	_cam.position = flaeche.get_center()
	var platz := Vector2(get_viewport().get_visible_rect().size)
	_cam.zoom = Vector2.ONE * minf(1.0, minf(platz.x / (flaeche.size.x + 80.0), platz.y / (flaeche.size.y + 80.0)))
	queue_redraw()
	_n = 0


func _draw() -> void:
	for r: Rect2i in _rauten:
		var p := PackedVector2Array([
			BaukastenBoden.cell_to_screen(Vector2(r.position)),
			BaukastenBoden.cell_to_screen(Vector2(r.position.x + r.size.x, r.position.y)),
			BaukastenBoden.cell_to_screen(Vector2(r.end)),
			BaukastenBoden.cell_to_screen(Vector2(r.position.x, r.position.y + r.size.y)),
		])
		draw_colored_polygon(p, Color(0.2, 0.25, 0.2))
		p.append(p[0])
		draw_polyline(p, Color(1, 1, 0), 2.0)


func _process(_d: float) -> void:
	_n += 1
	if _n == 6 and _i < _namen.size():
		get_viewport().get_texture().get_image().save_png(_ordner.path_join("hinten_%s.png" % _namen[_i]))
		_naechstes()
