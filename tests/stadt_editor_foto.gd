extends Node
## Fotos vom Stadt-Editor (S4a): Kreuzweg mit ausgewählter Figur, Glutoase nachts mit ausgewähltem Teil. Ordner nach --


func _ready() -> void:
	var ordner: String = OS.get_cmdline_user_args()[0]
	var platzhalter := Node.new()
	get_tree().root.add_child.call_deferred(platzhalter)
	await get_tree().process_frame
	get_tree().current_scene = platzhalter
	var skript: GDScript = load("res://scripts/welt/stadt_editor.gd")
	skript.stadt = "kreuzweg"
	skript.nacht = false
	skript.zoom_stufe = 2
	get_tree().change_scene_to_file("res://scenes/stadt_editor.tscn")
	await get_tree().create_timer(1.0).timeout
	var ed: Node = get_tree().current_scene
	ed.auswahl = {art = "figur", nr = 0}
	ed._auswahl_zeigen()
	ed._kamera.position = (ed.figuren[0].node as Node2D).position
	await get_tree().create_timer(0.5).timeout
	_foto(ordner + "/stadt_editor_kreuzweg.png")
	skript.stadt = "glutoase"
	skript.nacht = true
	get_tree().reload_current_scene()
	await get_tree().create_timer(1.0).timeout
	ed = get_tree().current_scene
	ed._dazu_panel.visible = true
	ed.auswahl = {art = "teil", nr = 1}
	ed._auswahl_zeigen()
	ed._kamera.position = (ed.objekte[1].bild as Rect2).get_center()
	await get_tree().create_timer(0.5).timeout
	_foto(ordner + "/stadt_editor_glutoase.png")
	get_tree().quit()


func _foto(pfad: String) -> void:
	get_viewport().get_texture().get_image().save_png(pfad)
