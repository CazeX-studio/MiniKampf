class_name NetzGruppenkampfHelfer
extends RefCounted
## Hilfe für tests/netz_gruppenkampf_test.gd: spielt die eigene Figur in der echten Kampf-Anzeige automatisch
## (Standardangriff, Erklär-Fenster wegklicken) und schreibt das Ergebnis in eine Datei zum Vergleichen.


static func drive(tree: SceneTree) -> void:
	var scene := tree.current_scene
	if scene == null or not scene is Combat:
		return
	# Erklär-Fenster („Verstanden“) wegklicken
	for node in scene.find_children("*", "Button", true, false):
		var button := node as Button
		if button.text == "Verstanden" and button.is_visible_in_tree():
			button.pressed.emit()
	# Eigener Zug (die Uhr läuft): Standardangriff
	if scene._turn_time >= 0.0 and scene._current != null:
		scene._turn_time = -1.0
		scene._action_chosen.emit(GemeinsamerKampf.default_action(scene.state.skills, scene._current, KampfKI.new(3)))


## Fertig gekämpft? Dann Ergebnis speichern und zurück in die Stadt. Gibt true zurück, wenn das passiert ist.
static func finish(tree: SceneTree, file_name: String) -> bool:
	var scene := tree.current_scene
	if scene == null or not scene is Combat or not scene.state.battle_over:
		return false
	var hp: Array = []
	for f in scene.state.heroes + scene.state.enemies:
		hp.append(f.hp)
	var file := FileAccess.open("user://" + file_name, FileAccess.WRITE)
	file.store_string(JSON.stringify({won = scene.state.won, turns = scene.state.turns, hp = hp}))
	file.close()
	scene._back_to_world(scene.state.won)
	return true
