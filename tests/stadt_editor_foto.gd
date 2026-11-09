extends "res://scripts/welt/stadt_editor.gd"
## Foto vom Stadt-Editor (S4a): Ordner als Argument nach --; KARTE=… wählt die Karte


func _ready() -> void:
	karte = OS.get_environment("KARTE") if OS.get_environment("KARTE") != "" else "kreuzweg"
	super()
	await get_tree().create_timer(0.5).timeout
	# Das erste stehende Teil wählen und einen Schritt verschieben
	for i in _teil_views.size():
		if not _teil_views[i].is_empty() and not _teil_views[i].flach:
			waehlen({art = "teil", index = i})
			_kamera.position = _teil_views[i].node.position
			break
	await get_tree().create_timer(0.3).timeout
	get_viewport().get_texture().get_image().save_png(OS.get_cmdline_user_args()[0] + "/stadt_%s.png" % karte)
	get_tree().quit()
