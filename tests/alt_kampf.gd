extends Combat
## Testfassung des bisherigen Kampfes (Regeln und Anzeige noch vermischt):
## Der Computer spielt, Animationen und Wartezeiten fallen weg, alles wird mitgeschrieben.

var ki: KampfKI
var protokoll := KampfProtokoll.new()
var start_seed := 1


func _ready() -> void:
	seed(start_seed)
	ki = KampfKI.new(start_seed + 1000)
	skills = Skills.new(self)
	_build_ui()
	_create_heroes()
	_waves = Sandbox.ENCOUNTERS[Sandbox.encounter].waves
	if Sandbox.ENCOUNTERS[Sandbox.encounter].get("dungeon", "") == "pilzhoehle":
		dungeon = Pilzhoehle.new(self)
	_spawn_wave(0)
	_battle_loop()


func _begin_turn(f: Fighter) -> void:
	protokoll.turn(_turns, f, all_fighters())
	if OS.has_environment("KAMPF_DEBUG"): print("ZUG ", _turns, " ", f.display_name, " ", f.next_time)
	if _turns >= KampfProtokoll.MAX_TURNS:
		battle_over = true
		protokoll.finish("Abbruch", heroes)
		return
	await super(f)


func _player_turn(f: Fighter) -> void:
	var pick := ki.choose(skills, f)
	if OS.has_environment("KAMPF_DEBUG"): print("  > ", f.display_name, " ", pick.ab.id, " ", pick.target.display_name if pick.target else "-")
	await _execute(f, pick.ab, pick.target)


func _reaction_window(_attacker: Fighter, _target: Fighter, _duration: float) -> bool:
	return ki.react()


func ask_choice(_title: String, options: Array[Dictionary]) -> String:
	return ki.choose_option(options)


func _show_end_screen(won: bool) -> void:
	protokoll.finish("Sieg" if won else "Niederlage", heroes)


func add_log(text: String) -> void:
	if OS.has_environment("KAMPF_DEBUG"): print(text)
	protokoll.log_text(text)


func float_text(f: Fighter, text: String, _color: Color, _offset := 0.0) -> void:
	if has_view(f):
		protokoll.float_text(f, text)


func wait(_seconds: float) -> void:
	pass


func lunge(_f: Fighter, _target: Fighter, _duration: float) -> void:
	pass


func projectile(_from: Fighter, _to: Fighter, _color: Color, _duration := 0.3) -> void:
	pass


func move_to_row(_f: Fighter) -> void:
	pass


func refresh() -> void:
	pass
