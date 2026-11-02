extends Node
## Foto der Kampf-Sandbox mit Effekten (Projekt 14, K.4): Ordner als Argument nach --


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	BattleRequest.kampf_id = ""
	BattleRequest.setup = {}
	Sandbox.team = ["archer", "tank"] as Array[String]
	Sandbox.effekt_probe = true
	var kampf: Node = load("res://scenes/kampf.tscn").instantiate()
	add_child(kampf)
	await get_tree().create_timer(1.5).timeout
	var state: BattleState = kampf.state
	var gegner := state.alive(state.enemies)
	Effekte.anwenden(state, state.heroes[0], gegner[0], "brennen")
	Effekte.anwenden(state, state.heroes[0], gegner[0], "gift")
	Effekte.anwenden(state, state.heroes[0], gegner[0], "gift")
	if gegner.size() > 1:
		Effekte.anwenden(state, state.heroes[0], gegner[1], "schattenmale")
		Effekte.anwenden(state, state.heroes[0], gegner[1], "laehmen")
	Effekte.anwenden(state, gegner[0], state.heroes[1], "gift")
	Effekte.anwenden(state, gegner[0], state.heroes[1], "festhalten")
	await get_tree().create_timer(1.0).timeout
	get_viewport().get_texture().get_image().save_png(args[0] + "/effekte.png")
	print("Foto gespeichert")
	get_tree().quit()
