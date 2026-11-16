extends Node
## Foto vom Fähigkeitenbaum (P12, gemalte Pfeile und Rahmen aus V4): Ordner als Argument nach --


func _ready() -> void:
	var ordner: String = OS.get_cmdline_user_args()[0]
	for klasse: String in ["archer", "smith"]:
		var p := Progress.new()
		p.flags = {"klasse": klasse, "klasse_gelernt": true}
		p.klassen_xp = 40000
		var ids: Array = Faehigkeiten.baum(klasse).faehigkeiten.map(func(f: Dictionary) -> String: return f.id)
		for i in ids.size() / 2:
			p.faehigkeiten[ids[i]] = 3
		var grund := Panel.new()
		grund.size = Vector2(1280, 720)
		add_child(grund)
		var rollen := ScrollContainer.new()
		rollen.size = Vector2(1280, 720)
		grund.add_child(rollen)
		var baum := FaehigkeitenBaum.new()
		rollen.add_child(baum)
		baum.bauen(p, func(_b: Dictionary) -> void: pass, func() -> void: pass)
		await get_tree().create_timer(0.6).timeout
		get_viewport().get_texture().get_image().save_png(ordner + "/baum_%s.png" % klasse)
		grund.queue_free()
		await get_tree().process_frame
	get_tree().quit()
