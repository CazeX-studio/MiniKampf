extends Node
## A9b: Fotos vom Film, wenn ein Boss in Phase 2 geht (vor, beim und nach dem Bruch).
## Ordner als Argument nach --, danach optional "leere" (Vorbote) statt Kettenschmied.

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var leere := args.size() > 1 and args[1] == "leere"
	BattleRequest.prepare("pilz_urbaum" if leere else "kettenschmied", 20, 0, "blade")
	var kampf: Node = load("res://scenes/kampf.tscn").instantiate()
	add_child(kampf)
	await get_tree().create_timer(2.0).timeout
	var c := kampf as Combat
	var boss: Fighter = c.state.enemies[0]
	if leere:
		PhasenFilm.abspielen(c, c._field, c.view(boss), "leere", "Der Vorbote", "Er frisst das Licht. Nur im Licht trifft man ihn.",
				Color("b48cff"))
	else:
		PhasenFilm.abspielen(c, c._field, c.view(boss), "ketten", "Entfesselt!",
				"Die Ketten reißen. Nur das Kühlbecken bricht seinen Panzer.", Color("ff8a3d"))
	var name := "leere" if leere else "ketten"
	for zeit: Array in [[1.1, "1"], [0.55, "2"], [0.9, "3"]]:
		await get_tree().create_timer(zeit[0]).timeout
		get_viewport().get_texture().get_image().save_png(args[0] + "/phasen_film_%s_%s.png" % [name, zeit[1]])
	get_tree().quit()
