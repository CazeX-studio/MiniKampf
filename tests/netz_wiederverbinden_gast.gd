extends SceneTree
## Mitspieler für tests/netz_wiederverbinden_test.gd: spielt in der echten Stadt, wird vom Gastgeber getrennt
## und muss sich von selbst neu verbinden. Schreibt am Ende auf, was passiert ist.

var _t := 0.0
var _reconnecting := 0
var _reconnected := 0


func _initialize() -> void:
	_go.call_deferred()


func _go() -> void:
	Netz.save_override = "user://zz_wv_gast_spielstand.json"
	SaveGame.path = Netz.save_override
	SaveGame.delete()
	Netz.join("localhost", "Mira", "wizzard_f")
	Netz._node().connected.connect(func() -> void:
		Netz._node().group_invited.connect(func(_a: String, _b: String) -> void: Netz.group_action("annehmen"))
		Netz._node().reconnecting.connect(func(_a: int, _b: int) -> void: _reconnecting += 1)
		Netz._node().reconnected.connect(func() -> void: _reconnected += 1)
		change_scene_to_file("res://scenes/kreuzweg.tscn"))


func _process(delta: float) -> bool:
	_t += delta
	if _t > 20.0:
		var file := FileAccess.open("user://zz_wv_gast.json", FileAccess.WRITE)
		file.store_string(JSON.stringify({
			wiederverbinden = _reconnecting, wieder_da = _reconnected, online = Netz.online(),
			in_stadt = current_scene != null and current_scene.has_method("local_player"),
			gruppe = Netz.group.get("members", []).size(),
			eigene_figur = Netz.world != null and Netz.world.players.has(Netz.my_id)}))
		file.close()
		SaveGame.delete()
		Netz.stop()
		return true
	return false
