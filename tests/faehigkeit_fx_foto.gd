extends Node
## Fotos eigener Effekte (K.6): Ordner als Argument nach --, danach die Effekt-Namen


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	BattleRequest.kampf_id = ""
	BattleRequest.setup = {}
	Sandbox.team = ["archer", "tank"] as Array[String]
	var kampf: Control = load("res://scenes/kampf.tscn").instantiate()
	add_child(kampf)
	await get_tree().create_timer(1.5).timeout
	var state: BattleState = kampf.state
	for name: String in args.slice(1):
		FaehigkeitFx.spielen(kampf, name, state.heroes[0], state.heroes[1], 0)
		await get_tree().create_timer(0.2).timeout
		get_viewport().get_texture().get_image().save_png("%s/fx_%s.png" % [args[0], name])
		await get_tree().create_timer(1.0).timeout
	print("Fotos gespeichert")
	get_tree().quit()
