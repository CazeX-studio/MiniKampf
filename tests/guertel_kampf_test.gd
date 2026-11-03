extends SceneTree
## Prüft im echten Kampf-Zustand (ohne Grafik): Der erste Gürtel-Trank im Zug ist gratis (man ist noch dran),
## danach sind alle Tränke 3 Runden gesperrt und zählen sichtbar herunter (Projekt 5, Schritt 2 und 3).
## Aufruf: Godot --headless --path . --script res://tests/guertel_kampf_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	# Tränke am Gürtel hat jede eigene Klasse, nicht aber eine fremde Klasse in der Probestunde
	BattleRequest.prepare("wild:0", 15, 3, "archer")
	_check(int(BattleRequest.setup.helden[0].get("traenke", 0)) == 3, "Bogenschütze hat seine Heiltränke dabei")
	BattleRequest.prepare("probe:blade", 8, 3, "novize")
	_check(not BattleRequest.setup.helden[0].has("traenke"), "Probestunde mit fremder Klasse: keine eigenen Tränke")
	BattleRequest.player_mana_potions = 2
	BattleRequest.prepare("gruppenkampf", 4, 4)
	BattleRequest.player_mana_potions = 0
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
	_check(steuerer.log.slice(0, 2) == ["trank", "noch dran"], "Erster Trank gratis, man ist noch dran (%s)" % str(steuerer.log))
	_check(steuerer.free_info.contains("gratis"), "Knopf sagt, dass der Trank gratis ist")
	_check(steuerer.sperren == ["Trank-Wartezeit: bereit in 4", "Trank-Wartezeit: bereit in 3", "Trank-Wartezeit: bereit in 2",
			"Trank-Wartezeit: bereit in 1"], "Danach sind alle Tränke gesperrt und zählen herunter (%s)" % str(steuerer.sperren))
	_check(steuerer.mana_gesperrt, "Auch der Manatrank wartet mit")
	_check(steuerer.wieder_frei, "Nach 3 Runden geht wieder ein Trank")
	print("Gürtel im Kampf: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	steuerer.state.cleanup()
	quit(_failed)


## Steuerer: Spieler trinkt einen Trank, schaut danach jede Runde, ob Tränke gesperrt sind, und trinkt, sobald es geht.
class Steuerer extends Node:
	var state: BattleState
	var log: Array[String] = []
	var done := false
	var free_info := ""
	var sperren: Array[String] = []
	var mana_gesperrt := false
	var wieder_frei := false
	var _player: Fighter

	func play(_events: Array[Dictionary]) -> void:
		pass

	func choose_action(f: Fighter) -> Dictionary:
		if _player == null and not state.computer.has(f):
			_player = f
		if f != _player or done:
			return {ab = state.skills.wait_ability(), target = null}
		f.hp = f.max_hp
		var trank: Dictionary = state.skills.abilities(f).filter(func(a: Dictionary) -> bool: return a.id == "trank")[0]
		if log.is_empty():
			free_info = trank.info
			log.append("trank")
			return {ab = trank, target = f}
		if log.size() == 1:
			log.append("noch dran")
		var grund := state.skills.blocked_reason(f, trank)
		if grund == "":
			wieder_frei = true
			done = true
			state.battle_over = true
			return {ab = trank, target = f}
		sperren.append(grund)
		var mana: Array = state.skills.abilities(f).filter(func(a: Dictionary) -> bool: return a.id == "manatrank_trinken")
		if not mana.is_empty() and state.skills.blocked_reason(f, mana[0]).begins_with("Trank-Wartezeit"):
			mana_gesperrt = true
		if sperren.size() > 6:
			done = true
			state.battle_over = true
		return {ab = state.skills.wait_ability(), target = null}

	func react(_a: Fighter, _t: Fighter, _d: float) -> Variant:
		return 0

	func choose_option(_title: String, options: Array[Dictionary]) -> String:
		return options[0].id
