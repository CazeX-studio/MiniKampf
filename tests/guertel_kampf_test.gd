extends SceneTree
## Prüft im echten Kampf-Zustand (ohne Grafik): Der erste Gürtel-Trank im Zug ist gratis (man ist noch dran),
## ein zweiter Trank beendet den Zug (Projekt 5, Schritt 2).
## Aufruf: Godot --headless --path . --script res://tests/guertel_kampf_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	BattleRequest.prepare("gruppenkampf", 4, 4)
	var steuerer := Steuerer.new()
	root.add_child(steuerer)
	steuerer.state = BattleState.new(steuerer, [] as Array[String], "", 7)
	steuerer.state.setup = BattleRequest.setup
	steuerer.state.max_turns = 40
	steuerer.state.run()
	for i in 600:
		await process_frame
		if steuerer.done:
			break
	_check(steuerer.done, "Der Spieler war am Zug")
	_check(steuerer.log == ["trank", "trank", "ende"], "Erster Trank gratis, zweiter Trank beendet den Zug (%s)" % str(steuerer.log))
	_check(steuerer.free_info.contains("gratis") and steuerer.second_info.contains("kostet den Zug"), "Knopf sagt, ob der Trank gratis ist")
	print("Gürtel im Kampf: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	steuerer.state.cleanup()
	quit(_failed)


## Steuerer: Spieler trinkt zweimal hintereinander, danach wird nur noch geschaut, wer dran ist.
class Steuerer extends Node:
	var state: BattleState
	var log: Array[String] = []
	var done := false
	var free_info := ""
	var second_info := ""
	var _player: Fighter

	func play(_events: Array[Dictionary]) -> void:
		pass

	func choose_action(f: Fighter) -> Dictionary:
		if _player == null and not state.computer.has(f):
			_player = f
		if f == _player and log.size() < 2:
			var trank: Dictionary = state.skills.abilities(f).filter(func(a: Dictionary) -> bool: return a.id == "trank")[0]
			if log.is_empty():
				free_info = trank.info
			else:
				second_info = trank.info
			log.append("trank")
			return {ab = trank, target = f}
		if log.size() == 2 and not done:
			# Nächster Zug: war es wieder der Spieler, hätte der zweite Trank den Zug nicht beendet
			log.append("ende" if f != _player else "noch dran")
			done = true
			state.battle_over = true
		return {ab = state.skills.wait_ability(), target = null}

	func react(_a: Fighter, _t: Fighter, _d: float) -> Variant:
		return 0

	func choose_option(_title: String, options: Array[Dictionary]) -> String:
		return options[0].id
