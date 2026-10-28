extends SceneTree
## Prüft den gemeinsamen Kampf ohne Netz: Der Gastgeber (GemeinsamerKampf) und zwei Mitspieler rechnen denselben Kampf.
## Die Mitspieler entscheiden für ihre eigene Figur, schicken die Entscheidung an den Gastgeber und übernehmen,
## was er an alle zurückschickt – genau wie die Kampf-Anzeige. Am Ende müssen alle drei Kämpfe gleich ausgehen.
## Dazu: Einer gibt mitten im Kampf auf (der Gastgeber springt ein), ungültige Entscheidungen werden ersetzt.
## Aufruf: Godot --headless --path . --script res://tests/gruppenkampf_test.gd

var _failed := 0


## Ein Mitspieler: eigener Kampf-Zustand, entscheidet für seine Figur mit eigenem Zufall.
class Teilnehmer:
	signal got
	var id: String
	var state: BattleState
	var owners: Array
	var server: GemeinsamerKampf
	var buffer := {}
	var seq := 0
	var ki: KampfKI
	var own: KampfKI
	var leave_at := -1
	var cheat := false
	var log: Array[String] = []

	func _init(p_id: String, setup: Dictionary, battle_seed: int, p_owners: Array, p_server: GemeinsamerKampf, own_seed: int) -> void:
		id = p_id
		owners = p_owners
		server = p_server
		state = BattleState.new(self, [] as Array[String], "", battle_seed)
		state.setup = setup.duplicate(true)
		ki = KampfKI.new(GemeinsamerKampf.ki_seed(battle_seed))
		own = KampfKI.new(own_seed)

	func play(events: Array[Dictionary]) -> void:
		for e in events:
			if e.type == "log":
				log.append(e.text)

	func _wait(n: int) -> Dictionary:
		while not buffer.has(n):
			await got
		return buffer[n]

	func choose_action(f: Fighter) -> Dictionary:
		seq += 1
		var n := seq
		if state.computer.has(f):
			return ki.choose(state.skills, f)
		if GemeinsamerKampf.owner_in(state, owners, f) == id:
			if leave_at > 0 and n >= leave_at:
				server.player_gone(id)
			else:
				var data := GemeinsamerKampf.encode_action(state.skills, f, own.choose(state.skills, f))
				if cheat:
					data = {a = 99, c = -1, t = 0}
				server.receive(id, n, data)
		return GemeinsamerKampf.decode_action(state.skills, f, await _wait(n))

	func react(_a: Fighter, target: Fighter, _d: float) -> int:
		seq += 1
		var n := seq
		if state.computer.has(target):
			return ki.react_grade(Combat.ALLY_PARRY_CHANCE, Combat.ALLY_NORMAL_CHANCE)
		if GemeinsamerKampf.owner_in(state, owners, target) == id and not server.gone.has(id):
			server.receive(id, n, {g = own.react_grade(0.4, 0.3)})
		return int((await _wait(n)).get("g", 0))

	func choose_option(_t: String, options: Array[Dictionary]) -> String:
		seq += 1
		var n := seq
		if server.first_owner() == id:
			server.receive(id, n, {o = options[0].id})
		return str((await _wait(n)).get("o", options[0].id))


func _initialize() -> void:
	_run_case("Zwei Spieler + ein Mitstreiter, alle bleiben", -1, false, 11)
	_run_case("Mira gibt mitten im Kampf auf, der Gastgeber springt ein", 6, false, 12)
	_run_case("Ungültige Entscheidungen werden durch einen Standardangriff ersetzt", -1, true, 13)
	print("Gruppenkampf: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)


func _run_case(title: String, leave_at: int, cheat: bool, battle_seed: int) -> void:
	print("--- " + title)
	var members := [{name = "Marco", stufe = 4, traenke = 1, aussehen = "knight_m"}, {name = "Mira", stufe = 4, traenke = 0}]
	var setup := BattleRequest.build_group("gruppenkampf", members)
	_check(setup.helden.size() == 3 and setup.helden[2].get("computer", false), "Aufbau: zwei Spieler, ein Mitstreiter füllt auf")
	_check(setup.helden[0].name == "Marco" and setup.helden[0].aussehen == "knight_m" and not setup.helden[0].get("computer", false), "Spieler stehen vorne und spielen selbst")
	var owners: Array = ["a", "b", "", ""]
	var players: Array[Teilnehmer] = []
	var server := GemeinsamerKampf.new(1, setup, battle_seed, owners, func(_bid: int, n: int, data: Dictionary) -> void:
		for t in players:
			t.buffer[n] = data
			t.got.emit())
	players.append(Teilnehmer.new("a", setup, battle_seed, owners, server, 100))
	players.append(Teilnehmer.new("b", setup, battle_seed, owners, server, 200))
	players[1].leave_at = leave_at
	players[1].cheat = cheat
	var done := [false, false, false]
	server.state.max_turns = 400
	for i in 2:
		players[i].state.max_turns = 400
	server.finished.connect(func() -> void: done[0] = true)
	var run_player := func(i: int) -> void:
		await players[i].state.run()
		done[i + 1] = true
	server.start()
	run_player.call(0)
	run_player.call(1)
	_check(done[0] and done[1] and done[2], "Alle drei Kämpfe sind zu Ende")
	var same := true
	for t in players:
		same = same and t.state.won == server.state.won and t.state.turns == server.state.turns
		for i in t.state.heroes.size():
			same = same and t.state.heroes[i].hp == server.state.heroes[i].hp
		for i in t.state.enemies.size():
			same = same and t.state.enemies[i].hp == server.state.enemies[i].hp
	_check(same, "Alle rechnen genau denselben Kampf (Sieger, Züge, Leben aller Figuren)")
	_check(players[0].log == players[1].log and not players[0].log.is_empty(), "Beide Mitspieler sehen dasselbe Kampf-Log (%d Zeilen)" % players[0].log.size())
	if leave_at > 0:
		_check(server.gone.has("b"), "Gastgeber hat Miras Figur übernommen")
	print("    %s nach %d Zügen" % ["Sieg" if server.state.won else "Niederlage", server.state.turns])
	for t in players:
		t.state.cleanup()


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failed += 1
	print("%s %s" % ["OK    " if ok else "FEHLER", what])
