extends Node
## A9c1: Fotos der gemalten Effekte beim Kettenschmied (Lava unter den Reihen, glühende Kette, nass, Panzer, Lavaflut).
## Ordner als Argument nach --


func _ready() -> void:
	var ordner: String = OS.get_cmdline_user_args()[0]
	BattleRequest.prepare("kettenschmied", 20, 0, "blade")
	var kampf: Node = load("res://scenes/kampf.tscn").instantiate()
	add_child(kampf)
	await get_tree().create_timer(2.0).timeout
	var c := kampf as Combat
	var helden: Array[Fighter] = c.state.allies()
	var boss: Fighter = c.state.enemies[0]
	# Lava: vorne Warnung, hinten Lava oben; dazu die glühende Kette zwischen zwei Helden
	c._zeige_lava("vorne", "warnung")
	c._zeige_lava("hinten", "oben")
	c._fessel_a = helden[0]
	c._fessel_b = helden[1]
	c._fessel_glut = 1
	await get_tree().create_timer(1.0).timeout
	_foto(ordner, "lava_kette")
	FaehigkeitFx.spielen(c, "nass", helden[2], null, 0)
	FaehigkeitFx.spielen(c, "panzer_splitter", boss, null, 0)
	FaehigkeitFx.spielen(c, "kette_reisst", helden[0], helden[1], 0)
	await get_tree().create_timer(0.3).timeout
	_foto(ordner, "nass_panzer")
	c._fessel_glut = 0
	FaehigkeitFx.spielen(c, "lavaflut", boss, null, 0)
	await get_tree().create_timer(0.55).timeout
	_foto(ordner, "lavaflut")
	get_tree().quit()


func _foto(ordner: String, name: String) -> void:
	get_viewport().get_texture().get_image().save_png("%s/vulkan_%s.png" % [ordner, name])
