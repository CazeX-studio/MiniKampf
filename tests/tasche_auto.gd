extends "res://scripts/welt/kreuzweg.gd"
## Nur für Bildschirmfotos: die Tasche mit Kästchen, ein Gegenstand wird verschoben und angeklickt.

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
			p.progress.gold = 12345
			for id: String in ["heiltrank", "kraut", "wiesenkraut", "honigwabe", "sternensplitter", "schleuder", "essenskorb",
					"buerste", "festlaterne", "wildfleisch", "sternentafel"]:
				p.progress.add_item(id, 3 if id == "heiltrank" else 1)
			p.progress.add_item("kraut", 4)],
		[2.0, func() -> void: _toggle_panel("tasche")],
		[3.0, func() -> void:
			# Wie Ziehen und Ablegen: Heiltrank vom ersten ins letzte Kästchen der ersten Reihe
			_send({type = "tasche_tauschen", von = 0, nach = 9})
			_bag_selected = 9
			_fill_panel()],
		[4.0, func() -> void:
			get_viewport().get_texture().get_image().save_png("user://tasche.png")
			print("Foto: ", ProjectSettings.globalize_path("user://tasche.png"))
			get_tree().quit()],
	]
	while _step < plan.size() and _t >= plan[_step][0]:
		plan[_step][1].call()
		_step += 1
	super(delta)


func _exit_tree() -> void:
	_no_save = true
	SaveGame.delete()
