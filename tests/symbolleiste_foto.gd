extends Node
## A22: Foto der Fähigkeiten-Leiste im Kampf (nur Bilder) mit der Beschreibung beim Drüberfahren. Ordner nach --,
## danach optional die Klasse (Standard: blade).


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var klasse: String = args[1] if args.size() > 1 else "blade"
	BattleRequest.prepare("kettenschmied", 20, 2, klasse)
	var kampf: Node = load("res://scenes/kampf.tscn").instantiate()
	add_child(kampf)
	var c := kampf as Combat
	for i in 60:
		await get_tree().create_timer(0.1).timeout
		if not c._grid_buttons().is_empty():
			break
	await get_tree().create_timer(0.3).timeout
	var knoepfe := c._grid_buttons()
	if knoepfe.size() > 1:
		knoepfe[1].mouse_entered.emit()
	await get_tree().create_timer(0.3).timeout
	get_viewport().get_texture().get_image().save_png(args[0] + "/symbolleiste_%s.png" % klasse)
	get_tree().quit()
