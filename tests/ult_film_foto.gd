extends Node
## Fotos der filmischen Ult (D9a), je Klasse ein Hintergrund: Ordner als Argument nach --


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	BattleRequest.kampf_id = ""
	BattleRequest.setup = {}
	Sandbox.team = ["archer", "tank"] as Array[String]
	var kampf: Node = load("res://scenes/kampf.tscn").instantiate()
	add_child(kampf)
	await get_tree().create_timer(1.5).timeout
	Musik.ist_ult_kurz()
	var alt_gesehen: Array = Musik._ult_gesehen.duplicate()
	var alt_kurz := Musik.ult_kurz
	Musik.ult_kurz = false
	var state: BattleState = kampf.state
	for klasse: String in UltFilm.BILD:
		var ansicht: FighterView = kampf.view(state.heroes[0])
		UltFilm.abspielen(kampf, kampf._field, ansicht, klasse, "Name der Ult")
		await get_tree().create_timer(1.7).timeout
		get_viewport().get_texture().get_image().save_png("%s/ult_%s.png" % [args[0], klasse])
		await get_tree().create_timer(2.2).timeout
	Musik._ult_gesehen = alt_gesehen
	Musik.ult_kurz = alt_kurz
	Musik._save_settings()
	print("Fotos gespeichert")
	get_tree().quit()
