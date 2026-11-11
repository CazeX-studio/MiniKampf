extends Node
## Fotos der Klassenwahl mit den gemalten Klassenbildern (A3b): Ordner als Argument nach --


func _ready() -> void:
	for id: String in ["archer", "smith", "blade", "tamer", "singer", "tank"]:
		var wahl: Node = load("res://scenes/klassenwahl.tscn").instantiate()
		add_child(wahl)
		await get_tree().process_frame
		wahl._select(id)
		await get_tree().create_timer(0.5, true).timeout
		get_viewport().get_texture().get_image().save_png("%s/klassenwahl_%s.png" % [OS.get_cmdline_user_args()[0], id])
		wahl.queue_free()
		await get_tree().process_frame
	get_tree().quit()
