extends Node
## A9c2: Fotos der gemalten Effekte in der Pilzhöhle (Giftwolken, Heilsporen, Wurzeln, Laternen, Splitterlicht, Leere)
## und vom Film des Vorboten. Ordner als Argument nach --


func _ready() -> void:
	var ordner: String = OS.get_cmdline_user_args()[0]
	BattleRequest.prepare("pilz_koenigin", 20, 0, "blade")
	var kampf: Node = load("res://scenes/kampf.tscn").instantiate()
	add_child(kampf)
	await get_tree().create_timer(2.0).timeout
	var c := kampf as Combat
	var helden: Array[Fighter] = c.state.allies()
	var gegner: Array[Fighter] = c.state.enemies
	c._setze_wolken(3)
	await get_tree().create_timer(1.0).timeout
	FaehigkeitFx.spielen(c, "heilsporen", gegner[gegner.size() - 1], gegner[0], 0)
	FaehigkeitFx.spielen(c, "wurzelgriff", helden[0], null, 0)
	FaehigkeitFx.spielen(c, "leere", helden[1], null, 0)
	await get_tree().create_timer(0.4).timeout
	_foto(ordner, "wolken_sporen_wurzeln")
	# Dunkelheit mit Laternen und Splitterlicht
	c._setze_wolken(0)
	c._darkness = 0.6
	c._add_lantern()
	c._add_lantern()
	helden[2].light = true
	FaehigkeitFx.spielen(c, "splitterlicht", helden[2], helden[0], 0)
	await get_tree().create_timer(0.3).timeout
	_foto(ordner, "dunkel_laternen")
	await get_tree().create_timer(0.8).timeout
	c._darkness = 0.0
	FaehigkeitFx.spielen(c, "lichtfrass", gegner[0], null, 0)
	await get_tree().create_timer(0.45).timeout
	_foto(ordner, "lichtfrass")
	get_tree().quit()


func _foto(ordner: String, name: String) -> void:
	get_viewport().get_texture().get_image().save_png("%s/pilz_%s.png" % [ordner, name])
