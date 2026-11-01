extends Node
## Fotos vom Titelbildschirm und vom Menü danach: Ordner als Argument nach --


func _ready() -> void:
	var ordner: String = OS.get_cmdline_user_args()[0]
	var menu: Node = load("res://scenes/menu.tscn").instantiate()
	add_child(menu)
	await get_tree().create_timer(1.3).timeout
	get_viewport().get_texture().get_image().save_png(ordner + "/titel.png")
	menu.titel_schliessen()
	await get_tree().create_timer(0.8).timeout
	get_viewport().get_texture().get_image().save_png(ordner + "/menu.png")
	get_tree().quit()
