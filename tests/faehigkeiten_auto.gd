extends "res://scripts/welt/kreuzweg.gd"
## Nur für Bildschirmfotos: Fähigkeiten-Baum (Projekt 14, K.3): Fenster mit Klassenstufe 12, zwei Fähigkeiten gelernt.

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
			p.progress.flags["klasse"] = "archer"
			p.progress.flags["klasse_bestaetigt"] = true
			p.progress.flags["klasse_gelernt"] = true
			p.progress.klassen_xp = 4100
			p.progress.faehigkeiten = {shot = 3, charge = 2, net = 1}
			p.progress.leiste = ["charge", "net", "", "", "", ""]
			FaehigkeitenBaum.gewaehlt = "rapid"
			_toggle_panel("faehigkeiten")],
		[2.0, func() -> void:
			_foto("faehigkeiten")
			get_tree().quit()],
	]
	while _step < plan.size() and _t >= plan[_step][0]:
		plan[_step][1].call()
		_step += 1
	super(delta)


func _foto(name: String) -> void:
	var ordner := OS.get_cmdline_user_args()[0] if not OS.get_cmdline_user_args().is_empty() else "user:/"
	get_viewport().get_texture().get_image().save_png("%s/%s.png" % [ordner, name])


func _exit_tree() -> void:
	_no_save = true
	SaveGame.delete()
