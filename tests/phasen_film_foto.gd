extends Node
## A9b: Fotos vom Film, wenn ein Boss in Phase 2 geht (vor, beim und nach dem Bruch).
## Ordner als Argument nach --, danach optional das Motiv: "leere" (Vorbote), "sporen" (Sporenkönigin),
## "amboss" (Hammerbrüder); ohne: Kettenschmied.

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var motiv: String = args[1] if args.size() > 1 else "ketten"
	var kampf_id: String = {"leere": "pilz_urbaum", "sporen": "pilz_koenigin", "amboss": "hammerbrueder"}.get(motiv, "kettenschmied")
	BattleRequest.prepare(kampf_id, 20, 0, "blade")
	var kampf: Node = load("res://scenes/kampf.tscn").instantiate()
	add_child(kampf)
	await get_tree().create_timer(2.0).timeout
	var c := kampf as Combat
	var boss: Fighter = c.state.enemies[0]
	var texte := {"leere": ["Der Vorbote", "Er frisst das Licht. Nur im Licht trifft man ihn.", Color("b48cff")],
			"sporen": ["Die Königin erblüht!", "Ihre Knospen schützen sie. Besiegt beide zugleich!", Color("b0ff70")],
			"amboss": ["Hammerwut!", "Der Doppelschlag kommt jetzt viel öfter. Stört sie!", Color("ffb070")],
			"ketten": ["Entfesselt!", "Die Ketten reißen. Nur das Kühlbecken bricht seinen Panzer.", Color("ff8a3d")]}
	var t: Array = texte.get(motiv, texte.ketten)
	PhasenFilm.abspielen(c, c._field, c.view(boss), motiv, t[0], t[1], t[2])
	var name := motiv
	for zeit: Array in [[1.1, "1"], [0.55, "2"], [0.9, "3"]]:
		await get_tree().create_timer(zeit[0]).timeout
		get_viewport().get_texture().get_image().save_png(args[0] + "/phasen_film_%s_%s.png" % [name, zeit[1]])
	get_tree().quit()
