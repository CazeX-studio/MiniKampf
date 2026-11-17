extends SceneTree
## Mitspieler für tests/netz_gruppenkampf_test.gd: tritt bei, nimmt die Gruppen-Einladung an, kämpft mit und kehrt zurück.
## Aufruf mit Name und Figur: … --script res://tests/netz_gruppenkampf_gast.gd -- Mira wizzard_f

var _t := 0.0
var _done := false
var _name := "Mira"
var _look := "wizzard_f"
var _greeted := false


func _initialize() -> void:
	_go.call_deferred()


func _go() -> void:
	Engine.time_scale = 4.0
	var args := OS.get_cmdline_user_args()
	if args.size() >= 2:
		_name = args[0]
		_look = args[1]
	Netz.save_override = "user://zz_gk_gast_spielstand_%s.json" % _name
	SaveGame.path = Netz.save_override
	SaveGame.delete()
	_join()


## Beitreten. Starten drei Mitspieler gleichzeitig, lädt der Gastgeber vielleicht noch die Stadt und antwortet
## nicht rechtzeitig: dann klopft der Mitspieler nach einer Sekunde erneut an (17.11.2026).
func _join() -> void:
	Netz.join("localhost", _name, _look)
	var node := Netz._node()
	if not node.connected.is_connected(_on_connected):
		node.connected.connect(_on_connected)
		node.connection_failed.connect(func() -> void:
			print("%s: Gastgeber antwortet nicht, versuche es erneut" % _name)
			create_timer(1.0, true, false, true).timeout.connect(_join))


func _on_connected() -> void:
	Netz._node().group_invited.connect(func(_a: String, _b: String) -> void: Netz.group_action("annehmen"))
	change_scene_to_file("res://scenes/kreuzweg.tscn")


func _process(delta: float) -> bool:
	_t += delta
	NetzGruppenkampfHelfer.drive(self)
	# In der Stadt angekommen: einmal grüßen
	if not _greeted and Netz.world != null and Netz.world.players.has(Netz.my_id) and current_scene != null \
			and current_scene.has_method("local_player") and _t > 1.0:
		_greeted = true
		Netz.chat("Hallo, ich bin %s!" % _name)
	if not _done and NetzGruppenkampfHelfer.finish(self, "zz_gk_gast_%s.json" % _name):
		_done = true
		_t = 0.0
	if _done and _t > 6.0:
		SaveGame.delete()
		Netz.stop()
		return true
	return _t > 400.0
