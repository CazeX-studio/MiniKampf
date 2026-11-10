extends Node
## Übersicht einer Stadt (E3h): die ganze Karte und neun Ausschnitte, ohne Knöpfe. -- <Ordner> <stadt> [nacht]
## Städte: kreuzweg, wipfelheim, glutoase

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var ordner: String = args[0]
	var platzhalter := Node.new()
	get_tree().root.add_child.call_deferred(platzhalter)
	await get_tree().process_frame
	get_tree().current_scene = platzhalter
	var skript: GDScript = load("res://scripts/welt/stadt_editor.gd")
	skript.stadt = args[1]
	skript.nacht = args.size() > 2
	get_tree().change_scene_to_file("res://scenes/stadt_editor.tscn")
	await get_tree().create_timer(1.0).timeout
	var ed: Node = get_tree().current_scene
	ed.get_child(ed.get_child_count() - 1).visible = false
	for c in ed.get_children():
		if c is CanvasLayer:
			c.visible = false
	var karte: Dictionary = GameData.roh(StadtAenderungen.STAEDTE[args[1]].karte)
	var groesse := Vector2(karte.boden[0].length(), karte.boden.size())
	ed._kamera.zoom = Vector2.ONE * 0.3
	ed._kamera.position = BaukastenBoden.cell_to_screen(groesse * 0.5)
	await get_tree().create_timer(0.4).timeout
	get_viewport().get_texture().get_image().save_png(ordner + "/ganz.png")
	ed._kamera.zoom = Vector2.ONE * 0.62
	for y in 3:
		for x in 3:
			ed._kamera.position = BaukastenBoden.cell_to_screen(Vector2(groesse.x * (x + 0.5) / 3.0, groesse.y * (y + 0.5) / 3.0))
			await get_tree().create_timer(0.3).timeout
			get_viewport().get_texture().get_image().save_png(ordner + "/teil_%d_%d.png" % [x, y])
	get_tree().quit()
