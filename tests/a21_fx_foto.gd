extends Node
## A21: Fotos von Marcos Zusatz-Effekten (goldenes Nachbild bei perfekter Abwehr, Blitzeinschlag). Ordner nach --


func _ready() -> void:
	var ordner: String = OS.get_cmdline_user_args()[0]
	BattleRequest.prepare("kettenschmied", 20, 0, "blade")
	var kampf: Node = load("res://scenes/kampf.tscn").instantiate()
	add_child(kampf)
	await get_tree().create_timer(2.0).timeout
	var c := kampf as Combat
	var held: Fighter = c.state.allies()[0]
	FxBild.spawn(c._field, "parade_perfekt", c.view(held).center(), 0.4, false, 0.0, 1.0).z_index = 9
	FxBild.spawn(c._field, "nachbild", c.view(held).center() + Vector2(14, 6), 0.7, true, 0.0, 1.2).z_index = 8
	FaehigkeitFx.spielen(c, "blitz_einschlag", c.state.allies()[1], null, 0)
	await get_tree().create_timer(0.25).timeout
	get_viewport().get_texture().get_image().save_png(ordner + "/a21_effekte.png")
	get_tree().quit()
