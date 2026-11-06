extends Node
## Fotos vom Demo-Start (S1), so wie Tester ihn sehen: Menü, Spitznamen-Fenster, Dankesliste, Welt mit
## Feedback-Knopf, Ende der Glutoase mit Tester-Code. Ordner als Argument nach --


func _ready() -> void:
	var ordner: String = OS.get_cmdline_user_args()[0]
	Tester.als_demo = true
	Tester.datei = "user://tester_foto.json"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Tester.datei))
	Tester.neu_laden()
	load("res://scripts/menu.gd").titel_gesehen = true
	var menu: Node = load("res://scenes/menu.tscn").instantiate()
	add_child(menu)
	await get_tree().create_timer(0.8).timeout
	_foto(ordner + "/demo_menu.png")
	Tester.spitzname_fenster(menu, func() -> void: pass)
	await get_tree().create_timer(0.4).timeout
	_foto(ordner + "/demo_spitzname.png")
	Tester.festlegen("Sternchen")
	menu.queue_free()
	await get_tree().process_frame
	menu = load("res://scenes/menu.tscn").instantiate()
	add_child(menu)
	await get_tree().create_timer(0.6).timeout
	menu._danke_zeigen()
	await get_tree().create_timer(0.4).timeout
	_foto(ordner + "/demo_danke.png")
	menu.queue_free()
	var welt: Node = load("res://scenes/kreuzweg.tscn").instantiate()
	add_child(welt)
	await get_tree().create_timer(1.5).timeout
	_foto(ordner + "/demo_welt.png")
	welt.queue_free()
	await get_tree().process_frame
	Abspann.variante = "glutoase"
	var ende: Node = load("res://scenes/abspann.tscn").instantiate()
	add_child(ende)
	await get_tree().create_timer(0.8).timeout
	_foto(ordner + "/demo_ende.png")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Tester.datei))
	get_tree().quit()


func _foto(pfad: String) -> void:
	get_viewport().get_texture().get_image().save_png(pfad)
