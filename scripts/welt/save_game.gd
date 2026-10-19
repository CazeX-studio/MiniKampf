class_name SaveGame
extends RefCounted
## Speichert den Fortschritt des eigenen Spielers auf dem Gerät (im Browser: im Browser-Speicher).
## Später übernimmt das der Server; dann bleibt nur das Format gleich.

const PATH := "user://spielstand.json"
## Version 2: Ankunft in Kreuzweg (Schritt 2). Ältere Spielstände passen nicht mehr und werden ignoriert.
const VERSION := 2


static func save(p: PlayerState) -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify({version = VERSION, progress = p.progress.to_dict(), feld = [p.cell.x, p.cell.y]}, "\t"))


## Lädt einen gespeicherten Stand in den Spieler. Gibt false zurück, wenn es keinen gibt.
static func load_into(p: PlayerState) -> bool:
	if not FileAccess.file_exists(PATH):
		return false
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if not data is Dictionary or int(data.get("version", 0)) < VERSION:
		return false
	p.progress.load_dict(data.get("progress", {}))
	var cell: Array = data.get("feld", [])
	if cell.size() == 2:
		p.cell = Vector2i(int(cell[0]), int(cell[1]))
		p.pos = Vector2(p.cell)
	return true


## Liest etwas Gemerktes aus dem Spielstand (z. B. eine Entscheidung). "" = nichts gemerkt.
static func get_flag(flag: String) -> String:
	var data := _read()
	return str(data.get("progress", {}).get("flags", {}).get(flag, ""))


## Merkt sich etwas im Spielstand, ohne den Rest zu verändern.
static func set_flag(flag: String, value: String) -> void:
	var data := _read()
	var progress: Dictionary = data.get("progress", {})
	var flags: Dictionary = progress.get("flags", {})
	flags[flag] = value
	progress["flags"] = flags
	data["progress"] = progress
	data["version"] = VERSION
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data, "\t"))


static func _read() -> Dictionary:
	if not FileAccess.file_exists(PATH):
		return {}
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	return data if data is Dictionary else {}


static func delete() -> void:
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))


## Fortschritt aus dem Spielstand lesen, ohne einen Spieler anzulegen (z. B. für die Klassenwahl).
static func read_progress() -> Dictionary:
	return _read().get("progress", {})
