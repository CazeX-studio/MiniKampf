extends Node
## Fotos der Klassen-Körper in der Probestunde (D25b): Ordner als Argument nach --


func _ready() -> void:
	var faelle := [["novize_m+m1", "smith"], ["novize_w+w2", "smith"], ["novize_w+w1", "singer"]]
	for fall: Array in faelle:
		BattleRequest.player_look = fall[0]
		BattleRequest.prepare("probe:" + str(fall[1]), 8, 0, "novize")
		var kampf: Node = load("res://scenes/kampf.tscn").instantiate()
		add_child(kampf)
		await get_tree().create_timer(1.5, true).timeout
		var datei := "%s/%s_%s.png" % [OS.get_cmdline_user_args()[0], fall[1], str(fall[0]).right(2)]
		get_viewport().get_texture().get_image().save_png(datei)
		kampf.queue_free()
		await get_tree().process_frame
	get_tree().quit()
