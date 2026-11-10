extends Node2D
## Fotos zur Kopfrichtung (A7): Figuren in der Welt nach links, rechts, schräg von vorne, schräg von hinten,
## stehend und laufend. Ordner nach --, danach optional die Figuren (Standard: Novizen m1, w1 und Layla, Nadia, Hanne).

const RICHTUNGEN := [[-1, false, false], [1, false, false], [1, true, false], [-1, true, false], [1, true, true]]


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var ordner: String = args[0]
	var looks: Array = args.slice(1) if args.size() > 1 else ["novize_m+m1", "novize_w+w1", "grund_frau+layla", "grund_frau+nadia", "grund_frau+hanne"]
	var bg := ColorRect.new()
	bg.color = Color("4f7a3a")
	bg.size = Vector2(1280, 720)
	add_child(bg)
	for look: String in looks:
		for c in get_children():
			if c is WorldCharacter:
				c.queue_free()
		for zeile in 2:
			for spalte in RICHTUNGEN.size():
				var r: Array = RICHTUNGEN[spalte]
				var f := WorldCharacter.new()
				f.setup(look, "")
				f.position = Vector2(130 + spalte * 250, 330 + zeile * 330)
				f.scale = Vector2(2.2, 2.2)
				f.facing = r[0]
				f.richtungen = r[1] or f.richtungen
				f.hinten = r[2]
				f.moving = zeile == 1
				f.festes_bild = 1
				add_child(f)
		await get_tree().create_timer(0.5).timeout
		get_viewport().get_texture().get_image().save_png(ordner + "/kopf_%s.png" % look.replace("+", "_").get_slice("#", 0))
	get_tree().quit()
