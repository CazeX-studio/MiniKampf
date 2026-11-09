extends Node
## Fotos vom Bewegungs-Editor in der Welt (S3b): Novizin von hinten laufend, angehalten. Ordner nach --


func _ready() -> void:
	var ordner: String = OS.get_cmdline_user_args()[0]
	var platzhalter := Node.new()
	get_tree().root.add_child.call_deferred(platzhalter)
	await get_tree().process_frame
	get_tree().current_scene = platzhalter
	var skript: GDScript = load("res://scripts/welt/welt_bewegung_editor.gd")
	skript.gruppe = 0
	skript.figur = "novize_w"
	skript.kopf = "w2"
	skript.richtung = 4
	skript.bewegung = 1
	get_tree().change_scene_to_file("res://scenes/welt_bewegung_editor.tscn")
	await get_tree().create_timer(1.0).timeout
	var ed: Node = get_tree().current_scene
	ed._schritt(2)
	await get_tree().create_timer(0.3).timeout
	_foto(ordner + "/welt_bewegung_hinten.png")
	ed._figur_wahl.get_parent().get_child(1).item_selected.emit(2)
	ed._richtung_knoepfe[3].pressed.emit()
	ed._bewegung_knoepfe[0].pressed.emit()
	await get_tree().create_timer(0.3).timeout
	_foto(ordner + "/welt_bewegung_baukasten.png")
	get_tree().quit()


func _foto(pfad: String) -> void:
	get_viewport().get_texture().get_image().save_png(pfad)
