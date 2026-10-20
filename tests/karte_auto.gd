extends "res://scripts/welt/kreuzweg.gd"
## Nur für Bildschirmfotos: Kamera-Zoom und Position aus Umgebungsvariablen ZOOM und ZIEL (x,y).

func _ready() -> void:
	SaveGame.delete()
	super()


func _process(delta: float) -> void:
	super(delta)
	var z := float(OS.get_environment("ZOOM")) if OS.has_environment("ZOOM") else 0.4
	_camera.zoom = Vector2(z, z)
	var parts := (OS.get_environment("ZIEL") if OS.has_environment("ZIEL") else "22,22").split(",")
	_camera.position = cell_center(Vector2(float(parts[0]), float(parts[1])))
	_camera.reset_smoothing()
