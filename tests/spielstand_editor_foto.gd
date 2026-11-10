extends Node
## Fotos vom Spielstand-Editor (S5): der Editor, dann „Spielen“ nach einem Sprung (Klingentänzerin, Miras Lied). Ordner nach --

const TEST_SAVE := "user://test_spielstand_editor_foto.json"


func _ready() -> void:
	var ordner: String = OS.get_cmdline_user_args()[0]
	var platzhalter := Node.new()
	get_tree().root.add_child.call_deferred(platzhalter)
	await get_tree().process_frame
	get_tree().current_scene = platzhalter
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	var skript: GDScript = load("res://scripts/welt/spielstand_editor.gd")
	skript.speicher = TEST_SAVE
	get_tree().change_scene_to_file("res://scenes/spielstand_editor.tscn")
	await get_tree().create_timer(0.5).timeout
	var ed: Node = get_tree().current_scene
	ed.klasse_setzen("blade")
	ed.springen_zu("miras_lied")
	ed.stufe_setzen(14)
	ed._ziel_wahl.select(Sprung.pfad("blade").find("miras_lied"))
	await get_tree().create_timer(0.3).timeout
	_foto(ordner + "/spielstand_editor.png")
	ed.spielen()
	await get_tree().create_timer(3.0).timeout
	_foto(ordner + "/spielstand_editor_spiel.png")
	SaveGame.path = SaveGame.DEFAULT_PATH
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit()


func _foto(pfad: String) -> void:
	get_viewport().get_texture().get_image().save_png(pfad)
