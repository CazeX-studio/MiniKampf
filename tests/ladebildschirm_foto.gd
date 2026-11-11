extends Node
## A20: Foto vom Ladebildschirm beim Betreten der Welt. Ordner als Argument nach --, danach optional ein Bild
## (z. B. klingentaenzer): dann nur dieses Bild als Ladebildschirm.


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 1:
		var schirm := Ladebildschirm.new()
		add_child(schirm)
		schirm._aufbauen(load(Ladebildschirm.ORDNER % args[1]), "Glutoase", "Ein Tipp zum Ausprobieren.",
				GameData.get_file("ladebildschirm").get("zuschnitt", {}).get(args[1], 0.5))
		await get_tree().create_timer(0.5).timeout
		get_viewport().get_texture().get_image().save_png(args[0] + "/ladebildschirm_%s.png" % args[1])
		get_tree().quit()
		return
	var welt: Node = load("res://scenes/kreuzweg.tscn").instantiate()
	add_child(welt)
	await get_tree().create_timer(1.2).timeout
	get_viewport().get_texture().get_image().save_png(OS.get_cmdline_user_args()[0] + "/ladebildschirm.png")
	await get_tree().create_timer(2.2).timeout
	get_viewport().get_texture().get_image().save_png(OS.get_cmdline_user_args()[0] + "/ladebildschirm_danach.png")
	get_tree().quit()
