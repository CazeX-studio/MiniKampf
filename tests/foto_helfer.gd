extends Node
## Hilfe für Bildschirmfotos über einen Szenenwechsel hinweg: hängt an der Wurzel, wartet, fotografiert, beendet.

var path := ""
var wait := 3.0


func _process(delta: float) -> void:
	wait -= delta
	if wait > 0.0:
		return
	get_viewport().get_texture().get_image().save_png(path)
	print("Foto: ", path)
	get_tree().quit()
