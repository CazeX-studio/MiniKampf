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
	# Angabe "name" oder "name:sekunden" (wann das Foto entsteht)
	for angabe: String in args.slice(1):
		var name := angabe.get_slice(":", 0)
		FaehigkeitFx.spielen(kampf, name, state.heroes[0], state.alive(state.enemies)[0], 0, Color("ff8a3c"))
		await get_tree().create_timer(float(angabe.get_slice(":", 1)) if ":" in angabe else 0.2).timeout
		get_viewport().get_texture().get_image().save_png("%s/fx_%s.png" % [args[0], name])
		await get_tree().create_timer(1.0).timeout
	print("Fotos gespeichert")
	get_tree().quit()
