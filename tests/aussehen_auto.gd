extends "res://scripts/welt/kreuzweg.gd"
## Nur für Bildschirmfotos: Aussehen-Plätze im Werte-Fenster (Projekt 13, Schritt 6). Hut, Umhang und Farben werden gewählt.

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
			p.look = "novize_m+m2"
			p.figur_name = "Testi"],
		[1.5, func() -> void:
			_send({type = "aussehen", hut = "wanderhut", ruecken = "reiseumhang", farben = "glutschmiede"})
			_toggle_panel("werte")],
		[3.0, func() -> void:
			get_viewport().get_texture().get_image().save_png("user://aussehen.png")
			print("Foto: ", ProjectSettings.globalize_path("user://aussehen.png"))
			get_tree().quit()],
	]
	while _step < plan.size() and _t >= plan[_step][0]:
		plan[_step][1].call()
		_step += 1
	super(delta)


func _exit_tree() -> void:
	_no_save = true
	SaveGame.delete()
