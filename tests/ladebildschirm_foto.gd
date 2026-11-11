extends Node
## A20: Foto vom Ladebildschirm beim Betreten der Welt. Ordner als Argument nach --


func _ready() -> void:
	var welt: Node = load("res://scenes/kreuzweg.tscn").instantiate()
	add_child(welt)
	await get_tree().create_timer(1.2).timeout
	get_viewport().get_texture().get_image().save_png(OS.get_cmdline_user_args()[0] + "/ladebildschirm.png")
	await get_tree().create_timer(2.2).timeout
	get_viewport().get_texture().get_image().save_png(OS.get_cmdline_user_args()[0] + "/ladebildschirm_danach.png")
	get_tree().quit()
