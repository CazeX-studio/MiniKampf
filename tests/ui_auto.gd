extends "res://scripts/welt/kreuzweg.gd"
## Nur für Bildschirmfotos: Meldungen mit Rahmen, Tasche, Auftragsbuch, Werte und Laden im Asterfall-UI-Look.
## Fotos landen in FOTO_ORDNER (sonst user://).

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
			p.progress.gold = 42
			for id: String in ["heiltrank", "kraut", "honigwabe", "sternensplitter"]:
				p.progress.add_item(id, 2)
			p.progress.quests["ankunft"] = "offen"],
		[1.0, func() -> void:
			_on_notice(local_id, GameData.text("gold", [20]))
			_on_notice(local_id, GameData.text("gegenstand", [1, "Heiltrank"]))
			_on_notice(local_id, GameData.text("erfahrung", [120]))
			_on_notice(local_id, GameData.text("auftrag_neu", ["Ein Korb für die Wache"]))],
		[1.6, func() -> void: _shot("meldungen")],
		[4.6, func() -> void:
			_bag_selected = 0
			_toggle_panel("tasche")],
		[5.0, func() -> void: _shot("tasche")],
		[5.2, func() -> void: _toggle_panel("auftraege")],
		[5.6, func() -> void: _shot("auftraege")],
		[5.8, func() -> void: _toggle_panel("werte")],
		[6.2, func() -> void: _shot("werte")],
		[6.4, func() -> void:
			_panel.visible = false
			p.shop = "bingo"
			_shop_shown = ""],
		[7.0, func() -> void:
			_shot("laden")
			get_tree().quit()],
	]
	while _step < plan.size() and _t >= plan[_step][0]:
		plan[_step][1].call()
		_step += 1
	super(delta)


func _shot(name: String) -> void:
	var folder := OS.get_environment("FOTO_ORDNER")
	var path := (folder if folder != "" else ProjectSettings.globalize_path("user://")) + "/ui_%s.png" % name
	get_viewport().get_texture().get_image().save_png(path)
	print("Foto: ", path)


func _exit_tree() -> void:
	_no_save = true
	SaveGame.delete()
