extends Node
## Fotos vom Bewegungs- und Effekt-Editor (S3a): Klasse wählen, Bewegung, Fähigkeit, Effekt. Ordner nach --
## Mit einem zweiten Argument eine andere Klasse (z. B. -- <Ordner> blade).


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var ordner: String = args[0]
	var platzhalter := Node.new()
	get_tree().root.add_child.call_deferred(platzhalter)
	await get_tree().process_frame
	get_tree().current_scene = platzhalter
	var editor_skript: GDScript = load("res://scripts/kampf/bewegung_editor.gd")
	editor_skript.klasse = args[1] if args.size() > 1 else "archer"
	editor_skript.aussehen = "eigen"
	editor_skript.monster = "glasskorpion"
	get_tree().change_scene_to_file("res://scenes/bewegung_editor.tscn")
	await get_tree().create_timer(1.5).timeout
	var ed: Node = get_tree().current_scene
	_foto(ordner + "/bewegung_start.png")
	# Auf den Zug des Helden warten, dann die zweite Fähigkeit
	for i in 40:
		if ed._kampf._current == ed._held and not ed._kampf._grid_buttons().is_empty():
			break
		await get_tree().create_timer(0.25).timeout
	var knoepfe: Array = ed._faehigkeiten_box.get_children()
	print("Fähigkeiten: ", knoepfe.map(func(b: Button) -> String: return b.text))
	knoepfe[min(1, knoepfe.size() - 1)].pressed.emit()
	await get_tree().create_timer(0.5).timeout
	_foto(ordner + "/bewegung_faehigkeit.png")
	await get_tree().create_timer(1.5).timeout
	ed._auf_monster = true
	ed._fx_bild.select(ed._fx_bild.item_count - 1)
	FxBild.spawn(ed._kampf._field, "komet", ed._kampf.view(ed._held).center(), 0.7)
	ed._kampf.view(ed._gegner).hit_react()
	await get_tree().create_timer(0.3).timeout
	_foto(ordner + "/bewegung_effekt.png")
	print("Status: ", ed._status.text)
	get_tree().quit()


func _foto(pfad: String) -> void:
	get_viewport().get_texture().get_image().save_png(pfad)
