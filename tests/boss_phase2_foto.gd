extends Node
## A9b: Fotos vom Film beim Wechsel in Phase 2 (Vorbote und Kettenschmied). Ordner als Argument nach --
## Aufruf: Godot --path . res://tests/boss_phase2_foto.tscn -- <Ordner>


func _ready() -> void:
	var ordner: String = OS.get_cmdline_user_args()[0]
	for paar: Array in [["pilz_urbaum", "wurzelmutter", "vorbote"], ["kettenschmied", "kettenschmied_1", "kettenschmied"]]:
		BattleRequest.prepare(paar[0], 20, 0, "blade")
		var kampf: Combat = load("res://scenes/kampf.tscn").instantiate()
		add_child(kampf)
		await get_tree().create_timer(1.5).timeout
		var st: BattleState = kampf.state
		for e in st.enemies:
			if e.klass == paar[1]:
				e.hp = 0
		st.dungeon.check_phase()
		st._flush()
		await get_tree().create_timer(1.6).timeout
		get_viewport().get_texture().get_image().save_png(ordner + "/phase2_%s.png" % paar[2])
		kampf.queue_free()
		await get_tree().create_timer(0.3).timeout
	get_tree().quit()
