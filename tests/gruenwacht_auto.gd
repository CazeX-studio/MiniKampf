extends "res://scripts/welt/kreuzweg.gd"
## Bildschirmfotos der Karten von Grünwacht (Weg, Waldboden, Wipfelheim), des Ausgangs in Kreuzweg
## und zum Schluss eines Kampfes im Wald (Bogenschütze gegen Rindenbär und Donnerhirsch).
## Aufruf mit Fenster: Godot --path . res://tests/gruenwacht_auto.tscn
## Die Bilder landen im Ordner aus der Umgebungsvariable FOTO_ORDNER (sonst user://).

const SPOTS := [
	["weg_osten", "weg_gruenwacht", Vector2i(36, 6)],
	["weg_mitte", "weg_gruenwacht", Vector2i(19, 5)],
	["weg_westen", "weg_gruenwacht", Vector2i(4, 6)],
	["waldboden_pfad", "waldboden", Vector2i(23, 13)],
	["waldboden_aufzug", "waldboden", Vector2i(15, 13)],
	["wipfelheim_ankunft", "wipfelheim", Vector2i(6, 15)],
	["wipfelheim_halle", "wipfelheim", Vector2i(16, 15)],
	["wipfelheim_fenn", "wipfelheim", Vector2i(16, 5)],
	["wipfelheim_tilda", "wipfelheim", Vector2i(26, 15)],
	["wipfelheim_esche", "wipfelheim", Vector2i(16, 24)],
	["wipfelheim_marv", "wipfelheim", Vector2i(21, 14)],
	["kreuzweg_westen", "kreuzweg", Vector2i(4, 22)],
	["waldboden_hirsch", "waldboden", Vector2i(5, 23)],
]

var _t := 0.0
var _index := -1


func _ready() -> void:
	var file := FileAccess.open(SaveGame.path, FileAccess.WRITE)
	file.store_string(JSON.stringify({version = SaveGame.VERSION, karte = "weg_gruenwacht", feld = [37, 6],
			progress = {level = 10, flags = {"angekommen": true, "klasse": "archer", "klasse_bestaetigt": true,
				"angesprochen:marv_gruenwacht": true, "fenn_ziele": true}, quests = {nach_gruenwacht = "aktiv", fenns_pruefung = "aktiv"}}}))
	file.close()
	super()
	_no_save = true


func _process(delta: float) -> void:
	super(delta)
	_t += delta
	if _t < 1.2:
		return
	_t = 0.0
	if _index >= 0:
		var path := path_for(SPOTS[_index][0])
		get_viewport().get_texture().get_image().save_png(path)
		print("Foto: ", path)
	_index += 1
	if _index >= SPOTS.size():
		SaveGame.delete()
		var helper: Node = load("res://tests/foto_helfer.gd").new()
		helper.path = path_for("kampf_wald")
		helper.wait = 4.0
		get_tree().root.add_child(helper)
		var wild := GameData.wild_monsters()
		var index := wild.size() - 2
		BattleRequest.prepare("wild:%d" % index, wild[index].stufe, 0, "archer")
		get_tree().change_scene_to_file("res://scenes/kampf.tscn")
		set_process(false)
		return
	var spot: Array = SPOTS[_index]
	if spot[0] == "weg_mitte":
		local_player().progress.level = 12
	state.change_map(local_player(), spot[1], spot[2])


static func path_for(name: String) -> String:
	var folder := OS.get_environment("FOTO_ORDNER")
	return (folder if folder != "" else ProjectSettings.globalize_path("user://")) + "/grünwacht_%s.png" % name
