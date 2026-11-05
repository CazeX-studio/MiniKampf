extends Node
## Fotos aller Kampf-Hintergründe der Orte (E3d), dazu zwei bei Nacht: Ordner als Argument nach --


func _ready() -> void:
	var ordner := OS.get_cmdline_user_args()[0]
	var liste: Array = []
	for stil: String in BackdropOrte.STILE:
		liste.append([stil, 0.0])
	liste.append(["aschensteppe", 1.0])
	liste.append(["waldweg", 1.0])
	for eintrag: Array in liste:
		var b := Backdrop.new()
		b.style = eintrag[0]
		b.nacht = eintrag[1]
		add_child(b)
		await get_tree().create_timer(0.4).timeout
		var name: String = eintrag[0] + ("_nacht" if eintrag[1] > 0.0 else "")
		get_viewport().get_texture().get_image().save_png(ordner + "/hg_" + name + ".png")
		b.queue_free()
		await get_tree().process_frame
	get_tree().quit()
