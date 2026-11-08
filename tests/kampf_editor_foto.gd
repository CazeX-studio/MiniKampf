extends Node
## Fotos vom Kampf-Editor (S2): der Bildschirm, ein Probe-Lauf, ein Kampf daraus und die Rückkehr. Ordner nach --


func _ready() -> void:
	var ordner: String = OS.get_cmdline_user_args()[0]
	# Dieser Knoten bleibt beim Szenenwechsel erhalten: Platzhalter als aktuelle Szene
	var platzhalter := Node.new()
	get_tree().root.add_child.call_deferred(platzhalter)
	await get_tree().process_frame
	get_tree().current_scene = platzhalter
	KampfEditor.auswahl = KampfEditor.standard()
	KampfEditor.auswahl.gruppe = [{klasse = "blade", stufe = 15}, {klasse = "singer", stufe = 15}, {klasse = "", stufe = 15}, {klasse = "", stufe = 15}]
	KampfEditor.auswahl.monster = ["glasskorpion", "sandwurm", "", ""]
	KampfEditor.auswahl.monster_stufe = 15
	KampfEditor.auswahl.ort = "palmenrast"
	get_tree().change_scene_to_file("res://scenes/kampf_editor.tscn")
	await get_tree().create_timer(0.8).timeout
	_foto(ordner + "/editor.png")
	get_tree().current_scene._probe_lauf()
	await get_tree().create_timer(1.5).timeout
	_foto(ordner + "/editor_probe.png")
	get_tree().current_scene._kaempfen()
	await get_tree().create_timer(1.6).timeout
	_foto(ordner + "/editor_kampf.png")
	BattleRequest.finish(true)
	get_tree().change_scene_to_file(BattleRequest.return_scene)
	await get_tree().create_timer(0.6).timeout
	_foto(ordner + "/editor_zurueck.png")
	get_tree().quit()


func _foto(pfad: String) -> void:
	get_viewport().get_texture().get_image().save_png(pfad)
