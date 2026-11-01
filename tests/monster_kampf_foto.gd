extends Node
## Foto eines Kampfes mit frei gewählten Gegnern: Ordner, Dateiname und Gegner (mit Komma getrennt) als Argumente nach --


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	BattleRequest.player_look = "vega"
	BattleRequest.prepare("gruppenkampf", 3, 2, "")
	BattleRequest.setup.wellen = [Array(args[2].split(","))]
	add_child(load("res://scenes/kampf.tscn").instantiate())
	await get_tree().create_timer(1.5).timeout
	get_viewport().get_texture().get_image().save_png(args[0] + "/" + args[1] + ".png")
	get_tree().quit()
