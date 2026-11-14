extends "res://scripts/welt/welt_bewegung_editor.gd"
## Fotos vom Bewegungs-Editor in der Welt (S3b): Ordner als Argument nach --

const FAELLE := [[0, "novize_m", "laufen", false], [1, "klingentaenzer_w", "laufen", true], [2, "", "stehen", false], [3, "ye", "laufen", false],
		[0, "novize_w", "sitzen", false], [0, "novize_m", "stehen", false], [0, "novize_w", "laufen", true]]


func _ready() -> void:
	var fall: int = int(OS.get_environment("FALL")) if OS.get_environment("FALL") != "" else 0
	gruppe = FAELLE[fall][0]
	figur = FAELLE[fall][1]
	bewegung = FAELLE[fall][2]
	bild_fuer_bild = FAELLE[fall][3]
	bild = 2
	super()
	await get_tree().create_timer(0.7).timeout
	get_viewport().get_texture().get_image().save_png(OS.get_cmdline_user_args()[0] + "/welt_bewegung_%d.png" % fall)
	get_tree().quit()
