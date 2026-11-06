extends Node
## Fotos vom Gruppenkampf vor jedem Kampf-Hintergrund (E3d), dazu zwei bei Nacht: Ordner als Argument nach --
## Mit einem zweiten Argument nur dieser Hintergrund (z. B. -- <Ordner> glutgrat).


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var ordner := args[0]
	var liste: Array = []
	for stil: String in ["kreuzwegfelder", "marktplatz_nacht", "waldweg", "wald", "wipfelheim", "tiefwurzel", "pilzhoehle",
			"aschensteppe", "aschensteppe_sand", "palmenrast", "sternenduene", "glutoase_stadt", "glutoase_schmiede",
			"glutgrat", "vulkanschmiede", "ankerkammer"]:
		if args.size() < 2 or args[1] == stil:
			liste.append([stil, 0.0])
	if args.size() < 2:
		liste.append(["aschensteppe", 1.0])
		liste.append(["waldweg", 1.0])
	BattleRequest.player_look = "vega"
	for eintrag: Array in liste:
		Tageszeit.feste_stunde = 23.0 if eintrag[1] > 0.0 else 12.0
		BattleRequest.prepare("gruppenkampf", 3, 2, "")
		BattleRequest.setup.hintergrund = eintrag[0]
		var kampf: Node = load("res://scenes/kampf.tscn").instantiate()
		add_child(kampf)
		await get_tree().create_timer(1.2).timeout
		var name: String = eintrag[0] + ("_nacht" if eintrag[1] > 0.0 else "")
		get_viewport().get_texture().get_image().save_png(ordner + "/kampf_" + name + ".png")
		kampf.queue_free()
		await get_tree().process_frame
	get_tree().quit()
