extends Node
## A9b: Fotos vom Film, wenn der Kettenschmied in Phase 2 geht (vor, beim und nach dem Reißen der Ketten).
## Ordner als Argument nach --

func _ready() -> void:
	BattleRequest.prepare("kettenschmied", 20, 0, "blade")
	var kampf: Node = load("res://scenes/kampf.tscn").instantiate()
	add_child(kampf)
	await get_tree().create_timer(2.0).timeout
	var c := kampf as Combat
	var boss: Fighter = c.state.enemies[0]
	PhasenFilm.abspielen(c, c._field, c.view(boss), "ketten", "Entfesselt!",
			"Die Ketten reißen. Nur das Kühlbecken bricht seinen Panzer.", Color("ff8a3d"))
	var ordner: String = OS.get_cmdline_user_args()[0]
	for zeit: Array in [[1.1, "1"], [0.55, "2"], [0.9, "3"]]:
		await get_tree().create_timer(zeit[0]).timeout
		get_viewport().get_texture().get_image().save_png(ordner + "/phasen_film_%s.png" % zeit[1])
	get_tree().quit()
