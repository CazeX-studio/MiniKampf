extends Node
## Foto vom Gruppenkampf auf der Übungswiese mit den Kreuzwegfeld-Monstern: Ordner als Argument nach --


func _ready() -> void:
	BattleRequest.player_look = "vega"
	BattleRequest.prepare("gruppenkampf", 3, 2, "")
	add_child(load("res://scenes/kampf.tscn").instantiate())
	await get_tree().create_timer(1.5).timeout
	get_viewport().get_texture().get_image().save_png(OS.get_cmdline_user_args()[0] + "/feld_kampf.png")
	get_tree().quit()
