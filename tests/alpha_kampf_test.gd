extends SceneTree
## A1b: Heiltrank heilt bei jeder Klasse (Alpha-Punkt 35), die Klingen treffen nach Klingenschritt nach (36).
## Aufruf: Godot --headless --path . -s tests/alpha_kampf_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	_run.call_deferred()


func _kampf(klasse: String, modus: String, skills := {}) -> Steuerer:
	BattleRequest.player_skills = skills
	BattleRequest.player_skills_known = not skills.is_empty()
	BattleRequest.prepare("wild:0", 15, 3, klasse)
	var s := Steuerer.new()
	s.modus = modus
	root.add_child(s)
	s.state = BattleState.new(s, [] as Array[String], "", 7)
	s.state.setup = BattleRequest.setup
	s.state.max_turns = 6
	s.state.run()
	for i in 300:
		await process_frame
		if s.done:
			break
	s.state.cleanup()
	BattleRequest.player_skills = {}
	BattleRequest.player_skills_known = false
	return s


func _run() -> void:
	for klasse: String in ["novize", "blade", "singer", "archer", "smith", "tamer"]:
		var s := await _kampf(klasse, "trank")
		_check(s.nachher > s.vorher, "%s: Heiltrank heilt (%d -> %d)" % [klasse, s.vorher, s.nachher])
	var ohne := await _kampf("blade", "klingen0", {step = 1})
	var mit := await _kampf("blade", "klingen", {step = 1})
	_check(mit.vorher - mit.nachher > ohne.vorher - ohne.nachher, "Klingenschritt ohne Klingenkranz: zwei Klingen treffen nach (%d statt %d Schaden)" % [
			mit.vorher - mit.nachher, ohne.vorher - ohne.nachher])
	# A2b: Im gemeinsamen Kampf die eigene Figur in Klassenkleidung, mit den eigenen Tränken
	var aufbau := BattleRequest.build_group("wild:0", [{name = "Katie", stufe = 12, klasse = "blade", eigene_klasse = "blade",
			aussehen = "novize_w+w1", traenke = 3}, {name = "Marco", stufe = 12, klasse = "novize", aussehen = "novize_m+m1", traenke = 2}])
	var helden: Array = aufbau.get("helden", [])
	_check(helden.size() >= 2 and helden[0].aussehen == "klingentaenzer_w+w1" and int(helden[0].get("traenke", 0)) == 3,
			"Gruppenkampf: Klingentänzerin in eigener Figur mit Tränken (%s)" % (helden[0] if not helden.is_empty() else {}))
	_check(helden.size() >= 2 and helden[1].aussehen == "novize_m+m1", "Gruppenkampf: Novize in eigener Figur")
	print("Alpha-Kampf: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


## Spieler: trinkt einmal einen Heiltrank bzw. macht mit zwei Klingen einen Klingenschritt.
class Steuerer extends Node:
	var state: BattleState
	var modus := ""
	var done := false
	var vorher := -1
	var nachher := -1
	var _p: Fighter
	var _ziel: Fighter

	func play(_e: Array[Dictionary]) -> void:
		pass

	func react(_a: Fighter, _t: Fighter, _d: float) -> int:
		return 0

	func choose_action(f: Fighter) -> Dictionary:
		if _p == null and not state.computer.has(f):
			_p = f
		if f != _p or done:
			return {ab = state.skills.wait_ability(), target = null}
		if vorher < 0:
			if modus == "trank":
				f.hp = f.max_hp / 3
				vorher = f.hp
				var t: Array = state.skills.abilities(f).filter(func(a: Dictionary) -> bool: return a.id == "trank")
				return {ab = t[0], target = f}
			f.blades = 0 if modus == "klingen0" else 2
			_ziel = state.alive(state.enemies)[0]
			_ziel.hp = _ziel.max_hp
			vorher = _ziel.hp
			var step: Array = state.skills.abilities(f).filter(func(a: Dictionary) -> bool: return a.id == "step")
			return {ab = step[0], target = _ziel}
		nachher = f.hp if modus == "trank" else _ziel.hp
		done = true
		return {ab = state.skills.wait_ability(), target = null}
