extends Node2D
## Foto aller Köpfe auf passenden Körpern, schräg von vorne nach rechts (A7: Kopfrichtung prüfen). Ordner nach --
## Bei jedem neuen Kopf ansehen: Gesicht und Körper müssen in dieselbe Richtung schauen.


func _ready() -> void:
	var ordner: String = OS.get_cmdline_user_args()[0]
	var bg := ColorRect.new()
	bg.color = Color("4f7a3a")
	bg.size = Vector2(1280, 720)
	add_child(bg)
	var daten: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/figurteile.json"))
	# Jeder Kopf auf dem ersten Körper, zu dem er gehört (Novizen-Köpfe auf dem Novizen-Körper)
	var koerper_von := {}
	var namen: Array = daten.keys()
	namen.sort()
	namen.reverse()  # novize_* vor grund_*
	for koerper: String in namen:
		if not daten[koerper] is Dictionary:
			continue
		for k: String in daten[koerper].get("_koepfe", {}):
			if not koerper_von.has(k) or (k.length() == 2 and koerper.begins_with("novize")):
				koerper_von[k] = koerper
	var koepfe: Array = koerper_von.keys()
	koepfe.sort()
	for i in koepfe.size():
		var kopf: String = koepfe[i]
		var f := WorldCharacter.new()
		f.setup("%s+%s" % [koerper_von[kopf], kopf], kopf)
		f.position = Vector2(55 + (i % 13) * 97, 190 + (i / 13) * 230)
		f.scale = Vector2(1.1, 1.1)
		f.richtungen = true
		f.facing = 1
		add_child(f)
	await get_tree().create_timer(0.8).timeout
	get_viewport().get_texture().get_image().save_png(ordner + "/alle_koepfe.png")
	get_tree().quit()
