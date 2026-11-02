extends "res://scripts/welt/kreuzweg.gd"
## Nur für Bildschirmfotos: Hinsetzen (Projekt 14, K.2): Mana in der Anzeige oben, die Figur sitzt.

var _t := 0.0
var _step := 0


func _ready() -> void:
	SaveGame.delete()
	super()


func _process(delta: float) -> void:
	_t += delta
	var p := local_player()
	var plan: Array = [
		[0.5, func() -> void:
			p.dialog = {}
			p.progress.flags["angekommen"] = true
			p.progress.mana_anteil = 0.3
			_send({type = "hinsetzen"})],
		[2.0, func() -> void:
			_foto("hinsetzen")
			get_tree().quit()],
	]
	while _step < plan.size() and _t >= plan[_step][0]:
		plan[_step][1].call()
		_step += 1
	super(delta)


func _foto(name: String) -> void:
	get_viewport().get_texture().get_image().save_png("user://%s.png" % name)
	print("Foto: ", ProjectSettings.globalize_path("user://%s.png" % name))


func _exit_tree() -> void:
	_no_save = true
	SaveGame.delete()
