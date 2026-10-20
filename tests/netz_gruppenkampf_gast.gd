extends SceneTree
## Mitspieler für tests/netz_gruppenkampf_test.gd: tritt bei, nimmt die Gruppen-Einladung an, kämpft mit und kehrt zurück.

var _t := 0.0
var _done := false


func _initialize() -> void:
	_go.call_deferred()


func _go() -> void:
	Engine.time_scale = 4.0
	Netz.save_override = "user://zz_gk_gast_spielstand.json"
	SaveGame.path = Netz.save_override
	SaveGame.delete()
	Netz.join("localhost", "Mira", "wizzard_f")
	Netz._node().connected.connect(func() -> void:
		Netz._node().group_invited.connect(func(_a: String, _b: String) -> void: Netz.group_action("annehmen"))
		change_scene_to_file("res://scenes/kreuzweg.tscn"))


func _process(delta: float) -> bool:
	_t += delta
	NetzGruppenkampfHelfer.drive(self)
	if not _done and NetzGruppenkampfHelfer.finish(self, "zz_gk_gast.json"):
		_done = true
		_t = 0.0
	if _done and _t > 6.0:
		SaveGame.delete()
		Netz.stop()
		return true
	return _t > 400.0
