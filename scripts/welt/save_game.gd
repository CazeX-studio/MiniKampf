class_name SaveGame
extends RefCounted
## Speichert den Fortschritt des eigenen Spielers auf dem Gerät (im Browser: im Browser-Speicher).
## Später übernimmt das der Server; dann bleibt nur das Format gleich.

const PATH := "user://spielstand.json"
const VERSION := 1


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
	if not data is Dictionary:
		return false
	p.progress.load_dict(data.get("progress", {}))
	var cell: Array = data.get("feld", [])
	if cell.size() == 2:
		p.cell = Vector2i(int(cell[0]), int(cell[1]))
		p.pos = Vector2(p.cell)
	return true


static func delete() -> void:
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
