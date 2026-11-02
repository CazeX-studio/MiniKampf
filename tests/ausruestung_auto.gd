extends "res://scripts/welt/kreuzweg.gd"
## Nur für Bildschirmfotos: Ausrüstung (Projekt 14, K.1). Breitschwert in der Tasche mit Vergleich, danach das Werte-Fenster.

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
			p.progress.add_item("breitschwert", 1)
			p.progress.add_item("wollrobe", 1)
			p.look = "novize_m+m2"
			p.figur_name = "Testi"],
		[1.5, func() -> void:
			_toggle_panel("tasche")
			_bag_selected = p.progress.bag_slots().find("breitschwert")
			_fill_panel()],
		[2.5, func() -> void: _foto("ausruestung_tasche")],
		[2.7, func() -> void:
			_send({type = "anlegen", gegenstand = "wollrobe"})
			_toggle_panel("werte")],
		[3.5, func() -> void:
			_foto("ausruestung_werte")
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
