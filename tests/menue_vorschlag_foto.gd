extends "res://scripts/welt/kreuzweg.gd"
## Nur für Bildschirmfotos (P10): die Leiste oben und Hinsetzen unten links.
## Godot --path . res://tests/menue_vorschlag_foto.tscn -- <Ordner>

var _t := 0.0
var _fertig := false


func _ready() -> void:
	SaveGame.delete()
	super()


func _process(delta: float) -> void:
	_t += delta
	if _t > 0.5:
		local_player().dialog = {}
		local_player().progress.flags["angekommen"] = true
	if _t > 2.5 and not _fertig:
		_fertig = true
		var args := OS.get_cmdline_user_args()
		var ordner := args[0] if not args.is_empty() else "user:/"
		get_viewport().get_texture().get_image().save_png("%s/menue.png" % ordner)
		get_tree().quit()
	super(delta)


func _exit_tree() -> void:
	_no_save = true
	SaveGame.delete()
